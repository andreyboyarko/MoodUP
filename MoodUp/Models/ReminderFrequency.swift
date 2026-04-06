//
//  ReminderFrequency.swift
//  MoodUp
//

import Foundation

enum ReminderFrequency: String, Codable, CaseIterable, Identifiable {
    case onceADay
    case twiceADay
    case eveningOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .onceADay: return "Once a day"
        case .twiceADay: return "Twice a day"
        case .eveningOnly: return "Evening only"
        }
    }
}
