//
//  EmptyStateView.swift
//  MoodUp
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var systemImage: String = "chart.bar.xaxis"

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .light))
                .foregroundColor(AppColors.accent(for: colorScheme).opacity(0.85))
                .padding(24)
                .background(
                    Circle()
                        .fill(AppColors.cardBackground(for: colorScheme))
                )
                .shadow(color: AppColors.accent(for: colorScheme).opacity(0.2), radius: 16, y: 6)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
