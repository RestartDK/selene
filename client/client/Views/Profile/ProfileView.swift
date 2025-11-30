//
//  ProfileView.swift
//  client
//
//  Selene App - User Profile View
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var appState = AppState.shared
    
    @State private var selectedVenue: Venue?
    @State private var selectedApiVenueId: String = ""
    @State private var showVenueDetail: Bool = false
    @State private var showSettings: Bool = false
    
    private var displayUser: User {
        appState.currentUser ?? MockData.currentUser
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Profile header
                    profileHeader
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Saved places grid
                    SavedPlacesGrid(
                        venues: appState.savedVenues,
                        onSelectVenue: { venue in
                            selectedVenue = venue
                            // Try to find the API ID
                            if let feedItem = appState.feedItems.first(where: { $0.venue.id == venue.id }) {
                                selectedApiVenueId = feedItem.apiVenueId
                            }
                            showVenueDetail = true
                        }
                    )
                    .padding(.horizontal)
                    
                    // My Bookings Section
                    if !appState.bookings.isEmpty {
                        bookingsSection
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .navigationDestination(isPresented: $showVenueDetail) {
                if let venue = selectedVenue {
                    VenueDetailView(
                        venue: venue,
                        apiVenueId: selectedApiVenueId
                    )
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .refreshable {
                await appState.initialize()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cardGradientStart,
                                Color.cardGradientEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.contentPrimary.opacity(0.3), Color.contentPrimary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                
                Text(displayUser.avatarEmoji)
                    .font(.system(size: 50))
            }
            
            // Name and username
            VStack(spacing: 4) {
                Text(displayUser.name)
                    .font(.seleneHeadline)
                    .foregroundStyle(.primary)
                
                Text("@\(displayUser.username)")
                    .font(.seleneCaption)
                    .foregroundStyle(.secondary)
            }
            
            // Vibe status badge
            if let currentUser = appState.currentUser {
                vibeStatusBadge(for: currentUser)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Vibe Status Badge
    private func vibeStatusBadge(for user: User) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(user.isOnline ? Color.matchHigh : Color.matchMedium)
                .frame(width: 8, height: 8)
            
            Text(user.isOnline ? "Ready to go out" : "Just exploring")
                .font(.seleneCaptionMedium)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.seleneSecondaryBackground)
        )
    }
    
    // MARK: - Bookings Section
    private var bookingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Bookings")
                .font(.seleneHeadline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                ForEach(appState.bookings) { booking in
                    BookingCard(booking: booking)
                }
            }
        }
    }
}

// MARK: - Booking Card
struct BookingCard: View {
    let booking: Booking
    
    var body: some View {
        HStack(spacing: 12) {
            // Venue icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.seleneTertiaryBackground)
                    .frame(width: 60, height: 60)
                
                Text(booking.venue.categoryIcon)
                    .font(.system(size: 28))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.venue.name)
                    .font(.seleneBodyMedium)
                    .foregroundStyle(.primary)
                
                Text(formattedDate)
                    .font(.seleneCaption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 10))
                    Text("Party of \(booking.partySize)")
                        .font(.seleneSmall)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Status badge
            Text(booking.confirmationCode)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(SeleneTheme.success)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(SeleneTheme.success.opacity(0.2))
                )
        }
        .padding(12)
        .background(Color.seleneSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d 'at' h:mm a"
        return formatter.string(from: booking.dateTime)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Label("Edit Profile", systemImage: "person.circle")
                    Label("Notifications", systemImage: "bell")
                    Label("Privacy", systemImage: "lock")
                }
                
                Section("Preferences") {
                    Label("Appearance", systemImage: "paintbrush")
                    Label("Location", systemImage: "location")
                }
                
                Section("Developer") {
                    HStack {
                        Label("API Server", systemImage: "server.rack")
                        Spacer()
                        Text(APIConfig.baseURL)
                            .font(.seleneSmall)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        Task {
                            do {
                                let health = try await APIClient.shared.healthCheck()
                                print("Server status: \(health.status)")
                            } catch {
                                print("Health check failed: \(error)")
                            }
                        }
                    } label: {
                        Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
                
                Section("Support") {
                    Label("Help Center", systemImage: "questionmark.circle")
                    Label("Send Feedback", systemImage: "envelope")
                }
                
                Section {
                    Button(role: .destructive) {
                        // Sign out action
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
