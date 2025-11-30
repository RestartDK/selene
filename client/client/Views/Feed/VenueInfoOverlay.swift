//
//  VenueInfoOverlay.swift
//  client
//
//  Selene App - Normal State Venue Info Overlay
//

import SwiftUI

struct VenueInfoOverlay: View {
    let venue: Venue
    @Binding var isSaved: Bool
    var onTap: () -> Void
    var onSaveToggle: ((Bool) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            // Gradient scrim
            LinearGradient(
                colors: [
                    .clear,
                    Color.overlayBlack.opacity(0.4),
                    Color.overlayDark,
                    Color.overlayDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .overlay(alignment: .bottom) {
                overlayContent
            }
        }
    }
    
    private var overlayContent: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Left side - Venue info
            VStack(alignment: .leading, spacing: 8) {
                // Venue name
                Text(venue.name)
                    .seleneTextStyle(.venueName)
                    .lineLimit(2)
                
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                    Text(venue.location)
                }
                .seleneTextStyle(.venueLocation)
                .lineLimit(1)
                
                // Face pile
                if !venue.interestedFriends.isEmpty {
                    FacePileView(users: venue.interestedFriends)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                onTap()
            }
            
            // Right side - Like button (fixed size)
            LikeButton(isLiked: $isSaved) {
                onSaveToggle?(isSaved)
            }
            .layoutPriority(1)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        // Mock video background
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.accentPurple, Color.accentBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        
        VenueInfoOverlay(
            venue: MockData.blueNote,
            isSaved: .constant(false),
            onTap: {
                print("Tapped venue")
            },
            onSaveToggle: { saved in
                print("Save toggled: \(saved)")
            }
        )
    }
    .ignoresSafeArea()
    .preferredColorScheme(.dark)
}
