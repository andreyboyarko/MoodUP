//
//  MoodView.swift
//  MoodUp
//

import SwiftUI

struct MoodView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedMood: Mood?
    @State private var savePulse = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var latest: MoodEntry? { moodStorage.latestEntry() }

    var body: some View {
        ZStack {
            AppColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    SectionHeaderView("How do you feel today?", subtitle: "Track your current mood and save it")

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Mood.allCases) { mood in
                            MoodCardView(mood: mood, isSelected: selectedMood == mood) {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                                    selectedMood = mood
                                }
                            }
                        }
                    }

                    if let latest {
                        currentMoodBlock(entry: latest)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 110)
            }

            VStack {
                Spacer()
                PrimaryButton(title: "Save mood", isEnabled: selectedMood != nil) {
                    saveMood()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(
                    AppColors.screenBackground(for: colorScheme)
                        .opacity(0.94)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .animation(.easeInOut(duration: 0.28), value: latest?.id)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image("arrow2")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .shadow(color: AppColors.accent.opacity(0.35), radius: 8, y: 2)
            Spacer()
        }
    }

    private func currentMoodBlock(entry: MoodEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current mood")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
            HStack(spacing: 12) {
                Text(entry.mood.emoji)
                    .font(.title)
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.mood.title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    Text(updatedLabel(for: entry.date))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                }
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.cardBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.accent.opacity(savePulse ? 0.55 : 0.25), lineWidth: 1)
            )
            .scaleEffect(savePulse ? 1.02 : 1)
        }
    }

    private func updatedLabel(for date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "Updated just now"
        }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return "Updated \(f.localizedString(for: date, relativeTo: Date()))"
    }

    private func saveMood() {
        guard let mood = selectedMood else { return }
        moodStorage.saveMood(mood)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            savePulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation {
                savePulse = false
            }
        }
    }
}
