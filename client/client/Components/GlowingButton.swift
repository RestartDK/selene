//
//  GlowingButton.swift
//  client
//
//  Selene App - Glowing Action Button Component
//

import SwiftUI

struct GlowingButton: View {
    let title: String
    let icon: String?
    let style: ButtonVariant
    let action: () -> Void
    
    enum ButtonVariant {
        case primary    // Solid purple
        case gold       // Solid gold
        case secondary  // Outlined style
        case ghost      // Transparent with border
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color.primaryButtonColor
            case .gold:
                return SeleneTheme.accept // Solid gold
            case .secondary:
                return Color.seleneSecondaryBackground
            case .ghost:
                return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .gold: return Color.contentPrimary
            case .secondary: return .primary
            case .ghost: return .secondary
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonVariant = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text(title)
                    .font(.seleneButton)
            }
            .foregroundStyle(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(overlayBorder)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        style.backgroundColor
    }
    
    @ViewBuilder
    private var overlayBorder: some View {
        switch style {
        case .secondary:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        case .ghost:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        default:
            EmptyView()
        }
    }
}

// MARK: - Dual Button Row
struct DualButtonRow: View {
    let leftTitle: String
    let leftIcon: String?
    let leftAction: () -> Void
    
    let rightTitle: String
    let rightIcon: String?
    let rightAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            GlowingButton(leftTitle, icon: leftIcon, style: .secondary, action: leftAction)
            GlowingButton(rightTitle, icon: rightIcon, style: .primary, action: rightAction)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        GlowingButton("Book & Invite", icon: "sparkles", style: .gold) {}
        
        GlowingButton("Let's Go", icon: "arrow.right", style: .primary) {}
        
        GlowingButton("Save", icon: "heart", style: .secondary) {}
        
        GlowingButton("Cancel", style: .ghost) {}
        
        DualButtonRow(
            leftTitle: "Save",
            leftIcon: "heart",
            leftAction: {},
            rightTitle: "Let's Go",
            rightIcon: "arrow.right",
            rightAction: {}
        )
        .padding(.horizontal)
    }
    .padding()
}

