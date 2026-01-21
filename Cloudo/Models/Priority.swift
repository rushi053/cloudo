//
//  Priority.swift
//  Cloudo
//
//  Task priority levels with vibrant colors
//

import SwiftUI

enum Priority: String, CaseIterable, Identifiable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return CloudoTheme.lime
        case .medium: return CloudoTheme.peach
        case .high: return CloudoTheme.salmon
        }
    }
    
    /// Sort order (higher value = higher priority)
    var sortOrder: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }
}
