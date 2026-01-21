import Foundation

enum RecurrenceType: Int, CaseIterable, Identifiable {
    case none = 0
    case hourly = 3
    case daily = 4
    case weekdays = 5
    case weekends = 6
    case weekly = 7
    case fifteenDays = 8
    case monthly = 9
    case quarterly = 10
    case yearly = 11
    
    var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .none:
            return "None"
        case .hourly:
            return "Hourly"
        case .daily:
            return "Daily"
        case .weekdays:
            return "Weekdays"
        case .weekends:
            return "Weekends"
        case .weekly:
            return "Weekly"
        case .fifteenDays:
            return "Every 15 Days"
        case .monthly:
            return "Monthly"
        case .quarterly:
            return "Quarterly"
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
        case .weekdays:
            return "calendar.badge.plus"
        case .weekends:
            return "calendar.badge.minus"
        case .weekly:
            return "calendar.badge.clock"
        case .fifteenDays:
            return "calendar.badge.exclamationmark"
        case .monthly:
            return "calendar"
        case .quarterly:
            return "calendar.badge.checkmark"
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
        case .weekdays:
            return "WD"
        case .weekends:
            return "WE"
        case .weekly:
            return "1w"
        case .fifteenDays:
            return "15d"
        case .monthly:
            return "1m"
        case .quarterly:
            return "3m"
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
        case .weekdays:
            // Find next weekday
            var nextDate = date
            repeat {
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            } while calendar.isDateInWeekend(nextDate)
            return nextDate
        case .weekends:
            // Find next weekend day
            var nextDate = date
            repeat {
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            } while !calendar.isDateInWeekend(nextDate)
            return nextDate
        case .weekly:
            dateComponents.day = 7
        case .fifteenDays:
            dateComponents.day = 15
        case .monthly:
            dateComponents.month = 1
        case .quarterly:
            dateComponents.month = 3
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
        case .weekdays:
            return "Repeats on weekdays (Mon-Fri)"
        case .weekends:
            return "Repeats on weekends (Sat-Sun)"
        case .weekly:
            formatter.dateFormat = "EEEE"
            let dayOfWeek = formatter.string(from: date)
            return "Repeats every \(dayOfWeek)"
        case .fifteenDays:
            return "Repeats every 15 days"
        case .monthly:
            formatter.dateFormat = "d"
            let dayOfMonth = formatter.string(from: date)
            return "Repeats on day \(dayOfMonth) of each month"
        case .quarterly:
            formatter.dateFormat = "MMMM d"
            let monthAndDay = formatter.string(from: date)
            return "Repeats quarterly on \(monthAndDay)"
        case .yearly:
            formatter.dateFormat = "MMMM d"
            let monthAndDay = formatter.string(from: date)
            return "Repeats annually on \(monthAndDay)"
        }
    }
} 
