import type { Invite, CreateInviteRequest, UpdateInviteRequest } from "../types";
import { loadInvites, saveInvites, getCurrentUserId } from "../db";
import { jsonResponse, errorResponse } from "../utils/cors";
import { nanoid } from "../utils/nanoid";

/**
 * GET /invites - Get user's invites (both sent and received)
 */
export async function getInvites(): Promise<Response> {
  const invites = await loadInvites();
  const currentUserId = getCurrentUserId();

  // Get invites where user is sender or recipient
  const userInvites = invites.filter(
    (inv) => inv.fromUserId === currentUserId || inv.toUserId === currentUserId
  );

  // Separate into sent and received
  const sent = userInvites.filter((inv) => inv.fromUserId === currentUserId);
  const received = userInvites.filter((inv) => inv.toUserId === currentUserId);

  return jsonResponse({
    sent,
    received,
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

  for (const toUserId of toUserIds) {
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
      id: nanoid(),
      venueId,
      fromUserId: currentUserId,
      toUserId,
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

  // Only recipient can accept/decline
  if (invite.toUserId !== currentUserId) {
    return errorResponse("Only the recipient can update this invite", 403);
  }

  if (invite.status !== "pending") {
    return errorResponse(`Invite already ${invite.status}`, 400);
  }

  // Update invite status
  invites[inviteIndex] = {
    ...invite,
    status,
  };

  await saveInvites(invites);

  return jsonResponse({
    message: `Invite ${status}`,
    invite: invites[inviteIndex],
  });
}

