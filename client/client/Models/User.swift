//
//  User.swift
//  client
//
//  Selene App - User Model
//

import Foundation

struct User: Identifiable, Hashable {
    let id: UUID
    let name: String
    let username: String
    let avatarEmoji: String
    let avatarUrl: String?
    var isOnline: Bool
    var matchScore: MatchScore
    
    enum MatchScore: String, CaseIterable {
        case high = "High Match"
        case medium = "Medium Match"
        case low = "Low Match"
        
        var color: String {
            switch self {
            case .high: return "matchHigh"
            case .medium: return "matchMedium"
            case .low: return "matchLow"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        username: String,
        avatarEmoji: String = "😊",
        avatarUrl: String? = nil,
        isOnline: Bool = false,
        matchScore: MatchScore = .medium
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarEmoji = avatarEmoji
        self.avatarUrl = avatarUrl
        self.isOnline = isOnline
        self.matchScore = matchScore
    }
}

