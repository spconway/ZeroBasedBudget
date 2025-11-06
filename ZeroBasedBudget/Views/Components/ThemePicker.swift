//
//  ThemePicker.swift
//  ZeroBasedBudget
//
//  Theme selection UI component for Settings view.
//  Displays all available themes with color previews and descriptions.
//

import SwiftUI
import SwiftData

/// Theme picker component for Settings
struct ThemePicker: View {
    // MARK: - Properties

    /// Theme manager reference
    @Bindable var themeManager: ThemeManager

    /// Current theme from environment
    @Environment(\.theme) private var currentTheme

    // MARK: - Body

    var body: some View {
        ForEach(ThemeType.allCases) { themeType in
            themeRow(for: themeType)
        }
    }

    // MARK: - Private Views

    /// Individual theme row
    private func themeRow(for themeType: ThemeType) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                themeManager.setTheme(themeType.theme)
            }
        } label: {
            HStack(spacing: 12) {
                // Theme info
                VStack(alignment: .leading, spacing: 4) {
                    Text(themeType.name)
                        .font(.headline)
                        .foregroundColor(currentTheme.colors.textPrimary)

                    Text(themeType.description)
                        .font(.caption)
                        .foregroundColor(currentTheme.colors.textSecondary)
                }

                Spacer()

                // Color preview swatches
                HStack(spacing: 6) {
                    colorSwatch(themeType.theme.colors.primary)
                    colorSwatch(themeType.theme.colors.accent)
                    colorSwatch(themeType.theme.colors.success)
                }

                // Selection indicator
                if themeManager.currentTheme.identifier == themeType.theme.identifier {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(currentTheme.colors.accent)
                        .imageScale(.large)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(themeType.name) theme: \(themeType.description)")
        .accessibilityHint(
            themeManager.currentTheme.identifier == themeType.theme.identifier
                ? "Selected"
                : "Double tap to select"
        )
    }

    /// Color swatch circle
    private func colorSwatch(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .stroke(currentTheme.colors.border, lineWidth: 1)
            )
    }
}

// MARK: - Preview

struct ThemePickerPreview: View {
    @State private var themeManager: ThemeManager

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: AppSettings.self,
            configurations: config
        )
        let context = container.mainContext

        let settings = AppSettings()
        context.insert(settings)

        _themeManager = State(initialValue: ThemeManager(appSettings: settings, modelContext: context))
    }

    var body: some View {
        List {
            Section("Theme") {
                ThemePicker(themeManager: themeManager)
            }
        }
        .withTheme(themeManager.currentTheme)
    }
}

#Preview("Theme Picker") {
    ThemePickerPreview()
}
