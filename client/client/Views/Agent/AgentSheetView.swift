//
//  AgentSheetView.swift
//  client
//
//  Selene App - Selene Agent Booking Sheet
//

import SwiftUI

struct AgentSheetView: View {
    let venue: Venue
    var apiVenueId: String = ""
    let invitation: Invitation?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = AppState.shared
    
    @State private var selectedFriends: Set<String> = []
    @State private var selectedFriendApiIds: [String] = []
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var showConfirmation: Bool = false
    @State private var confirmedBooking: Booking?
    @State private var isLoading: Bool = false
    @State private var agentSuggestion: APIAgentSuggestion?
    
    // Interested friends (pre-selected)
    private var interestedFriends: [User] {
        venue.interestedFriends
    }
    
    // All friends for searching
    private var allFriends: [User] {
        appState.friends
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if showConfirmation, let booking = confirmedBooking {
                    BookingConfirmationView(
                        booking: booking,
                        onAddToCalendar: {
                            // Add to calendar action
                        },
                        onDone: {
                            dismiss()
                        }
                    )
                } else {
                    bookingForm
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showConfirmation {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            // Pre-select all interested friends
            for friend in interestedFriends {
                selectedFriends.insert(friend.id)
                let apiId = friend.name.lowercased()
                if !selectedFriendApiIds.contains(apiId) {
                    selectedFriendApiIds.append(apiId)
                }
            }
            
            // Pre-select inviter if this is from an invitation
            if let invitation = invitation {
                selectedFriends.insert(invitation.inviter.id)
                let apiId = invitation.inviter.name.lowercased()
                if !selectedFriendApiIds.contains(apiId) {
                    selectedFriendApiIds.append(apiId)
                }
            }
            
            // Set default time to tonight at 9 PM
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 21
            components.minute = 0
            if let tonight = Calendar.current.date(from: components) {
                selectedDate = tonight
            }
            
            // Fetch agent suggestion for smart reasoning
            Task {
                if let suggestion = try? await APIClient.shared.getAgentSuggestion(venueId: apiVenueId) {
                    agentSuggestion = suggestion
                    // Pre-select suggested friends (by their IDs)
                    for friendId in suggestion.friendIds {
                        selectedFriends.insert(friendId)
                        if !selectedFriendApiIds.contains(friendId) {
                            selectedFriendApiIds.append(friendId)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Booking Form
    private var bookingForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Agent header
                agentHeader
                
                // Smart reasoning banner from Luna
                if let suggestion = agentSuggestion {
                    reasoningBanner(suggestion: suggestion)
                }
                
                // Friend selection
                FriendSelectionList(
                    interestedFriends: interestedFriends,
                    allFriends: allFriends,
                    selectedFriends: $selectedFriends,
                    onSelectionChange: { user, isSelected in
                        let apiId = user.id
                        if isSelected {
                            if !selectedFriendApiIds.contains(apiId) {
                                selectedFriendApiIds.append(apiId)
                            }
                        } else {
                            selectedFriendApiIds.removeAll { $0 == apiId }
                        }
                    }
                )
                
                // Date/time picker
                dateTimePicker
                
                // Book button
                bookButton
            }
            .padding(20)
        }
    }
    
    // MARK: - Agent Header
    private var agentHeader: some View {
        VStack(spacing: 12) {
            // Venue name
            Text(venue.name)
                .font(.seleneAgentTitle)
                .multilineTextAlignment(.center)
            
            // Category and vibe
            HStack(spacing: 4) {
                Text(venue.categoryIcon)
                Text("\(venue.category) • \(venue.vibe)")
            }
            .font(.seleneCaption)
            .foregroundStyle(.secondary)
            
            // Location and distance
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11))
                Text("\(venue.distance) • \(venue.location)")
            }
            .font(.seleneCaption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    // MARK: - Reasoning Banner
    private func reasoningBanner(suggestion: APIAgentSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(SeleneTheme.moonGlow)
                Text("Luna")
                    .font(.seleneCaption)
                    .foregroundStyle(.secondary)
            }
            Text(suggestion.reasoning)
                .font(.seleneBody)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SeleneTheme.moonGlow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Date/Time Picker
    private var dateTimePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    
                    Text(formattedDate)
                        .font(.seleneBodyMedium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(Color.seleneSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            
            if showDatePicker {
                DatePicker(
                    "Select date and time",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color.seleneSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Book Button
    private var bookButton: some View {
        AppButton("Book & Invite", icon: "sparkles", style: .success) {
            performBooking()
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1)
        .overlay {
            if isLoading {
                ProgressView()
                    .tint(Color.contentPrimary)
            }
        }
    }
    
    // MARK: - Helpers
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
        
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            formatter.dateFormat = "'Tonight,' h:mm a"
        } else if calendar.isDateInTomorrow(selectedDate) {
            formatter.dateFormat = "'Tomorrow,' h:mm a"
        }
        
        return formatter.string(from: selectedDate)
    }
    
    private func performBooking() {
        isLoading = true
        
        Task {
            // Get selected users from both interested friends and all friends
            let selectedFromInterested = interestedFriends.filter { selectedFriends.contains($0.id) }
            let selectedFromAll = allFriends.filter { selectedFriends.contains($0.id) }
            
            // Combine and deduplicate by ID
            var allSelectedUsers: [User] = []
            var seenIds = Set<String>()
            for user in selectedFromInterested + selectedFromAll {
                if !seenIds.contains(user.id) {
                    allSelectedUsers.append(user)
                    seenIds.insert(user.id)
                }
            }
            
            let partySize = allSelectedUsers.count + 1 // +1 for current user
            
            // Create booking via API
            if let booking = await appState.createBooking(
                venueApiId: apiVenueId,
                venue: venue,
                partySize: partySize,
                dateTime: selectedDate,
                guestIds: selectedFriendApiIds,
                guests: allSelectedUsers
            ) {
                // Also create invites for selected friends
                if !selectedFriendApiIds.isEmpty {
                    _ = await appState.createInvite(
                        venueApiId: apiVenueId,
                        toUserIds: selectedFriendApiIds,
                        proposedTime: selectedDate
                    )
                }
                
                confirmedBooking = booking
                
                withAnimation(.spring(response: 0.4)) {
                    showConfirmation = true
                }
            }
            
            isLoading = false
        }
    }
}

