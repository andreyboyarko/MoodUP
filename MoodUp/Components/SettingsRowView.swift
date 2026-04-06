//
//  SettingsRowView.swift
//  MoodUp
//

import SwiftUI

struct SettingsRowView<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.colorScheme) private var colorScheme

    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
            Spacer()
            trailing()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
