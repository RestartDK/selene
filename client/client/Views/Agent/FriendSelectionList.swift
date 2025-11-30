//
//  FriendSelectionList.swift
//  client
//
//  Selene App - Friend Selection for Booking
//

import SwiftUI

struct FriendSelectionList: View {
    let interestedFriends: [User]
    let allFriends: [User]
    @Binding var selectedFriends: Set<UUID>
    var onSelectionChange: ((User, Bool) -> Void)?
    
    @State private var searchText: String = ""
    
    // Get interested friend IDs for filtering
    private var interestedFriendIds: Set<UUID> {
        Set(interestedFriends.map { $0.id })
    }
    
    // Filtered friends from all friends (excluding already interested ones)
    private var filteredAllFriends: [User] {
        let friendsNotInterested = allFriends.filter { !interestedFriendIds.contains($0.id) }
        
        if searchText.isEmpty {
            return friendsNotInterested
        }
        
        return friendsNotInterested.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("SELECT WHO TO INVITE")
                .seleneTextStyle(.sectionHeader)
            
            // Interested friends section (pre-selected)
            if !interestedFriends.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interested")
                        .font(.seleneCaptionMedium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        ForEach(interestedFriends) { friend in
                            SelectableFriendRow(
                                user: friend,
                                isSelected: selectedFriends.contains(friend.id)
                            ) {
                                toggleSelection(friend)
                            }
                            
                            if friend.id != interestedFriends.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .background(Color.seleneSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Search section for all friends
            VStack(alignment: .leading, spacing: 8) {
                Text("Search Friends")
                    .font(.seleneCaptionMedium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 0) {
                    // Search row
                    searchRow
                    
                    // Search results
                    if !searchText.isEmpty && !filteredAllFriends.isEmpty {
                        Divider()
                            .padding(.leading, 56)
                        
                        ForEach(filteredAllFriends) { friend in
                            SelectableFriendRow(
                                user: friend,
                                isSelected: selectedFriends.contains(friend.id)
                            ) {
                                toggleSelection(friend)
                            }
                            
                            if friend.id != filteredAllFriends.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    } else if !searchText.isEmpty && filteredAllFriends.isEmpty {
                        Divider()
                            .padding(.leading, 56)
                        
                        HStack(spacing: 12) {
                            Spacer()
                                .frame(width: 44)
                            
                            Text("No friends found")
                                .font(.seleneBody)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 16)
                            
                            Spacer()
                        }
                    }
                }
                .background(Color.seleneSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
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

