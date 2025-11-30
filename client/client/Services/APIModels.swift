//
//  APIModels.swift
//  client
//
//  Selene App - API Response Models matching backend types
//

import Foundation

// MARK: - API Configuration
enum APIConfig {
    // Change this to your server URL
    // For iOS Simulator use localhost, for device use your computer's IP
    #if targetEnvironment(simulator)
    static let baseURL = "http://localhost:3000"
    #else
    static let baseURL = "http://192.168.1.100:3000" // Replace with your computer's IP
    #endif
}

// MARK: - User Types
enum APIVibeStatus: String, Codable {
    case readyToMingle = "ready_to_mingle"
    case chilling = "chilling"
    case exploring = "exploring"
}

struct APIUser: Codable, Identifiable {
    let id: String
    let name: String
    let avatarUrl: String
    let vibeStatus: APIVibeStatus
    let friends: [String]
}

// MARK: - Venue Types
struct APIVenueLocation: Codable {
    let address: String
    let distance: String
    let lat: Double
    let lng: Double
}

struct APIVenue: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let vibe: String
    let description: String
    let location: APIVenueLocation
    let mediaUrl: String
    let thumbnailUrl: String
}

// MARK: - Enriched Venue (from feed)
struct APIEnrichedVenue: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let vibe: String
    let description: String
    let location: APIVenueLocation
    let mediaUrl: String
    let thumbnailUrl: String
    let interestedFriends: [APIUser]
    let mutualCount: Int
    let inviteState: APIInvite?
    let isSaved: Bool
}

// MARK: - Interest Types
struct APIInterest: Codable, Identifiable {
    let id: String
    let userId: String
    let venueId: String
    let createdAt: String
}

// MARK: - Invite Types
enum APIInviteStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
}

// Enriched invite with full user objects (returned by GET /invites)
struct APIEnrichedInvite: Codable, Identifiable {
    let id: String
    let venueId: String
    let fromUser: APIUser
    let toUser: APIUser
    let status: APIInviteStatus
    let proposedTime: String
    let createdAt: String
}

// Legacy invite format (used in some responses like inviteState in EnrichedVenue)
struct APIInvite: Codable, Identifiable {
    let id: String
    let venueId: String
    let fromUserId: String
    let toUserId: String
    let status: APIInviteStatus
    let proposedTime: String
    let createdAt: String
}

// MARK: - Booking Types
enum APIBookingStatus: String, Codable {
    case confirmed = "confirmed"
    case pending = "pending"
    case cancelled = "cancelled"
}

struct APIBooking: Codable, Identifiable {
    let id: String
    let venueId: String
    let userId: String
    let guests: [String]
    let partySize: Int
    let dateTime: String
    let status: APIBookingStatus
    let confirmationCode: String
    let createdAt: String
}

// MARK: - Request Types
struct CreateInviteRequest: Codable {
    let venueId: String
    let toUserIds: [String]
    let proposedTime: String
}

struct UpdateInviteRequest: Codable {
    let status: String // "accepted" or "declined"
}

struct CreateBookingRequest: Codable {
    let venueId: String
    let partySize: Int
    let dateTime: String
    let guestIds: [String]?
}

// MARK: - Agent Chat Types
struct AgentChatMessage: Codable {
    let role: String // "user" or "assistant"
    let content: String
}

struct AgentChatRequest: Codable {
    let message: String
    let conversationHistory: [AgentChatMessage]?
}

// MARK: - Agent Suggestion Types
struct APIAgentSuggestion: Codable {
    let venueId: String
    let venueName: String
    let friendNames: [String]
    let friendIds: [String]
    let partySize: Int
    let suggestedTime: String
    let reasoning: String
    let sharedInterests: [String]?
}

// MARK: - Health Check
struct HealthCheckResponse: Codable {
    let status: String
    let timestamp: String
}

// MARK: - Response Wrapper Types
struct HeartVenueResponse: Codable {
    let message: String
    let interest: APIInterest
    let venue: APIEnrichedVenue?
}

struct CreateInviteResponse: Codable {
    let message: String
    let invites: [APIInvite]
}

struct UpdateInviteResponse: Codable {
    let message: String
    let invite: APIInvite
}

struct CreateBookingResponse: Codable {
    let message: String
    let booking: APIBooking
}

struct GetInvitesResponse: Codable {
    let sent: [APIEnrichedInvite]
    let received: [APIEnrichedInvite]
    let related: [APIEnrichedInvite]?
    let pending: [APIEnrichedInvite]
}

struct GetBookingsResponse: Codable {
    let bookings: [APIBooking]
    let count: Int
}

