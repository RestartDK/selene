import type { Venue, User, Interest, Invite, EnrichedVenue } from "../types";
import {
  loadVenues,
  loadUsers,
  loadInterests,
  loadInvites,
  getCurrentUserId,
} from "../db";

const PORT = process.env.PORT || 3000;
const DEFAULT_BASE_URL = `http://localhost:${PORT}`;

/**
 * Construct full video URL from filename or path
 */
function constructVideoUrl(mediaUrl: string, baseUrl: string): string {
  // If it's already a full URL, return as is
  if (mediaUrl.startsWith("http://") || mediaUrl.startsWith("https://")) {
    return mediaUrl;
  }
  
  // If it's a relative path starting with /, use as is
  if (mediaUrl.startsWith("/")) {
    return `${baseUrl}${mediaUrl}`;
  }
  
  // Otherwise, assume it's a filename and construct path
  return `${baseUrl}/videos/${mediaUrl}`;
}

/**
 * Build enriched feed with social state for each venue
 */
export async function buildEnrichedFeed(baseUrl?: string): Promise<EnrichedVenue[]> {
  const videoBaseUrl = baseUrl || DEFAULT_BASE_URL;
  const [venues, users, interests, invites] = await Promise.all([
    loadVenues(),
    loadUsers(),
    loadInterests(),
    loadInvites(),
  ]);

  const currentUserId = getCurrentUserId();
  const currentUser = users.find((u) => u.id === currentUserId);
  const friendIds = new Set(currentUser?.friends || []);

  // Create user lookup map
  const userMap = new Map<string, User>();
  users.forEach((u) => userMap.set(u.id, u));

  return venues.map((venue) => {
    // Get all interests for this venue
    const venueInterests = interests.filter((i) => i.venueId === venue.id);

    // Find friends who are interested
    const interestedFriends = venueInterests
      .filter((i) => friendIds.has(i.userId))
      .map((i) => userMap.get(i.userId))
      .filter((u): u is User => u !== undefined);

    // Count non-friend users interested (mutual/others)
    const mutualCount = venueInterests.filter(
      (i) => !friendIds.has(i.userId) && i.userId !== currentUserId
    ).length;

    // Find active invite for current user at this venue
    const inviteState =
      invites.find(
        (inv) =>
          inv.venueId === venue.id &&
          (inv.toUserId === currentUserId || inv.fromUserId === currentUserId) &&
          inv.status === "pending"
      ) || null;

    return {
      ...venue,
      mediaUrl: constructVideoUrl(venue.mediaUrl, videoBaseUrl),
      interestedFriends,
      mutualCount,
      inviteState,
    };
  });
}

/**
 * Get enriched data for a single venue
 */
export async function getEnrichedVenue(
  venueId: string,
  baseUrl?: string
): Promise<EnrichedVenue | null> {
  const enrichedFeed = await buildEnrichedFeed(baseUrl);
  return enrichedFeed.find((v) => v.id === venueId) || null;
}
