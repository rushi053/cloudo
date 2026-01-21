//
//  DesignSystem.swift
//  Cloudo
//
//  Bold, colorful design system inspired by modern app aesthetics
//

import SwiftUI

// MARK: - Design Tokens

enum Design {
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let huge: CGFloat = 56
    }
    
    // MARK: - Corner Radius
    
    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 32
        static let full: CGFloat = 100
    }
    
    // MARK: - Typography (SF Pro Display style)
    
    enum Typography {
        // Large display titles
        static let huge = Font.system(size: 48, weight: .bold, design: .default)
        static let largeTitle = Font.system(size: 36, weight: .bold, design: .default)
        static let title = Font.system(size: 28, weight: .bold, design: .default)
        static let title2 = Font.system(size: 24, weight: .bold, design: .default)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        
        // Body text
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let callout = Font.system(size: 15, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
        
        // Small text
        static let footnote = Font.system(size: 13, weight: .medium, design: .default)
        static let caption = Font.system(size: 12, weight: .medium, design: .default)
        static let caption2 = Font.system(size: 11, weight: .semibold, design: .default)
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.65)
        static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
}

// MARK: - Color Theme (Behance-inspired palette)

struct CloudoTheme {
    
    // MARK: - Core Palette
    
    /// Light background
    static let smokyWhite = Color(hex: "#EFF0F6")
    
    /// Lavender purple for cards
    static let purple = Color(hex: "#D9B8F3")
    
    /// Lime/yellow-green for cards
    static let lime = Color(hex: "#DFF37D")
    
    /// Dark color for text and tab bar
    static let jetBlack = Color(hex: "#292B2D")
    
    /// Royal blue accent
    static let royalBlue = Color(hex: "#4558C8")
    
    /// Salmon orange for cards
    static let salmon = Color(hex: "#EE5E37")
    
    // MARK: - Extended Palette
    
    static let softPink = Color(hex: "#F5D0E0")
    static let mint = Color(hex: "#B8E6D4")
    static let sky = Color(hex: "#B8D4F0")
    static let peach = Color(hex: "#FFD4B8")
    
    // MARK: - Backgrounds
    
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#121214")
                : UIColor(hex: "#FFFFFF")
        })
    }
    
    static var secondaryBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: "#1C1C1E")
                : UIColor(hex: "#F5F5F7")
        })
    }
    
    // MARK: - Text Colors
    
    static let textPrimary = Color(hex: "#1A1A1A")
    static let textSecondary = Color(hex: "#6B6B6B")
    static let textOnColor = Color(hex: "#1A1A1A") // Dark text on colored cards
    
    // MARK: - Tab Bar
    
    static let tabBarBackground = Color(hex: "#292B2D")
    static let tabBarInactive = Color(hex: "#8E8E93")
    static let tabBarActive = Color.white
    
    // MARK: - Card Colors (for task cards - each task gets a color)
    
    static let cardColors: [Color] = [
        purple,     // Lavender
        lime,       // Lime green
        salmon,     // Orange
        royalBlue,  // Blue
        softPink,   // Pink
        mint,       // Mint
        sky,        // Sky blue
        peach       // Peach
    ]
    
    static let cardColorHexes: [String] = [
        "#D9B8F3", "#DFF37D", "#EE5E37", "#4558C8",
        "#F5D0E0", "#B8E6D4", "#B8D4F0", "#FFD4B8"
    ]
    
    // MARK: - Priority Colors
    
    static let priorityLow = lime
    static let priorityMedium = peach
    static let priorityHigh = salmon
    
    // MARK: - Category Colors (same vibrant palette)
    
    static let categoryColors = cardColors
    static let categoryColorHexes = cardColorHexes
}

// MARK: - UIColor Extension

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
    
    /// Check if color is light (for determining text color)
    var isLight: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.6
    }
}

// MARK: - View Extensions

extension View {
    
    /// Apply large card styling
    func largeCardStyle(color: Color, cornerRadius: CGFloat = Design.Radius.xl) -> some View {
        self
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    /// Pill button style (outline)
    func pillStyle(isSelected: Bool = false) -> some View {
        self
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, Design.Spacing.xs)
            .background(
                Capsule()
                    .stroke(Color.black.opacity(isSelected ? 1 : 0.2), lineWidth: 1.5)
                    .background(isSelected ? Color.black.opacity(0.05) : Color.clear)
                    .clipShape(Capsule())
            )
    }
    
    /// Circle button with arrow
    func circleButtonStyle(size: CGFloat = 44) -> some View {
        self
            .frame(width: size, height: size)
            .background(CloudoTheme.jetBlack)
            .clipShape(Circle())
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

// MARK: - Placeholder Extension

extension View {
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
