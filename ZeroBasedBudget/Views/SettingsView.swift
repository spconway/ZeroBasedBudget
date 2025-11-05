//
//  SettingsView.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI
import SwiftData

/// Settings view with dark mode toggle and app information
///
/// Enhanced with Enhancement 3.3: Dark Mode Support
/// Full implementation coming in Enhancement 3.2
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]

    /// Get or create singleton settings
    private var appSettings: AppSettings {
        if let existing = settings.first {
            return existing
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Appearance Section (Enhancement 3.3)
                Section {
                    Picker("Appearance", selection: Binding(
                        get: { appSettings.colorSchemePreference },
                        set: { newValue in
                            appSettings.colorSchemePreference = newValue
                            appSettings.lastModifiedDate = Date()
                        }
                    )) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose your preferred color scheme. System will match your device settings.")
                }

                // Coming Soon Section
                Section {
                    Label("More settings coming soon", systemImage: "gear")
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Additional Settings")
                } footer: {
                    Text("Currency, formatting, notifications, and data management will be available in Enhancement 3.2")
                }

                // About Section
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
                        Text("Enhancement 3.3")
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
        .modelContainer(for: AppSettings.self, inMemory: true)
}
