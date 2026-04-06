//
//  EditProfileView.swift
//  MoodUp
//
//  Created by Andrei  Boyarko on 06/04/2026.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var appSettings: AppSettingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var name: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.screenBackground(for: colorScheme)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))

                        TextField("Enter your name", text: $name)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppColors.cardBackground(for: colorScheme))
                            )
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppColors.accent.opacity(0.12), lineWidth: 1)
                            )
                    }

                    Spacer()

                    Button {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        appSettings.setUserName(trimmed.isEmpty ? "Andrei" : trimmed)
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.accent)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
        .onAppear {
            name = appSettings.userName
        }
    }
}
