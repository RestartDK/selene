// Core models matching iOS app

export type VibeStatus = "ready_to_mingle" | "chilling" | "exploring";

export interface User {
  id: string;
  name: string;
  avatarUrl: string;
  vibeStatus: VibeStatus;
  friends: string[];
}

export interface VenueLocation {
  address: string;
  distance: string;
  lat: number;
  lng: number;
}

export interface Venue {
  id: string;
  name: string;
  type: string;
  vibe: string;
  description: string;
  location: VenueLocation;
  mediaUrl: string;
  thumbnailUrl: string;
}

// Enriched venue with social state for feed
export interface EnrichedVenue extends Venue {
  interestedFriends: User[];
  mutualCount: number;
  inviteState: Invite | null;
  isSaved: boolean;
}

export interface Interest {
  id: string;
  userId: string;
  venueId: string;
  createdAt: string;
}

export type InviteStatus = "pending" | "accepted" | "declined";

export interface Invite {
  id: string;
  venueId: string;
  fromUserId: string;
  toUserId: string;
  status: InviteStatus;
  proposedTime: string;
  createdAt: string;
}

// Enriched invite with full user objects for API responses
export interface EnrichedInvite {
  id: string;
  venueId: string;
  fromUser: User;
  toUser: User;
  status: InviteStatus;
  proposedTime: string;
  createdAt: string;
}

export type BookingStatus = "confirmed" | "pending" | "cancelled";

export interface Booking {
  id: string;
  venueId: string;
  userId: string;
  guests: string[];
  partySize: number;
  dateTime: string;
  status: BookingStatus;
  confirmationCode: string;
  createdAt: string;
}

// API request/response types
export interface CreateInviteRequest {
  venueId: string;
  toUserIds: string[];
  proposedTime: string;
}

export interface UpdateInviteRequest {
  status: "accepted" | "declined";
}

export interface CreateBookingRequest {
  venueId: string;
  partySize: number;
  dateTime: string;
  guestIds?: string[];
}

export interface AgentChatRequest {
  message: string;
  conversationHistory?: Array<{
    role: "user" | "assistant";
    content: string;
  }>;
}

