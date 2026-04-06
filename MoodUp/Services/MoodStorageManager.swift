//
//  MoodStorageManager.swift
//  MoodUp
//

import Foundation
import SwiftUI
import Combine

private let entriesKey = "moodup.moodEntries"
private let lastSleepKey = "moodup.lastSleepQuality"
private let lastEnergyKey = "moodup.lastEnergyLevel"

@MainActor
final class MoodStorageManager: ObservableObject {
    @Published private(set) var entries: [MoodEntry] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func load() {
        guard let data = defaults.data(forKey: entriesKey) else {
            entries = []
            return
        }
        do {
            entries = try JSONDecoder().decode([MoodEntry].self, from: data)
        } catch {
            entries = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(entries)
            defaults.set(data, forKey: entriesKey)
        } catch {
            assertionFailure("Mood encode failed: \(error)")
        }
    }

    /// Latest insight values (from Insights tab) get copied into the next mood entry.
    func saveMood(_ mood: Mood) {
        let sleep = SleepQuality(rawValue: defaults.string(forKey: lastSleepKey) ?? "")
        let energy = EnergyLevel(rawValue: defaults.string(forKey: lastEnergyKey) ?? "")
        let entry = MoodEntry(
            mood: mood,
            date: Date(),
            sleepQuality: sleep,
            energyLevel: energy
        )
        entries.insert(entry, at: 0)
        persist()
    }

    func latestEntry() -> MoodEntry? {
        entries.max(by: { $0.date < $1.date })
    }

    func resetAllEntries() {
        entries = []
        defaults.removeObject(forKey: entriesKey)
    }

    func entriesInLastDays(_ days: Int) -> [MoodEntry] {
        guard let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else {
            return entries
        }
        return entries.filter { $0.date >= start }
    }

    func weeklyMoodCounts() -> [(Mood, Int)] {
        let week = entriesInLastDays(7)
        var counts: [Mood: Int] = [:]
        for m in Mood.allCases {
            counts[m] = 0
        }
        for e in week {
            counts[e.mood, default: 0] += 1
        }
        return Mood.allCases.map { ($0, counts[$0] ?? 0) }
    }

    func mostFrequentMood() -> Mood? {
        guard !entries.isEmpty else { return nil }
        var counts: [Mood: Int] = [:]
        for e in entries {
            counts[e.mood, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
