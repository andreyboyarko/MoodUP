//
//  MoodCardView.swift
//  MoodUp
//

import SwiftUI

struct MoodCardView: View {
    let mood: Mood
    let isSelected: Bool
    var isFalling: Bool = false
    var isHeroHiddenInGrid: Bool = false
    var dimmedNonSelected: Bool = false
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var displayOpacity: Double {
        if isFalling { return 0 }
        if isHeroHiddenInGrid { return 0 }
        if dimmedNonSelected && !isSelected { return 0.32 }
        return 1
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                Image(systemName: mood.systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? AppColors.accent(for: colorScheme) : AppColors.textSecondary(for: colorScheme))
                Text(mood.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.cardBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? AppColors.accent(for: colorScheme) : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? AppColors.accent(for: colorScheme).opacity(0.45) : Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: isSelected ? 14 : 6, y: 4)
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .offset(y: isFalling ? 460 : 0)
            .opacity(displayOpacity)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.38, dampingFraction: 0.72), value: isSelected)
        .animation(.easeIn(duration: 0.45), value: isFalling)
        .animation(.easeOut(duration: 0.25), value: isHeroHiddenInGrid)
        .animation(.easeOut(duration: 0.22), value: dimmedNonSelected)
    }
}
