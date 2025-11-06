//
//  IconTheme.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 11/6/25.
//

import SwiftUI

// MARK: - Icon Theme View Modifiers

/// View modifier for primary themed icons (main navigation, important actions)
struct IconPrimaryModifier: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.colors.primary)
    }
}

/// View modifier for accent themed icons (secondary actions, edit buttons)
struct IconAccentModifier: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.colors.accent)
    }
}

/// View modifier for success themed icons (income, positive indicators)
struct IconSuccessModifier: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.colors.success)
    }
}

/// View modifier for error themed icons (expenses, negative indicators)
struct IconErrorModifier: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.colors.error)
    }
}

/// View modifier for warning themed icons (alerts, attention states)
struct IconWarningModifier: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.colors.warning)
    }
}

/// View modifier for neutral themed icons (chevrons, list indicators)
struct IconNeutralModifier: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.colors.textSecondary)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply primary theme color to icon (main navigation, important actions)
    func iconPrimary() -> some View {
        modifier(IconPrimaryModifier())
    }

    /// Apply accent theme color to icon (secondary actions, edit buttons)
    func iconAccent() -> some View {
        modifier(IconAccentModifier())
    }

    /// Apply success theme color to icon (income, positive indicators)
    func iconSuccess() -> some View {
        modifier(IconSuccessModifier())
    }

    /// Apply error theme color to icon (expenses, negative indicators)
    func iconError() -> some View {
        modifier(IconErrorModifier())
    }

    /// Apply warning theme color to icon (alerts, attention states)
    func iconWarning() -> some View {
        modifier(IconWarningModifier())
    }

    /// Apply neutral theme color to icon (chevrons, list indicators)
    func iconNeutral() -> some View {
        modifier(IconNeutralModifier())
    }

    /// Apply contextual icon theming based on transaction type
    /// - Parameter isIncome: true for income transactions, false for expenses
    func iconTransactionType(isIncome: Bool) -> some View {
        Group {
            if isIncome {
                self.modifier(IconSuccessModifier())
            } else {
                self.modifier(IconErrorModifier())
            }
        }
    }
}

// MARK: - Preview Helpers

#Preview("Icon Theme Styles") {
    VStack(spacing: 20) {
        HStack(spacing: 40) {
            VStack {
                Image(systemName: "star.fill")
                    .font(.title)
                    .iconPrimary()
                Text("Primary")
                    .font(.caption)
            }

            VStack {
                Image(systemName: "pencil.circle.fill")
                    .font(.title)
                    .iconAccent()
                Text("Accent")
                    .font(.caption)
            }

            VStack {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .iconSuccess()
                Text("Success")
                    .font(.caption)
            }
        }

        HStack(spacing: 40) {
            VStack {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title)
                    .iconError()
                Text("Error")
                    .font(.caption)
            }

            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .iconWarning()
                Text("Warning")
                    .font(.caption)
            }

            VStack {
                Image(systemName: "chevron.right")
                    .font(.title)
                    .iconNeutral()
                Text("Neutral")
                    .font(.caption)
            }
        }
    }
    .padding()
}
