//
//  PrimaryButton.swift
//  MoodUp
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(buttonLabelColor(isEnabled: isEnabled))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isEnabled ? AppColors.accent(for: colorScheme) : AppColors.cardBackground(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColors.accent(for: colorScheme).opacity(isEnabled ? 0.35 : 0), lineWidth: 1)
                )
                .shadow(color: isEnabled ? AppColors.accent(for: colorScheme).opacity(0.35) : .clear, radius: isEnabled ? 12 : 0, y: 4)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.22), value: isEnabled)
    }

    private func buttonLabelColor(isEnabled: Bool) -> Color {
        guard isEnabled else { return AppColors.textSecondary(for: colorScheme) }
        if colorScheme == .light {
            return Color.white
        }
        return Color.black
    }
}
