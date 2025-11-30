import type { Invite, EnrichedInvite, User, CreateInviteRequest, UpdateInviteRequest } from "../types";
import { loadInvites, saveInvites, getCurrentUserId, loadUsers } from "../db";
import { jsonResponse, errorResponse } from "../utils/cors";
import { randomUUID } from "crypto";

/**
 * Resolve a user identifier (UUID or name) to the actual UUID from users.json
 */
async function resolveUserId(userIdOrName: string): Promise<string | null> {
  const users = await loadUsers();
  
  // First try to find by UUID
  const userById = users.find((u) => u.id === userIdOrName);
  if (userById) {
    return userById.id;
  }
  
  // If not found, try to find by name (case-insensitive)
  const userByName = users.find(
    (u) => u.name.toLowerCase() === userIdOrName.toLowerCase()
  );
  if (userByName) {
    return userByName.id;
  }
  
  // User not found
  return null;
}

/**
 * Enrich an invite with full user objects
 */
function enrichInvite(invite: Invite, userMap: Map<string, User>): EnrichedInvite {
  const fromUser = userMap.get(invite.fromUserId) || {
    id: invite.fromUserId,
    name: "Unknown User",
    avatarUrl: "",
    vibeStatus: "chilling" as const,
    friends: [],
  };
  
  const toUser = userMap.get(invite.toUserId) || {
    id: invite.toUserId,
    name: "Unknown User",
    avatarUrl: "",
    vibeStatus: "chilling" as const,
    friends: [],
  };
  
  return {
    id: invite.id,
    venueId: invite.venueId,
    fromUser,
    toUser,
    status: invite.status,
    proposedTime: invite.proposedTime,
    createdAt: invite.createdAt,
  };
}

/**
 * GET /invites - Get user's invites (both sent and received)
 * Also includes invites from the same host for venues where the user has an invite
 * Returns enriched invites with full user objects
 */
export async function getInvites(): Promise<Response> {
  const [invites, users] = await Promise.all([loadInvites(), loadUsers()]);
  const currentUserId = getCurrentUserId();

  // Create user lookup map
  const userMap = new Map<string, User>();
  users.forEach((u) => userMap.set(u.id, u));

  // Get invites where user is sender or recipient
  const userInvites = invites.filter(
    (inv) => inv.fromUserId === currentUserId || inv.toUserId === currentUserId
  );

  // Get all venues where user has invites (both sent and received)
  const venueIdsWithUserInvites = new Set(
    userInvites.map((inv) => inv.venueId)
  );

  // For each venue, get all hosts who invited to that venue
  // This includes: hosts who invited the user, and the user themselves (if they sent invites)
  const hostIdsByVenue = new Map<string, Set<string>>();
  
  userInvites.forEach((inv) => {
    if (!hostIdsByVenue.has(inv.venueId)) {
      hostIdsByVenue.set(inv.venueId, new Set());
    }
    const hosts = hostIdsByVenue.get(inv.venueId)!;
    
    if (inv.toUserId === currentUserId) {
      // User received this invite, so add the host
      hosts.add(inv.fromUserId);
    } else if (inv.fromUserId === currentUserId) {
      // User sent this invite, so they are the host
      hosts.add(currentUserId);
    }
  });

  // Get additional invites: same venue, same host (from user's perspective), but user is not sender/recipient
  const relatedInvites = invites.filter((inv) => {
    if (!venueIdsWithUserInvites.has(inv.venueId)) {
      return false; // Not a venue where user has invites
    }
    
    if (inv.fromUserId === currentUserId || inv.toUserId === currentUserId) {
      return false; // Already in userInvites
    }
    
    // Check if this invite is from a host that the user has invites from/with for this venue
    const hostsForVenue = hostIdsByVenue.get(inv.venueId);
    return hostsForVenue?.has(inv.fromUserId) ?? false;
  });

  // Combine user invites with related invites (avoid duplicates)
  const allRelevantInvites = [...userInvites, ...relatedInvites];
  const uniqueInvites = Array.from(
    new Map(allRelevantInvites.map((inv) => [inv.id, inv])).values()
  );

  // Enrich all invites with full user objects
  const enrichedInvites = uniqueInvites.map((inv) => enrichInvite(inv, userMap));

  // Separate into sent, received, and related
  const sent = enrichedInvites.filter((inv) => inv.fromUser.id === currentUserId);
  const received = enrichedInvites.filter((inv) => inv.toUser.id === currentUserId);
  const related = relatedInvites.map((inv) => enrichInvite(inv, userMap));

  return jsonResponse({
    sent,
    received,
    related,
    pending: received.filter((inv) => inv.status === "pending"),
  });
}

/**
 * POST /invites - Create invite(s) for a venue
 */
export async function createInvite(req: Request): Promise<Response> {
  const body = (await req.json()) as CreateInviteRequest;
  const { venueId, toUserIds, proposedTime } = body;

  if (!venueId || !toUserIds || !proposedTime) {
    return errorResponse("Missing required fields: venueId, toUserIds, proposedTime", 400);
  }

  const invites = await loadInvites();
  const currentUserId = getCurrentUserId();
  const newInvites: Invite[] = [];

  for (const userIdOrName of toUserIds) {
    // Resolve to actual UUID from users.json
    const toUserId = await resolveUserId(userIdOrName);
    if (!toUserId) {
      // Skip if user not found
      continue;
    }

    // Check if invite already exists
    const existingInvite = invites.find(
      (inv) =>
        inv.venueId === venueId &&
        inv.fromUserId === currentUserId &&
        inv.toUserId === toUserId &&
        inv.status === "pending"
    );

    if (existingInvite) {
      continue; // Skip duplicate invites
    }

    const newInvite: Invite = {
      id: randomUUID(),
      venueId,
      fromUserId: currentUserId,
      toUserId, // Always use the UUID from users.json
      status: "pending",
      proposedTime,
      createdAt: new Date().toISOString(),
    };

    invites.push(newInvite);
    newInvites.push(newInvite);
  }

  await saveInvites(invites);

  return jsonResponse(
    {
      message: `Created ${newInvites.length} invite(s)`,
      invites: newInvites,
    },
    201
  );
}

/**
 * PATCH /invites/:id - Accept or decline invite
 */
export async function updateInvite(
  inviteId: string,
  req: Request
): Promise<Response> {
  const body = (await req.json()) as UpdateInviteRequest;
  const { status } = body;

  if (!status || !["accepted", "declined"].includes(status)) {
    return errorResponse("Invalid status. Must be 'accepted' or 'declined'", 400);
  }

  const invites = await loadInvites();
  const currentUserId = getCurrentUserId();

  const inviteIndex = invites.findIndex((inv) => inv.id === inviteId);

  if (inviteIndex === -1) {
    return errorResponse("Invite not found", 404);
  }

  const invite = invites[inviteIndex];
  if (!invite) {
    return errorResponse("Invite not found", 404);
  }

  // Only recipient can accept/decline
  if (invite.toUserId !== currentUserId) {
    return errorResponse("Only the recipient can update this invite", 403);
  }

  if (invite.status !== "pending") {
    return errorResponse(`Invite already ${invite.status}`, 400);
  }

  // Update invite status
  const updatedInvite: Invite = {
    ...invite,
    status: status as "accepted" | "declined",
  };
  invites[inviteIndex] = updatedInvite;

  await saveInvites(invites);

  return jsonResponse({
    message: `Invite ${status}`,
    invite: updatedInvite,
  });
}

