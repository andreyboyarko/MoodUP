//
//  StatsView.swift
//  MoodUp
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @Environment(\.colorScheme) private var colorScheme
    
    private var daySummaries: [DayMoodSummary] { moodStorage.lastSevenDaysSummaries() }
    private var weekTotal: Int { daySummaries.reduce(0) { $0 + $1.entryCount } }
    
    private var dayRowFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("EEE d MMM")
        return f
    }
    
    var body: some View {
        ZStack {
            AppColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeaderView("Stats", subtitle: "Your mood activity overview")
                    
                    if moodStorage.entries.isEmpty {
                        EmptyStateView(
                            title: "No mood data yet",
                            message: "Log how you feel on the Mood tab — your overview will appear here.",
                            systemImage: "chart.bar.xaxis"
                        )
                        .padding(.top, 8)
                    } else {
                        summaryGrid
                        weeklyByDaySection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
    }
    
    private var summaryGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SummaryCardView(
                    title: "Total entries",
                    value: "\(moodStorage.entries.count)"
                )
                SummaryCardView(
                    title: "Most frequent mood",
                    value: moodStorage.mostFrequentMood()?.title ?? "—"
                )
            }
            HStack(spacing: 12) {
                SummaryCardView(
                    title: "Last mood",
                    value: moodStorage.latestEntry()?.mood.title ?? "—"
                )
                SummaryCardView(
                    title: "This week",
                    value: "\(weekTotal) entries"
                )
            }
        }
    }
    
    private var weeklyByDaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("This week by day")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(daySummaries) { summary in
                    dayRow(summary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.cardBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.accent(for: colorScheme).opacity(0.12), lineWidth: 1)
            )
        }
    }
    
    private func moodTimelineRow(_ entry: MoodEntry) -> some View {
        HStack(spacing: 10) {

            Text(entry.date.formatted(date: .omitted, time: .shortened))
                .font(.caption.monospacedDigit())
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .leading)

            Text(entry.mood.emoji)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.mood.title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))

                if let sleep = entry.sleepQuality {
                    Text("Sleep: \(sleep.title)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if let energy = entry.energyLevel {
                    Text("Energy: \(energy.title)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
    }
    
    private func dayRow(_ summary: DayMoodSummary) -> some View {
        let entries = moodStorage.entries(on: summary.dayStart)

        return VStack(alignment: .leading, spacing: 10) {

            // 📅 Дата
            Text(dayRowFormatter.string(from: summary.dayStart))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            if entries.isEmpty {
                Text("No logs")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
            } else {
                VStack(spacing: 6) {
                    ForEach(entries) { entry in
                        moodTimelineRow(entry)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
