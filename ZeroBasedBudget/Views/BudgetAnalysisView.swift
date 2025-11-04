//
//  BudgetAnalysisView.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import SwiftUI
import SwiftData
import Charts

struct BudgetAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTransactions: [Transaction]
    @Query private var categories: [BudgetCategory]

    @State private var selectedMonth = Date()

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
                            totalDifference: totalDifference
                        )

                        // Chart Section
                        ChartSection(categoryComparisons: categoryComparisons)

                        // Detailed List Section
                        DetailedListSection(categoryComparisons: categoryComparisons)
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
                .foregroundStyle(.secondary)

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
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Summary Section

struct SummarySection: View {
    let totalBudgeted: Decimal
    let totalActual: Decimal
    let totalDifference: Decimal

    var body: some View {
        VStack(spacing: 12) {
            Text("Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                SummaryCard(
                    title: "Total Budgeted",
                    amount: totalBudgeted,
                    color: .blue
                )

                SummaryCard(
                    title: "Total Actual",
                    amount: totalActual,
                    color: totalActual > totalBudgeted ? .red : .green
                )
            }

            SummaryCard(
                title: totalDifference >= 0 ? "Under Budget" : "Over Budget",
                amount: abs(totalDifference),
                color: totalDifference >= 0 ? .green : .red,
                isFullWidth: true
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Decimal
    let color: Color
    var isFullWidth: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(amount, format: .currency(code: "USD"))
                .font(isFullWidth ? .title2.bold() : .headline.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Chart Section

struct ChartSection: View {
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
                    .foregroundStyle(.blue)
                    .position(by: .value("Type", "Budgeted"))

                    // Actual bar
                    BarMark(
                        x: .value("Category", comparison.categoryName),
                        y: .value("Amount", Double(truncating: comparison.actual as NSDecimalNumber))
                    )
                    .foregroundStyle(comparison.isOverBudget ? .red : .green)
                    .position(by: .value("Type", "Actual"))
                }
            }
            .chartLegend(position: .bottom)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 300)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Detailed List Section

struct DetailedListSection: View {
    let categoryComparisons: [CategoryComparison]

    var body: some View {
        VStack(spacing: 12) {
            Text("Detailed Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(categoryComparisons) { comparison in
                    CategoryComparisonRow(comparison: comparison)
                }
            }
        }
    }
}

struct CategoryComparisonRow: View {
    let comparison: CategoryComparison

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
                    .foregroundStyle(comparison.isOverBudget ? .red : .green)
            }

            // Metrics grid
            HStack(spacing: 12) {
                MetricColumn(
                    title: "Budgeted",
                    value: comparison.budgeted,
                    color: .primary
                )

                Divider()

                MetricColumn(
                    title: "Actual",
                    value: comparison.actual,
                    color: comparison.isOverBudget ? .red : .green
                )

                Divider()

                MetricColumn(
                    title: "Difference",
                    value: comparison.difference,
                    color: comparison.difference >= 0 ? .green : .red
                )

                Divider()

                VStack(spacing: 4) {
                    Text("% Used")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(comparison.percentageUsedFormatted)
                        .font(.body.bold())
                        .foregroundStyle(comparison.percentageUsed > 1.0 ? .red : .primary)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 60)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MetricColumn: View {
    let title: String
    let value: Decimal
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value, format: .currency(code: "USD"))
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
