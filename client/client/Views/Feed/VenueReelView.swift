//
//  VenueReelView.swift
//  client
//
//  Selene App - Single Venue Card in the Feed Reel
//

import SwiftUI
import AVKit

struct VenueReelView: View {
    let feedItem: FeedItem
    var onSelectVenue: (Venue) -> Void
    var onAcceptInvitation: (Invitation) -> Void
    
    @StateObject private var appState = AppState.shared
    @State private var isSaved: Bool = false
    @State private var showVenueDetail: Bool = false
    
    // Video Player State
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    
    // Placeholder gradient colors for video backgrounds
    private var placeholderGradient: [Color] {
        return Color.venueReelGradients[abs(feedItem.venue.name.hashValue) % Color.venueReelGradients.count]
    }
    
    var body: some View {
        ZStack {
            // 1. Video/Image Layer
            if let player = player {
                CustomVideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                // Loading State or no video
                gradientPlaceholder
                    .overlay {
                        if feedItem.venue.videoURL != nil {
                            ProgressView()
                                .tint(.white)
                        }
                    }
            }
            
            // 2. Overlay Content
            if feedItem.isInvited, let invitation = feedItem.invitation {
                InvitedOverlay(
                    venue: feedItem.venue,
                    invitation: invitation,
                    onAccept: {
                        onAcceptInvitation(invitation)
                    },
                    onTapVenue: {
                        onSelectVenue(feedItem.venue)
                    }
                )
            } else {
                VenueInfoOverlay(
                    venue: feedItem.venue,
                    isSaved: $isSaved,
                    onTap: {
                        onSelectVenue(feedItem.venue)
                    },
                    onSaveToggle: { saved in
                        Task {
                            if saved {
                                await appState.heartVenue(feedItem.venue, apiId: feedItem.apiVenueId)
                            } else {
                                await appState.unheartVenue(feedItem.venue, apiId: feedItem.apiVenueId)
                            }
                        }
                    }
                )
            }
        }
        // Lifecycle Management
        .onAppear {
            isSaved = appState.isVenueSaved(apiId: feedItem.apiVenueId)
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    // MARK: - Video Player Setup
    private func setupPlayer() {
        // Only setup if we have a video URL
        guard let videoURL = feedItem.venue.videoURL else { return }
        
        // Avoid recreating player if already exists
        guard player == nil else {
            player?.play()
            return
        }
        
        let playerItem = AVPlayerItem(url: videoURL)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Create Looper for seamless video loop
        looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        self.player = queuePlayer
        queuePlayer.play()
    }
    
    // MARK: - Gradient Placeholder
    private var gradientPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: placeholderGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Venue category icon as visual element
            VStack {
                Text(feedItem.venue.categoryIcon)
                    .font(.system(size: 80))
                    .opacity(0.3)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VenueReelView(
        feedItem: FeedItem(venue: MockData.blueNote, apiVenueId: "blue-note"),
        onSelectVenue: { _ in },
        onAcceptInvitation: { _ in }
    )
    .ignoresSafeArea()
    .preferredColorScheme(.dark)
}
