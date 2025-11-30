//
//  SavedVenueCard.swift
//  client
//
//  Selene App - Card for Saved Venues in Profile Grid
//

import SwiftUI

struct SavedVenueCard: View {
    let venue: Venue
    var onTap: () -> Void
    
    // Gradient colors based on venue
    private var cardGradient: [Color] {
        return Color.savedCardGradients[abs(venue.name.hashValue) % Color.savedCardGradients.count]
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image placeholder
                ZStack {
                    LinearGradient(
                        colors: cardGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Text(venue.categoryIcon)
                        .font(.system(size: 36))
                        .opacity(0.6)
                }
                .aspectRatio(1.0, contentMode: .fill)
                .clipped()
                
                // Venue name
                VStack(alignment: .leading, spacing: 4) {
                    Text(venue.name)
                        .font(.seleneCaptionBold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(venue.location)
                        .font(.seleneSmall)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.seleneSecondaryBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.overlayBlack.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}


