import SwiftUI

struct DocumentDrawingViewControllerWrapper: UIViewControllerRepresentable {
    var examFile: String
    
    func makeUIViewController(context: Context) -> DocumentDrawingViewController {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DocumentDrawingViewController") as! DocumentDrawingViewController
        viewController.examFile = examFile
        return viewController
    }

    func updateUIViewController(_ uiViewController: DocumentDrawingViewController, context: Context) {
        // Update any necessary properties or data when needed
    }
}
