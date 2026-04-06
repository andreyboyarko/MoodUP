//
//  MainTabView.swift
//  MoodUp
//
//  Created by Andrei  Boyarko on 06/04/2026.
//

import SwiftUI

struct MainTabView: View {
    
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
        .tint(AppColors.accent)
    }
    
    private func configureTabBarAppearance() {
        
        let neonColor = UIColor(red: 163/255, green: 255/255, blue: 18/255, alpha: 1)
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // 🎨 фон (динамический)
        appearance.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
        
        // 🟢 активная иконка
        appearance.stackedLayoutAppearance.selected.iconColor = neonColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: neonColor
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
