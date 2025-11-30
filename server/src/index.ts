import { getVenues, getVenueById, heartVenue, unheartVenue } from "./routes/venues";
import { getInterestedFriends, getFriends, getCurrentUser } from "./routes/social";
import { getInvites, createInvite, updateInvite } from "./routes/invites";
import { getBookings, createBooking } from "./routes/bookings";
import { agentChat } from "./routes/agent";
import { handlePreflight, errorResponse, corsHeaders } from "./utils/cors";

const PORT = process.env.PORT || 3000;

/**
 * Extract path parameter from URL
 * e.g., extractParam("/venues/123/heart", "/venues/:id/heart") => { id: "123" }
 */
function extractParam(path: string, pattern: string): Record<string, string> | null {
  const pathParts = path.split("/").filter(Boolean);
  const patternParts = pattern.split("/").filter(Boolean);

  if (pathParts.length !== patternParts.length) {
    return null;
  }

  const params: Record<string, string> = {};

  for (let i = 0; i < patternParts.length; i++) {
    if (patternParts[i].startsWith(":")) {
      const paramName = patternParts[i].slice(1);
      params[paramName] = pathParts[i];
    } else if (patternParts[i] !== pathParts[i]) {
      return null;
    }
  }

  return params;
}

/**
 * Main request handler
 */
async function handleRequest(req: Request): Promise<Response> {
  const url = new URL(req.url);
  const path = url.pathname;
  const method = req.method;

  // Handle CORS preflight
  if (method === "OPTIONS") {
    return handlePreflight();
  }

  try {
    // ===== VENUES ROUTES =====

    // GET /venues - List all venues
    if (method === "GET" && path === "/venues") {
      return await getVenues();
    }

    // GET /venues/:id - Get single venue
    const venueMatch = extractParam(path, "/venues/:id");
    if (method === "GET" && venueMatch && !path.includes("/heart")) {
      return await getVenueById(venueMatch.id);
    }

    // POST /venues/:id/heart - Heart a venue
    const heartMatch = extractParam(path, "/venues/:id/heart");
    if (method === "POST" && heartMatch) {
      return await heartVenue(heartMatch.id);
    }

    // DELETE /venues/:id/heart - Unheart a venue
    if (method === "DELETE" && heartMatch) {
      return await unheartVenue(heartMatch.id);
    }

    // ===== SOCIAL ROUTES =====

    // GET /social/interested/:venueId - Get friends interested in venue
    const interestedMatch = extractParam(path, "/social/interested/:venueId");
    if (method === "GET" && interestedMatch) {
      return await getInterestedFriends(interestedMatch.venueId);
    }

    // GET /social/friends - Get friend list
    if (method === "GET" && path === "/social/friends") {
      return await getFriends();
    }

    // GET /users/me - Get current user
    if (method === "GET" && path === "/users/me") {
      return await getCurrentUser();
    }

    // ===== INVITES ROUTES =====

    // GET /invites - Get user's invites
    if (method === "GET" && path === "/invites") {
      return await getInvites();
    }

    // POST /invites - Create invite
    if (method === "POST" && path === "/invites") {
      return await createInvite(req);
    }

    // PATCH /invites/:id - Update invite
    const inviteMatch = extractParam(path, "/invites/:id");
    if (method === "PATCH" && inviteMatch) {
      return await updateInvite(inviteMatch.id, req);
    }

    // ===== BOOKINGS ROUTES =====

    // GET /bookings - Get user's bookings
    if (method === "GET" && path === "/bookings") {
      return await getBookings();
    }

    // POST /bookings - Create booking
    if (method === "POST" && path === "/bookings") {
      return await createBooking(req);
    }

    // ===== AGENT ROUTES =====

    // POST /agent/chat - Chat with Luna
    if (method === "POST" && path === "/agent/chat") {
      return await agentChat(req);
    }

    // ===== HEALTH CHECK =====
    if (method === "GET" && path === "/health") {
      return Response.json({ status: "ok", timestamp: new Date().toISOString() }, {
        headers: corsHeaders
      });
    }

    // 404 Not Found
    return errorResponse("Not Found", 404);
  } catch (error) {
    console.error("Request error:", error);
    return errorResponse("Internal Server Error", 500);
  }
}

// Start the Bun server
const server = Bun.serve({
  port: PORT,
  fetch: handleRequest,
});

console.log(`🌙 Selene API server running at http://localhost:${server.port}`);
console.log(`   Current user: ${process.env.CURRENT_USER_ID || "alex"}`);

