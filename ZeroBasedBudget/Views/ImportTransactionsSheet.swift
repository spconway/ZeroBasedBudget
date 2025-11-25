//
//  ImportTransactionsSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/9/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Data struct for sheet(item:) pattern - ensures data is passed at presentation time
struct ImportSheetData: Identifiable {
    let id = UUID()
    let headers: [String]
    let rows: [[String]]
    let fileURL: URL
}

struct ImportTransactionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.modelContext) private var modelContext

    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL?
    @State private var selectedFileName: String?
    @State private var selectedFileSize: String?
    @State private var importSheetData: ImportSheetData?  // Use item-based sheet pattern
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
                    onPick: handleFilePicked,
                    onError: handleFileError
                )
            }
            .sheet(item: $importSheetData) { data in
                ImportColumnMappingSheet(
                    headers: data.headers,
                    rows: data.rows,
                    fileURL: data.fileURL,
                    onDismissAll: {
                        // Dismiss column mapping sheet first
                        importSheetData = nil
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

    private func handleFileError(_ message: String) {
        errorMessage = message
        showingError = true
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
        print("📁 DEBUG parseCSVAndProceed: Called")
        guard let fileURL = selectedFileURL else {
            print("📁 DEBUG parseCSVAndProceed: No file URL selected")
            return
        }

        print("📁 DEBUG parseCSVAndProceed: File URL: \(fileURL)")

        do {
            let (headers, rows) = try ImportManager.parseCSV(fileURL)
            print("📁 DEBUG parseCSVAndProceed: Parsing succeeded")
            print("📁 DEBUG parseCSVAndProceed: Headers: \(headers)")
            print("📁 DEBUG parseCSVAndProceed: Rows count: \(rows.count)")

            // Use item-based sheet pattern to ensure data is passed at presentation time
            // This fixes the closure capture issue on physical iOS devices
            print("📁 DEBUG parseCSVAndProceed: Creating ImportSheetData and showing column mapping sheet")
            importSheetData = ImportSheetData(headers: headers, rows: rows, fileURL: fileURL)
        } catch let error as ImportManager.ImportError {
            print("📁 DEBUG parseCSVAndProceed: ImportError: \(error)")
            errorMessage = error.errorDescription
            showingError = true
        } catch {
            print("📁 DEBUG parseCSVAndProceed: Unexpected error: \(error)")
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onPick: (URL) -> Void
    let onError: (String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onError: onError)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        let onError: (String) -> Void

        init(onPick: @escaping (URL) -> Void, onError: @escaping (String) -> Void) {
            self.onPick = onPick
            self.onError = onError
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("📁 DEBUG: documentPicker called with \(urls.count) URLs")
            guard let url = urls.first else {
                print("📁 DEBUG: No URL in urls array")
                return
            }

            print("📁 DEBUG: Selected URL: \(url)")
            print("📁 DEBUG: URL path: \(url.path)")
            print("📁 DEBUG: URL isFileURL: \(url.isFileURL)")

            // Start accessing security-scoped resource (required on real devices)
            let hasAccess = url.startAccessingSecurityScopedResource()
            print("📁 DEBUG: Security-scoped access granted: \(hasAccess)")

            guard hasAccess else {
                onError("Unable to access the selected file. Please try selecting it again.")
                return
            }

            defer {
                print("📁 DEBUG: Stopping security-scoped access")
                url.stopAccessingSecurityScopedResource()
            }

            // Copy file to temporary location for processing
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(url.lastPathComponent)

            print("📁 DEBUG: Temp URL: \(tempURL)")

            do {
                // Remove existing temp file if present (ignore errors)
                try? FileManager.default.removeItem(at: tempURL)
                // Copy the file - this must succeed
                print("📁 DEBUG: Attempting file copy...")
                try FileManager.default.copyItem(at: url, to: tempURL)
                print("📁 DEBUG: File copied successfully")

                // Verify file exists
                let exists = FileManager.default.fileExists(atPath: tempURL.path)
                print("📁 DEBUG: Temp file exists: \(exists)")

                if let attributes = try? FileManager.default.attributesOfItem(atPath: tempURL.path),
                   let size = attributes[.size] as? Int64 {
                    print("📁 DEBUG: Temp file size: \(size) bytes")
                }

                onPick(tempURL)
            } catch {
                print("📁 DEBUG: File copy ERROR: \(error)")
                print("📁 DEBUG: Error details: \(error.localizedDescription)")
                onError("Unable to copy file: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ImportTransactionsSheet()
        .modelContainer(for: [Transaction.self, BudgetCategory.self, MonthlyBudget.self, Account.self], inMemory: true)
        .environment(ThemeManager())
}
