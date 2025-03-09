import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @StateObject private var themeManager = ThemeManager.shared
    @State private var dragOffset: CGFloat = 0
    @State private var previousTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                ForEach(TabItem.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab.rawValue
                            HapticManager.shared.lightTapFeedback()
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: selectedTab == tab.rawValue ? 28 : 24))
                            Text(tab.title)
                                .font(.system(size: selectedTab == tab.rawValue ? 14 : 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(selectedTab == tab.rawValue ? themeManager.backgroundColor : Theme.primaryPastel)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTab == tab.rawValue ? themeManager.textColor : Color.clear)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                        )
                        .scaleEffect(selectedTab == tab.rawValue ? 1.1 : 1.0)
                        .offset(y: selectedTab == tab.rawValue ? -4 : 0)
                    }
                    .frame(maxHeight: .infinity)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                }
            }
            .frame(height: 60)
            .padding(.bottom, 8)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let translation = gesture.translation.width
                        dragOffset = translation
                        
                        // Calculate potential new tab based on drag direction
                        let tabWidth = UIScreen.main.bounds.width / CGFloat(TabItem.allCases.count)
                        let potentialTab = previousTab - Int(translation / tabWidth)
                        
                        // Ensure we stay within bounds
                        if potentialTab >= 0 && potentialTab < TabItem.allCases.count {
                            withAnimation(.interactiveSpring()) {
                                selectedTab = potentialTab
                            }
                        }
                    }
                    .onEnded { gesture in
                        previousTab = selectedTab
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
            )
        }
        .background(themeManager.backgroundColor)
        .onAppear {
            previousTab = selectedTab
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
}
