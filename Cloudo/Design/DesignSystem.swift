//
//  DesignSystem.swift
//  Cloudo
//
//  Modern, vibrant design system
//

import SwiftUI

// MARK: - Design Tokens

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
        static let huge: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let full: CGFloat = 100
    }
    
    // MARK: - Typography
    
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 15, weight: .medium, design: .rounded)
        static let subheadline = Font.system(size: 14, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
        static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
}

// MARK: - Color Theme

struct CloudoTheme {
    
    // MARK: - Brand Colors (Vibrant & Fun)
    
    /// Primary gradient colors
    static let gradientStart = Color(hex: "#667EEA") // Vibrant purple-blue
    static let gradientEnd = Color(hex: "#764BA2")   // Deep purple
    
    /// Accent colors
    static let coral = Color(hex: "#FF6B6B")         // Warm coral red
    static let mint = Color(hex: "#4ECDC4")          // Fresh mint
    static let sunshine = Color(hex: "#FFE66D")      // Bright yellow
    static let peach = Color(hex: "#FFA07A")         // Soft peach
    static let lavender = Color(hex: "#B19CD9")      // Soft lavender
    static let sky = Color(hex: "#87CEEB")           // Sky blue
    
    // MARK: - Semantic Colors
    
    static let primary = Color(hex: "#667EEA")
    static let secondary = Color(hex: "#A0AEC0")
    
    /// Background colors - Light mode
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1)
                : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        })
    }
    
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)
                : UIColor.white
        })
    }
    
    static var elevatedBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.15, green: 0.15, blue: 0.22, alpha: 1)
                : UIColor.white
        })
    }
    
    // MARK: - Priority Colors (More vibrant)
    
    static let priorityLow = Color(hex: "#4ECDC4")    // Mint
    static let priorityMedium = Color(hex: "#FFB347") // Warm orange
    static let priorityHigh = Color(hex: "#FF6B6B")   // Coral
    
    // MARK: - Category Colors (Fun & Distinct)
    
    static let categoryColors: [Color] = [
        Color(hex: "#FF6B6B"), // Coral
        Color(hex: "#4ECDC4"), // Mint
        Color(hex: "#FFE66D"), // Sunshine
        Color(hex: "#667EEA"), // Purple-blue
        Color(hex: "#FFA07A"), // Peach
        Color(hex: "#B19CD9"), // Lavender
        Color(hex: "#87CEEB"), // Sky
        Color(hex: "#98D8C8"), // Sea foam
    ]
    
    static let categoryColorHexes: [String] = [
        "#FF6B6B", "#4ECDC4", "#FFE66D", "#667EEA",
        "#FFA07A", "#B19CD9", "#87CEEB", "#98D8C8"
    ]
    
    // MARK: - Gradients
    
    static let primaryGradient = LinearGradient(
        colors: [gradientStart, gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let coralGradient = LinearGradient(
        colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF8E8E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let mintGradient = LinearGradient(
        colors: [Color(hex: "#4ECDC4"), Color(hex: "#7EDDD6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunshineGradient = LinearGradient(
        colors: [Color(hex: "#FFE66D"), Color(hex: "#FFF0A0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Extensions

extension View {
    
    /// Apply modern card styling with shadow
    func cardStyle(cornerRadius: CGFloat = Design.Radius.lg) -> some View {
        self
            .background(CloudoTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    /// Apply glassmorphism effect
    func glassStyle() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
    }
    
    /// Apply button press effect
    func pressable(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(Design.Animation.quick, value: isPressed)
    }
    
    /// Shimmer loading effect
    @ViewBuilder
    func shimmer(_ isActive: Bool = true) -> some View {
        if isActive {
            self.modifier(ShimmerModifier())
        } else {
            self
        }
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

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Color Extensions

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

// MARK: - Gradient Text

extension Text {
    func gradientForeground(_ gradient: LinearGradient) -> some View {
        self.overlay(gradient)
            .mask(self)
    }
}
