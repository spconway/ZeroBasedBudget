//
//  RefinedComponents.swift
//  ZeroBasedBudget
//
//  Created for Minimalist Refined Design System
//  Reusable refined UI components with subtle borders, generous spacing, and elegant typography
//

import SwiftUI

// MARK: - Refined Card Component

/// A card component with 1px borders, 12px corner radius, and refined styling
struct RefinedCard<Content: View>: View {
    let content: Content
    let padding: CGFloat

    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var cardBackground: Color {
        colorScheme == .light ? .white : colors.surface
    }

    private var borderColor: Color {
        colorScheme == .light ? Color(hex: "#E5E5EA") : Color.white.opacity(0.1)
    }
}

// MARK: - Refined Input Field Component

/// Custom input field with uppercase label, subtle underline, and refined styling
struct RefinedInputField: View {
    let label: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let textAlignment: TextAlignment

    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    init(
        label: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textAlignment: TextAlignment = .leading
    ) {
        self.label = label
        self._text = text
        self.keyboardType = keyboardType
        self.textAlignment = textAlignment
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(colors.textSecondary)
                .tracking(0.5)

            TextField("", text: $text)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(colors.textPrimary)
                .keyboardType(keyboardType)
                .multilineTextAlignment(textAlignment)
                .focused($isFocused)

            // Subtle underline accent
            Rectangle()
                .fill(isFocused ? colors.primary : colors.borderSubtle)
                .frame(height: isFocused ? 2 : 1)
                .opacity(isFocused ? 1.0 : 0.3)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .padding(16)
        .background(inputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? colors.primary : borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    private var inputBackground: Color {
        colorScheme == .light ? .white : colors.surface
    }

    private var borderColor: Color {
        colorScheme == .light ? Color(hex: "#E5E5EA") : Color.white.opacity(0.1)
    }
}

// MARK: - Refined Currency Input Field

/// Specialized input for currency amounts with light-weight typography
struct RefinedCurrencyInput: View {
    let label: String
    @Binding var amount: String

    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(colors.textSecondary)
                .tracking(0.5)

            TextField("0.00", text: $amount)
                .font(.system(size: 34, weight: .light)) // Light weight for elegance
                .foregroundStyle(colors.textPrimary)
                .keyboardType(.decimalPad)
                .focused($isFocused)

            // Subtle underline accent
            Rectangle()
                .fill(colors.primary)
                .frame(width: min(CGFloat(amount.count) * 20 + 40, 200), height: 1)
                .opacity(0.3)
        }
        .padding(16)
        .background(inputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? colors.primary : borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    private var inputBackground: Color {
        colorScheme == .light ? .white : colors.surface
    }

    private var borderColor: Color {
        colorScheme == .light ? Color(hex: "#E5E5EA") : Color.white.opacity(0.1)
    }
}

// MARK: - Refined Icon Badge

/// Circular icon badge with 10% opacity background and themed icon color
struct RefinedIconBadge: View {
    let systemName: String
    let color: Color
    let size: CGFloat

    init(systemName: String, color: Color, size: CGFloat = 36) {
        self.systemName = systemName
        self.color = color
        self.size = size
    }

    var body: some View {
        Circle()
            .fill(color.opacity(0.1))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundStyle(color)
            )
    }
}

// MARK: - Refined List Row

/// Standardized list row with refined styling and consistent height
struct RefinedListRow<Content: View>: View {
    let content: Content
    let height: CGFloat

    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme

    init(height: CGFloat = 80, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }

    var body: some View {
        content
            .frame(minHeight: height)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(rowBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var rowBackground: Color {
        colorScheme == .light ? .white : colors.surface
    }

    private var borderColor: Color {
        colorScheme == .light ? Color(hex: "#E5E5EA") : Color.white.opacity(0.1)
    }
}

// MARK: - Refined Section Header

/// Section header with uppercase tracking and refined typography
struct RefinedSectionHeader: View {
    let title: String

    @Environment(\.themeColors) private var colors

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(colors.textSecondary)
            .tracking(1.2)
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply refined card styling
    func refinedCard(padding: CGFloat = 16) -> some View {
        modifier(RefinedCardModifier(padding: padding))
    }

    /// Apply refined section spacing
    func refinedSectionSpacing() -> some View {
        self.padding(.vertical, 8)
    }
}

struct RefinedCardModifier: ViewModifier {
    let padding: CGFloat

    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(colorScheme == .light ? .white : colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        colorScheme == .light ? Color(hex: "#E5E5EA") : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
