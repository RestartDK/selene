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
        guard let videoURL = feedItem.venue.videoURL else {
            print("⚠️ No video URL for venue: \(feedItem.venue.name)")
            return
        }
        
        print("🎥 Setting up video player with URL: \(videoURL.absoluteString)")
        
        // Avoid recreating player if already exists
        guard player == nil else {
            player?.play()
            return
        }
        
        // Create player item with better configuration for HTTP streaming
        let playerItem = AVPlayerItem(url: videoURL)
        
        // Enable automatic waiting for network resources
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        
        // Observe player item ready to play
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewErrorLogEntry,
            object: playerItem,
            queue: .main
        ) { _ in
            print("📋 Video log entry")
        }
        
        // Observe when item becomes ready
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            print("✅ Video played to end: \(videoURL.lastPathComponent)")
        }
        
        // Observe failed playback notifications
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { notification in
            if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                print("❌ Video failed to play to end: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("   Error domain: \(nsError.domain), code: \(nsError.code)")
                }
            }
        }
        
        // Observe playback stall notifications
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemPlaybackStalled,
            object: playerItem,
            queue: .main
        ) { _ in
            print("⏸️ Video playback stalled")
        }
        
        // Check status after a short delay to log initial state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch playerItem.status {
            case .readyToPlay:
                print("✅ Video ready to play: \(videoURL.lastPathComponent)")
            case .failed:
                if let error = playerItem.error {
                    print("❌ Video playback failed: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("   Error domain: \(nsError.domain), code: \(nsError.code)")
                        print("   User info: \(nsError.userInfo)")
                    }
                }
            case .unknown:
                print("⏳ Video status unknown, still loading...")
            @unknown default:
                print("⚠️ Unknown video status")
            }
        }
        
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
