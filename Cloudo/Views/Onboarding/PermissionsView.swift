import SwiftUI

struct PermissionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var notificationPermissionRequested = false
    @State private var isRequestingPermission = false
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Theme.primaryPastel
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                
                Text("Almost Ready!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Enable notifications to get the most out of Cloudo")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 30) {
                    permissionCard(
                        title: "Notifications",
                        description: "Receive reminders for your tasks exactly when you need them. Never miss an important deadline again.",
                        iconName: "bell.badge.fill",
                        buttonTitle: isRequestingPermission ? "Requesting..." : 
                                    (notificationPermissionRequested ? "Enabled ✓" : "Enable Notifications"),
                        buttonAction: {
                            if !notificationPermissionRequested && !isRequestingPermission {
                                isRequestingPermission = true
                                NotificationManager.shared.requestAuthorization { granted in
                                    DispatchQueue.main.async {
                                        notificationPermissionRequested = granted
                                        isRequestingPermission = false
                                    }
                                }
                            }
                        },
                        isCompleted: notificationPermissionRequested
                    )
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 10) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 16, height: 16)
                    
                    Text("Remember to back up your data regularly through Settings")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .frame(maxWidth: 320)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
                        onContinue()
                    }) {
                        Text("Continue to Cloudo")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 220, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Theme.accentPastel.opacity(0.25))
                            )
                    }
                    
                    Button(action: {
                        onContinue()
                    }) {
                        Text("Skip for now")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 8)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func permissionCard(
        title: String,
        description: String,
        iconName: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void,
        isCompleted: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            
            Text(description)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: buttonAction) {
                Text(buttonTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.primaryPastel)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(isCompleted ? Color.white.opacity(0.3) : Color.white)
                    )
            }
            .disabled(isCompleted || isRequestingPermission)
            .opacity(isCompleted || isRequestingPermission ? 0.7 : 1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.accentPastel.opacity(0.2))
        )
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView(onContinue: {})
    }
} 
