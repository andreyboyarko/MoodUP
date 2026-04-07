//
//  MoodView.swift
//  MoodUp
//

import SwiftUI

private enum SaveOverlayState: Equatable {
    case idle
    case running(mood: Mood, valence: MoodValence)
}

struct MoodView: View {
    @EnvironmentObject private var moodStorage: MoodStorageManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedMood: Mood?
    @State private var savePulse = false
    @State private var saveOverlay: SaveOverlayState = .idle

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var latest: MoodEntry? { moodStorage.latestEntry() }

    private var isSaveAnimating: Bool {
        if case .running = saveOverlay { return true }
        return false
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    SectionHeaderView("How do you feel today?", subtitle: "Track your current mood and save it")

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Mood.allCases) { mood in
                            MoodCardView(
                                mood: mood,
                                isSelected: selectedMood == mood,
                                isFalling: shouldFall(mood),
                                isHeroHiddenInGrid: shouldHideInGrid(mood),
                                dimmedNonSelected: shouldDim(mood),
                                action: {
                                    guard !isSaveAnimating else { return }
                                    withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                                        selectedMood = mood
                                    }
                                }
                            )
                        }
                    }
                    .allowsHitTesting(!isSaveAnimating)

                    if let latest {
                        currentMoodBlock(entry: latest)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 110)
            }
            .allowsHitTesting(!isSaveAnimating)

            VStack {
                Spacer()
                PrimaryButton(
                    title: "Save mood",
                    isEnabled: selectedMood != nil && !isSaveAnimating
                ) {
                    playSaveSequence()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(
                    AppColors.screenBackground(for: colorScheme)
                        .opacity(0.94)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            .allowsHitTesting(!isSaveAnimating)

            if case .running(let mood, let valence) = saveOverlay {
                saveCelebrationLayer(mood: mood, valence: valence)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.28), value: latest?.id)
    }

    @ViewBuilder
    private func saveCelebrationLayer(mood: Mood, valence: MoodValence) -> some View {
        ZStack {
            Color.black.opacity(valence == .negative ? 0.5 : 0.32)
                .ignoresSafeArea()

            MoodSaveHeroContent(mood: mood, valence: valence)
                .id(mood.id)
                .padding(.horizontal, 24)
        }
    }

    private func shouldFall(_ mood: Mood) -> Bool {
        guard case .running(let m, let v) = saveOverlay, v == .negative else { return false }
        return mood != m
    }

    private func shouldHideInGrid(_ mood: Mood) -> Bool {
        guard case .running(let m, let v) = saveOverlay, v == .negative else { return false }
        return mood == m
    }

    private func shouldDim(_ mood: Mood) -> Bool {
        guard case .running(let m, let v) = saveOverlay else { return false }
        if v == .negative { return false }
        return mood != m
    }

    private func playSaveSequence() {
        guard let mood = selectedMood else { return }
        let valence = mood.valence
        withAnimation(.easeOut(duration: 0.22)) {
            saveOverlay = .running(mood: mood, valence: valence)
        }

        let delay: TimeInterval
        switch valence {
        case .positive: delay = 0.95
        case .neutral: delay = 0.82
        case .negative: delay = 1.08
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completeSave(mood: mood)
        }
    }

    private func completeSave(mood: Mood) {
        moodStorage.saveMood(mood)
        withAnimation(.easeOut(duration: 0.28)) {
            saveOverlay = .idle
            selectedMood = nil
        }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            savePulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation {
                savePulse = false
            }
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
                    .stroke(AppColors.accent(for: colorScheme).opacity(savePulse ? 0.55 : 0.25), lineWidth: 1)
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
}

// MARK: - Hero overlay

private struct MoodSaveHeroContent: View {
    let mood: Mood
    let valence: MoodValence

    @Environment(\.colorScheme) private var colorScheme
    @State private var heroScale: CGFloat = 0.62
    @State private var glowStrong = false
    @State private var shakeX: CGFloat = 0

    var body: some View {
        VStack(spacing: 18) {
            Text(mood.emoji)
                .font(.system(size: 72))

            Image(systemName: mood.systemImage)
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(AppColors.accent(for: colorScheme))

            Text(mood.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 36)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    AppColors.accent(for: colorScheme).opacity(glowStrong ? 0.7 : 0.38),
                    lineWidth: 2
                )
        )
        .shadow(
            color: AppColors.accent(for: colorScheme).opacity(valence == .negative ? 0.22 : 0.5),
            radius: valence == .negative ? 14 : 32,
            y: 10
        )
        .scaleEffect(heroScale)
        .offset(x: shakeX)
        .onAppear {
            if valence == .negative {
                runNegativeSequence()
            } else {
                withAnimation(.spring(response: 0.52, dampingFraction: 0.72)) {
                    heroScale = 1.0
                    glowStrong = true
                }
            }
        }
    }

    private func runNegativeSequence() {
        withAnimation(.spring(response: 0.48, dampingFraction: 0.78)) {
            heroScale = 1.0
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 120_000_000)
            for i in 0..<15 {
                try? await Task.sleep(nanoseconds: 68_000_000)
                withAnimation(.linear(duration: 0.05)) {
                    shakeX = (i % 2 == 0) ? 9 : -9
                }
            }
            withAnimation(.easeOut(duration: 0.1)) {
                shakeX = 0
            }
        }
    }
}
