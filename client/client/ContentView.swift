//
//  ContentView.swift
//  client
//
//  Selene App - Content View (Legacy - redirects to MainTabView)
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
