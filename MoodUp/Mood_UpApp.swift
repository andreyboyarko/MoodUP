//
//  Mood_trackApp.swift
//  Mood track
//
//  Created by Andrei  Boyarko on 06/04/2026.
//

import SwiftUI

@main
struct Mood_UpApp: App {
    @StateObject private var moodStorage = MoodStorageManager()
    @StateObject private var appSettings = AppSettingsStore()
    @StateObject private var profilePhotoStore = ProfilePhotoStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(moodStorage)
                .environmentObject(appSettings)
                .environmentObject(profilePhotoStore)
                .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
                .onAppear {
                    if appSettings.remindersEnabled {
                        LocalNotificationScheduler.schedule(
                            frequency: appSettings.reminderFrequency,
                            goal: appSettings.reminderGoal
                        )
                    }
                }
        }
    }
}
