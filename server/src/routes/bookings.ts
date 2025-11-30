import type { Booking, CreateBookingRequest } from "../types";
import { loadBookings, saveBookings, getCurrentUserId } from "../db";
import { jsonResponse, errorResponse } from "../utils/cors";
import { nanoid } from "../utils/nanoid";

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
 * Simulate booking delay (1-2 seconds)
 */
function simulateDelay(): Promise<void> {
  const delay = 1000 + Math.random() * 1000;
  return new Promise((resolve) => setTimeout(resolve, delay));
}

/**
 * GET /bookings - Get user's bookings
 */
export async function getBookings(): Promise<Response> {
  const bookings = await loadBookings();
  const currentUserId = getCurrentUserId();

  // Get bookings where user is owner or guest
  const userBookings = bookings.filter(
    (b) => b.userId === currentUserId || b.guests.includes(currentUserId)
  );

  return jsonResponse({
    bookings: userBookings,
    count: userBookings.length,
  });
}

/**
 * POST /bookings - Create a mock booking
 */
export async function createBooking(req: Request): Promise<Response> {
  const body = (await req.json()) as CreateBookingRequest;
  const { venueId, partySize, dateTime, guestIds } = body;

  if (!venueId || !partySize || !dateTime) {
    return errorResponse(
      "Missing required fields: venueId, partySize, dateTime",
      400
    );
  }

  // Simulate booking processing delay
  await simulateDelay();

  const bookings = await loadBookings();
  const currentUserId = getCurrentUserId();

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

  return jsonResponse(
    {
      message: "Booking confirmed!",
      booking: newBooking,
    },
    201
  );
}

