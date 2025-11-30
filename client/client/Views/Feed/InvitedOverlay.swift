//
//  InvitedOverlay.swift
//  client
//
//  Selene App - Invited State Overlay
//

import SwiftUI

// TODO: Remove the padding here so that we use this correctly

struct InvitedOverlay: View {
    let venue: Venue
    let invitation: Invitation
    var onAccept: () -> Void
    var onTapVenue: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            // Gradient scrim
            LinearGradient(
                colors: [
                    .clear,
                    Color.overlayLight,
                    Color.overlayMedium,
                    Color.overlayDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)
            .overlay(alignment: .bottom) {
                overlayContent
            }
        }
    }
    
    private var overlayContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Invited badge
            invitedBadge
            
            // Main content row
            HStack(alignment: .bottom, spacing: 12) {
                // Left side - Venue info and inviter
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
                    
                    // Inviter info
                    inviterRow
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    onTapVenue()
                }
                
                // Right side - Accept button (fixed size)
                AcceptButton(onAccept: onAccept)
                    .layoutPriority(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 60) // Content padding + space for tab bar
    }
    
    private var invitedBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
            Text("INVITED")
                .seleneTextStyle(.invitedBadge)
            Image(systemName: "star.fill")
                .font(.system(size: 10))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(SeleneTheme.accept)
        )
    }
    
    private var inviterRow: some View {
        HStack(spacing: 8) {
            AvatarCircle(user: invitation.inviter, size: 28, showOnlineIndicator: true)
            
                    Text("\(invitation.inviter.name) invited you")
                .font(.seleneCaptionMedium)
                .foregroundStyle(Color.contentSecondary)
        }
        .padding(.top, 4)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        // Mock video background
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.accentIndigo, Color.accentPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        
        InvitedOverlay(
            venue: MockData.blueNote,
            invitation: MockData.sampleInvitation,
            onAccept: { print("Accepted!") },
            onTapVenue: { print("Tapped venue") }
        )
    }
    .ignoresSafeArea()
}

