//
//  AppSettingsStore.swift
//  MoodUp
//

import SwiftUI
import Combine

private let lastSleepKey = "moodup.lastSleepQuality"
private let lastEnergyKey = "moodup.lastEnergyLevel"

@MainActor
final class AppSettingsStore: ObservableObject {
    @Published var darkModeEnabled: Bool
    @Published var remindersEnabled: Bool
    @Published var reminderFrequency: ReminderFrequency
    @Published var reminderGoal: ReminderGoal
    @Published var userName: String
    @Published var sleepQuality: SleepQuality?
    @Published var energyLevel: EnergyLevel?

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if defaults.object(forKey: Keys.darkMode) == nil {
            darkModeEnabled = true
        } else {
            darkModeEnabled = defaults.bool(forKey: Keys.darkMode)
        }

        remindersEnabled = defaults.bool(forKey: Keys.reminders)
        if let raw = defaults.string(forKey: Keys.reminderFrequency), let f = ReminderFrequency(rawValue: raw) {
            reminderFrequency = f
        } else {
            reminderFrequency = .onceADay
        }
        if let raw = defaults.string(forKey: Keys.reminderGoal), let g = ReminderGoal(rawValue: raw) {
            reminderGoal = g
        } else {
            reminderGoal = .checkMood
        }
        userName = defaults.string(forKey: Keys.userName) ?? "Andrei"

        if let s = defaults.string(forKey: lastSleepKey), let q = SleepQuality(rawValue: s) {
            sleepQuality = q
        } else {
            sleepQuality = nil
        }
        if let s = defaults.string(forKey: lastEnergyKey), let e = EnergyLevel(rawValue: s) {
            energyLevel = e
        } else {
            energyLevel = nil
        }
    }

    private enum Keys {
        static let darkMode = "moodup.darkMode"
        static let reminders = "moodup.remindersEnabled"
        static let reminderFrequency = "moodup.reminderFrequency"
        static let reminderGoal = "moodup.reminderGoal"
        static let userName = "moodup.userName"
    }

    func setDarkMode(_ value: Bool) {
        darkModeEnabled = value
        defaults.set(value, forKey: Keys.darkMode)
    }

    func setReminderFrequency(_ value: ReminderFrequency) {
        reminderFrequency = value
        defaults.set(value.rawValue, forKey: Keys.reminderFrequency)
        if remindersEnabled {
            LocalNotificationScheduler.schedule(frequency: value, goal: reminderGoal)
        }
    }

    func setReminderGoal(_ value: ReminderGoal) {
        reminderGoal = value
        defaults.set(value.rawValue, forKey: Keys.reminderGoal)
        if remindersEnabled {
            LocalNotificationScheduler.schedule(frequency: reminderFrequency, goal: value)
        }
    }

    /// Turns reminders on (requests system permission) or off and syncs local notifications.
    func userRequestedReminders(_ enabled: Bool) {
        if !enabled {
            remindersEnabled = false
            defaults.set(false, forKey: Keys.reminders)
            LocalNotificationScheduler.cancelAll()
            return
        }
        LocalNotificationScheduler.requestAuthorizationIfNeeded { [weak self] granted in
            Task { @MainActor in
                guard let self else { return }
                if granted {
                    self.remindersEnabled = true
                    self.defaults.set(true, forKey: Keys.reminders)
                    LocalNotificationScheduler.schedule(frequency: self.reminderFrequency, goal: self.reminderGoal)
                } else {
                    self.remindersEnabled = false
                    self.defaults.set(false, forKey: Keys.reminders)
                }
            }
        }
    }

    func setUserName(_ newValue: String) {
        userName = newValue
        defaults.set(newValue, forKey: Keys.userName)
    }

    func persistInsightSelection(sleep: SleepQuality?, energy: EnergyLevel?) {
        sleepQuality = sleep
        energyLevel = energy
        if let sleep {
            defaults.set(sleep.rawValue, forKey: lastSleepKey)
        } else {
            defaults.removeObject(forKey: lastSleepKey)
        }
        if let energy {
            defaults.set(energy.rawValue, forKey: lastEnergyKey)
        } else {
            defaults.removeObject(forKey: lastEnergyKey)
        }
    }
}
