//
//  LocalNotificationScheduler.swift
//  MoodUp
//

import Foundation
import UserNotifications

enum LocalNotificationScheduler {
    static func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func schedule(frequency: ReminderFrequency, goal: ReminderGoal) {
        cancelAll()
        let content = UNMutableNotificationContent()
        content.title = "MoodUp"
        content.body = notificationBody(for: goal)
        content.sound = .default

        let hours: [Int]
        switch frequency {
        case .onceADay:
            hours = [9]
        case .twiceADay:
            hours = [9, 20]
        case .eveningOnly:
            hours = [20]
        }

        for (index, hour) in hours.enumerated() {
            var components = DateComponents()
            components.hour = hour
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "moodup.reminder.\(index)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    private static func notificationBody(for goal: ReminderGoal) -> String {
        switch goal {
        case .checkMood:
            return "How are you feeling right now? Log your mood in MoodUp."
        case .improveMood:
            return "Take a mindful moment — open MoodUp and check in with yourself."
        case .eveningReflection:
            return "Wind down with a quick evening reflection in MoodUp."
        }
    }
}
