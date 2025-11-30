//
//  MainTabView.swift
//  client
//
//  Selene App - Main Tab Navigation
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home
    
    enum Tab: Int, CaseIterable {
        case home
        case profile
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .profile: return "Profile"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house"
            case .profile: return "person"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .profile: return "person.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tag(Tab.home)
                .tabItem {
                    Label(Tab.home.title, systemImage: selectedTab == .home ? Tab.home.selectedIcon : Tab.home.icon)
                }
            
            ProfileView()
                .tag(Tab.profile)
                .tabItem {
                    Label(Tab.profile.title, systemImage: selectedTab == .profile ? Tab.profile.selectedIcon : Tab.profile.icon)
                }
        }
        .tint(SeleneTheme.moonGlow)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AppState.shared)
        .preferredColorScheme(.dark)
}
