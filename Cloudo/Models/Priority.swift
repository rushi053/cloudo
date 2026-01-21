//
//  Priority.swift
//  Cloudo
//
//  Task priority levels with vibrant colors
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
        case .low: return CloudoTheme.priorityLow
        case .medium: return CloudoTheme.priorityMedium
        case .high: return CloudoTheme.priorityHigh
        }
    }
    
    /// Fallback colors - now the same as main colors
    var fallbackColor: Color {
        color
    }
}
