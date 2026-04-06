//
//  StatsView.swift
//  MoodUp
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @Environment(\.colorScheme) private var colorScheme

    private var weekly: [(Mood, Int)] { moodStorage.weeklyMoodCounts() }
    private var weekTotal: Int { weekly.reduce(0) { $0 + $1.1 } }
    private var maxWeekCount: Int { max(weekly.map(\.1).max() ?? 0, 1) }

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
                        weeklySection
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

    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("This week")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            VStack(alignment: .leading, spacing: 14) {
                ForEach(weekly, id: \.0) { mood, count in
                    HStack(spacing: 12) {
                        Text(mood.emoji)
                            .frame(width: 28, alignment: .center)
                        Text(mood.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            .frame(width: 88, alignment: .leading)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.cardBackground(for: colorScheme))
                                .frame(height: 10)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.accent.opacity(0.85))
                                .frame(width: max(6, 120 * CGFloat(count) / CGFloat(maxWeekCount)), height: 10)
                        }
                        .frame(width: 120, height: 10, alignment: .leading)
                        Text("\(count)")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            .frame(width: 28, alignment: .trailing)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.cardBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.accent.opacity(0.12), lineWidth: 1)
            )
        }
    }
}
