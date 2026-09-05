// ThemeManager.swift
import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme = .auto
    @Published var accentColor: Color = .blue
    @Published var fontSize: FontSize = .medium

    enum AppTheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
        case highContrast = "High Contrast"
        case ocean = "Ocean"
        case forest = "Forest"
        case sunset = "Sunset"
    }

    enum FontSize: String, CaseIterable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
    }

    var colorScheme: ColorScheme? {
        switch currentTheme {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        case .highContrast: return .dark
        case .ocean: return .dark
        case .forest: return .dark
        case .sunset: return .dark
        }
    }

    var backgroundColor: Color {
        switch currentTheme {
        case .light: return .white
        case .dark: return Color(nsColor: .windowBackgroundColor)
        case .auto: return Color(nsColor: .windowBackgroundColor)
        case .highContrast: return Color(nsColor: .controlBackgroundColor)
        case .ocean: return Color(red: 0.05, green: 0.1, blue: 0.15)
        case .forest: return Color(red: 0.05, green: 0.12, blue: 0.05)
        case .sunset: return Color(red: 0.15, green: 0.08, blue: 0.1)
        }
    }

    var textColor: Color {
        switch currentTheme {
        case .light: return .primary
        case .dark: return .primary
        case .auto: return .primary
        case .highContrast: return .white
        case .ocean: return Color(red: 0.8, green: 0.9, blue: 1.0)
        case .forest: return Color(red: 0.8, green: 1.0, blue: 0.8)
        case .sunset: return Color(red: 1.0, green: 0.9, blue: 0.8)
        }
    }

    var accentGradient: LinearGradient {
        switch currentTheme {
        case .ocean:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .forest:
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sunset:
            return LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private init() {
        loadTheme()
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveTheme()
    }

    func setAccentColor(_ color: Color) {
        accentColor = color
        saveTheme()
    }

    func setFontSize(_ size: FontSize) {
        fontSize = size
        saveTheme()
    }

    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        UserDefaults.standard.set(accentColor.description, forKey: "accentColor")
        UserDefaults.standard.set(fontSize.rawValue, forKey: "fontSize")
    }

    private func loadTheme() {
        if let themeRaw = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: themeRaw) {
            currentTheme = theme
        }
        if let sizeRaw = UserDefaults.standard.string(forKey: "fontSize"),
           let size = FontSize(rawValue: sizeRaw) {
            fontSize = size
        }
    }
}
