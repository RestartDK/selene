//
//  LikeButton.swift
//  client
//
//  Selene App - Heart/Like Button Component
//

import SwiftUI

struct LikeButton: View {
    @Binding var isLiked: Bool
    var size: CGFloat = 48
    var onTap: (() -> Void)?
    
    @State private var animationScale: CGFloat = 1.0
    @State private var showParticles: Bool = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isLiked.toggle()
                animationScale = isLiked ? 1.3 : 0.8
            }
            
            // Trigger haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Show particles on like
            if isLiked {
                showParticles = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showParticles = false
                }
            }
            
            // Reset scale
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    animationScale = 1.0
                }
            }
            
            onTap?()
        } label: {
            ZStack {
                // Background blur
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)
                
                // Heart icon
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundStyle(isLiked ? SeleneTheme.like : Color.contentPrimary)
                    .scaleEffect(animationScale)
                
                // Particle effect
                if showParticles {
                    ParticleEffect()
                        .frame(width: size * 1.5, height: size * 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Particle Effect
struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        var scale: CGFloat
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(SeleneTheme.like)
                    .frame(width: 6, height: 6)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .offset(x: particle.x, y: particle.y)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let particle = Particle(x: 0, y: 0, opacity: 1, scale: 1)
            particles.append(particle)
            
            withAnimation(.easeOut(duration: 0.5)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].x = CGFloat(cos(angle)) * 30
                    particles[index].y = CGFloat(sin(angle)) * 30
                    particles[index].opacity = 0
                    particles[index].scale = 0.3
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.overlayBlack
        
        VStack(spacing: 30) {
            LikeButton(isLiked: .constant(false))
            LikeButton(isLiked: .constant(true))
        }
    }
}

