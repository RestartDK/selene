//
//  VenueDetailView.swift
//  client
//
//  Selene App - Venue Detail View
//

import SwiftUI

struct VenueDetailView: View {
    let venue: Venue
    var apiVenueId: String = ""
    
    @StateObject private var appState = AppState.shared
    @State private var isSaved: Bool = false
    @State private var showAgentSheet: Bool = false
    @State private var isLoadingDetails: Bool = false
    @State private var detailedVenue: Venue?
    @Environment(\.dismiss) private var dismiss
    
    // Number of friends to show before "more mutuals" row
    private let maxVisibleFriends = 3
    
    // Use detailed venue if loaded, otherwise fall back to passed venue
    private var displayVenue: Venue {
        detailedVenue ?? venue
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                heroImage
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Venue header
                    venueHeader
                    
                    Divider()
                    
                    // Interested friends section
                    if !displayVenue.interestedFriends.isEmpty {
                        interestedFriendsSection
                        Divider()
                    }
                    
                    // About section
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120) // Space for bottom buttons
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        // Share action
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // Report action
                    } label: {
                        Label("Report", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }
        }
        .overlay(alignment: .bottom) {
            bottomButtons
        }
        .sheet(isPresented: $showAgentSheet) {
            AgentSheetView(
                venue: displayVenue,
                apiVenueId: apiVenueId,
                invitation: nil
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
        }
        .onAppear {
            isSaved = appState.isVenueSaved(apiId: apiVenueId)
        }
        .task {
            await loadVenueDetails()
        }
    }
    
    // MARK: - Load Venue Details
    private func loadVenueDetails() async {
        guard !apiVenueId.isEmpty else { return }
        
        isLoadingDetails = true
        defer { isLoadingDetails = false }
        
        do {
            let apiVenue = try await APIClient.shared.getVenue(id: apiVenueId)
            detailedVenue = apiVenue.toVenue()
        } catch {
            print("Error loading venue details: \(error)")
            // Keep using the passed venue
        }
    }
    
    // MARK: - Hero Image
    private var heroImage: some View {
        ZStack {
            if let imageUrl = displayVenue.videoURL {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        placeholderGradient
                            .overlay {
                                ProgressView()
                                    .tint(Color.contentPrimary)
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 260)
                            .clipped()
                    case .failure:
                        placeholderGradient
                    @unknown default:
                        placeholderGradient
                    }
                }
            } else {
                placeholderGradient
            }
        }
        .frame(height: 260)
        .clipped()
    }
    
    private var placeholderGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SeleneTheme.twilight,
                    Color(red: 0.25, green: 0.20, blue: 0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Category icon
            Text(displayVenue.categoryIcon)
                .font(.system(size: 60))
                .opacity(0.4)
        }
    }
    
    // MARK: - Venue Header
    private var venueHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayVenue.name)
                .font(.seleneTitle)
                .foregroundStyle(.primary)
            
            HStack(spacing: 12) {
                // Category and vibe
                HStack(spacing: 4) {
                    Text(displayVenue.categoryIcon)
                    Text("\(displayVenue.category) • \(displayVenue.vibe)")
                }
                .font(.seleneCaption)
                .foregroundStyle(.secondary)
            }
            
            // Distance
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11))
                Text("\(displayVenue.distance) • \(displayVenue.location)")
            }
            .font(.seleneCaption)
            .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Interested Friends Section
    private var interestedFriendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("People you know interested")
                .seleneTextStyle(.sectionHeader)
            
            VStack(spacing: 0) {
                // Visible friends
                ForEach(Array(displayVenue.interestedFriends.prefix(maxVisibleFriends))) { friend in
                    InterestedFriendRow(user: friend)
                    
                    if friend.id != displayVenue.interestedFriends.prefix(maxVisibleFriends).last?.id {
                        Divider()
                    }
                }
                
                // More mutuals row if needed
                if displayVenue.interestedFriends.count > maxVisibleFriends {
                    Divider()
                    MoreMutualsRow(count: displayVenue.interestedFriends.count - maxVisibleFriends)
                }
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About this venue")
                .seleneTextStyle(.sectionHeader)
            
            Text(displayVenue.description)
                .font(.seleneBody)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Save button
                GlowingButton("Interested", icon: isSaved ? "heart.fill" : "heart", style: .secondary) {
                    Task {
                        if isSaved {
                            await appState.unheartVenue(displayVenue, apiId: apiVenueId)
                        } else {
                            await appState.heartVenue(displayVenue, apiId: apiVenueId)
                        }
                        isSaved.toggle()
                    }
                }
                
                // Let's Go button
                GlowingButton("Let's Go", icon: "arrow.right", style: .primary) {
                    showAgentSheet = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        VenueDetailView(
            venue: MockData.blueNote,
            apiVenueId: "blue-note"
        )
    }
    .preferredColorScheme(.dark)
}
