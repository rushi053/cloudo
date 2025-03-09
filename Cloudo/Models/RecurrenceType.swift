import Foundation

enum RecurrenceType: Int, CaseIterable, Identifiable {
    case none = 0
    case hourly = 1
    case daily = 2
    case weekly = 3
    case monthly = 4
    case yearly = 5
    
    var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .none:
            return "None"
        case .hourly:
            return "Hourly"
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none:
            return "xmark.circle"
        case .hourly:
            return "clock"
        case .daily:
            return "calendar.day.timeline.left"
        case .weekly:
            return "calendar.badge.clock"
        case .monthly:
            return "calendar"
        case .yearly:
            return "calendar.circle"
        }
    }
    
    var shortName: String {
        switch self {
        case .none:
            return ""
        case .hourly:
            return "1h"
        case .daily:
            return "1d"
        case .weekly:
            return "1w"
        case .monthly:
            return "1m"
        case .yearly:
            return "1y"
        }
    }
    
    func nextDate(from date: Date) -> Date? {
        guard self != .none else { return nil }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch self {
        case .hourly:
            dateComponents.hour = 1
        case .daily:
            dateComponents.day = 1
        case .weekly:
            dateComponents.day = 7
        case .monthly:
            dateComponents.month = 1
        case .yearly:
            dateComponents.year = 1
        case .none:
            return nil
        }
        
        return calendar.date(byAdding: dateComponents, to: date)
    }
    
    func description(for date: Date) -> String {
        let formatter = DateFormatter()
        
        switch self {
        case .none:
            return "No recurrence"
        case .hourly:
            return "Repeats every hour"
        case .daily:
            return "Repeats daily"
        case .weekly:
            formatter.dateFormat = "EEEE"
            let dayOfWeek = formatter.string(from: date)
            return "Repeats every \(dayOfWeek)"
        case .monthly:
            formatter.dateFormat = "d"
            let dayOfMonth = formatter.string(from: date)
            return "Repeats on day \(dayOfMonth) of each month"
        case .yearly:
            formatter.dateFormat = "MMMM d"
            let monthAndDay = formatter.string(from: date)
            return "Repeats annually on \(monthAndDay)"
        }
    }
} 