//
//  APIClient.swift
//  client
//
//  Selene App - API Client for Backend Communication
//

import Foundation
import Combine

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String?)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message ?? "Unknown")"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - API Client
@MainActor
class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    // MARK: - Generic Request Methods
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, message)
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func requestVoid(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode, nil)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Health Check
    
    func healthCheck() async throws -> HealthCheckResponse {
        try await request(endpoint: "/health")
    }
    
    // MARK: - User Endpoints
    
    func getCurrentUser() async throws -> APIUser {
        try await request(endpoint: "/users/me")
    }
    
    func getFriends() async throws -> [APIUser] {
        try await request(endpoint: "/social/friends")
    }
    
    // MARK: - Venue Endpoints
    
    func getVenues() async throws -> [APIEnrichedVenue] {
        try await request(endpoint: "/venues")
    }
    
    func getVenue(id: String) async throws -> APIEnrichedVenue {
        try await request(endpoint: "/venues/\(id)")
    }
    
    func heartVenue(id: String) async throws -> APIInterest {
        let response: HeartVenueResponse = try await request(endpoint: "/venues/\(id)/heart", method: "POST")
        return response.interest
    }
    
    func unheartVenue(id: String) async throws {
        try await requestVoid(endpoint: "/venues/\(id)/heart", method: "DELETE")
    }
    
    // MARK: - Social Endpoints
    
    func getInterestedFriends(venueId: String) async throws -> [APIUser] {
        try await request(endpoint: "/social/interested/\(venueId)")
    }
    
    // MARK: - Invite Endpoints
    
    func getInvites() async throws -> [APIEnrichedInvite] {
        let response: GetInvitesResponse = try await request(endpoint: "/invites")
        // Return all invites (sent, received, and related combined)
        let related = response.related ?? []
        return response.sent + response.received + related
    }
    
    func createInvite(request: CreateInviteRequest) async throws -> APIInvite {
        let body = try encoder.encode(request)
        let response: CreateInviteResponse = try await self.request(endpoint: "/invites", method: "POST", body: body)
        // Return the first invite (server creates one per toUserId)
        guard let firstInvite = response.invites.first else {
            throw APIError.unknown
        }
        return firstInvite
    }
    
    func updateInvite(id: String, status: String) async throws -> APIInvite {
        let updateRequest = UpdateInviteRequest(status: status)
        let body = try encoder.encode(updateRequest)
        let response: UpdateInviteResponse = try await request(endpoint: "/invites/\(id)", method: "PATCH", body: body)
        return response.invite
    }
    
    // MARK: - Booking Endpoints
    
    func getBookings() async throws -> [APIBooking] {
        let response: GetBookingsResponse = try await request(endpoint: "/bookings")
        return response.bookings
    }
    
    func createBooking(request: CreateBookingRequest) async throws -> APIBooking {
        let body = try encoder.encode(request)
        let response: CreateBookingResponse = try await self.request(endpoint: "/bookings", method: "POST", body: body)
        return response.booking
    }
    
    // MARK: - Agent Endpoints
    
    func getAgentSuggestion(venueId: String) async throws -> APIAgentSuggestion? {
        try await request(endpoint: "/agent/suggestion?venueId=\(venueId)")
    }
}

// MARK: - Model Converters
extension APIUser {
    func toUser() -> User {
        // Construct full avatar URL if it's a relative path
        let fullAvatarUrl: String? = {
            if avatarUrl.isEmpty {
                return nil
            }
            // If it's already a full URL, return as is
            if avatarUrl.hasPrefix("http://") || avatarUrl.hasPrefix("https://") {
                return avatarUrl
            }
            // If it's a relative path starting with /, construct full URL
            if avatarUrl.hasPrefix("/") {
                return "\(APIConfig.baseURL)\(avatarUrl)"
            }
            // Otherwise, assume it's a filename in the media folder
            return "\(APIConfig.baseURL)/media/\(avatarUrl)"
        }()
        
        return User(
            id: id, // Use the API user ID string directly
            name: name,
            username: name.lowercased(),
            avatarEmoji: avatarForName(name),
            avatarUrl: fullAvatarUrl,
            isOnline: vibeStatus == .readyToMingle,
            matchScore: matchScoreFromVibe(vibeStatus)
        )
    }
    
    private func avatarForName(_ name: String) -> String {
        let avatars = ["😊", "🤙", "🎸", "🌟", "🎨", "😎", "🔥", "✨"]
        let hash = abs(name.hashValue)
        return avatars[hash % avatars.count]
    }
    
    private func matchScoreFromVibe(_ vibe: APIVibeStatus) -> User.MatchScore {
        switch vibe {
        case .readyToMingle: return .high
        case .exploring: return .medium
        case .chilling: return .low
        }
    }
}

extension APIEnrichedVenue {
    func toVenue() -> Venue {
        Venue(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            category: type,
            vibe: vibe,
            location: location.address,
            distance: location.distance,
            description: description,
            heroImageName: thumbnailUrl,
            videoURL: URL(string: mediaUrl),
            interestedFriends: interestedFriends.map { $0.toUser() },
            isSaved: isSaved
        )
    }
    
    func toFeedItem(currentUserId: String) -> FeedItem {
        let venue = toVenue()
        
        // Check if there's an invite for the current user
        var invitation: Invitation? = nil
        if let invite = inviteState, invite.toUserId == currentUserId {
            // Find the inviter from interested friends or create placeholder
            let inviter = interestedFriends
                .first { $0.id == invite.fromUserId }?
                .toUser() ?? User(id: invite.fromUserId, name: "Someone", username: "unknown")
            
            invitation = Invitation(
                id: UUID(uuidString: invite.id) ?? UUID(),
                apiInviteId: invite.id,
                venue: venue,
                inviter: inviter,
                invitedAt: ISO8601DateFormatter().date(from: invite.createdAt) ?? Date(),
                status: invite.status == .pending ? .pending : .accepted,
                scheduledTime: ISO8601DateFormatter().date(from: invite.proposedTime)
            )
        }
        
        return FeedItem(
            id: venue.id,
            venue: venue,
            invitation: invitation,
            apiVenueId: id
        )
    }
}

extension APIInvite {
    func toInvitation(venue: Venue, inviter: User) -> Invitation {
        Invitation(
            id: UUID(uuidString: id) ?? UUID(),
            apiInviteId: id,
            venue: venue,
            inviter: inviter,
            invitedAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            status: status == .pending ? .pending : (status == .accepted ? .accepted : .declined),
            scheduledTime: ISO8601DateFormatter().date(from: proposedTime)
        )
    }
}

extension APIEnrichedInvite {
    func toInvitation(venue: Venue, inviter: User) -> Invitation {
        Invitation(
            id: UUID(uuidString: id) ?? UUID(),
            apiInviteId: id,
            venue: venue,
            inviter: inviter,
            invitedAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            status: status == .pending ? .pending : (status == .accepted ? .accepted : .declined),
            scheduledTime: ISO8601DateFormatter().date(from: proposedTime)
        )
    }
}

extension APIBooking {
    func toBooking(venue: Venue, attendees: [User]) -> Booking {
        Booking(
            id: UUID(uuidString: id) ?? UUID(),
            venue: venue,
            dateTime: ISO8601DateFormatter().date(from: dateTime) ?? Date(),
            partySize: partySize,
            attendees: attendees,
            confirmationCode: confirmationCode
        )
    }
}

