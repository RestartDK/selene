//
//  SavedPlacesGrid.swift
//  client
//
//  Selene App - Grid of Saved/Interested Venues
//

import SwiftUI

struct SavedPlacesGrid: View {
    let venues: [Venue]
    var onSelectVenue: (Venue) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Saved Places")
                .font(.seleneHeadline)
                .foregroundStyle(.primary)
            
            if venues.isEmpty {
                emptyState
            } else {
                // Grid of venue cards
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(venues) { venue in
                        SavedVenueCard(venue: venue) {
                            onSelectVenue(venue)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            
            Text("No saved places yet")
                .font(.seleneBody)
                .foregroundStyle(.secondary)
            
            Text("Swipe through the feed and tap ♡ to save venues you're interested in")
                .font(.seleneCaption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}


