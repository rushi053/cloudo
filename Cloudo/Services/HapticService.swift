//
//  HapticService.swift
//  Cloudo
//
//  Centralized haptic feedback management
//

import UIKit
import SwiftUI

/// Observable service for haptic feedback - can be used as environment object
final class HapticService: ObservableObject {
    
    // MARK: - Singleton (for services)
    
    static let shared = HapticService()
    
    // MARK: - Properties
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "hapticFeedbackEnabled")
        }
    }
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - Initialization
    
    init() {
        // Load saved preference, default to true
        self.isEnabled = UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
        prepareGenerators()
    }
    
    // MARK: - Public Methods
    
    /// Trigger impact feedback
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        
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
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(type)
    }
    
    /// Trigger selection feedback (for pickers, toggles)
    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    /// Success feedback - completed actions
    func success() {
        notification(.success)
    }
    
    /// Error feedback - failed actions
    func error() {
        notification(.error)
    }
    
    /// Warning feedback - destructive actions
    func warning() {
        notification(.warning)
    }
    
    /// Light tap - button presses
    func tap() {
        impact(.light)
    }
    
    /// Medium tap - important interactions
    func mediumTap() {
        impact(.medium)
    }
    
    /// Prepare generators for reduced latency
    func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
}
