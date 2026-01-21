//
//  DesignSystem.swift
//  Cloudo
//
//  Centralized design system for consistent UI
//

import SwiftUI

// MARK: - Design Tokens

/// Core design tokens for the app
enum Design {
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 100
    }
    
    // MARK: - Typography
    
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        static let sm = (color: Color.black.opacity(0.05), radius: CGFloat(4), y: CGFloat(2))
        static let md = (color: Color.black.opacity(0.08), radius: CGFloat(8), y: CGFloat(4))
        static let lg = (color: Color.black.opacity(0.12), radius: CGFloat(16), y: CGFloat(8))
    }
}

// MARK: - Color Theme

/// App color theme - adapts to light/dark mode automatically
struct CloudoTheme {
    
    // MARK: - Brand Colors
    
    /// Primary brand color - vibrant blue
    static let primary = Color(red: 0.35, green: 0.55, blue: 0.95)
    
    /// Secondary brand color
    static let secondary = Color(red: 0.55, green: 0.65, blue: 0.85)
    
    /// Accent color for highlights
    static let accent = Color(red: 0.95, green: 0.55, blue: 0.35)
    
    // MARK: - System Semantic Colors (auto-adapt to light/dark)
    
    /// Background colors
    static let background = Color(UIColor.systemBackground)
    static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let backgroundTertiary = Color(UIColor.tertiarySystemBackground)
    
    /// Text colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    /// Semantic colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // MARK: - Category Colors
    
    static let categoryColors: [Color] = [
        Color(red: 1.0, green: 0.6, blue: 0.6),     // Coral
        Color(red: 1.0, green: 0.8, blue: 0.5),     // Peach
        Color(red: 0.95, green: 0.9, blue: 0.5),    // Yellow
        Color(red: 0.6, green: 0.9, blue: 0.6),     // Mint
        Color(red: 0.5, green: 0.8, blue: 0.9),     // Sky
        Color(red: 0.7, green: 0.6, blue: 0.9),     // Lavender
        Color(red: 0.9, green: 0.6, blue: 0.8),     // Pink
        Color(red: 0.7, green: 0.7, blue: 0.75),    // Gray
    ]
    
    static let categoryColorHexes: [String] = [
        "#FF9999", "#FFD699", "#F2E680", "#99E699",
        "#80CCE6", "#B399E6", "#E699CC", "#B3B3BF"
    ]
}

// MARK: - View Extensions

extension View {
    
    /// Apply card styling
    func cardStyle() -> some View {
        self
            .background(CloudoTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
            .shadow(
                color: Design.Shadow.sm.color,
                radius: Design.Shadow.sm.radius,
                y: Design.Shadow.sm.y
            )
    }
    
    /// Apply button press effect
    func pressable(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(Design.Animation.quick, value: isPressed)
    }
    
    /// Apply standard padding
    func standardPadding() -> some View {
        self.padding(Design.Spacing.lg)
    }
    
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Color Extensions

extension Color {
    
    /// Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Placeholder Extension

extension View {
    /// Custom placeholder modifier
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
