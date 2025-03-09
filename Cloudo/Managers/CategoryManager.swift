import SwiftUI
import CoreData

class CategoryManager {
    static let shared = CategoryManager()
    
    private init() {}
    
    // Enhanced pastel category colors with better contrast against app backgrounds
    let categoryColors: [String] = [
        "#FF9AA2", // Enhanced Pastel Pink
        "#74C0E0", // Enhanced Light Blue
        "#7AE582", // Enhanced Pale Green
        "#FFC17A", // Enhanced Peach
        "#C5A3FF", // Enhanced Lavender
        "#FFE66D", // Enhanced Lemon Chiffon
        "#6EB5C0", // Enhanced Powder Blue
        "#FFBDBD", // Enhanced Misty Rose
        "#A0E7A0", // Enhanced Honeydew
        "#E8D595"  // Enhanced Beige
    ]
    
    // Create default categories if none exist
    func createDefaultCategoriesIfNeeded(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            
            if count == 0 {
                // Create default categories
                let defaultCategories = ["Work", "Personal", "Shopping", "Health", "Finance"]
                
                for (index, name) in defaultCategories.enumerated() {
                    let category = Category(context: context)
                    category.id = UUID()
                    category.name = name
                    category.color = categoryColors[index % categoryColors.count]
                }
                
                try context.save()
            }
        } catch {
            print("Error checking for categories: \(error)")
        }
    }
    
    // Get color from hex string with adjusted opacity for pastel effect
    func color(from hex: String?) -> Color {
        guard let hex = hex else { return .gray.opacity(0.7) }
        
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
    
    // Get a color for text that will contrast with the background color
    func textColor(for backgroundColor: Color, isDarkMode: Bool) -> Color {
        return isDarkMode ? .white.opacity(0.9) : .black.opacity(0.7)
    }
    
    // Get a random color for a new category
    func randomColor() -> String {
        return categoryColors.randomElement() ?? "#FF9AA2"
    }
} 