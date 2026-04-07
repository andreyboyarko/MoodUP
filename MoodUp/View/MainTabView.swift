//
//  MainTabView.swift
//  MoodUp
//
//  Created by Andrei  Boyarko on 06/04/2026.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme

    init() {
        configureTabBarAppearance()
    }

    var body: some View {
        TabView {
            
            MoodView()
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("Mood")
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            
            InsightsView()
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Insights")
                }
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notifications")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .tint(AppColors.accent(for: colorScheme))
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // 🎨 фон (динамический)
        appearance.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
        
        // Акцент выбранной вкладки: яркий в тёмной теме, приглушённый в светлой
        let accentDynamic = UIColor { traits in
            AppColors.accentUIColor(for: traits)
        }
        appearance.stackedLayoutAppearance.selected.iconColor = accentDynamic
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: accentDynamic
        ]
        
        // ⚫ неактивная
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.gray : UIColor.black
        }
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor.gray : UIColor.black
            }
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
