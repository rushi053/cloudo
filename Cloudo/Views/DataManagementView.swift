import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct DataManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    @State private var showingExportAlert = false
    @State private var showingImportAlert = false
    @State private var showingDeleteAlert = false
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportMessage = ""
    @State private var importMessage = ""
    
    var body: some View {
        ZStack {
            themeManager.sheetBackgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Warning Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("IMPORTANT")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                            .padding(.leading, 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color(hex: "#FF9AA2"))
                                Text("Your data is stored locally on your device. If you delete the app, your data will be permanently lost.")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.sheetTextColor)
                            }
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(Theme.primaryPastel)
                                Text("Regularly export your data to keep a backup.")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.sheetTextColor)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.sheetTextColor.opacity(0.1))
                        )
                    }
                    
                    // Export/Import Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DATA MANAGEMENT")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                            .padding(.leading, 4)
                        
                        VStack(spacing: 12) {
                            // Export Button
                            Button(action: {
                                exportData()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18))
                                    Text("Export All Data")
                                        .font(.system(size: 16, weight: .medium))
                                    Spacer()
                                    if isExporting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: themeManager.sheetTextColor))
                                    }
                                }
                                .foregroundColor(themeManager.sheetTextColor)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(themeManager.sheetTextColor.opacity(0.1))
                                )
                            }
                            .disabled(isExporting || isImporting)
                            
                            // Import Button
                            Button(action: {
                                importData()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 18))
                                    Text("Import Backup")
                                        .font(.system(size: 16, weight: .medium))
                                    Spacer()
                                    if isImporting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: themeManager.sheetTextColor))
                                    }
                                }
                                .foregroundColor(themeManager.sheetTextColor)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(themeManager.sheetTextColor.opacity(0.1))
                                )
                            }
                            .disabled(isExporting || isImporting)
                        }
                        
                        if !exportMessage.isEmpty {
                            Text(exportMessage)
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                .padding(.top, 8)
                        }
                        
                        if !importMessage.isEmpty {
                            Text(importMessage)
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                .padding(.top, 8)
                        }
                    }
                    
                    // Stats Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DATA STATISTICS")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                            .padding(.leading, 4)
                        
                        VStack(spacing: 12) {
                            StatRow(title: "Total Tasks", value: "\(tasks.count)")
                            StatRow(title: "Categories", value: "\(categories.count)")
                            StatRow(title: "Completed Tasks", value: "\(tasks.filter { $0.completed }.count)")
                            StatRow(title: "Recurring Tasks", value: "\(tasks.filter { $0.isRecurring }.count)")
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.sheetTextColor.opacity(0.1))
                        )
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(themeManager.sheetTextColor)
            }
            
            ToolbarItem(placement: .principal) {
                Text("Data Management")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeManager.sheetTextColor)
            }
        }
        .fileExporter(
            isPresented: $showingExportAlert,
            document: JSONDocument(data: prepareExportData()),
            contentType: .json,
            defaultFilename: "Cloudo_Backup_\(Date().formatted(.dateTime.year().month().day().hour().minute()))"
        ) { result in
            switch result {
            case .success(let url):
                exportMessage = "Backup saved successfully to: \(url.lastPathComponent)"
            case .failure(let error):
                exportMessage = "Failed to save backup: \(error.localizedDescription)"
            }
            isExporting = false
        }
        .fileImporter(
            isPresented: $showingImportAlert,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importData(from: url)
                }
            case .failure(let error):
                importMessage = "Failed to import backup: \(error.localizedDescription)"
                isImporting = false
            }
        }
    }
    
    private func prepareExportData() -> Data {
        var exportData: [String: Any] = [:]
        
        // Export tasks
        let tasksData = tasks.map { task in
            [
                "id": task.id?.uuidString ?? "",
                "title": task.title ?? "",
                "description": task.taskDescription ?? "",
                "completed": task.completed,
                "createdAt": task.createdAt?.timeIntervalSince1970 ?? 0,
                "reminderDate": task.reminderDate?.timeIntervalSince1970 ?? 0,
                "priority": task.priority,
                "category": task.category?.name ?? "",
                "isRecurring": task.isRecurring,
                "recurrenceType": task.recurrenceType,
                "lastCompletedDate": task.lastCompletedDate?.timeIntervalSince1970 ?? 0
            ]
        }
        
        // Export categories
        let categoriesData = categories.map { category in
            [
                "id": category.id?.uuidString ?? "",
                "name": category.name ?? "",
                "color": category.color ?? ""
            ]
        }
        
        exportData["tasks"] = tasksData
        exportData["categories"] = categoriesData
        exportData["exportDate"] = Date().timeIntervalSince1970
        
        return try! JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    private func exportData() {
        isExporting = true
        exportMessage = "Preparing backup..."
        showingExportAlert = true
    }
    
    private func importData() {
        isImporting = true
        importMessage = "Select backup file to import..."
        showingImportAlert = true
    }
    
    private func importData(from url: URL) {
        do {
            // Start file access coordination
            guard url.startAccessingSecurityScopedResource() else {
                importMessage = "Failed to access the backup file. Please ensure you have permission to access this file."
                isImporting = false
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            let data: Data
            do {
                data = try Data(contentsOf: url)
            } catch {
                importMessage = "Failed to read the backup file: \(error.localizedDescription)"
                isImporting = false
                return
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                importMessage = "Invalid backup file format. Please ensure you're using a valid Cloudo backup file."
                isImporting = false
                return
            }
            
            // Clear existing data
            clearExistingData()
            
            // Import categories first
            if let categoriesData = json["categories"] as? [[String: Any]] {
                for categoryData in categoriesData {
                    let category = Category(context: viewContext)
                    category.id = UUID(uuidString: categoryData["id"] as? String ?? UUID().uuidString)
                    category.name = categoryData["name"] as? String
                    category.color = categoryData["color"] as? String
                }
            }
            
            // Save categories first to ensure they exist for task relationships
            try viewContext.save()
            
            // Import tasks
            if let tasksData = json["tasks"] as? [[String: Any]] {
                for taskData in tasksData {
                    let task = Task(context: viewContext)
                    task.id = UUID(uuidString: taskData["id"] as? String ?? UUID().uuidString)
                    task.title = taskData["title"] as? String
                    task.taskDescription = taskData["description"] as? String
                    task.completed = taskData["completed"] as? Bool ?? false
                    if let createdAt = taskData["createdAt"] as? TimeInterval {
                        task.createdAt = Date(timeIntervalSince1970: createdAt)
                    }
                    if let reminderDate = taskData["reminderDate"] as? TimeInterval {
                        task.reminderDate = Date(timeIntervalSince1970: reminderDate)
                    }
                    task.priority = taskData["priority"] as? Int16 ?? 0
                    task.isRecurring = taskData["isRecurring"] as? Bool ?? false
                    task.recurrenceType = taskData["recurrenceType"] as? Int16 ?? 0
                    if let lastCompletedDate = taskData["lastCompletedDate"] as? TimeInterval {
                        task.lastCompletedDate = Date(timeIntervalSince1970: lastCompletedDate)
                    }
                    
                    // Set category relationship
                    if let categoryName = taskData["category"] as? String,
                       let category = categories.first(where: { $0.name == categoryName }) {
                        task.category = category
                    }
                }
            }
            
            try viewContext.save()
            importMessage = "Data imported successfully!"
        } catch {
            print("Import error: \(error)")
            importMessage = "Failed to import backup: \(error.localizedDescription)"
        }
        isImporting = false
    }
    
    private func clearExistingData() {
        // Delete all existing tasks
        for task in tasks {
            viewContext.delete(task)
        }
        
        // Delete all existing categories
        for category in categories {
            viewContext.delete(category)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error clearing existing data: \(error)")
        }
    }
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.sheetTextColor)
        }
    }
} 