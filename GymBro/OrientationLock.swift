import SwiftUI

// Wrapper per bloccare l'orientamento
struct OrientationLock: UIViewControllerRepresentable {
    let orientation: UIInterfaceOrientationMask

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Blocca l'orientamento in modalità verticale (portrait)
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientation: .portrait))
        }
    }
}
