import { streamText } from "ai";
import { createGoogleGenerativeAI } from "@ai-sdk/google";
import { z } from "zod";
import type { Booking, Invite, AgentChatRequest } from "../types";
import {
  loadVenues,
  loadUsers,
  loadBookings,
  saveBookings,
  loadInvites,
  saveInvites,
  getCurrentUserId,
} from "../db";
import { buildEnrichedFeed } from "./feed-builder";
import { nanoid } from "../utils/nanoid";

// Initialize Google Generative AI client
const google = createGoogleGenerativeAI({
  apiKey: process.env.GOOGLE_GENERATIVE_AI_API_KEY,
});

/**
 * Generate a mock confirmation code
 */
function generateConfirmationCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let code = "";
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

/**
 * Luna's system prompt - friendly nightlife concierge persona
 */
const LUNA_SYSTEM_PROMPT = `You are Luna, a friendly and knowledgeable nightlife concierge AI assistant. You help users discover and plan nights out with their friends.

Your personality:
- Warm, enthusiastic, and helpful
- You speak casually but professionally
- You're excited about helping people have great experiences
- You give concise, actionable suggestions

Your capabilities:
- Help users discover venues that match their vibe
- Send invites to their friends for a night out
- Book tables at venues
- Answer questions about venues and nightlife

When helping users:
1. Be conversational and natural
2. Ask clarifying questions if needed
3. Proactively suggest relevant friends to invite based on their interests
4. Confirm details before making bookings

Always be helpful and make the planning process fun!`;

/**
 * Build context about venues and user's friends for Luna
 */
async function buildLunaContext(): Promise<string> {
  const [enrichedFeed, users] = await Promise.all([
    buildEnrichedFeed(),
    loadUsers(),
  ]);

  const currentUserId = getCurrentUserId();
  const currentUser = users.find((u) => u.id === currentUserId);

  const venueContext = enrichedFeed
    .map((v) => {
      const friendNames = v.interestedFriends.map((f) => f.name).join(", ");
      return `- ${v.name} (${v.type}, ${v.vibe}): ${v.description.slice(0, 100)}... ${
        friendNames ? `Friends interested: ${friendNames}` : ""
      }`;
    })
    .join("\n");

  const friendContext = currentUser?.friends
    .map((friendId) => {
      const friend = users.find((u) => u.id === friendId);
      return friend
        ? `- ${friend.name} (${friend.id}): ${friend.vibeStatus.replace(/_/g, " ")}`
        : null;
    })
    .filter(Boolean)
    .join("\n");

  return `
CURRENT CONTEXT:
User: ${currentUser?.name || "Unknown"} (ID: ${currentUserId})

AVAILABLE VENUES:
${venueContext}

USER'S FRIENDS:
${friendContext}
`;
}

/**
 * Booking tool - Book a table at a venue
 */
async function executeBooking({
  venueId,
  partySize,
  dateTime,
  guestIds,
}: {
  venueId: string;
  partySize: number;
  dateTime: string;
  guestIds: string[];
}) {
  const bookings = await loadBookings();
  const venues = await loadVenues();
  const currentUserId = getCurrentUserId();

  const venue = venues.find((v) => v.id === venueId);
  if (!venue) {
    return { success: false, error: "Venue not found" };
  }

  const newBooking: Booking = {
    id: nanoid(),
    venueId,
    userId: currentUserId,
    guests: guestIds || [],
    partySize,
    dateTime,
    status: "confirmed",
    confirmationCode: generateConfirmationCode(),
    createdAt: new Date().toISOString(),
  };

  bookings.push(newBooking);
  await saveBookings(bookings);

  return {
    success: true,
    message: `Booking confirmed at ${venue.name}!`,
    confirmationCode: newBooking.confirmationCode,
    booking: newBooking,
  };
}

/**
 * Send invite tool - Send invites to friends for a venue
 */
async function executeSendInvites({
  venueId,
  toUserIds,
  proposedTime,
}: {
  venueId: string;
  toUserIds: string[];
  proposedTime: string;
}) {
  const invites = await loadInvites();
  const venues = await loadVenues();
  const users = await loadUsers();
  const currentUserId = getCurrentUserId();

  const venue = venues.find((v) => v.id === venueId);
  if (!venue) {
    return { success: false, error: "Venue not found" };
  }

  const newInvites: Invite[] = [];

  for (const toUserId of toUserIds) {
    const friend = users.find((u) => u.id === toUserId);
    if (!friend) continue;

    // Check for existing pending invite
    const existingInvite = invites.find(
      (inv) =>
        inv.venueId === venueId &&
        inv.fromUserId === currentUserId &&
        inv.toUserId === toUserId &&
        inv.status === "pending"
    );

    if (existingInvite) continue;

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

  const invitedNames = newInvites
    .map((inv) => users.find((u) => u.id === inv.toUserId)?.name)
    .filter(Boolean)
    .join(", ");

  return {
    success: true,
    message: `Invites sent to ${invitedNames} for ${venue.name}!`,
    inviteCount: newInvites.length,
    invites: newInvites,
  };
}

/**
 * Stream chat response from Luna agent
 */
export async function streamLunaChat(request: AgentChatRequest) {
  const context = await buildLunaContext();

  const messages = [
    ...(request.conversationHistory || []).map((msg) => ({
      role: msg.role as "user" | "assistant",
      content: msg.content,
    })),
    { role: "user" as const, content: request.message },
  ];

  const result = streamText({
    model: google("gemini-3.0-flash"),
    system: `${LUNA_SYSTEM_PROMPT}\n\n${context}`,
    messages,
    tools: {
      bookTable: {
        description:
          "Book a table at a venue. Use this when the user wants to make a reservation.",
        inputSchema: z.object({
          venueId: z
            .string()
            .describe("The ID of the venue to book (e.g., 'blue-note', 'rooftop-99')"),
          partySize: z.number().describe("Number of people in the party"),
          dateTime: z
            .string()
            .describe("Date and time for the booking in ISO format"),
          guestIds: z
            .array(z.string())
            .describe("Array of friend IDs to include as guests"),
        }),
        execute: executeBooking,
      },
      sendInvites: {
        description:
          "Send invites to friends for a venue. Use this when the user wants to invite friends to join them.",
        inputSchema: z.object({
          venueId: z.string().describe("The ID of the venue"),
          toUserIds: z.array(z.string()).describe("Array of friend IDs to invite"),
          proposedTime: z
            .string()
            .describe("Proposed date and time in ISO format"),
        }),
        execute: executeSendInvites,
      },
    },
    // @ts-expect-error - maxSteps is supported but types may be out of sync
    maxSteps: 5, // Allow multiple tool calls if needed
  });

  return result;
}

