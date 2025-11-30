//
//  CustomVideoPlayer.swift
//  client
//
//  Selene App - Custom Video Player for Reels
//

import SwiftUI
import AVKit

struct CustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        // Create the player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill // Crucial for full screen 'Reels' look
        playerLayer.frame = .zero // Will be updated in layoutSubviews
        
        controller.view.layer.addSublayer(playerLayer)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update layer frame on layout changes
        if let layer = uiViewController.view.layer.sublayers?.first as? AVPlayerLayer {
            layer.frame = uiViewController.view.bounds
        }
    }
}

