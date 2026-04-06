//
//  ProfileView.swift
//  MoodUp
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @EnvironmentObject private var appSettings: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetConfirm = false
    @State private var showEditProfile = false

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "MoodUp v\(v)"
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    SectionHeaderView("Profile")

                    profileCard

                    VStack(spacing: 0) {
                        SettingsRowView(title: "Dark mode") {
                            Toggle(isOn: Binding(
                                get: { appSettings.darkModeEnabled },
                                set: { appSettings.setDarkMode($0) }
                            )) {
                                EmptyView()
                            }
                            .labelsHidden()
                            .tint(AppColors.accent)
                        }
                        Divider().opacity(0.2)
                        SettingsRowView(title: "Notifications") {
                            Toggle(isOn: Binding(
                                get: { appSettings.remindersEnabled },
                                set: { appSettings.userRequestedReminders($0) }
                            )) {
                                EmptyView()
                            }
                            .labelsHidden()
                            .tint(AppColors.accent)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColors.cardBackground(for: colorScheme))
                    )

                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Text("Reset mood history")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red.opacity(0.9))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColors.cardBackground(for: colorScheme))
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("App info")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        Text(appVersion)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .alert("Reset all mood history?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                moodStorage.resetAllEntries()
            }
        } message: {
            Text("This removes all saved mood entries from this device.")
        }
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.cardBackground(for: colorScheme))
            }
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.accent)
            )
            .overlay(
                Circle()
                    .stroke(AppColors.accent.opacity(0.35), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(appSettings.userName)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                Text("MoodUp user")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
            }
            Spacer()
        }
        .padding(18)
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
