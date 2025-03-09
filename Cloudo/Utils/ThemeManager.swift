import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode: Bool = false
    
    private init() {}
    
    // Main view colors
    var backgroundColor: Color {
        isDarkMode ? Theme.textPrimary : Theme.backgroundPastel
    }
    
    var textColor: Color {
        isDarkMode ? Theme.backgroundPastel : Theme.textPrimary
    }
    
    var secondaryColor: Color {
        isDarkMode ? Theme.backgroundPastel.opacity(0.8) : Theme.textSecondary
    }
    
    // Sheet colors (inverted from main view)
    var sheetBackgroundColor: Color {
        isDarkMode ? Theme.backgroundPastel : Theme.textPrimary
    }
    
    var sheetTextColor: Color {
        isDarkMode ? Theme.textPrimary : Theme.backgroundPastel
    }
    
    var sheetSecondaryColor: Color {
        isDarkMode ? Theme.textSecondary : Theme.backgroundPastel.opacity(0.8)
    }
    
    var inputBackground: Color {
        isDarkMode ? Theme.backgroundPastel.opacity(0.1) : Theme.textPrimary
    }
    
    func toggleTheme() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isDarkMode.toggle()
            HapticManager.shared.mediumTapFeedback()
        }
    }
} 