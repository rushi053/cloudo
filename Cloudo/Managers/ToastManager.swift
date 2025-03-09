import SwiftUI
import Combine

class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var title = ""
    @Published var message = ""
    @Published var icon = ""
    @Published var iconColor = Color.blue
    
    private var cancellable: AnyCancellable?
    
    func showToast(title: String, message: String, icon: String, iconColor: Color) {
        // Cancel any existing timer
        cancellable?.cancel()
        
        // Update toast content
        self.title = title
        self.message = message
        self.icon = icon
        self.iconColor = iconColor
        
        // Show the toast with animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            self.isShowing = true
        }
        
        // Hide the toast after 3 seconds
        cancellable = Just(())
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self?.isShowing = false
                }
            }
    }
    
    func hideToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isShowing = false
        }
    }
}

struct ToastBanner: View {
    @ObservedObject var toastManager: ToastManager
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack {
            if toastManager.isShowing {
                HStack(spacing: 12) {
                    Image(systemName: toastManager.icon)
                        .font(.system(size: 18))
                        .foregroundColor(toastManager.iconColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(toastManager.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        
                        Text(toastManager.message)
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        toastManager.hideToast()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.isDarkMode ? 
                              Color(hex: "#3A4A64") : // Darker blue for dark mode
                              Color(hex: "#D8E6F1")) // Light blue for light mode
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100) // Ensure it's above all other content
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: toastManager.isShowing)
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            ToastBanner(toastManager: toastManager)
                .padding(.top, 8) // Add some padding from the top of the screen
        }
    }
}

extension View {
    func toast(with toastManager: ToastManager) -> some View {
        self.modifier(ToastModifier(toastManager: toastManager))
    }
} 