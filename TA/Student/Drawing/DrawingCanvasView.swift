import SwiftUI
import CoreData
import PencilKit

struct DrawingCanvasView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    
    func updateUIViewController(_ uiViewController: DrawingCanvasViewController, context: Context) {
        
        uiViewController.drawingData = data
    }
    typealias UIViewControllerType = DrawingCanvasViewController
    
    var data: Data
    var id: UUID
    @Binding var currentPage: Int
    
    func makeUIViewController(context: Context) -> DrawingCanvasViewController {
        let viewController = DrawingCanvasViewController.shared
        viewController.drawingData = data
        viewController.drawingChanged = { data in
            let request: NSFetchRequest<Drawing> = Drawing.fetchRequest()
            
            let predicate = NSPredicate(format: "id == %@ AND pageNumber == \(currentPage)", id as CVarArg)
            
            request.predicate = predicate
            
            do {
                    let result = try viewContext.fetch(request)
                    if let drawing = result.first {
                        // If data for page 2 exists, set it to the view controller
                        if let canvasData = drawing.Canvasdata {
                            viewController.drawingData = canvasData
                        }
                    } else {
                        // If data for page 2 doesn't exist, create a new instance and set it to the view controller
                        let newDrawing = Drawing(context: viewContext)
                        newDrawing.id = id
                        newDrawing.page = 2
                        // Set any default values for the new drawing if needed
                        viewController.drawingData = Data() // Initialize with empty data
                    }
                } catch {
                    print("Error fetching CoreData data: \(error)")
                    // If an error occurs, initialize drawing data to an empty Data object
                    viewController.drawingData = Data()
                }
                
                viewController.drawingChanged = { [weak self] data in
                    guard let self = self else { return }
                    let request: NSFetchRequest<Drawing> = Drawing.fetchRequest()
                    let predicate = NSPredicate(format: "id == %@ AND pageNumber == \(currentPage)", id as CVarArg)
                    request.predicate = predicate
                    
                    do {
                        let result = try self.viewContext.fetch(request)
                        if let drawing = result.first {
                            // If data for page 2 exists, update its canvas data
                            drawing.Canvasdata = data
                        } else {
                            // If data for page 2 doesn't exist (which shouldn't happen), handle appropriately
                            print("Error: Drawing data for page 2 not found.")
                        }
                        do {
                            try self.viewContext.save()
                        } catch {
                            print("Error saving CoreData context: \(error)")
                        }
                    } catch {
                        print("Error fetching CoreData data: \(error)")
                    }
                }
                
                return viewController
            
    }
}
