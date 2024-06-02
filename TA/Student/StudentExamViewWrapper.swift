import SwiftUI
import UIKit

struct StudentExamViewWrapper: UIViewControllerRepresentable {
    let studentExamView: StudentExamView
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let hostingController = UIHostingController(rootView: studentExamView)
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false // Disable the swipe back gesture
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update your view controller if needed
    }
}
