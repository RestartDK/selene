//
//  AcceptButton.swift
//  client
//
//  Selene App - Accept Invitation Button
//

import SwiftUI

struct AcceptButton: View {
    var onAccept: () -> Void
    var size: CGSize = CGSize(width: 80, height: 36)
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            onAccept()
        } label: {
            Text("ACCEPT")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .tracking(1)
                .frame(width: size.width, height: size.height)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(SeleneTheme.accept)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.overlayBlack.opacity(0.8)
        
        AcceptButton {
            print("Accepted!")
        }
    }
}

