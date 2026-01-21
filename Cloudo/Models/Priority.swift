//
//  Priority.swift
//  Cloudo
//
//  Task priority levels with associated colors and icons
//

import SwiftUI

enum Priority: Int16, CaseIterable, Identifiable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    
    var id: Int16 { rawValue }
    
    var name: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "minus"
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return Color(.systemGray4)
        case .low: return Color("LowPriority")
        case .medium: return Color("MediumPriority")
        case .high: return Color("HighPriority")
        }
    }
    
    /// Fallback colors if asset colors aren't set
    var fallbackColor: Color {
        switch self {
        case .none: return Color(.systemGray4)
        case .low: return Color(red: 0.45, green: 0.75, blue: 0.88) // Soft blue
        case .medium: return Color(red: 1.0, green: 0.76, blue: 0.48) // Warm orange
        case .high: return Color(red: 0.96, green: 0.49, blue: 0.49) // Soft red
        }
    }
}
