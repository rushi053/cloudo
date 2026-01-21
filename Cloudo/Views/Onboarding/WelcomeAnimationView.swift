import SwiftUI

struct WelcomeAnimationView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            Theme.primaryPastel
                .ignoresSafeArea()
            
            if !showOnboarding {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentPastel.opacity(0.2))
                            .frame(width: 160, height: 160)
                        
                        Circle()
                            .fill(Theme.accentPastel.opacity(0.3))
                            .frame(width: 130, height: 130)
                        
                        AppIconView()
                            .frame(width: 90, height: 90)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    Text("Cloudo")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                        logoScale = 1
                        logoOpacity = 1
                    }
                    
                    withAnimation(.easeInOut(duration: 0.8).delay(0.5)) {
                        textOpacity = 1
                    }
                    
                    // After the animation, show the onboarding view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showOnboarding = true
                        }
                    }
                }
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
    }
}

struct WelcomeAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeAnimationView()
    }
} 