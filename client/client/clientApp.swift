//
//  clientApp.swift
//  client
//
//  Selene App - Entry Point
//

import SwiftUI

@main
struct SeleneApp: App {
    @StateObject private var appState = AppState.shared
    
    init() {
        // Configure App Transport Security for localhost development
        // This allows HTTP connections to localhost in the simulator
        configureATS()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Initialize app state when app launches
                    Task {
                        await appState.initialize()
                    }
                }
                .alert("Error", isPresented: $appState.showError) {
                    Button("OK") {
                        appState.clearError()
                    }
                } message: {
                    if let error = appState.lastError {
                        Text(error.localizedDescription)
                    }
                }
        }
    }
    
    private func configureATS() {
        // Note: ATS configuration should ideally be in Info.plist
        // This is a workaround for development. In production, use proper Info.plist configuration.
        #if DEBUG
        // For simulator/development, we rely on system defaults which allow localhost
        // If needed, you can add runtime configuration here
        #endif
    }
}
