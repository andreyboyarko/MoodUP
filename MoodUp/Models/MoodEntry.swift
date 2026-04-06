//
//  MoodEntry.swift
//  MoodUp
//

import Foundation

struct MoodEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var mood: Mood
    var date: Date
    var sleepQuality: SleepQuality?
    var energyLevel: EnergyLevel?

    init(
        id: UUID = UUID(),
        mood: Mood,
        date: Date = Date(),
        sleepQuality: SleepQuality? = nil,
        energyLevel: EnergyLevel? = nil
    ) {
        self.id = id
        self.mood = mood
        self.date = date
        self.sleepQuality = sleepQuality
        self.energyLevel = energyLevel
    }
}
