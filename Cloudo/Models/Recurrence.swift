//
//  Recurrence.swift
//  Cloudo
//
//  Defines recurrence patterns for recurring tasks
//

import Foundation

enum Recurrence: Int16, CaseIterable, Identifiable {
    case none = 0
    case daily = 1
    case weekly = 2
    case biweekly = 3
    case monthly = 4
    case yearly = 5
    
    var id: Int16 { rawValue }
    
    var name: String {
        switch self {
        case .none: return "Never"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Every 2 Weeks"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var shortName: String {
        switch self {
        case .none: return ""
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Biweekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "xmark"
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .biweekly: return "calendar"
        case .monthly: return "calendar.circle"
        case .yearly: return "sparkles"
        }
    }
    
    /// Calculate the next occurrence date from a given date
    /// - Parameter date: The reference date
    /// - Returns: The next occurrence date, or nil if non-recurring
    func nextDate(from date: Date) -> Date? {
        guard self != .none else { return nil }
        
        let calendar = Calendar.current
        
        switch self {
        case .none:
            return nil
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        }
    }
    
    /// Human-readable description of when the task recurs
    /// - Parameter date: The reference date for context
    /// - Returns: A description string
    func description(for date: Date) -> String {
        let formatter = DateFormatter()
        
        switch self {
        case .none:
            return "Does not repeat"
        case .daily:
            return "Every day"
        case .weekly:
            formatter.dateFormat = "EEEE"
            return "Every \(formatter.string(from: date))"
        case .biweekly:
            formatter.dateFormat = "EEEE"
            return "Every other \(formatter.string(from: date))"
        case .monthly:
            formatter.dateFormat = "d"
            let day = formatter.string(from: date)
            return "Monthly on the \(day.ordinal)"
        case .yearly:
            formatter.dateFormat = "MMMM d"
            return "Every year on \(formatter.string(from: date))"
        }
    }
}

// MARK: - String Extension for Ordinals

private extension String {
    var ordinal: String {
        guard let number = Int(self) else { return self }
        
        let suffix: String
        let ones = number % 10
        let tens = (number / 10) % 10
        
        if tens == 1 {
            suffix = "th"
        } else {
            switch ones {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        
        return "\(number)\(suffix)"
    }
}
