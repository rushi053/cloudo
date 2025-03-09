import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Light tap feedback for subtle interactions
    func lightTapFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Medium tap feedback for standard interactions
    func mediumTapFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Success feedback for completed actions
    func successFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
} 