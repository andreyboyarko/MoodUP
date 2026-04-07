//
//  MoodEntry+Calendar.swift
//  MoodUp
//

import Foundation

extension MoodEntry {
    /// Начало календарного дня для записи (локальный календарь).
    var dayStart: Date {
        Calendar.current.startOfDay(for: date)
    }
}
