//
//  ImportTransactionsSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/9/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportTransactionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.modelContext) private var modelContext

    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL?
    @State private var selectedFileName: String?
    @State private var selectedFileSize: String?
    @State private var showingColumnMapping = false
    @State private var parsedHeaders: [String] = []
    @State private var parsedRows: [[String]] = []
    @State private var errorMessage: String?
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 48))
                        .iconPrimary()

                    Text("Import Transactions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(themeColors.textPrimary)

                    Text("Select a CSV file exported from your bank")
                        .font(.subheadline)
                        .foregroundStyle(themeColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 32)

                // File selection section
                VStack(spacing: 16) {
                    if let fileName = selectedFileName {
                        // Selected file info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .iconSuccess()
                                Text("Selected File")
                                    .font(.caption)
                                    .foregroundStyle(themeColors.textSecondary)
                            }

                            Text(fileName)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(themeColors.textPrimary)

                            if let fileSize = selectedFileSize {
                                Text(fileSize)
                                    .font(.caption)
                                    .foregroundStyle(themeColors.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(themeColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeColors.success, lineWidth: 1)
                        )

                        // Change file button
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .iconPrimary()
                                Text("Choose Different File")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeColors.surface)
                            .foregroundStyle(themeColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeColors.primary, lineWidth: 1)
                            )
                        }
                    } else {
                        // Choose file button
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 40))
                                    .iconPrimary()

                                Text("Choose CSV File")
                                    .font(.headline)
                                    .foregroundStyle(themeColors.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(32)
                            .background(themeColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeColors.primary, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                            )
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Next button (enabled only when file selected)
                Button(action: parseCSVAndProceed) {
                    HStack {
                        Text("Next")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedFileURL != nil ? themeColors.primary : themeColors.textSecondary.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedFileURL == nil)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(themeColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(themeColors.primary)
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(
                    allowedContentTypes: [.commaSeparatedText, .text],
                    onPick: handleFilePicked
                )
            }
            .sheet(isPresented: $showingColumnMapping) {
                ImportColumnMappingSheet(
                    headers: parsedHeaders,
                    rows: parsedRows,
                    fileURL: selectedFileURL ?? URL(fileURLWithPath: ""),
                    onDismissAll: {
                        // Dismiss column mapping sheet first
                        showingColumnMapping = false
                        // Then dismiss this import transactions sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            dismiss()
                        }
                    }
                )
            }
            .alert("Import Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    // MARK: - File Handling

    private func handleFilePicked(_ url: URL) {
        selectedFileURL = url
        selectedFileName = url.lastPathComponent

        // Get file size
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let fileSize = attributes[.size] as? Int64 {
            selectedFileSize = formatFileSize(fileSize)
        }
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024.0
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        } else {
            let mb = kb / 1024.0
            return String(format: "%.2f MB", mb)
        }
    }

    private func parseCSVAndProceed() {
        guard let fileURL = selectedFileURL else { return }

        do {
            let (headers, rows) = try ImportManager.parseCSV(fileURL)
            parsedHeaders = headers
            parsedRows = rows

            // Show column mapping sheet
            showingColumnMapping = true
        } catch let error as ImportManager.ImportError {
            errorMessage = error.errorDescription
            showingError = true
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            // Copy file to temporary location for processing
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(url.lastPathComponent)

            try? FileManager.default.removeItem(at: tempURL)
            try? FileManager.default.copyItem(at: url, to: tempURL)

            onPick(tempURL)
        }
    }
}

#Preview {
    ImportTransactionsSheet()
        .modelContainer(for: [Transaction.self, BudgetCategory.self, MonthlyBudget.self, Account.self], inMemory: true)
        .environment(ThemeManager())
}
