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
  const timestamp = new Date().toISOString();
  const origin = req.headers.get("origin") || "no-origin";

  // Log incoming request
  console.log(`[${timestamp}] ${method} ${path} - Origin: ${origin}`);

  // Handle CORS preflight
  if (method === "OPTIONS") {
    console.log(`[${timestamp}] CORS preflight request handled`);
    return handlePreflight();
  }

  try {
    // ===== VENUES ROUTES =====

    // GET /venues - List all venues
    if (method === "GET" && path === "/venues") {
      console.log(`[${timestamp}] Handling GET /venues`);
      const response = await getVenues();
      console.log(`[${timestamp}] GET /venues - Status: ${response.status}`);
      return response;
    }

    // GET /venues/:id - Get single venue
    const venueMatch = extractParam(path, "/venues/:id");
    if (method === "GET" && venueMatch && !path.includes("/heart")) {
      console.log(`[${timestamp}] Handling GET /venues/${venueMatch.id}`);
      const response = await getVenueById(venueMatch.id);
      console.log(`[${timestamp}] GET /venues/${venueMatch.id} - Status: ${response.status}`);
      return response;
    }

    // POST /venues/:id/heart - Heart a venue
    const heartMatch = extractParam(path, "/venues/:id/heart");
    if (method === "POST" && heartMatch) {
      console.log(`[${timestamp}] Handling POST /venues/${heartMatch.id}/heart`);
      const response = await heartVenue(heartMatch.id);
      console.log(`[${timestamp}] POST /venues/${heartMatch.id}/heart - Status: ${response.status}`);
      return response;
    }

    // DELETE /venues/:id/heart - Unheart a venue
    if (method === "DELETE" && heartMatch) {
      console.log(`[${timestamp}] Handling DELETE /venues/${heartMatch.id}/heart`);
      const response = await unheartVenue(heartMatch.id);
      console.log(`[${timestamp}] DELETE /venues/${heartMatch.id}/heart - Status: ${response.status}`);
      return response;
    }

    // ===== SOCIAL ROUTES =====

    // GET /social/interested/:venueId - Get friends interested in venue
    const interestedMatch = extractParam(path, "/social/interested/:venueId");
    if (method === "GET" && interestedMatch) {
      console.log(`[${timestamp}] Handling GET /social/interested/${interestedMatch.venueId}`);
      const response = await getInterestedFriends(interestedMatch.venueId);
      console.log(`[${timestamp}] GET /social/interested/${interestedMatch.venueId} - Status: ${response.status}`);
      return response;
    }

    // GET /social/friends - Get friend list
    if (method === "GET" && path === "/social/friends") {
      console.log(`[${timestamp}] Handling GET /social/friends`);
      const response = await getFriends();
      console.log(`[${timestamp}] GET /social/friends - Status: ${response.status}`);
      return response;
    }

    // GET /users/me - Get current user
    if (method === "GET" && path === "/users/me") {
      console.log(`[${timestamp}] Handling GET /users/me`);
      const response = await getCurrentUser();
      console.log(`[${timestamp}] GET /users/me - Status: ${response.status}`);
      return response;
    }

    // ===== INVITES ROUTES =====

    // GET /invites - Get user's invites
    if (method === "GET" && path === "/invites") {
      console.log(`[${timestamp}] Handling GET /invites`);
      const response = await getInvites();
      console.log(`[${timestamp}] GET /invites - Status: ${response.status}`);
      return response;
    }

    // POST /invites - Create invite
    if (method === "POST" && path === "/invites") {
      console.log(`[${timestamp}] Handling POST /invites`);
      const response = await createInvite(req);
      console.log(`[${timestamp}] POST /invites - Status: ${response.status}`);
      return response;
    }

    // PATCH /invites/:id - Update invite
    const inviteMatch = extractParam(path, "/invites/:id");
    if (method === "PATCH" && inviteMatch) {
      console.log(`[${timestamp}] Handling PATCH /invites/${inviteMatch.id}`);
      const response = await updateInvite(inviteMatch.id, req);
      console.log(`[${timestamp}] PATCH /invites/${inviteMatch.id} - Status: ${response.status}`);
      return response;
    }

    // ===== BOOKINGS ROUTES =====

    // GET /bookings - Get user's bookings
    if (method === "GET" && path === "/bookings") {
      console.log(`[${timestamp}] Handling GET /bookings`);
      const response = await getBookings();
      console.log(`[${timestamp}] GET /bookings - Status: ${response.status}`);
      return response;
    }

    // POST /bookings - Create booking
    if (method === "POST" && path === "/bookings") {
      console.log(`[${timestamp}] Handling POST /bookings`);
      const response = await createBooking(req);
      console.log(`[${timestamp}] POST /bookings - Status: ${response.status}`);
      return response;
    }

    // ===== AGENT ROUTES =====

    // POST /agent/chat - Chat with Luna
    if (method === "POST" && path === "/agent/chat") {
      console.log(`[${timestamp}] Handling POST /agent/chat`);
      const response = await agentChat(req);
      console.log(`[${timestamp}] POST /agent/chat - Status: ${response.status}`);
      return response;
    }

    // ===== HEALTH CHECK =====
    if (method === "GET" && path === "/health") {
      console.log(`[${timestamp}] Handling GET /health`);
      const response = Response.json({ status: "ok", timestamp: new Date().toISOString() }, {
        headers: corsHeaders
      });
      console.log(`[${timestamp}] GET /health - Status: ${response.status}`);
      return response;
    }

    // 404 Not Found
    console.log(`[${timestamp}] 404 Not Found: ${method} ${path}`);
    return errorResponse("Not Found", 404);
  } catch (error) {
    console.error(`[${timestamp}] Request error:`, error);
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

