import SwiftUI
import CoreData
import PencilKit

struct DrawingCanvasView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    
    func updateUIViewController(_ uiViewController: DrawingCanvasViewController, context: Context) {
        uiViewController.drawingData = data
    }
    
    typealias UIViewControllerType = DrawingCanvasViewController
    
    @Binding var data: Data
    var id: UUID
    @Binding var currentPage: Int
    
    func makeUIViewController(context: Context) -> DrawingCanvasViewController {
        let viewController = DrawingCanvasViewController.shared
        viewController.drawingData = data
        viewController.drawingChanged = { data in
            clearCanvasData()
        }
        return viewController
    }
    
    private func clearCanvasData() {
        let request: NSFetchRequest<Drawing> = Drawing.fetchRequest()
        let predicate = NSPredicate(format: "id == %@ AND pdfPage == \(currentPage)", id as CVarArg)
        request.predicate = predicate
        
        do {
            let result = try viewContext.fetch(request)
            if let obj = result.first {
                obj.canvasData = nil
                do {
                    try viewContext.save()
                } catch {
                    print("Error saving context: \(error)")
                }
            }
        } catch {
            print("Error fetching drawing: \(error)")
        }
    }
    
    // Function to clear canvas data when loading a new PDF page
    func clearCanvasDataOnNewPage(newPage: Int) {
        // Update current page
        self.currentPage = newPage
        
        // Clear canvas data
        clearCanvasData()
    }
}
