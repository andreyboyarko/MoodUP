//
//  SectionHeaderView.swift
//  MoodUp
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let subtitle: String?

    @Environment(\.colorScheme) private var colorScheme

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
