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
}
