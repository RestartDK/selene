//
//  AppState.swift
//  client
//
//  Selene App - Centralized App State Management
//

import SwiftUI
import Combine

// MARK: - Feed Item (unified local model)
struct FeedItem: Identifiable {
    let id: UUID
    let venue: Venue
    let invitation: Invitation?
    let apiVenueId: String // Store the API ID for backend calls
    
    var isInvited: Bool { invitation != nil }
    
    init(id: UUID = UUID(), venue: Venue, invitation: Invitation? = nil, apiVenueId: String = "") {
        self.id = id
        self.venue = venue
        self.invitation = invitation
        self.apiVenueId = apiVenueId.isEmpty ? venue.id.uuidString : apiVenueId
    }
}

// MARK: - Loading State
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var value: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    // MARK: - Published State
    @Published var currentUser: User?
    @Published var friends: [User] = []
    @Published var feedItems: [FeedItem] = []
    @Published var savedVenues: [Venue] = []
    @Published var invites: [Invitation] = []
    @Published var bookings: [Booking] = []
    
    // Loading states
    @Published var feedLoadingState: LoadingState<Void> = .idle
    @Published var userLoadingState: LoadingState<Void> = .idle
    
    // Error handling
    @Published var lastError: Error?
    @Published var showError: Bool = false
    
    // API Client
    private let apiClient = APIClient.shared
    
    // Track API venue IDs for saved status
    private var savedVenueIds: Set<String> = []
    
    private init() {}
    
    // MARK: - Initialization
    
    func initialize() async {
        await loadCurrentUser()
        await loadFeed()
        await loadFriends()
        await loadInvites()
    }
    
    // MARK: - User Methods
    
    func loadCurrentUser() async {
        userLoadingState = .loading
        
        do {
            let apiUser = try await apiClient.getCurrentUser()
            currentUser = apiUser.toUser()
            userLoadingState = .loaded(())
        } catch {
            print("Error loading current user: \(error)")
            userLoadingState = .error(error)
        }
    }
    
    func loadFriends() async {
        do {
            let apiFriends = try await apiClient.getFriends()
            friends = apiFriends.map { $0.toUser() }
        } catch {
            print("Error loading friends: \(error)")
        }
    }
    
    // MARK: - Feed Methods
    
    func loadFeed() async {
        feedLoadingState = .loading
        
        do {
            let apiVenues = try await apiClient.getVenues()
            let currentUserId = currentUser?.id.uuidString.lowercased() ?? "alex"
            
            feedItems = apiVenues.map { apiVenue in
                apiVenue.toFeedItem(currentUserId: currentUserId)
            }
            
            feedLoadingState = .loaded(())
        } catch {
            print("Error loading feed: \(error)")
            feedLoadingState = .error(error)
        }
    }
    
    func refreshFeed() async {
        await loadFeed()
    }
    
    // MARK: - Venue Actions
    
    func heartVenue(_ venue: Venue, apiId: String) async {
        do {
            _ = try await apiClient.heartVenue(id: apiId)
            savedVenueIds.insert(apiId)
            
            // Update the venue in saved venues
            if !savedVenues.contains(where: { $0.id == venue.id }) {
                var updatedVenue = venue
                updatedVenue.isSaved = true
                savedVenues.append(updatedVenue)
            }
            
            // Update feed item
            if let index = feedItems.firstIndex(where: { $0.apiVenueId == apiId }) {
                var updatedVenue = feedItems[index].venue
                updatedVenue.isSaved = true
                feedItems[index] = FeedItem(
                    id: feedItems[index].id,
                    venue: updatedVenue,
                    invitation: feedItems[index].invitation,
                    apiVenueId: apiId
                )
            }
        } catch {
            handleError(error)
        }
    }
    
    func unheartVenue(_ venue: Venue, apiId: String) async {
        do {
            try await apiClient.unheartVenue(id: apiId)
            savedVenueIds.remove(apiId)
            
            // Remove from saved venues
            savedVenues.removeAll { $0.id == venue.id }
            
            // Update feed item
            if let index = feedItems.firstIndex(where: { $0.apiVenueId == apiId }) {
                var updatedVenue = feedItems[index].venue
                updatedVenue.isSaved = false
                feedItems[index] = FeedItem(
                    id: feedItems[index].id,
                    venue: updatedVenue,
                    invitation: feedItems[index].invitation,
                    apiVenueId: apiId
                )
            }
        } catch {
            handleError(error)
        }
    }
    
    func isVenueSaved(apiId: String) -> Bool {
        savedVenueIds.contains(apiId)
    }
    
    // MARK: - Invite Methods
    
    func loadInvites() async {
        do {
            let apiInvites = try await apiClient.getInvites()
            
            // Convert API invites to local Invitation models
            // We need venue and inviter info, so we'll map what we can
            invites = apiInvites.compactMap { apiInvite -> Invitation? in
                // Find the venue in our feed
                guard let feedItem = feedItems.first(where: { $0.apiVenueId == apiInvite.venueId }) else {
                    return nil
                }
                
                // Find the inviter in friends
                let inviter = friends.first { $0.name.lowercased() == apiInvite.fromUserId } ?? 
                              User(name: apiInvite.fromUserId, username: apiInvite.fromUserId)
                
                return apiInvite.toInvitation(venue: feedItem.venue, inviter: inviter)
            }
        } catch {
            print("Error loading invites: \(error)")
        }
    }
    
    func acceptInvite(_ invitation: Invitation, apiInviteId: String) async {
        do {
            _ = try await apiClient.updateInvite(id: apiInviteId, status: "accepted")
            
            // Update local state
            if let index = invites.firstIndex(where: { $0.id == invitation.id }) {
                var updatedInvite = invites[index]
                updatedInvite.status = .accepted
                invites[index] = updatedInvite
            }
        } catch {
            handleError(error)
        }
    }
    
    func declineInvite(_ invitation: Invitation, apiInviteId: String) async {
        do {
            _ = try await apiClient.updateInvite(id: apiInviteId, status: "declined")
            
            // Remove from local state
            invites.removeAll { $0.id == invitation.id }
        } catch {
            handleError(error)
        }
    }
    
    func createInvite(venueApiId: String, toUserIds: [String], proposedTime: Date) async -> Bool {
        let formatter = ISO8601DateFormatter()
        let request = CreateInviteRequest(
            venueId: venueApiId,
            toUserIds: toUserIds,
            proposedTime: formatter.string(from: proposedTime)
        )
        
        do {
            _ = try await apiClient.createInvite(request: request)
            await loadInvites()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - Booking Methods
    
    func createBooking(
        venueApiId: String,
        venue: Venue,
        partySize: Int,
        dateTime: Date,
        guestIds: [String],
        guests: [User]
    ) async -> Booking? {
        let formatter = ISO8601DateFormatter()
        let request = CreateBookingRequest(
            venueId: venueApiId,
            partySize: partySize,
            dateTime: formatter.string(from: dateTime),
            guestIds: guestIds.isEmpty ? nil : guestIds
        )
        
        do {
            let apiBooking = try await apiClient.createBooking(request: request)
            
            // Create local booking
            var allAttendees = guests
            if let current = currentUser {
                allAttendees.insert(current, at: 0)
            }
            
            let booking = apiBooking.toBooking(venue: venue, attendees: allAttendees)
            bookings.append(booking)
            
            return booking
        } catch {
            handleError(error)
            return nil
        }
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        lastError = error
        showError = true
        print("AppState Error: \(error.localizedDescription)")
    }
    
    func clearError() {
        lastError = nil
        showError = false
    }
}

