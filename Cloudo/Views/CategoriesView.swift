import SwiftUI

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var selectedColorHex = CategoryManager.shared.randomColor()
    @State private var editingCategory: Category?
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?
    @State private var showingDeleteAllAlert = false
    
    var body: some View {
        ZStack {
            themeManager.sheetBackgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.sheetTextColor)
                    
                    Spacer()
                    
                    Text("Categories")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.sheetTextColor)
                    
                    Spacer()
                    
                    Button(action: {
                        editingCategory = nil
                        newCategoryName = ""
                        selectedColorHex = CategoryManager.shared.randomColor()
                        showingAddCategory = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(themeManager.sheetTextColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                Divider()
                    .background(themeManager.secondaryColor.opacity(0.2))
                
                if categories.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Categories",
                        systemImage: "tag",
                        description: Text("Add categories to organize your tasks")
                    )
                    .foregroundStyle(themeManager.sheetTextColor)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(categories) { category in
                                HStack {
                                    Button(action: {
                                        editingCategory = category
                                        newCategoryName = category.name ?? ""
                                        selectedColorHex = category.color ?? CategoryManager.shared.randomColor()
                                        showingAddCategory = true
                                    }) {
                                        HStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(CategoryManager.shared.color(from: category.color))
                                                .frame(width: 16, height: 16)
                                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                            
                                            Text(category.name ?? "Unnamed")
                                                .font(.system(size: 16))
                                                .foregroundColor(themeManager.sheetTextColor)
                                            
                                            Spacer()
                                            
                                            Text("\(category.tasks?.count ?? 0) tasks")
                                                .font(.system(size: 14))
                                                .foregroundColor(themeManager.secondaryColor)
                                        }
                                    }
                                    
                                    // Delete button for individual category
                                    Button(action: {
                                        categoryToDelete = category
                                        showingDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#FF9AA2"))
                                            .padding(.horizontal, 8)
                                    }
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                
                                Divider()
                                    .padding(.leading, 44)
                                    .background(themeManager.secondaryColor.opacity(0.1))
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // Delete all categories button at bottom
                    if !categories.isEmpty {
                        Button(action: {
                            showingDeleteAllAlert = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                Text("Delete All Categories")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "#FF9AA2"))
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#FF9AA2").opacity(themeManager.isDarkMode ? 0.15 : 0.1))
                            )
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            NavigationView {
                ZStack {
                    themeManager.sheetBackgroundColor
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CATEGORY NAME")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                .padding(.leading, 4)
                            
                            TextField("", text: $newCategoryName)
                                .font(.system(size: 16))
                                .placeholder(when: newCategoryName.isEmpty) {
                                    Text("Category Name")
                                        .foregroundColor(themeManager.sheetTextColor.opacity(0.5))
                                }
                                .foregroundColor(themeManager.sheetTextColor)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(themeManager.sheetTextColor.opacity(0.1))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("COLOR")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                .padding(.leading, 4)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                                ForEach(CategoryManager.shared.categoryColors, id: \.self) { colorHex in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(CategoryManager.shared.color(from: colorHex))
                                        .frame(height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(themeManager.sheetTextColor, lineWidth: colorHex == selectedColorHex ? 2 : 0)
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        .onTapGesture {
                                            selectedColorHex = colorHex
                                        }
                                        .overlay(
                                            Group {
                                                if colorHex == selectedColorHex {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                                                        .font(.system(size: 16, weight: .bold))
                                                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 0)
                                                }
                                            }
                                        )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // Preview of the category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PREVIEW")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                .padding(.leading, 4)
                            
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(CategoryManager.shared.color(from: selectedColorHex))
                                    .frame(width: 16, height: 16)
                                
                                Text(newCategoryName.isEmpty ? "Category Name" : newCategoryName)
                                    .foregroundColor(themeManager.sheetTextColor)
                                    .font(.system(size: 16))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.sheetTextColor.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddCategory = false
                        }
                        .foregroundColor(themeManager.sheetTextColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text(editingCategory == nil ? "New Category" : "Edit Category")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(themeManager.sheetTextColor)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveCategory()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(newCategoryName.isEmpty ? themeManager.sheetTextColor.opacity(0.5) : Theme.primaryPastel)
                        .disabled(newCategoryName.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete {
                    deleteCategory(category)
                }
            }
        } message: {
            if let category = categoryToDelete {
                Text("Are you sure you want to delete \"\(category.name ?? "this category")\"?")
            }
        }
        .alert("Delete All Categories", isPresented: $showingDeleteAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllCategories()
            }
        } message: {
            Text("Are you sure you want to delete all categories?")
        }
    }
    
    private func saveCategory() {
        withAnimation {
            if let editingCategory = editingCategory {
                // Update existing category
                editingCategory.name = newCategoryName
                editingCategory.color = selectedColorHex
            } else {
                // Create new category
                let newCategory = Category(context: viewContext)
                newCategory.id = UUID()
                newCategory.name = newCategoryName
                newCategory.color = selectedColorHex
            }
            
            do {
                try viewContext.save()
                showingAddCategory = false
            } catch {
                print("Error saving category: \(error)")
            }
        }
    }
    
    private func deleteCategory(_ category: Category) {
        withAnimation {
            viewContext.delete(category)
            
            do {
                try viewContext.save()
                HapticManager.shared.successFeedback()
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
    private func deleteAllCategories() {
        withAnimation {
            for category in categories {
                viewContext.delete(category)
            }
            
            do {
                try viewContext.save()
                HapticManager.shared.successFeedback()
            } catch {
                print("Error deleting all categories: \(error)")
            }
        }
    }
}

#Preview {
    CategoriesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 
