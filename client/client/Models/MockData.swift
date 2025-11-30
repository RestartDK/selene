//
//  MockData.swift
//  client
//
//  Selene App - Mock Data for Development
//

import Foundation

enum MockData {
    // MARK: - Users
    static let currentUser = User(
        name: "Alex",
        username: "alexvibes",
        avatarEmoji: "😎",
        isOnline: true,
        matchScore: .high
    )
    
    static let meg = User(
        name: "meg",
        username: "megnyc",
        avatarEmoji: "😊",
        isOnline: true,
        matchScore: .high
    )
    
    static let dk = User(
        name: "dk",
        username: "dknight",
        avatarEmoji: "🤙",
        isOnline: false,
        matchScore: .high
    )
    
    static let sam = User(
        name: "Sam",
        username: "samwise",
        avatarEmoji: "🎸",
        isOnline: true,
        matchScore: .medium
    )
    
    static let jordan = User(
        name: "Jordan",
        username: "jcool",
        avatarEmoji: "🌟",
        isOnline: false,
        matchScore: .medium
    )
    
    static let riley = User(
        name: "Riley",
        username: "rileyrave",
        avatarEmoji: "🎨",
        isOnline: true,
        matchScore: .low
    )
    
    // Map to backend user IDs
    static let sarah = User(
        name: "Sarah",
        username: "sarah",
        avatarEmoji: "✨",
        isOnline: true,
        matchScore: .high
    )
    
    static let mike = User(
        name: "Mike",
        username: "mike",
        avatarEmoji: "🔥",
        isOnline: false,
        matchScore: .medium
    )
    
    static let allFriends: [User] = [sarah, mike, meg, dk, sam]
    
    // MARK: - Venues
    static let blueNote = Venue(
        name: "Blue Note Jazz Club",
        category: "Jazz Club",
        vibe: "Intimate & Soulful",
        location: "Greenwich Village",
        distance: "0.8 mi",
        description: "Legendary jazz venue featuring world-class musicians in an intimate setting. Dark wood interiors, candlelit tables, and the finest cocktails accompany nightly live performances.",
        heroImageName: "bluenote",
        videoURL: URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1170&h=2532&fit=crop&crop=center"),
        interestedFriends: [sarah, mike]
    )
    
    static let rooftop99 = Venue(
        name: "Rooftop 99",
        category: "Rooftop Bar",
        vibe: "Vibrant & Scenic",
        location: "Midtown",
        distance: "1.2 mi",
        description: "Stunning panoramic views of the city skyline from 40 floors up. Craft cocktails, small plates, and a chic crowd make this the hottest sunset spot in town.",
        heroImageName: "rooftop",
        videoURL: URL(string: "https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=1170&h=2532&fit=crop&crop=center"),
        interestedFriends: [sarah]
    )
    
    static let omenCoffee = Venue(
        name: "Omen Coffee",
        category: "Coffee Shop",
        vibe: "Minimalist & Cozy",
        location: "SoHo",
        distance: "0.5 mi",
        description: "A serene escape from the city bustle. Japanese-inspired minimalist design, single-origin pour-overs, and house-made matcha treats. Perfect for focused work or quiet conversations.",
        heroImageName: "coffee",
        videoURL: URL(string: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=1170&h=2532&fit=crop&crop=center"),
        interestedFriends: [mike]
    )
    
    static let noirBar = Venue(
        name: "Noir Bar",
        category: "Bar",
        vibe: "Mysterious",
        location: "SoHo",
        distance: "0.6 mi",
        description: "Hidden speakeasy with prohibition-era cocktails and live jazz on weekends. Password required for entry.",
        heroImageName: "noir",
        interestedFriends: [sarah, mike]
    )
    
    static let velvetLounge = Venue(
        name: "Velvet Lounge",
        category: "Club",
        vibe: "Electric",
        location: "Meatpacking",
        distance: "1.5 mi",
        description: "Underground electronic music venue with world-class DJs and immersive light installations.",
        heroImageName: "velvet",
        interestedFriends: [sam]
    )
    
    static let sakuraBistro = Venue(
        name: "Sakura Bistro",
        category: "Restaurant",
        vibe: "Elegant",
        location: "Upper East Side",
        distance: "2.1 mi",
        description: "Modern Japanese cuisine in a serene setting. Omakase experience with seasonal ingredients flown in from Tokyo.",
        heroImageName: "sakura",
        interestedFriends: [sarah]
    )
    
    static let allVenues: [Venue] = [blueNote, rooftop99, omenCoffee, noirBar, velvetLounge, sakuraBistro]
    
    // MARK: - Invitations
    static let sampleInvitation = Invitation(
        venue: blueNote,
        inviter: sarah,
        invitedAt: Date(),
        status: .pending,
        scheduledTime: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())
    )
}
