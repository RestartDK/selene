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
    
    @State private var selectedFriends: Set<UUID> = []
    @State private var selectedFriendApiIds: [String] = []
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var showConfirmation: Bool = false
    @State private var confirmedBooking: Booking?
    @State private var isLoading: Bool = false
    
    // Available friends from AppState or venue's interested friends
    private var availableFriends: [User] {
        if !appState.friends.isEmpty {
            return appState.friends
        }
        return venue.interestedFriends
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
            // Pre-select inviter if this is from an invitation
            if let invitation = invitation {
                selectedFriends.insert(invitation.inviter.id)
                selectedFriendApiIds.append(invitation.inviter.name.lowercased())
            }
            
            // Set default time to tonight at 9 PM
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 21
            components.minute = 0
            if let tonight = Calendar.current.date(from: components) {
                selectedDate = tonight
            }
        }
    }
    
    // MARK: - Booking Form
    private var bookingForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Agent header
                agentHeader
                
                // Friend selection
                FriendSelectionList(
                    availableFriends: availableFriends,
                    selectedFriends: $selectedFriends,
                    onSelectionChange: { user, isSelected in
                        let apiId = user.name.lowercased()
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
            // Moon icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.sheetGradientStart,
                                Color.sheetGradientEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(SeleneTheme.moonGlow)
            }
            
            Text("Selene Agent")
                .font(.seleneAgentTitle)
            
            Text("\"I can secure a spot via OpenTable\"")
                .seleneTextStyle(.agentMessage)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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
        GlowingButton("Book & Invite", icon: "sparkles", style: .gold) {
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
            // Get selected users
            let selectedUsers = availableFriends.filter { selectedFriends.contains($0.id) }
            let partySize = selectedUsers.count + 1 // +1 for current user
            
            // Create booking via API
            if let booking = await appState.createBooking(
                venueApiId: apiVenueId,
                venue: venue,
                partySize: partySize,
                dateTime: selectedDate,
                guestIds: selectedFriendApiIds,
                guests: selectedUsers
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

// MARK: - Preview
#Preview {
    AgentSheetView(
        venue: MockData.blueNote,
        apiVenueId: "blue-note",
        invitation: nil
    )
    .preferredColorScheme(.dark)
}
