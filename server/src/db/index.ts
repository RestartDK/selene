import type { User, Venue, Interest, Invite, Booking } from "../types";

const DATA_DIR = import.meta.dir + "/data";

// Simple in-memory cache for frequently accessed data
const cache = new Map<string, { data: unknown; timestamp: number }>();
const CACHE_TTL = 5000; // 5 seconds cache TTL

/**
 * Load and parse JSON data from a file
 */
export async function loadData<T>(filename: string): Promise<T> {
  const cacheKey = filename;
  const cached = cache.get(cacheKey);

  // Return cached data if still valid
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.data as T;
  }

  const filePath = `${DATA_DIR}/${filename}`;
  const file = Bun.file(filePath);

  // Check if file exists
  if (!(await file.exists())) {
    // Return empty array for missing files
    return [] as unknown as T;
  }

  const data = await file.json();

  // Update cache
  cache.set(cacheKey, { data, timestamp: Date.now() });

  return data as T;
}

/**
 * Save data to a JSON file with atomic write
 */
export async function saveData<T>(filename: string, data: T): Promise<void> {
  const filePath = `${DATA_DIR}/${filename}`;

  // Write JSON with pretty formatting
  await Bun.write(filePath, JSON.stringify(data, null, 2));

  // Invalidate cache for this file
  cache.delete(filename);
}

/**
 * Invalidate cache for a specific file or all files
 */
export function invalidateCache(filename?: string): void {
  if (filename) {
    cache.delete(filename);
  } else {
    cache.clear();
  }
}

// Convenience functions for typed data access
export const loadUsers = () => loadData<User[]>("users.json");
export const saveUsers = (data: User[]) => saveData("users.json", data);

export const loadVenues = () => loadData<Venue[]>("venues.json");
export const saveVenues = (data: Venue[]) => saveData("venues.json", data);

export const loadInterests = () => loadData<Interest[]>("interests.json");
export const saveInterests = (data: Interest[]) =>
  saveData("interests.json", data);

export const loadInvites = () => loadData<Invite[]>("invites.json");
export const saveInvites = (data: Invite[]) => saveData("invites.json", data);

export const loadBookings = () => loadData<Booking[]>("bookings.json");
export const saveBookings = (data: Booking[]) =>
  saveData("bookings.json", data);

// Helper to get current user (simulated auth via env variable)
export function getCurrentUserId(): string {
  return process.env.CURRENT_USER_ID || "550e8400-e29b-41d4-a716-446655440000";
}

