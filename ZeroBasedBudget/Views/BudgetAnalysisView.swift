//
//  BudgetAnalysisView.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import SwiftUI
import SwiftData
import Charts

enum ChartType: String, CaseIterable {
    case bar = "Bar"
    case donut = "Donut"
}

struct BudgetAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    @Query private var allTransactions: [Transaction]
    @Query private var categories: [BudgetCategory]
    @Query private var settings: [AppSettings]

    @State private var selectedMonth = Date()
    @State private var selectedChartType: ChartType = .bar

    // Currency code from settings
    private var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }

    // Generate category comparisons for selected month
    private var categoryComparisons: [CategoryComparison] {
        BudgetCalculations.generateCategoryComparisons(
            categories: categories.filter { $0.categoryType != "Income" },
            month: selectedMonth,
            transactions: allTransactions
        )
        .sorted(by: { $0.categoryName < $1.categoryName })
    }

    // Summary totals
    private var totalBudgeted: Decimal {
        categoryComparisons.reduce(Decimal.zero) { $0 + $1.budgeted }
    }

    private var totalActual: Decimal {
        categoryComparisons.reduce(Decimal.zero) { $0 + $1.actual }
    }

    private var totalDifference: Decimal {
        totalBudgeted - totalActual
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Month Selector
                    MonthPickerSection(selectedMonth: $selectedMonth)

                    if categoryComparisons.isEmpty {
                        ContentUnavailableView {
                            Label("No Budget Categories", systemImage: "chart.bar")
                        } description: {
                            Text("Add budget categories in the Budget Planning tab to see analysis")
                        }
                        .frame(minHeight: 300)
                    } else {
                        // Summary Section
                        SummarySection(
                            totalBudgeted: totalBudgeted,
                            totalActual: totalActual,
                            totalDifference: totalDifference,
                            currencyCode: currencyCode
                        )

                        // Chart Type Picker
                        Picker("Chart Type", selection: $selectedChartType) {
                            ForEach(ChartType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // Chart Section (conditional based on chart type)
                        if selectedChartType == .bar {
                            BarChartSection(categoryComparisons: categoryComparisons)
                        } else {
                            DonutChartSection(categoryComparisons: categoryComparisons, currencyCode: currencyCode)
                        }

                        // Detailed List Section
                        DetailedListSection(categoryComparisons: categoryComparisons, currencyCode: currencyCode)
                    }
                }
                .padding()
            }
            .navigationTitle("Budget Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Month Picker Section

struct MonthPickerSection: View {
    @Environment(\.theme) private var theme
    @Binding var selectedMonth: Date

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Analysis Period")
                .font(.caption)
                .foregroundStyle(theme.colors.textSecondary)

            HStack {
                Button {
                    selectedMonth = Calendar.current.date(
                        byAdding: .month,
                        value: -1,
                        to: selectedMonth
                    ) ?? selectedMonth
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }

                Spacer()

                Text(monthYearString)
                    .font(.title2.bold())

                Spacer()

                Button {
                    selectedMonth = Calendar.current.date(
                        byAdding: .month,
                        value: 1,
                        to: selectedMonth
                    ) ?? selectedMonth
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding()
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Summary Section

struct SummarySection: View {
    @Environment(\.theme) private var theme
    let totalBudgeted: Decimal
    let totalActual: Decimal
    let totalDifference: Decimal
    var currencyCode: String = "USD"

    var body: some View {
        VStack(spacing: 12) {
            Text("Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                SummaryCard(
                    title: "Total Budgeted",
                    amount: totalBudgeted,
                    color: theme.colors.accent,
                    currencyCode: currencyCode
                )

                SummaryCard(
                    title: "Total Actual",
                    amount: totalActual,
                    color: totalActual > totalBudgeted ? theme.colors.error : theme.colors.success,
                    currencyCode: currencyCode
                )
            }

            SummaryCard(
                title: totalDifference >= 0 ? "Under Budget" : "Over Budget",
                amount: abs(totalDifference),
                color: totalDifference >= 0 ? theme.colors.success : theme.colors.error,
                isFullWidth: true,
                currencyCode: currencyCode
            )
        }
        .padding()
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SummaryCard: View {
    @Environment(\.theme) private var theme
    let title: String
    let amount: Decimal
    let color: Color
    var isFullWidth: Bool = false
    var currencyCode: String = "USD"

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.colors.textSecondary)

            Text(amount, format: .currency(code: currencyCode))
                .font(isFullWidth ? .title2.bold() : .headline.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .padding()
        .background(theme.colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Bar Chart Section

struct BarChartSection: View {
    @Environment(\.theme) private var theme
    let categoryComparisons: [CategoryComparison]

    var body: some View {
        VStack(spacing: 12) {
            Text("Budget vs Actual")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Chart {
                ForEach(categoryComparisons) { comparison in
                    // Budgeted bar
                    BarMark(
                        x: .value("Category", comparison.categoryName),
                        y: .value("Amount", Double(truncating: comparison.budgeted as NSDecimalNumber))
                    )
                    .foregroundStyle(theme.colors.accent)
                    .position(by: .value("Type", "Budgeted"))

                    // Actual bar
                    BarMark(
                        x: .value("Category", comparison.categoryName),
                        y: .value("Amount", Double(truncating: comparison.actual as NSDecimalNumber))
                    )
                    .foregroundStyle(comparison.isOverBudget ? theme.colors.error : theme.colors.success)
                    .position(by: .value("Type", "Actual"))
                }
            }
            .chartLegend(position: .bottom)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 300)
            .padding()
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Donut Chart Section

struct DonutChartSection: View {
    @Environment(\.theme) private var theme
    let categoryComparisons: [CategoryComparison]
    var currencyCode: String = "USD"

    private let maxCategories = 10

    // Prepare data for donut chart, grouping smallest categories into "Other" if needed
    private var chartData: [DonutChartData] {
        // Filter out categories with no actual spending
        let categoriesWithSpending = categoryComparisons.filter { $0.actual > 0 }

        // If we have 10 or fewer categories, show them all
        if categoriesWithSpending.count <= maxCategories {
            return categoriesWithSpending.map { comparison in
                DonutChartData(
                    name: comparison.categoryName,
                    amount: comparison.actual,
                    color: comparison.categoryColor
                )
            }
        }

        // Otherwise, show top 9 categories and group the rest as "Other"
        let sortedByAmount = categoriesWithSpending.sorted { $0.actual > $1.actual }
        let topCategories = Array(sortedByAmount.prefix(maxCategories - 1))
        let otherCategories = Array(sortedByAmount.dropFirst(maxCategories - 1))
        let otherTotal = otherCategories.reduce(Decimal.zero) { $0 + $1.actual }

        var result = topCategories.map { comparison in
            DonutChartData(
                name: comparison.categoryName,
                amount: comparison.actual,
                color: comparison.categoryColor
            )
        }

        if otherTotal > 0 {
            result.append(DonutChartData(
                name: "Other",
                amount: otherTotal,
                color: "999999" // Gray color for "Other"
            ))
        }

        return result
    }

    private var totalSpending: Decimal {
        chartData.reduce(Decimal.zero) { $0 + $1.amount }
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Spending Distribution")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if chartData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundStyle(theme.colors.textSecondary)
                    Text("No spending recorded")
                        .font(.headline)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 16) {
                    // Donut Chart
                    Chart(chartData) { data in
                        SectorMark(
                            angle: .value("Amount", Double(truncating: data.amount as NSDecimalNumber)),
                            innerRadius: .ratio(0.618), // Golden ratio for aesthetics
                            angularInset: 1.5
                        )
                        .foregroundStyle(Color(hex: data.color))
                        .annotation(position: .overlay) {
                            // Only show label if segment is large enough
                            if data.amount / totalSpending > 0.08 {
                                Text(data.name)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            let frame = geometry[chartProxy.plotFrame!]
                            VStack(spacing: 4) {
                                Text("Total")
                                    .font(.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(totalSpending, format: .currency(code: currencyCode))
                                    .font(.title2.bold())
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                    .frame(height: 300)

                    // Legend
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(chartData) { data in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: data.color))
                                    .frame(width: 12, height: 12)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(data.name)
                                        .font(.caption)
                                        .lineLimit(1)

                                    Text(data.amount, format: .currency(code: currencyCode))
                                        .font(.caption2.bold())
                                        .foregroundStyle(theme.colors.textSecondary)
                                }

                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(theme.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// Data structure for donut chart
struct DonutChartData: Identifiable {
    let id = UUID()
    let name: String
    let amount: Decimal
    let color: String
}

// MARK: - Detailed List Section

struct DetailedListSection: View {
    let categoryComparisons: [CategoryComparison]
    var currencyCode: String = "USD"

    var body: some View {
        VStack(spacing: 12) {
            Text("Detailed Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(categoryComparisons) { comparison in
                    CategoryComparisonRow(comparison: comparison, currencyCode: currencyCode)
                }
            }
        }
    }
}

struct CategoryComparisonRow: View {
    @Environment(\.theme) private var theme
    let comparison: CategoryComparison
    var currencyCode: String = "USD"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with category name and status indicator
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: comparison.categoryColor))
                        .frame(width: 12, height: 12)

                    Text(comparison.categoryName)
                        .font(.headline)
                }

                Spacer()

                Image(systemName: comparison.isOverBudget ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(comparison.isOverBudget ? theme.colors.error : theme.colors.success)
            }

            // Metrics grid
            HStack(spacing: 12) {
                MetricColumn(
                    title: "Budgeted",
                    value: comparison.budgeted,
                    color: .primary,
                    currencyCode: currencyCode
                )

                Divider()

                MetricColumn(
                    title: "Actual",
                    value: comparison.actual,
                    color: comparison.isOverBudget ? theme.colors.error : theme.colors.success,
                    currencyCode: currencyCode
                )

                Divider()

                MetricColumn(
                    title: "Difference",
                    value: comparison.difference,
                    color: comparison.difference >= 0 ? theme.colors.success : theme.colors.error,
                    currencyCode: currencyCode
                )

                Divider()

                VStack(spacing: 4) {
                    Text("% Used")
                        .font(.caption)
                        .foregroundStyle(theme.colors.textSecondary)

                    Text(comparison.percentageUsedFormatted)
                        .font(.body.bold())
                        .foregroundStyle(comparison.percentageUsed > 1.0 ? theme.colors.error : theme.colors.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 60)
        }
        .padding()
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MetricColumn: View {
    @Environment(\.theme) private var theme
    let title: String
    let value: Decimal
    let color: Color
    var currencyCode: String = "USD"

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.colors.textSecondary)

            Text(value, format: .currency(code: currencyCode))
                .font(.body.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BudgetAnalysisView()
        .modelContainer(for: [Transaction.self, BudgetCategory.self])
}
