//
//  SettingsView.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI

/// Placeholder settings view for Enhancement 3.2
///
/// This view will be fully implemented in Enhancement 3.2 with:
/// - Appearance settings (dark mode)
/// - Currency & formatting
/// - Budget behavior
/// - Notifications
/// - Data management (export/import)
/// - About section
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Coming Soon", systemImage: "gear")
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Settings")
                } footer: {
                    Text("Comprehensive settings will be available in v1.4.0 (Enhancement 3.2)")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.4.0-dev")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("v1.4.0-alpha")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
