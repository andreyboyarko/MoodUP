//
//  InsightsView.swift
//  MoodUp
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @EnvironmentObject private var appSettings: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            AppColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    SectionHeaderView("Insights", subtitle: "Understand what affects your mood")

                    sleepBlock
                    energyBlock

                    recommendationBlock

                    if let insight = InsightsRecommendationEngine.optionalDataInsight(entries: moodStorage.entries) {
                        optionalInsightCard(text: insight)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
    }

    private var sleepBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did you sleep?")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SleepQuality.allCases) { quality in
                        insightChip(
                            title: quality.title,
                            isSelected: appSettings.sleepQuality == quality
                        ) {
                            appSettings.persistInsightSelection(sleep: quality, energy: appSettings.energyLevel)
                        }
                    }
                }
            }
        }
    }

    private var energyBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Energy level")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(EnergyLevel.allCases) { level in
                        insightChip(
                            title: level.title,
                            isSelected: appSettings.energyLevel == level
                        ) {
                            appSettings.persistInsightSelection(sleep: appSettings.sleepQuality, energy: level)
                        }
                    }
                }
            }
        }
    }

    private func insightChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isSelected ? Color.black : AppColors.textPrimary(for: colorScheme))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minWidth: 96)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? AppColors.accent : AppColors.cardBackground(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? AppColors.accent.opacity(0.4) : Color.clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? AppColors.accent.opacity(0.35) : .clear, radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var recommendationBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recommendation")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))

            Text(InsightsRecommendationEngine.recommendation(sleep: appSettings.sleepQuality, energy: appSettings.energyLevel))
                .font(.body)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
        )
    }

    private func optionalInsightCard(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("From your entries")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
        )
    }
}
