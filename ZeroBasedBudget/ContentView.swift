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
            BudgetPlanningView()
                .tabItem {
                    Label("Budget", systemImage: "dollarsign.circle")
                }
                .tag(0)

            TransactionLogView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
                .tag(1)

            BudgetAnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
