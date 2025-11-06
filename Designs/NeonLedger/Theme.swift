//
//  NeonLedgerTheme.swift
//  ZeroBasedBudget
//
//  Neon Ledger Design System
//  Dark graphite bases with electric teal and magenta accents
//

import SwiftUI
import Charts

struct NeonLedgerTheme {

    // MARK: - Colors

    struct Colors {
        // Backgrounds
        static let bg = Color(hex: "0A0A0A")
        static let surface = Color(hex: "121212")
        static let surfaceElevated = Color(hex: "1A1A1A")

        // Primary & Accent
        static let primary = Color(hex: "00E5CC")
        static let onPrimary = Color(hex: "000000")
        static let accent = Color(hex: "FF006E")
        static let onAccent = Color(hex: "FFFFFF")

        // Semantic Colors
        static let success = Color(hex: "00FF88")
        static let warning = Color(hex: "FFB800")
        static let error = Color(hex: "FF006E")

        // Text & Borders
        static let muted = Color(hex: "999999")
        static let border = Color(hex: "2A2A2A")

        // YNAB-Specific
        static let readyToAssignBg = Color(hex: "00E5CC")
        static let readyToAssignText = Color(hex: "000000")

        // Chart Colors
        struct Chart {
            static let income = Color(hex: "00FF88")
            static let expense = Color(hex: "FF006E")
            static let savings = Color(hex: "00E5CC")
            static let debt = Color(hex: "FFB800")
            static let budgeted = Color(hex: "7C3AED")
            static let actual = Color(hex: "00E5CC")
        }
    }

    // MARK: - Typography

    struct Typography {
        // Display (Headers)
        static let displayLarge = Font.system(size: 34, weight: .bold, design: .default)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
        static let displaySmall = Font.system(size: 20, weight: .semibold, design: .default)

        // Body Text
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

        // Emphasis
        static let bodyLargeBold = Font.system(size: 16, weight: .semibold, design: .default)
        static let bodyMediumBold = Font.system(size: 14, weight: .semibold, design: .default)

        // Labels
        static let label = Font.system(size: 12, weight: .bold, design: .default)
        static let caption = Font.system(size: 10, weight: .regular, design: .default)
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Corner Radius

    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
    }

    // MARK: - Button Styles

    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Typography.bodyLargeBold)
                .foregroundColor(Colors.onPrimary)
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Colors.primary)
                        .shadow(color: Colors.primary.opacity(0.3), radius: 12, x: 0, y: 4)
                )
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Typography.bodyMediumBold)
                .foregroundColor(Colors.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Colors.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.md)
                                .stroke(Colors.border, lineWidth: 1)
                        )
                )
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }

    // MARK: - Card Style

    struct CardStyle: ViewModifier {
        var isElevated: Bool = false

        func body(content: Content) -> some View {
            content
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(isElevated ? Colors.surfaceElevated : Colors.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Colors.border, lineWidth: 0.5)
                        .opacity(0.5)
                )
        }
    }

    struct GlowCardStyle: ViewModifier {
        var glowColor: Color = Colors.primary

        func body(content: Content) -> some View {
            content
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Colors.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.md)
                                .stroke(glowColor, lineWidth: 1)
                                .opacity(0.3)
                        )
                        .shadow(color: glowColor.opacity(0.2), radius: 8, x: 0, y: 2)
                )
        }
    }

    // MARK: - Chart Configuration

    struct ChartStyle {
        static func donutChartStyle() -> some ChartContent {
            // Example chart configuration
            // Use with Swift Charts SectorMark
            return EmptyView() as! any ChartContent
        }

        static func barChartStyle() -> some ChartContent {
            // Example chart configuration
            // Use with Swift Charts BarMark
            return EmptyView() as! any ChartContent
        }

        // Chart color mapping
        static func chartColor(for categoryType: String) -> Color {
            switch categoryType {
            case "Income":
                return Colors.Chart.income
            case "Expense":
                return Colors.Chart.expense
            case "Savings":
                return Colors.Chart.savings
            case "Debt":
                return Colors.Chart.debt
            default:
                return Colors.primary
            }
        }
    }

    // MARK: - Badge Style

    struct BadgeStyle: ViewModifier {
        var color: Color

        func body(content: Content) -> some View {
            content
                .font(Typography.label)
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                )
        }
    }
}

// MARK: - Color Extension

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
            (a, r, g, b) = (1, 1, 1, 0)
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

// MARK: - View Extensions

extension View {
    func neonCard(elevated: Bool = false) -> some View {
        modifier(NeonLedgerTheme.CardStyle(isElevated: elevated))
    }

    func neonGlowCard(color: Color = NeonLedgerTheme.Colors.primary) -> some View {
        modifier(NeonLedgerTheme.GlowCardStyle(glowColor: color))
    }

    func neonBadge(color: Color) -> some View {
        modifier(NeonLedgerTheme.BadgeStyle(color: color))
    }
}

// MARK: - Usage Examples

#if DEBUG
struct NeonLedgerTheme_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Ready to Assign Banner
            VStack {
                Text("READY TO ASSIGN")
                    .font(NeonLedgerTheme.Typography.bodyMediumBold)
                Text("$247.50")
                    .font(NeonLedgerTheme.Typography.displayLarge)
            }
            .foregroundColor(NeonLedgerTheme.Colors.readyToAssignText)
            .frame(maxWidth: .infinity)
            .padding()
            .background(NeonLedgerTheme.Colors.readyToAssignBg)
            .cornerRadius(NeonLedgerTheme.Radius.md)

            // Category Card
            HStack {
                VStack(alignment: .leading) {
                    Text("Groceries")
                        .font(NeonLedgerTheme.Typography.bodyLargeBold)
                        .foregroundColor(.white)
                    Text("$285 of $400")
                        .font(NeonLedgerTheme.Typography.bodyMedium)
                        .foregroundColor(NeonLedgerTheme.Colors.muted)
                }
                Spacer()
                Text("$400")
                    .font(NeonLedgerTheme.Typography.displaySmall)
                    .foregroundColor(.white)
            }
            .neonCard()

            // Buttons
            HStack {
                Button("Primary Action") {}
                    .buttonStyle(NeonLedgerTheme.PrimaryButtonStyle())

                Button("Secondary") {}
                    .buttonStyle(NeonLedgerTheme.SecondaryButtonStyle())
            }

            // Badges
            HStack {
                Text("INCOME")
                    .neonBadge(color: NeonLedgerTheme.Colors.success)

                Text("EXPENSE")
                    .neonBadge(color: NeonLedgerTheme.Colors.error)
            }
        }
        .padding()
        .background(NeonLedgerTheme.Colors.bg)
    }
}
#endif
