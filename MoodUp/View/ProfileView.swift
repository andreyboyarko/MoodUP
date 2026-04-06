//
//  ProfileView.swift
//  MoodUp
//

import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @EnvironmentObject private var appSettings: AppSettingsStore
    @EnvironmentObject private var profilePhotoStore: ProfilePhotoStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetConfirm = false
    @State private var showEditProfile = false
    @State private var showPhotoPicker = false

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "MoodUp v\(v)"
    }

    private var lastMoodTitle: String {
        moodStorage.entries.last?.mood.title ?? "—"
    }

    private var lastCheckInText: String {
        guard let date = moodStorage.entries.last?.date else { return "No check-ins yet" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    SectionHeaderView("Profile")

                    profileCard

                    quickStatsSection

                    settingsSection

                    resetButton

                    appInfoSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(appSettings)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoLibraryPicker(isPresented: $showPhotoPicker) { image in
                profilePhotoStore.savePickedImage(image)
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
            Button {
                showPhotoPicker = true
            } label: {
                avatarView
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change profile photo")

            VStack(alignment: .leading, spacing: 4) {
                Text(appSettings.userName)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))

                Text("MoodUp user")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
            }

            Spacer()

            Button {
                showEditProfile = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.accent(for: colorScheme))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppColors.accent(for: colorScheme).opacity(0.12))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accent(for: colorScheme).opacity(0.15), lineWidth: 1)
        )
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(AppColors.cardBackground(for: colorScheme))

            if let photo = profilePhotoStore.image {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(avatarPlaceholderGray)
            }
        }
        .frame(width: 64, height: 64)
        .overlay(
            Circle()
                .stroke(AppColors.accent(for: colorScheme).opacity(0.3), lineWidth: 1)
        )
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "camera.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(cameraGlyphOnAddButton)
                .padding(6)
                .background(
                    Circle()
                        .fill(addPhotoButtonGray)
                )
                .offset(x: 2, y: 2)
        }
    }

    /// Силуэт-заглушка в пустом аватаре (нейтральный серый).
    private var avatarPlaceholderGray: Color {
        colorScheme == .dark
            ? Color(red: 0.45, green: 0.45, blue: 0.45)
            : Color(red: 0.55, green: 0.55, blue: 0.55)
    }

    /// Заливка маленькой кнопки «добавить фото» — серый вместо салатового.
    private var addPhotoButtonGray: Color {
        colorScheme == .dark
            ? Color(red: 0.38, green: 0.38, blue: 0.38)
            : Color(red: 0.72, green: 0.72, blue: 0.72)
    }

    private var cameraGlyphOnAddButton: Color {
        colorScheme == .dark ? .white.opacity(0.92) : Color(white: 0.22)
    }

    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            statCard(title: "Entries", value: "\(moodStorage.entries.count)")
            statCard(title: "Last mood", value: lastMoodTitle)
            statCard(title: "Last check-in", value: lastCheckInText)
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.accent(for: colorScheme).opacity(0.08), lineWidth: 1)
        )
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsRowView(title: "Dark mode") {
                Toggle(isOn: Binding(
                    get: { appSettings.darkModeEnabled },
                    set: { appSettings.setDarkMode($0) }
                )) {
                    EmptyView()
                }
                .labelsHidden()
                .tint(AppColors.accent(for: colorScheme))
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
                .tint(AppColors.accent(for: colorScheme))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.cardBackground(for: colorScheme))
        )
    }

    private var resetButton: some View {
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
    }

    private var appInfoSection: some View {
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
}
