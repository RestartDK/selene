//
//  FeedView.swift
//  client
//
//  Selene App - Main Discovery Feed with Vertical Scrolling
//

import SwiftUI

struct FeedView: View {
    @StateObject private var appState = AppState.shared
    @State private var selectedVenue: Venue?
    @State private var selectedApiVenueId: String = ""
    @State private var showVenueDetail: Bool = false
    @State private var showAgentSheet: Bool = false
    @State private var selectedInvitation: Invitation?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if appState.feedLoadingState.isLoading && appState.feedItems.isEmpty {
                    loadingView
                } else if let error = appState.feedLoadingState.error, appState.feedItems.isEmpty {
                    errorView(error)
                } else {
                    feedContent
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
            .sheet(isPresented: $showAgentSheet) {
                if let venue = selectedVenue {
                    AgentSheetView(
                        venue: venue,
                        apiVenueId: selectedApiVenueId,
                        invitation: selectedInvitation
                    )
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
                }
            }
            .task {
                if appState.feedItems.isEmpty {
                    await appState.initialize()
                }
            }
            .refreshable {
                await appState.refreshFeed()
            }
        }
    }
    
    // MARK: - Feed Content
    @ViewBuilder
    private var feedContent: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(appState.feedItems) { feedItem in
                    VenueReelView(
                        feedItem: feedItem,
                        onSelectVenue: { venue in
                            selectedVenue = venue
                            selectedApiVenueId = feedItem.apiVenueId
                            showVenueDetail = true
                        },
                        onAcceptInvitation: { invitation in
                            selectedInvitation = invitation
                            selectedVenue = feedItem.venue
                            selectedApiVenueId = feedItem.apiVenueId
                            showAgentSheet = true
                        }
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        .background(.black)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(SeleneTheme.moonGlow)
            
            Text("Loading venues...")
                .font(.seleneBody)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SeleneTheme.nightSky)
    }
    
    // MARK: - Error View
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("Couldn't load venues")
                .font(.seleneHeadline)
            
            Text(error.localizedDescription)
                .font(.seleneCaption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await appState.refreshFeed()
                }
            } label: {
                Text("Try Again")
                    .font(.seleneButton)
                    .foregroundStyle(Color.contentPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.primaryButtonColor)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SeleneTheme.nightSky)
    }
}

// MARK: - Page Indicator
struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.contentPrimary : Color.contentPrimary.opacity(0.4))
                    .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Preview
#Preview {
    FeedView()
        .preferredColorScheme(.dark)
}
