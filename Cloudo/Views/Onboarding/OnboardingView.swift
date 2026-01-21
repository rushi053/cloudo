import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var onboardingManager = OnboardingManager.shared
    @State private var currentPage = 0
    @State private var showPermissionsView = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Cloudo",
            description: "Your personal task manager designed to make your life easier and more organized.",
            imageName: "app.logo",
            backgroundColor: Theme.textPrimary
        ),
        OnboardingPage(
            title: "Organize With Categories",
            description: "Create custom categories and keep your tasks neatly organized for easy access.",
            imageName: "tag.fill",
            backgroundColor: Theme.primaryPastel.opacity(0.8)
        ),
        OnboardingPage(
            title: "Set Reminders",
            description: "Never miss important tasks with customizable reminders and notifications.",
            imageName: "bell.badge.fill",
            backgroundColor: Theme.textPrimary
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Watch your productivity soar as you check off completed tasks and achieve your goals.",
            imageName: "chart.bar.fill",
            backgroundColor: Theme.primaryPastel.opacity(0.8)
        ),
        OnboardingPage(
            title: "Your Data Stays Private",
            description: "Your tasks are stored only on this device. Remember to create backups regularly through the Settings menu. Deleting the app will remove all data.",
            imageName: "lock.iphone",
            backgroundColor: Theme.textPrimary
        )
    ]
    
    var body: some View {
        ZStack {
            if showPermissionsView {
                PermissionsView {
                    onboardingManager.completeOnboarding()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                VStack {
                    Spacer()
                    
                    HStack {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Back")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                            }
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        } else {
                            Spacer()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if currentPage < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                withAnimation {
                                    showPermissionsView = true
                                }
                            }
                        }) {
                            HStack {
                                Text(currentPage < pages.count - 1 ? "Next" : "Continue")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                if currentPage < pages.count - 1 {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                        }
                        .foregroundColor(.white)
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        ZStack {
            page.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Theme.accentPastel.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .fill(Theme.accentPastel.opacity(0.4))
                        .frame(width: 130, height: 130)
                    
                    let isDarkBackground = page.backgroundColor == Theme.accentPastel || page.backgroundColor == Theme.accentPastel.opacity(0.9)
                    
                    if page.imageName == "app.logo" {
                        AppIconView()
                            .frame(width: 90, height: 90)
                    } else {
                        Image(systemName: page.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(isDarkBackground ? Color.white.opacity(0.95) : .white)
                    }
                }
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 20) {
                    Text(page.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(page.description)
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if page.title == "Your Data Stays Private" {
                        dataManagementInfoView()
                    }
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
    
    private func dataManagementInfoView() -> some View {
        VStack(spacing: 15) {
            VStack(spacing: 12) {
                dataFeatureView(iconName: "iphone.slash", text: "Deleting app removes data")
                dataFeatureView(iconName: "arrow.down.doc", text: "Create backups regularly")
                dataFeatureView(iconName: "arrow.up.doc", text: "Import from backups")
                dataFeatureView(iconName: "lock.shield", text: "No cloud storage used")
            }
        }
        .padding(.top, 10)
    }
    
    private func dataFeatureView(iconName: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.95))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.15))
        )
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

struct AppIconView: View {
    var body: some View {
        if let iconData = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIconData = iconData["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIconData["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            Image(uiImage: UIImage(named: lastIcon) ?? UIImage(named: "3") ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 22))
        } else {
            Image(uiImage: UIImage(named: "3") ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }
} 
