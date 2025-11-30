//
//  InterestedFriendRow.swift
//  client
//
//  Selene App - Friend Row in Venue Detail
//

import SwiftUI

struct InterestedFriendRow: View {
    let user: User
    var showMatchScore: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AvatarCircle(user: user, size: 44, showOnlineIndicator: true)
            
            // Name and status
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.seleneBodyMedium)
                    .foregroundStyle(.primary)
                
                if showMatchScore {
                    HStack(spacing: 6) {
                        Text(user.matchScore.rawValue)
                            .font(.seleneSmall)
                            .foregroundStyle(matchScoreColor)
                        
                        if user.isOnline {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.matchHigh)
                                    .frame(width: 6, height: 6)
                                Text("Online now")
                                    .font(.seleneSmall)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Chevron for navigation hint
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private var matchScoreColor: Color {
        switch user.matchScore {
        case .high: return Color.matchHigh
        case .medium: return Color.matchMedium
        case .low: return Color.matchLow
        }
    }
}

// MARK: - More Mutuals Row
struct MoreMutualsRow: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Stacked indicator
            ZStack {
                Circle()
                    .fill(Color.seleneTertiaryBackground)
                    .frame(width: 44, height: 44)
                
                Text("+\(count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            
            Text("\(count) more mutuals")
                .font(.seleneBody)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    VStack {
        InterestedFriendRow(user: MockData.meg)
        Divider()
        InterestedFriendRow(user: MockData.dk)
        Divider()
        MoreMutualsRow(count: 5)
    }
    .padding()
}

