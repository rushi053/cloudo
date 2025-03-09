import SwiftUI

enum TaskPriority: Int, CaseIterable, Identifiable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    
    var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .none:
            return "None"
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none:
            return "minus.circle"
        case .low:
            return "arrow.down.circle"
        case .medium:
            return "equal.circle"
        case .high:
            return "exclamationmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .none:
            return .gray.opacity(0.5)
        case .low:
            return Color(hex: "#74C0E0") // Light blue
        case .medium:
            return Color(hex: "#FFC17A") // Peach
        case .high:
            return Color(hex: "#FF9AA2") // Pink
        }
    }
} 