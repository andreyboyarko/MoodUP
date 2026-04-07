//
//  InsightsView.swift
//  MoodUp
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @EnvironmentObject private var appSettings: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var importedSleepText: String?
    @State private var importedSleepCaption: String?
    @State private var isImportingSleep = false
    @State private var healthErrorText: String?

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

                    if let todayText = InsightsRecommendationEngine.todayActivityMessage(logCount: moodStorage.entriesToday().count) {
                        todayContextCard(text: todayText)
                    }

                    if let insight = InsightsRecommendationEngine.optionalDataInsight(entries: moodStorage.entriesInLastDays(7)) {
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
            HStack(alignment: .center) {
                Text("How did you sleep?")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))

                Spacer()

                Button {
                    importSleepFromHealth()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.text.square")
                        Text(isImportingSleep ? "Loading..." : "Import")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.accent(for: colorScheme))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.cardBackground(for: colorScheme))
                    )
                    .overlay(
                        Capsule()
                            .stroke(AppColors.accent(for: colorScheme).opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isImportingSleep)
            }

            Text("Optional. You can also select sleep quality manually.")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
            
            if let importedSleepText {
                VStack(alignment: .leading, spacing: 4) {
                    Text(importedSleepText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))

                    if let importedSleepCaption {
                        Text(importedSleepCaption)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                }
            }

            if let healthErrorText {
                Text(healthErrorText)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
            }

            if let importedSleepText {
                Text(importedSleepText)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
            }

            if let healthErrorText {
                Text(healthErrorText)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SleepQuality.allCases) { quality in
                        insightChip(
                            title: quality.title,
                            isSelected: appSettings.sleepQuality == quality
                        ) {
                            appSettings.persistInsightSelection(
                                sleep: quality,
                                energy: appSettings.energyLevel
                            )
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
    
    private func importSleepFromHealth() {
        healthErrorText = nil
        importedSleepText = nil
        importedSleepCaption = nil
        isImportingSleep = true

        guard HealthKitManager.shared.isAvailable else {
            isImportingSleep = false
            healthErrorText = "Health data is not available on this device."
            return
        }

        HealthKitManager.shared.requestAuthorization { success, error in
            guard success else {
                isImportingSleep = false
                healthErrorText = error?.localizedDescription ?? "Health access was not granted."
                return
            }

            HealthKitManager.shared.fetchLastNightSleepDuration { result in
                isImportingSleep = false

                guard let result else {
                    healthErrorText = "No recent sleep data found in Apple Health. You can still select sleep quality manually."
                    return
                }

                let duration: TimeInterval
                let caption: String

                switch result {
                case .actual(let value):
                    duration = value
                    caption = "Imported from Apple Health"
                case .estimatedInBed(let value):
                    duration = value
                    caption = "Estimated from Apple Health (time in bed)"
                }

                let hours = Int(duration) / 3600
                let minutes = (Int(duration) % 3600) / 60
                importedSleepText = "Last night: \(hours) h \(minutes) min"
                importedSleepCaption = caption

                let mappedQuality: SleepQuality
                if duration >= 8.0 * 3600.0 {
                    mappedQuality = .great
                } else if duration >= 6.0 * 3600.0 {
                    mappedQuality = .okay
                } else {
                    mappedQuality = .bad
                }

                appSettings.persistInsightSelection(
                    sleep: mappedQuality,
                    energy: appSettings.energyLevel
                )
            }
        }
    }
    
    private func insightChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(chipTitleColor(isSelected: isSelected))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minWidth: 96)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? AppColors.accent(for: colorScheme) : AppColors.cardBackground(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? AppColors.accent(for: colorScheme).opacity(0.4) : Color.clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? AppColors.accent(for: colorScheme).opacity(0.35) : .clear, radius: 10, y: 4)
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
                .stroke(AppColors.accent(for: colorScheme).opacity(0.2), lineWidth: 1)
        )
    }

    private func chipTitleColor(isSelected: Bool) -> Color {
        guard isSelected else { return AppColors.textPrimary(for: colorScheme) }
        return colorScheme == .light ? Color.white : Color.black
    }

    private func todayContextCard(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
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
                .stroke(AppColors.accent(for: colorScheme).opacity(0.2), lineWidth: 1)
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
                .stroke(AppColors.accent(for: colorScheme).opacity(0.2), lineWidth: 1)
        )
    }
}
