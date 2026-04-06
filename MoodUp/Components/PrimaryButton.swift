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
                .foregroundColor(isEnabled ? Color.black : AppColors.textSecondary(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isEnabled ? AppColors.accent : AppColors.cardBackground(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColors.accent.opacity(isEnabled ? 0.35 : 0), lineWidth: 1)
                )
                .shadow(color: isEnabled ? AppColors.accent.opacity(0.35) : .clear, radius: isEnabled ? 12 : 0, y: 4)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.22), value: isEnabled)
    }
}
