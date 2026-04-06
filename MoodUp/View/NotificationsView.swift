//
//  NotificationsView.swift
//  MoodUp
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var appSettings: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            AppColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeaderView("Notifications", subtitle: "Stay connected with your mood")

                    Toggle(isOn: Binding(
                        get: { appSettings.remindersEnabled },
                        set: { appSettings.userRequestedReminders($0) }
                    )) {
                        Text("Enable reminders")
                            .font(.body)
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    }
                    .tint(AppColors.accent)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColors.cardBackground(for: colorScheme))
                    )

                    if appSettings.remindersEnabled {
                        frequencySection
                        goalSection
                    }

                    statusCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Frequency")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            VStack(spacing: 10) {
                ForEach(ReminderFrequency.allCases) { freq in
                    selectionRow(
                        title: freq.title,
                        isSelected: appSettings.reminderFrequency == freq
                    ) {
                        appSettings.setReminderFrequency(freq)
                    }
                }
            }
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder goal")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            VStack(spacing: 10) {
                ForEach(ReminderGoal.allCases) { goal in
                    selectionRow(
                        title: goal.title,
                        isSelected: appSettings.reminderGoal == goal
                    ) {
                        appSettings.setReminderGoal(goal)
                    }
                }
            }
        }
    }

    private func selectionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.accent)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.cardBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? AppColors.accent.opacity(0.55) : AppColors.accent.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
            Text(appSettings.remindersEnabled ? "Reminders are enabled" : "Reminders are off")
                .font(.body.weight(.semibold))
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
            if appSettings.remindersEnabled {
                Text("Frequency: \(appSettings.reminderFrequency.title)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
                Text("Goal: \(appSettings.reminderGoal.title)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accent.opacity(0.15), lineWidth: 1)
        )
    }
}
