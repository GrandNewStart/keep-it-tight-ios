//
//  SettingsView.swift
//  ledger
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("appAppearance") private var appearanceSetting: String = AppAppearance.light.rawValue

    var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceSetting) ?? .light
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [Expense]
    @State private var exportFile: URL?
    @State private var exportDocument: FileDocumentWrapper?
    @State private var showExporter: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showImporter: Bool = false
    @State private var importedExpenses: [Expense] = []
    @State private var showImportOptionsAlert: Bool = false
    @State private var importMessage: String = ""
    @State private var showImportErrorAlert: Bool = false
    @State private var selectedImportURL: URL?
    @State private var showTag = false
    
    var body: some View {
        List {
            Picker("화면 모드", selection: $appearanceSetting) {
                Text("라이트 모드").tag(AppAppearance.light.rawValue)
                Text("다크 모드").tag(AppAppearance.dark.rawValue)
            }
            .pickerStyle(.inline)
            Button("데이터 내보내기") {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                encoder.dateEncodingStrategy = .iso8601

                do {
                    let data = try encoder.encode(expenses)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyMMdd-HHmmss"
                    let timestamp = formatter.string(from: Date())
                    let tempDir = FileManager.default.temporaryDirectory
                    let fileName = "정신차려\(timestamp).json"
                    let fileURL = tempDir.appendingPathComponent(fileName)
                    try data.write(to: fileURL)
                    exportDocument = FileDocumentWrapper(url: fileURL)
                    exportFile = fileURL
                    showExporter = true
                } catch {
                    print("Failed to encode or write JSON: \(error)")
                }
            }

            Button("데이터 읽어오기") {
                showImporter = true
            }

            Button("태그 관리") {
                showTag = true
            }

            Button("초기화", role: .destructive) {
                for expense in expenses {
                    modelContext.delete(expense)
                }
                TagManager.clear()
            }
        }
        .fileExporter(
            isPresented: $showExporter,
            document: exportDocument ?? FileDocumentWrapper(url: FileManager.default.temporaryDirectory.appendingPathComponent("dummy.json")),
            contentType: .json,
            defaultFilename: exportDocument?.url.lastPathComponent ?? "정신차려.json"
        ) { result in
            switch result {
            case .success:
                showSuccessAlert = true
            case .failure(let error):
                print("Export failed: \(error)")
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                selectedImportURL = url
                do {
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        let data = try Data(contentsOf: url)
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let items = try decoder.decode([Expense].self, from: data)
                        importedExpenses = items

                        let currentIDs = Set(expenses.map { $0.id })
                        let newIDs = Set(items.map { $0.id })
                        let duplicates = currentIDs.intersection(newIDs)

                        importMessage = "총 \(items.count)개의 항목을 불러왔습니다."
                        if !duplicates.isEmpty {
                            importMessage += "\n\(duplicates.count)개의 항목이 기존 데이터와 중복됩니다."
                        }
                        showImportOptionsAlert = true
                    } else {
                        // PERMISSION ERROR
                    }
                } catch {
                    showImportErrorAlert = true
                }

            case .failure(let error):
                print("Import failed: \(error)")
                showImportErrorAlert = true
            }
        }
        .alert("내보내기 완료", isPresented: $showSuccessAlert) {
            Button("확인", role: .cancel) { }
        }
        .alert("불러오기 실패", isPresented: $showImportErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("파일을 읽을 수 없거나, 형식이 올바르지 않습니다.")
        }
        .alert("불러오기 확인", isPresented: $showImportOptionsAlert) {
            Button("모두 병합") {
                importedExpenses.forEach { modelContext.insert($0) }
            }
            Button("새로운 항목만") {
                let existingIDs = Set(expenses.map { $0.id })
                let filtered = importedExpenses.filter { !existingIDs.contains($0.id) }
                filtered.forEach { modelContext.insert($0) }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text(importMessage)
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showTag) {
            TagView()
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Expense.self, configurations: config)

    let context = container.mainContext
    context.insert(Expense(cost: 12000, name: "커피", tag: "내 카드", date: String(Date.now.timeIntervalSince1970)))
    context.insert(Expense(cost: 55000, name: "식사", tag: "법인 카드", date: String(Date.now.timeIntervalSince1970)))
    context.insert(Expense(cost: 8000, name: "버스", tag: "아빠 카드", date: String(Date.now.timeIntervalSince1970)))

    return SettingsView()
        .modelContainer(container)
}

struct FileDocumentWrapper: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var url: URL

    init(url: URL) {
        self.url = url
    }

    init(configuration: ReadConfiguration) throws {
        fatalError("init(configuration:) has not been implemented")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url)
    }
}
