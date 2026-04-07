//
//  MoodStorageManager.swift
//  MoodUp
//

import Foundation
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

    private var calendar: Calendar { Calendar.current }

    func entriesInLastDays(_ days: Int) -> [MoodEntry] {
        guard let start = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return entries
        }
        return entries.filter { $0.date >= start }
    }

    /// Все записи за календарный день (`dayStart` = `startOfDay`).
    func entries(on dayStart: Date) -> [MoodEntry] {
        let start = calendar.startOfDay(for: dayStart)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        return entries.filter { $0.date >= start && $0.date < end }
    }

    /// Записи за сегодня.
    func entriesToday() -> [MoodEntry] {
        entries(on: Date())
    }

    /// Словарь день → записи за интервал [rangeStart, rangeEnd] включительно по дням.
    func entriesGroupedByDay(from rangeStart: Date, to rangeEnd: Date) -> [Date: [MoodEntry]] {
        let rs = calendar.startOfDay(for: rangeStart)
        let re = calendar.startOfDay(for: rangeEnd)
        var dict: [Date: [MoodEntry]] = [:]
        for e in entries {
            let d = e.dayStart
            guard d >= rs && d <= re else { continue }
            dict[d, default: []].append(e)
        }
        for k in dict.keys {
            dict[k]?.sort { $0.date < $1.date }
        }
        return dict
    }

    /// Сводка по последним 7 календарным дням: от (сегодня − 6) до сегодня, по порядку.
    func lastSevenDaysSummaries() -> [DayMoodSummary] {
        let todayStart = calendar.startOfDay(for: Date())
        guard let first = calendar.date(byAdding: .day, value: -6, to: todayStart) else { return [] }
        let grouped = entriesGroupedByDay(from: first, to: todayStart)
        return (0..<7).compactMap { offset -> DayMoodSummary? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: first) else { return nil }
            let dayStart = calendar.startOfDay(for: day)
            let dayEntries = grouped[dayStart] ?? []
            let last = dayEntries.max(by: { $0.date < $1.date })

            return DayMoodSummary(
                dayStart: dayStart,
                entryCount: dayEntries.count,
                lastMood: last?.mood,
                lastSleep: last?.sleepQuality,
                lastEnergy: last?.energyLevel
            )
        }
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

struct DayMoodSummary: Identifiable {
    var id: Date { dayStart }

    let dayStart: Date
    let entryCount: Int
    let lastMood: Mood?
    let lastSleep: SleepQuality?
    let lastEnergy: EnergyLevel?
}
