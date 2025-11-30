import type { Interest } from "../types";
import { loadInterests, saveInterests, getCurrentUserId } from "../db";
import { buildEnrichedFeed, getEnrichedVenue } from "../services/feed-builder";
import { jsonResponse, errorResponse } from "../utils/cors";
import { nanoid } from "../utils/nanoid";

/**
 * Extract base URL from request
 */
function getBaseUrl(req: Request): string {
  const url = new URL(req.url);
  return `${url.protocol}//${url.host}`;
}

/**
 * GET /venues - List all venues with social state enrichment
 */
export async function getVenues(req: Request): Promise<Response> {
  const baseUrl = getBaseUrl(req);
  const enrichedFeed = await buildEnrichedFeed(baseUrl);
  return jsonResponse(enrichedFeed);
}

/**
 * GET /venues/:id - Get single venue with interested friends
 */
export async function getVenueById(venueId: string, req: Request): Promise<Response> {
  const baseUrl = getBaseUrl(req);
  const venue = await getEnrichedVenue(venueId, baseUrl);

  if (!venue) {
    return errorResponse("Venue not found", 404);
  }

  return jsonResponse(venue);
}

/**
 * POST /venues/:id/heart - Mark venue as interested
 */
export async function heartVenue(venueId: string, req: Request): Promise<Response> {
  const userId = getCurrentUserId();
  const interests = await loadInterests();

  // Check if already interested
  const existingInterest = interests.find(
    (i) => i.userId === userId && i.venueId === venueId
  );

  if (existingInterest) {
    return jsonResponse({
      message: "Already interested",
      interest: existingInterest,
    });
  }

  // Create new interest
  const newInterest: Interest = {
    id: nanoid(),
    userId,
    venueId,
    createdAt: new Date().toISOString(),
  };

  interests.push(newInterest);
  await saveInterests(interests);

  // Return updated venue with enriched data
  const baseUrl = getBaseUrl(req);
  const enrichedVenue = await getEnrichedVenue(venueId, baseUrl);

  return jsonResponse(
    {
      message: "Interest added",
      interest: newInterest,
      venue: enrichedVenue,
    },
    201
  );
}

/**
 * DELETE /venues/:id/heart - Remove interest from venue
 */
export async function unheartVenue(venueId: string, req: Request): Promise<Response> {
  const userId = getCurrentUserId();
  const interests = await loadInterests();

  const interestIndex = interests.findIndex(
    (i) => i.userId === userId && i.venueId === venueId
  );

  if (interestIndex === -1) {
    return errorResponse("Interest not found", 404);
  }

  // Remove interest
  interests.splice(interestIndex, 1);
  await saveInterests(interests);

  // Return updated venue with enriched data
  const baseUrl = getBaseUrl(req);
  const enrichedVenue = await getEnrichedVenue(venueId, baseUrl);

  return jsonResponse({
    message: "Interest removed",
    venue: enrichedVenue,
  });
}

