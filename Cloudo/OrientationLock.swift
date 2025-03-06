import SwiftUI

// Helper to lock orientation to portrait
class OrientationLock {
    static func lock(to orientation: UIInterfaceOrientationMask) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        }
    }
}

// SwiftUI modifier to lock orientation
struct OrientationLockModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                OrientationLock.lock(to: .portrait)
            }
    }
} 