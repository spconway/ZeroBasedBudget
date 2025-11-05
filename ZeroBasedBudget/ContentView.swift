//
//  ContentView.swift
//  ZeroBasedBudget
//
//  Created by Stephen Conway on 11/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Accounts (NEW - YNAB-style account tracking)
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "banknote")
                }
                .tag(0)

            // Tab 1: Budget (moved from tab 0)
            BudgetPlanningView()
                .tabItem {
                    Label("Budget", systemImage: "dollarsign.circle")
                }
                .tag(1)

            // Tab 2: Transactions (moved from tab 1)
            TransactionLogView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
                .tag(2)

            // Tab 3: Analysis (moved from tab 2)
            BudgetAnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar")
                }
                .tag(3)

            // Tab 4: Settings (NEW - placeholder for Enhancement 3.2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}
