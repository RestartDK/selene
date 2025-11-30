import { loadUsers, loadInterests, getCurrentUserId } from "../db";
import { jsonResponse, errorResponse } from "../utils/cors";

/**
 * GET /social/interested/:venueId - Get friends interested in specific venue
 */
export async function getInterestedFriends(venueId: string): Promise<Response> {
  const [users, interests] = await Promise.all([loadUsers(), loadInterests()]);

  const currentUserId = getCurrentUserId();
  const currentUser = users.find((u) => u.id === currentUserId);

  if (!currentUser) {
    return errorResponse("User not found", 404);
  }

  const friendIds = new Set(currentUser.friends);

  // Get interests for this venue from friends
  const venueInterests = interests.filter(
    (i) => i.venueId === venueId && friendIds.has(i.userId)
  );

  // Map to user objects
  const interestedFriends = venueInterests
    .map((i) => users.find((u) => u.id === i.userId))
    .filter((u) => u !== undefined);

  return jsonResponse({
    venueId,
    interestedFriends,
    count: interestedFriends.length,
  });
}

/**
 * GET /social/friends - Get current user's friend list
 */
export async function getFriends(): Promise<Response> {
  const users = await loadUsers();
  const currentUserId = getCurrentUserId();
  const currentUser = users.find((u) => u.id === currentUserId);

  if (!currentUser) {
    return errorResponse("User not found", 404);
  }

  const friends = currentUser.friends
    .map((friendId) => users.find((u) => u.id === friendId))
    .filter((u) => u !== undefined);

  return jsonResponse({
    friends,
    count: friends.length,
  });
}

/**
 * GET /users/me - Get current user profile
 */
export async function getCurrentUser(): Promise<Response> {
  const users = await loadUsers();
  const currentUserId = getCurrentUserId();
  const currentUser = users.find((u) => u.id === currentUserId);

  if (!currentUser) {
    return errorResponse("User not found", 404);
  }

  return jsonResponse(currentUser);
}

