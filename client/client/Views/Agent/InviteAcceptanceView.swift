//
//  InviteAcceptanceView.swift
//  client
//
//  Selene App - Invite Acceptance Sheet
//

import SwiftUI

struct InviteAcceptanceView: View {
    let venue: Venue
    var apiVenueId: String = ""
    let invitation: Invitation
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = AppState.shared
    
    @State private var showConfirmation: Bool = false
    @State private var confirmedBooking: Booking?
    @State private var isLoading: Bool = false
    
    // Get all invites for this venue to show who was invited
    private var venueInvites: [Invitation] {
        appState.getInvitesForVenue(apiVenueId: apiVenueId)
    }
    
    // Get other invitees (people invited by the same host to the same venue)
    // Exclude the current user's invite and the current user themselves
    private var otherInvites: [Invitation] {
        let currentUserId = appState.currentUser?.id
        return venueInvites.filter { invite in
            let sameHost = invite.inviter.id == invitation.inviter.id
            let notCurrentInvite = invite.id != invitation.id
            let invitee = getInviteeUser(for: invite)
            let notCurrentUser = currentUserId == nil || invitee?.id != currentUserId
            return sameHost && notCurrentInvite && notCurrentUser
        }
    }
    
    // Get invitee user for an invitation
    private func getInviteeUser(for invite: Invitation) -> User? {
        return appState.getInviteeUser(for: invite)
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
                    acceptanceForm
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
    }
    
    // MARK: - Acceptance Form
    private var acceptanceForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Venue header (similar to agent header)
                venueHeader
                
                // Invitees section
                inviteesSection
                
                // Date/time display (read-only, from invitation)
                dateTimeSection
                
                // Confirm button
                confirmButton
            }
            .padding(20)
        }
    }
    
    // MARK: - Venue Header
    private var venueHeader: some View {
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
    
    // MARK: - Invitees Section
    private var inviteesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who's Going")
                .font(.seleneHeadline)
            
            VStack(spacing: 12) {
                // Host (inviter)
                HStack(spacing: 12) {
                    AvatarCircle(user: invitation.inviter, size: 44, showOnlineIndicator: true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(invitation.inviter.name)
                            .font(.seleneBodyMedium)
                        Text("Host")
                            .font(.seleneCaption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.seleneSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Other invitees (people invited by the same host to the same venue)
                ForEach(otherInvites) { invite in
                    HStack(spacing: 12) {
                        // Try to get invitee user, otherwise show placeholder
                        if let invitee = getInviteeUser(for: invite) {
                            AvatarCircle(user: invitee, size: 44, showOnlineIndicator: true)
                        } else {
                            Circle()
                                .fill(Color.seleneTertiaryBackground)
                                .frame(width: 44, height: 44)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let invitee = getInviteeUser(for: invite) {
                                Text(invitee.name)
                                    .font(.seleneBodyMedium)
                            } else {
                                Text("Guest")
                                    .font(.seleneBodyMedium)
                            }
                            Text(invite.status == .accepted ? "Accepted" : "Pending")
                                .font(.seleneCaption)
                                .foregroundStyle(invite.status == .accepted ? SeleneTheme.success : .secondary)
                        }
                        
                        Spacer()
                        
                        if invite.status == .accepted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SeleneTheme.success)
                        }
                    }
                    .padding(12)
                    .background(Color.seleneSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Current user (you)
                if let currentUser = appState.currentUser {
                    HStack(spacing: 12) {
                        AvatarCircle(user: currentUser, size: 44, showOnlineIndicator: true)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("You")
                                .font(.seleneBodyMedium)
                            Text("Accepting...")
                                .font(.seleneCaption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.seleneSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Date/Time Section
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When")
                .font(.seleneHeadline)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                
                Text(formattedDate)
                    .font(.seleneBodyMedium)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(16)
            .background(Color.seleneSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Confirm Button
    private var confirmButton: some View {
        AppButton("Confirm Reservation", icon: "checkmark.circle.fill", style: .success) {
            performConfirmation()
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
        guard let scheduledTime = invitation.scheduledTime else {
            return "Time TBD"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
        
        let calendar = Calendar.current
        if calendar.isDateInToday(scheduledTime) {
            formatter.dateFormat = "'Tonight,' h:mm a"
        } else if calendar.isDateInTomorrow(scheduledTime) {
            formatter.dateFormat = "'Tomorrow,' h:mm a"
        }
        
        return formatter.string(from: scheduledTime)
    }
    
    private func performConfirmation() {
        isLoading = true
        
        Task {
            // Accept the invite
            await appState.acceptInvite(invitation)
            
            // Get scheduled time from invitation
            guard let scheduledTime = invitation.scheduledTime else {
                isLoading = false
                // Still show success even without scheduled time
                withAnimation(.spring(response: 0.4)) {
                    showConfirmation = true
                }
                return
            }
            
            // Calculate party size: host + current user + other accepted invitees
            let acceptedInvitees = venueInvites.filter { $0.status == .accepted }
            let partySize = 1 + 1 + acceptedInvitees.count // host + current user + accepted
            
            // Get guest IDs (host, excluding current user) - use user ID
            var guestIds: [String] = [invitation.inviter.id]
            
            // Get guest User objects (host)
            var guests: [User] = [invitation.inviter]
            
            // Create booking to show confirmation
            if let booking = await appState.createBooking(
                venueApiId: apiVenueId,
                venue: venue,
                partySize: partySize,
                dateTime: scheduledTime,
                guestIds: guestIds,
                guests: guests
            ) {
                confirmedBooking = booking
                
                withAnimation(.spring(response: 0.4)) {
                    showConfirmation = true
                }
            } else {
                // If booking creation fails, still show success for accepting invite
                // Create a simple booking object for display
                if let currentUser = appState.currentUser {
                    let simpleBooking = Booking(
                        venue: venue,
                        dateTime: scheduledTime,
                        partySize: partySize,
                        attendees: [invitation.inviter, currentUser] + guests,
                        confirmationCode: ""
                    )
                    confirmedBooking = simpleBooking
                    withAnimation(.spring(response: 0.4)) {
                        showConfirmation = true
                    }
                }
            }
            
            isLoading = false
        }
    }
}

