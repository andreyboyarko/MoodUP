//
//  SleepQuality.swift
//  MoodUp
//

import Foundation

enum SleepQuality: String, Codable, CaseIterable, Identifiable {
    case great
    case okay
    case bad

    var id: String { rawValue }

    var title: String {
        switch self {
        case .great: return "Great"
        case .okay: return "Okay"
        case .bad: return "Bad"
        }
    }
}
