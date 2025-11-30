import type { AgentChatRequest, User, EnrichedVenue } from "../types";
import { streamLunaChat } from "../services/agent";
import { errorResponse, corsHeaders, jsonResponse } from "../utils/cors";
import { getEnrichedVenue } from "../services/feed-builder";
import { loadInterests, loadVenues, loadUsers, getCurrentUserId } from "../db";

/**
 * POST /agent/chat - Streaming chat with Luna agent
 * Returns Server-Sent Events (SSE) stream
 */
// MARK: - Agent Suggestion Response Type
interface AgentSuggestion {
  venueId: string;
  venueName: string;
  friendNames: string[];
  friendIds: string[];
  partySize: number;
  suggestedTime: string;
  reasoning: string;
  sharedInterests: string[];
}

/**
 * Generate smart reasoning based on shared venue preferences
 */
function generateReasoning(
  venue: EnrichedVenue,
  sharedTypes: string[],
  friendNames: string
): string {
  // Direct match: they both like this exact venue type
  if (sharedTypes.includes(venue.type)) {
    return `You and ${friendNames} both love ${venue.type.toLowerCase()} spots - ${venue.name} would be perfect for tonight!`;
  }

  // Indirect match: they have shared taste in general
  if (sharedTypes.length > 0 && sharedTypes[0]) {
    return `Since you all enjoy ${sharedTypes[0].toLowerCase()} vibes, ${venue.name} seems like a great fit!`;
  }

  // Fallback: use venue vibe
  return `${friendNames} are into ${venue.vibe.toLowerCase()} places too - ${venue.name} could be your next spot!`;
}

/**
 * GET /agent/suggestion - Get proactive booking suggestion with smart reasoning
 * Returns suggestion with interested friends and shared interest analysis
 */
export async function getSuggestion(req: Request): Promise<Response> {
  try {
    const url = new URL(req.url);
    const venueId = url.searchParams.get("venueId");

    if (!venueId) {
      return errorResponse("Missing required query parameter: venueId", 400);
    }

    // Get enriched venue data
    const venue = await getEnrichedVenue(venueId);
    if (!venue) {
      return errorResponse("Venue not found", 404);
    }

    // Check if there are enough interested friends
    if (venue.interestedFriends.length < 1) {
      return jsonResponse(null); // No suggestion if no interested friends
    }

    // Load all data for interest analysis
    const [interests, venues, users] = await Promise.all([
      loadInterests(),
      loadVenues(),
      loadUsers(),
    ]);

    const currentUserId = getCurrentUserId();

    // Create venue type lookup map
    const venueTypeMap = new Map<string, string>();
    venues.forEach((v) => venueTypeMap.set(v.id, v.type));

    // Get current user's interested venue types
    const currentUserInterests = interests.filter(
      (i) => i.userId === currentUserId
    );
    const currentUserVenueTypes = new Set(
      currentUserInterests
        .map((i) => venueTypeMap.get(i.venueId))
        .filter((t): t is string => t !== undefined)
    );

    // Get interested friends' venue types
    const friendIds = venue.interestedFriends.map((f) => f.id);
    const friendInterests = interests.filter((i) => friendIds.includes(i.userId));
    const friendVenueTypes = new Set(
      friendInterests
        .map((i) => venueTypeMap.get(i.venueId))
        .filter((t): t is string => t !== undefined)
    );

    // Find shared venue types
    const sharedTypes = Array.from(currentUserVenueTypes).filter((type) =>
      friendVenueTypes.has(type)
    );

    // Build friend names string
    const friendNames = venue.interestedFriends.map((f) => f.name);
    let friendNamesStr: string;
    if (friendNames.length === 1) {
      friendNamesStr = friendNames[0] ?? "Your friend";
    } else if (friendNames.length === 2) {
      friendNamesStr = `${friendNames[0] ?? "Someone"} and ${friendNames[1] ?? "someone"}`;
    } else {
      const lastFriend = friendNames[friendNames.length - 1] ?? "someone";
      friendNamesStr = `${friendNames.slice(0, -1).join(", ")}, and ${lastFriend}`;
    }

    // Generate smart reasoning
    const reasoning = generateReasoning(venue, sharedTypes, friendNamesStr);

    // Calculate suggested time (tonight at 9 PM)
    const now = new Date();
    const suggestedTime = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate(),
      21,
      0,
      0
    ).toISOString();

    const suggestion: AgentSuggestion = {
      venueId: venue.id,
      venueName: venue.name,
      friendNames,
      friendIds,
      partySize: friendIds.length + 1, // +1 for current user
      suggestedTime,
      reasoning,
      sharedInterests: sharedTypes,
    };

    return jsonResponse(suggestion);
  } catch (error) {
    console.error("Agent suggestion error:", error);
    return errorResponse("Failed to generate suggestion", 500);
  }
}

/**
 * POST /agent/chat - Streaming chat with Luna agent
 * Returns Server-Sent Events (SSE) stream
 */
export async function agentChat(req: Request): Promise<Response> {
  try {
    const body = (await req.json()) as AgentChatRequest;

    if (!body.message) {
      return errorResponse("Missing required field: message", 400);
    }

    const result = await streamLunaChat(body);

    // Create SSE stream
    const stream = new ReadableStream({
      async start(controller) {
        const encoder = new TextEncoder();

        try {
          for await (const chunk of result.textStream) {
            const data = `data: ${JSON.stringify({ type: "text", content: chunk })}\n\n`;
            controller.enqueue(encoder.encode(data));
          }

          // Send final message
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify({ type: "done" })}\n\n`)
          );
          controller.close();
        } catch (error) {
          const errorMessage =
            error instanceof Error ? error.message : "Stream error";
          controller.enqueue(
            encoder.encode(
              `data: ${JSON.stringify({ type: "error", error: errorMessage })}\n\n`
            )
          );
          controller.close();
        }
      },
    });

    return new Response(stream, {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
      },
    });
  } catch (error) {
    console.error("Agent chat error:", error);
    return errorResponse("Failed to process chat request", 500);
  }
}

