//
//  FriendSelectionList.swift
//  client
//
//  Selene App - Friend Selection for Booking
//

import SwiftUI

struct FriendSelectionList: View {
    let availableFriends: [User]
    @Binding var selectedFriends: Set<UUID>
    var onSelectionChange: ((User, Bool) -> Void)?
    
    @State private var searchText: String = ""
    
    private var filteredFriends: [User] {
        if searchText.isEmpty {
            return availableFriends
        }
        return availableFriends.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("SELECT WHO TO INVITE")
                .seleneTextStyle(.sectionHeader)
            
            // Friend list
            VStack(spacing: 0) {
                ForEach(filteredFriends) { friend in
                    SelectableFriendRow(
                        user: friend,
                        isSelected: selectedFriends.contains(friend.id)
                    ) {
                        toggleSelection(friend)
                    }
                    
                    if friend.id != filteredFriends.last?.id {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
                
                // Search row
                Divider()
                    .padding(.leading, 56)
                searchRow
            }
            .background(Color.seleneSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var searchRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.seleneTertiaryBackground)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            
            TextField("Search for others...", text: $searchText)
                .font(.seleneBody)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func toggleSelection(_ user: User) {
        let wasSelected = selectedFriends.contains(user.id)
        
        if wasSelected {
            selectedFriends.remove(user.id)
        } else {
            selectedFriends.insert(user.id)
        }
        
        onSelectionChange?(user, !wasSelected)
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Selectable Friend Row
struct SelectableFriendRow: View {
    let user: User
    let isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primaryButtonColor)
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                // Avatar
                AvatarCircle(user: user, size: 44, showOnlineIndicator: true)
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.seleneBodyMedium)
                        .foregroundStyle(.primary)
                    
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
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var matchScoreColor: Color {
        switch user.matchScore {
        case .high: return Color.matchHigh
        case .medium: return Color.matchMedium
        case .low: return Color.matchLow
        }
    }
}

// MARK: - Preview
#Preview {
    FriendSelectionList(
        availableFriends: MockData.allFriends,
        selectedFriends: .constant([MockData.meg.id, MockData.dk.id])
    )
    .padding()
    .preferredColorScheme(.dark)
}
