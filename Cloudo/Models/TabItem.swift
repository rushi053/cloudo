import SwiftUI

enum TabItem: Int, CaseIterable {
    case active = 0
    case completed = 1
    case all = 2
    
    var title: String {
        switch self {
        case .active: return "Active"
        case .completed: return "Completed"
        case .all: return "All"
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "list.bullet.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .all: return "tray.fill"
        }
    }
} 