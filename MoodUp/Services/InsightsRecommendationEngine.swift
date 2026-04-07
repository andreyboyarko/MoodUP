//
//  InsightsRecommendationEngine.swift
//  MoodUp
//

import Foundation

enum InsightsRecommendationEngine {
    static func recommendation(sleep: SleepQuality?, energy: EnergyLevel?) -> String {
        guard let sleep, let energy else {
            return "Select how you slept and your energy level to see a personalized tip."
        }

        if sleep == .bad, energy == .low {
            return "You may need more rest today. Try to slow down and avoid overload."
        }
        if sleep == .great, energy == .high {
            return "You seem energized today. This may be a good time for focused tasks."
        }
        if sleep == .bad || energy == .low {
            return "Your body may be asking for recovery. Prioritize hydration, short breaks, and gentle movement."
        }
        if sleep == .great, energy == .medium {
            return "You have a solid baseline today. Channel it into one meaningful task you can finish."
        }
        if sleep == .okay, energy == .high {
            return "Balanced sleep with high energy — a good window for creative or social tasks."
        }
        if sleep == .okay, energy == .medium {
            return "Balanced energy is a good moment for planning and steady progress."
        }
        if sleep == .great, energy == .low {
            return "Even with good sleep, energy can dip. Try a short walk or light stretch to reset."
        }
        if sleep == .okay, energy == .low {
            return "Keep tasks small and celebrate quick wins — momentum builds from there."
        }
        return "Listen to your rhythm today: small consistent steps beat forcing intensity."
    }

    /// Simple heuristic when enough mood + sleep data exists.
    static func optionalDataInsight(entries: [MoodEntry]) -> String? {
        guard entries.count >= 3 else { return nil }
        let withSleep = entries.filter { $0.sleepQuality != nil }
        guard withSleep.count >= 2 else { return nil }

        let tiredBadSleep = withSleep.filter { $0.mood == .tired && $0.sleepQuality == .bad }.count
        if tiredBadSleep >= 2 {
            return "You often feel tired on days with poor sleep."
        }

        let stressedLowEnergy = withSleep.filter { $0.mood == .stressed && $0.energyLevel == .low }.count
        if stressedLowEnergy >= 2 {
            return "Stress shows up more when your energy is low — short resets may help."
        }

        return nil
    }

    /// Короткий контекст по числу записей за сегодня (календарный день).
    static func todayActivityMessage(logCount: Int) -> String? {
        guard logCount > 0 else { return nil }
        if logCount == 1 { return "You've logged 1 mood today." }
        return "You've logged \(logCount) moods today."
    }
}
