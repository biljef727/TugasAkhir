import SwiftUI

struct DocumentDrawingViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DocumentDrawingViewController {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DocumentDrawingViewController") as! DocumentDrawingViewController
        return viewController
    }

    func updateUIViewController(_ uiViewController: DocumentDrawingViewController, context: Context) {
        // Update any necessary properties or data when needed
    }
}
