//
//  Typography.swift
//  client
//
//  Selene App - Typography Theme
//

import SwiftUI

extension Font {
    // MARK: - Display Fonts
    static let seleneTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let seleneHeadline = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let seleneSubheadline = Font.system(size: 17, weight: .medium, design: .rounded)
    
    // MARK: - Body Fonts
    static let seleneBody = Font.system(size: 16, weight: .regular, design: .default)
    static let seleneBodyMedium = Font.system(size: 16, weight: .medium, design: .default)
    static let seleneBodyBold = Font.system(size: 16, weight: .bold, design: .default)
    
    // MARK: - Caption Fonts
    static let seleneCaption = Font.system(size: 13, weight: .regular, design: .default)
    static let seleneCaptionMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let seleneCaptionBold = Font.system(size: 13, weight: .bold, design: .default)
    
    // MARK: - Small Text
    static let seleneSmall = Font.system(size: 11, weight: .regular, design: .default)
    static let seleneSmallMedium = Font.system(size: 11, weight: .medium, design: .default)
    
    // MARK: - Special Purpose
    static let seleneBadge = Font.system(size: 10, weight: .heavy, design: .rounded)
    static let seleneButton = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let seleneVenueName = Font.system(size: 24, weight: .bold, design: .rounded)
    static let seleneAgentTitle = Font.system(size: 20, weight: .semibold, design: .rounded)
}

// MARK: - Text Style Modifiers
struct SeleneTextStyle: ViewModifier {
    enum Style {
        case venueName
        case venueLocation
        case invitedBadge
        case socialProof
        case agentMessage
        case sectionHeader
    }
    
    let style: Style
    
    func body(content: Content) -> some View {
        switch style {
        case .venueName:
            content
                .font(.seleneVenueName)
                .foregroundColor(Color.contentPrimary)
                .shadow(color: Color.overlayBlack.opacity(0.5), radius: 2, x: 0, y: 1)
                
        case .venueLocation:
            content
                .font(.seleneCaption)
                .foregroundColor(Color.contentSecondary)
                .shadow(color: Color.overlayBlack.opacity(0.3), radius: 1, x: 0, y: 1)
                
        case .invitedBadge:
            content
                .font(.seleneBadge)
                .foregroundColor(Color.contentPrimary)
                .tracking(2)
                
        case .socialProof:
            content
                .font(.seleneSmallMedium)
                .foregroundColor(Color.contentTertiary)
                
        case .agentMessage:
            content
                .font(.seleneBody)
                .foregroundColor(.secondary)
                .italic()
                
        case .sectionHeader:
            content
                .font(.seleneCaptionBold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(1)
        }
    }
}

extension View {
    func seleneTextStyle(_ style: SeleneTextStyle.Style) -> some View {
        modifier(SeleneTextStyle(style: style))
    }
}

