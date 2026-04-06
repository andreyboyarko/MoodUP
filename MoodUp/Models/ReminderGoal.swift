//
//  ReminderGoal.swift
//  MoodUp
//

import Foundation

enum ReminderGoal: String, Codable, CaseIterable, Identifiable {
    case checkMood
    case improveMood
    case eveningReflection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checkMood: return "Check my mood"
        case .improveMood: return "Improve my mood"
        case .eveningReflection: return "Evening reflection"
        }
    }
}
