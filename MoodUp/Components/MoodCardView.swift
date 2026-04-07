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

    private var borderColor: Color {
        isSelected ? AppColors.accent(for: colorScheme) : Color.clear
    }

    private var shadowColor: Color {
        if isSelected {
            return AppColors.accent(for: colorScheme).opacity(0.45)
        } else {
            return Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08)
        }
    }

    private var currentScale: CGFloat {
        if isFalling { return 0.78 }
        return isSelected ? 1.03 : 1.0
    }

    private var currentYOffset: CGFloat {
        isFalling ? 260 : 0
    }

    private var currentRotation: Double {
        isFalling ? mood.fallRotation : 0
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(mood.emoji)
                    .font(.system(size: 32))

                Image(systemName: mood.systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(
                        isSelected
                        ? AppColors.accent(for: colorScheme)
                        : AppColors.textSecondary(for: colorScheme)
                    )

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
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(
                color: shadowColor,
                radius: isSelected ? 14 : 6,
                y: 4
            )
            .scaleEffect(currentScale)
            .rotationEffect(.degrees(currentRotation))
            .offset(y: currentYOffset)
            .opacity(displayOpacity)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.84), value: isSelected)
        .animation(.easeIn(duration: 0.42), value: isFalling)
        .animation(.easeOut(duration: 0.18), value: isHeroHiddenInGrid)
        .animation(.easeOut(duration: 0.2), value: dimmedNonSelected)
    }
}
