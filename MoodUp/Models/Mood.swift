//
//  Mood.swift
//  MoodUp
//

import SwiftUI

enum MoodValence: Equatable {
    case positive
    case neutral
    case negative
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case great
    case good
    case calm
    case okay
    case tired
    case stressed

    var id: String { rawValue }

    var valence: MoodValence {
        switch self {
        case .great, .good, .calm: return .positive
        case .okay: return .neutral
        case .tired, .stressed: return .negative
        }
    }

    var title: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .calm: return "Calm"
        case .okay: return "Okay"
        case .tired: return "Tired"
        case .stressed: return "Stressed"
        }
    }

    var systemImage: String {
        switch self {
        case .great: return "face.smiling.fill"
        case .good: return "face.smiling"
        case .calm: return "leaf.fill"
        case .okay: return "face.smiling"
        case .tired: return "moon.zzz.fill"
        case .stressed: return "exclamationmark.triangle.fill"
        }
    }

    var emoji: String {
        switch self {
        case .great: return "🤩"
        case .good: return "🙂"
        case .calm: return "😌"
        case .okay: return "😐"
        case .tired: return "😴"
        case .stressed: return "😣"
        }
    }

    func accentTint(for scheme: ColorScheme) -> Color {
        switch self {
        case .great: return AppColors.accent(for: scheme)
        case .good: return AppColors.accent(for: scheme).opacity(0.9)
        case .calm: return Color.mint.opacity(0.85)
        case .okay: return Color.yellow.opacity(0.85)
        case .tired: return Color.blue.opacity(0.7)
        case .stressed: return Color.orange.opacity(0.85)
        }
    }
}
