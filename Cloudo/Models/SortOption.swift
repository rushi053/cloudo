//
//  SortOption.swift
//  Cloudo
//
//  Defines sorting options for tasks
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case dueDate = "dueDate"
    case priority = "priority"
    case dateCreated = "dateCreated"
    case alphabetical = "alphabetical"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .dueDate: return "Due Date"
        case .priority: return "Priority"
        case .dateCreated: return "Date Created"
        case .alphabetical: return "Alphabetical"
        }
    }
    
    var icon: String {
        switch self {
        case .dueDate: return "calendar"
        case .priority: return "flag"
        case .dateCreated: return "clock"
        case .alphabetical: return "textformat.abc"
        }
    }
}
