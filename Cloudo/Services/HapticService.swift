//
//  HapticService.swift
//  Cloudo
//
//  Centralized haptic feedback management
//

import UIKit

/// Singleton service for haptic feedback
final class HapticService {
    
    // MARK: - Singleton
    
    static let shared = HapticService()
    
    // MARK: - Properties
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - Initialization
    
    private init() {
        // Prepare generators for reduced latency
        prepareGenerators()
    }
    
    // MARK: - Public Methods
    
    /// Trigger impact feedback
    /// - Parameter style: The impact style
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        
        switch style {
        case .light:
            lightGenerator.impactOccurred()
        case .medium:
            mediumGenerator.impactOccurred()
        case .heavy:
            heavyGenerator.impactOccurred()
        case .soft:
            lightGenerator.impactOccurred(intensity: 0.5)
        case .rigid:
            heavyGenerator.impactOccurred(intensity: 0.8)
        @unknown default:
            mediumGenerator.impactOccurred()
        }
    }
    
    /// Trigger notification feedback
    /// - Parameter type: The notification type
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(type)
    }
    
    /// Trigger selection feedback (for pickers, etc.)
    func selection() {
        guard isHapticsEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    /// Success feedback - use for completed actions
    func success() {
        notification(.success)
    }
    
    /// Error feedback - use for failed actions
    func error() {
        notification(.error)
    }
    
    /// Warning feedback - use for destructive actions
    func warning() {
        notification(.warning)
    }
    
    /// Light tap - use for button presses
    func tap() {
        impact(.light)
    }
    
    /// Prepare generators for upcoming feedback
    func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Private Properties
    
    private var isHapticsEnabled: Bool {
        // Default to true if not set
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }
}
