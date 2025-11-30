//
//  FacePileView.swift
//  client
//
//  Selene App - Face Pile Component showing interested friends
//

import SwiftUI

struct FacePileView: View {
    let users: [User]
    let maxVisible: Int
    var avatarSize: CGFloat = 24
    var overlap: CGFloat = 8
    
    init(users: [User], maxVisible: Int = 3, avatarSize: CGFloat = 24) {
        self.users = users
        self.maxVisible = maxVisible
        self.avatarSize = avatarSize
        self.overlap = avatarSize / 3
    }
    
    private var visibleUsers: [User] {
        Array(users.prefix(maxVisible))
    }
    
    private var remainingCount: Int {
        max(0, users.count - maxVisible)
    }
    
    private var displayText: String {
        let names = visibleUsers.map { $0.name.lowercased() }
        
        if names.isEmpty {
            return ""
        } else if names.count == 1 {
            return "\(names[0]) likes this"
        } else if remainingCount > 0 {
            return "\(names.joined(separator: ", ")) +\(remainingCount) like this"
        } else {
            let allButLast = names.dropLast().joined(separator: ", ")
            let last = names.last ?? ""
            return "\(allButLast), \(last) like this"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Avatar stack
            HStack(spacing: -overlap) {
                ForEach(Array(visibleUsers.enumerated()), id: \.element.id) { index, user in
                    AvatarCircle(user: user, size: avatarSize)
                        .zIndex(Double(visibleUsers.count - index))
                }
                
                // +N indicator
                if remainingCount > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.overlayMedium)
                            .frame(width: avatarSize, height: avatarSize)
                        
                        Circle()
                            .stroke(Color.contentPrimary.opacity(0.3), lineWidth: 1)
                            .frame(width: avatarSize, height: avatarSize)
                        
                        Text("+\(remainingCount)")
                            .font(.system(size: avatarSize * 0.4, weight: .semibold))
                            .foregroundColor(Color.contentPrimary)
                    }
                }
            }
            
            // Text description
            Text(displayText)
                .seleneTextStyle(.socialProof)
        }
    }
}

// MARK: - Avatar Circle
struct AvatarCircle: View {
    let user: User
    var size: CGFloat = 24
    var showOnlineIndicator: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.avatarGradientStart,
                                Color.avatarGradientEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                Circle()
                    .stroke(Color.contentPrimary.opacity(0.3), lineWidth: 1)
                    .frame(width: size, height: size)
                
                // Display image if available, otherwise emoji
                if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: size * 0.6, height: size * 0.6)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: size, height: size)
                                .clipShape(Circle())
                        case .failure:
                            Text(user.avatarEmoji)
                                .font(.system(size: size * 0.5))
                        @unknown default:
                            Text(user.avatarEmoji)
                                .font(.system(size: size * 0.5))
                        }
                    }
                } else {
                    Text(user.avatarEmoji)
                        .font(.system(size: size * 0.5))
                }
            }
            
            // Online indicator
            if showOnlineIndicator && user.isOnline {
                Circle()
                    .fill(Color.matchHigh)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .overlay(
                        Circle()
                            .stroke(Color.contentPrimary, lineWidth: 1.5)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }
}


