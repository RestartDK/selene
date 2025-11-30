//
//  Venue.swift
//  client
//
//  Selene App - Venue Model
//

import Foundation

struct Venue: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String
    let vibe: String
    let location: String
    let distance: String
    let description: String
    let heroImageName: String
    let videoURL: URL?
    var interestedFriends: [User]
    var isSaved: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        vibe: String,
        location: String,
        distance: String,
        description: String,
        heroImageName: String = "venue_placeholder",
        videoURL: URL? = nil,
        interestedFriends: [User] = [],
        isSaved: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.vibe = vibe
        self.location = location
        self.distance = distance
        self.description = description
        self.heroImageName = heroImageName
        self.videoURL = videoURL
        self.interestedFriends = interestedFriends
        self.isSaved = isSaved
    }
    
    // Computed property to get a color for the venue based on category
    var categoryIcon: String {
        switch category.lowercased() {
        case "live music", "jazz club": return "🎵"
        case "restaurant": return "🍽️"
        case "bar", "rooftop bar": return "🍸"
        case "coffee", "coffee shop": return "☕"
        case "rooftop": return "🌆"
        case "club": return "🪩"
        default: return "📍"
        }
    }
    
    // Hash only by id for Set operations
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.id == rhs.id
    }
}
