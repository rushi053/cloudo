//
//  SortOption.swift
//  Cloudo
//
//  Defines sorting options for tasks
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case dateCreated = "Date Created"
    case dueDate = "Due Date"
    case priority = "Priority"
    case alphabetical = "Alphabetical"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dateCreated: return "clock"
        case .dueDate: return "calendar"
        case .priority: return "flag"
        case .alphabetical: return "textformat.abc"
        }
    }
    
    var isAscending: Bool {
        switch self {
        case .alphabetical: return true
        default: return false
        }
    }
}
