//
//  Colors.swift
//  client
//
//  Selene App - Color Theme
//

import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors
    static let selenePrimary = Color("selenePrimary")
    static let seleneAccent = Color("seleneAccent")
    static let seleneGold = Color(red: 0.85, green: 0.65, blue: 0.13)
    
    // MARK: - Semantic Colors
    static let seleneBackground = Color(uiColor: .systemBackground)
    static let seleneSecondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let seleneTertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    
    // MARK: - Text Colors
    static let selenePrimaryText = Color(uiColor: .label)
    static let seleneSecondaryText = Color(uiColor: .secondaryLabel)
    static let seleneTertiaryText = Color(uiColor: .tertiaryLabel)
    
    // MARK: - Match Score Colors
    static let matchHigh = Color.green
    static let matchMedium = Color.orange
    static let matchLow = Color.gray
    
    // MARK: - Overlay Colors
    static let overlayBlack = Color.black
    static let overlayLight = Color.black.opacity(0.3)
    static let overlayMedium = Color.black.opacity(0.6)
    static let overlayDark = Color.black.opacity(0.85)
    
    // MARK: - Content Colors (for use on dark backgrounds)
    static let contentPrimary = Color.white
    static let contentSecondary = Color.white.opacity(0.9)
    static let contentTertiary = Color.white.opacity(0.85)
    
    // MARK: - Accent Colors
    static let accentIndigo = Color.indigo
    static let accentPurple = Color.purple
    static let accentBlue = Color.blue
    
    // MARK: - Gradient Overlays
    static var venueOverlayGradient: LinearGradient {
        LinearGradient(
            colors: [
                .clear,
                .clear,
                overlayLight,
                overlayDark,
                overlayDark
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var invitedBadgeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.75, blue: 0.20),
                Color(red: 0.85, green: 0.55, blue: 0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Solid button colors (replacing gradients)
    static var primaryButtonColor: Color {
        Color(red: 0.4, green: 0.3, blue: 0.85) // Solid deep purple
    }
    
    static var goldButtonColor: Color {
        SeleneTheme.accept // Solid gold
    }
    
    // MARK: - Card/Sheet Background Gradients
    static let cardGradientStart = Color(red: 0.3, green: 0.25, blue: 0.45)
    static let cardGradientEnd = Color(red: 0.2, green: 0.15, blue: 0.35)
    
    static let sheetGradientStart = Color(red: 0.2, green: 0.2, blue: 0.35)
    static let sheetGradientEnd = Color(red: 0.15, green: 0.15, blue: 0.25)
    
    static let avatarGradientStart = Color(red: 0.3, green: 0.3, blue: 0.4)
    static let avatarGradientEnd = Color(red: 0.2, green: 0.2, blue: 0.3)
    
    // MARK: - Venue Reel Gradients (array of gradient pairs)
    static let venueReelGradients: [[Color]] = [
        [Color(red: 0.2, green: 0.1, blue: 0.4), Color(red: 0.4, green: 0.2, blue: 0.5)],
        [Color(red: 0.1, green: 0.2, blue: 0.3), Color(red: 0.2, green: 0.3, blue: 0.5)],
        [Color(red: 0.3, green: 0.1, blue: 0.2), Color(red: 0.5, green: 0.2, blue: 0.3)],
        [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.2, blue: 0.4)],
        [Color(red: 0.2, green: 0.2, blue: 0.1), Color(red: 0.4, green: 0.3, blue: 0.2)]
    ]
    
    // MARK: - Saved Venue Card Gradients
    static let savedCardGradients: [[Color]] = [
        [Color(red: 0.25, green: 0.15, blue: 0.35), Color(red: 0.35, green: 0.25, blue: 0.45)],
        [Color(red: 0.15, green: 0.20, blue: 0.30), Color(red: 0.25, green: 0.30, blue: 0.40)],
        [Color(red: 0.30, green: 0.15, blue: 0.20), Color(red: 0.40, green: 0.25, blue: 0.30)],
        [Color(red: 0.20, green: 0.15, blue: 0.25), Color(red: 0.30, green: 0.25, blue: 0.35)]
    ]
}

// MARK: - Selene Theme
struct SeleneTheme {
    // Moon-inspired colors
    static let moonGlow = Color(red: 0.85, green: 0.88, blue: 0.95)
    static let nightSky = Color(red: 0.08, green: 0.08, blue: 0.15)
    static let twilight = Color(red: 0.15, green: 0.12, blue: 0.25)
    static let starlight = Color(red: 0.95, green: 0.95, blue: 1.0)
    static let selene = Color(red: 0.70, green: 0.75, blue: 0.85)
    
    // Action colors
    static let accept = Color(red: 0.95, green: 0.75, blue: 0.20) // Gold
    static let like = Color(red: 0.95, green: 0.30, blue: 0.40)   // Coral red
    static let success = Color(red: 0.30, green: 0.85, blue: 0.50) // Emerald
}

