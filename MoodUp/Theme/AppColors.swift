//
//  AppColors.swift
//  MoodUp
//

import SwiftUI
import UIKit

enum AppColors {
    static let backgroundDark = Color(red: 0, green: 0, blue: 0)
    static let cardDark = Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255)

    /// Яркий неон (#A3FF12) — тёмная тема, сплэш и тёмный UI.
    static let accentNeon = Color(red: 163 / 255, green: 1, blue: 18 / 255)

    /// Спокойный лайм для светлой темы (ниже насыщенность, комфортно на белом).
    private static let accentLightMuted = Color(red: 96 / 255, green: 140 / 255, blue: 52 / 255)

    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? accentNeon : accentLightMuted
    }

    /// Обратная совместимость: по умолчанию «ядерный» оттенок (сплэш и статический UIKit).
    static var accent: Color { accentNeon }
    static let textPrimaryDark = Color(red: 1, green: 1, blue: 1)
    static let textSecondaryDark = Color(red: 154 / 255, green: 154 / 255, blue: 154 / 255)

    static let tabBarLight = Color.white
    static let textPrimaryLight = Color.black
    static let textSecondaryLight = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let cardLight = Color(red: 0.96, green: 0.96, blue: 0.96)

    static func screenBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundDark : Color.white
    }

    static func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? cardDark : cardLight
    }

    static func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textPrimaryDark : textPrimaryLight
    }

    static func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textSecondaryDark : textSecondaryLight
    }

    /// Акцент для `UITabBarAppearance` и другого UIKit с учётом светлой/тёмной схемы.
    static func accentUIColor(for traits: UITraitCollection) -> UIColor {
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 163 / 255, green: 1, blue: 18 / 255, alpha: 1)
            : UIColor(red: 96 / 255, green: 140 / 255, blue: 52 / 255, alpha: 1)
    }
}
