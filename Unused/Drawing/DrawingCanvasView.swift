import SwiftUI
import CoreData
import PencilKit

struct DrawingCanvasView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    
    class Coordinator: NSObject {
            var parent: DrawingCanvasView
            
            init(parent: DrawingCanvasView) {
                self.parent = parent
            }
            
            func updateStateVariable(newValue: Data) {
                DispatchQueue.main.async {
                    self.parent.data = newValue
                }
            }
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }
    
    func updateUIViewController(_ uiViewController: DrawingCanvasViewController, context: Context) {
        //if(previousPage != currentPage){
           // previousPage = currentPage
            clearCanvasData(context: context)
        //}
        //uiViewController.drawingData = data
    }
    
    typealias UIViewControllerType = DrawingCanvasViewController
    
    @Binding var data: Data
    var id: UUID
    @Binding var currentPage: Int
    @State var previousPage: Int = 0
    weak var delegate: MyViewControllerDelegate?
    
    func makeUIViewController(context: Context) -> DrawingCanvasViewController {
        let viewController = DrawingCanvasViewController()
        viewController.delegate = delegate // Set the delegate
        viewController.drawingData = data
        viewController.drawingChanged = { data in
            clearCanvasData()
        }
        return viewController
    }
    
    private func clearCanvasData(context: Context? = nil) {
        let request: NSFetchRequest<Drawing> = Drawing.fetchRequest()
        let predicate = NSPredicate(format: "id == %@ AND pdfPage == \(currentPage)", id as CVarArg)
        request.predicate = predicate
        //print(predicate)
        do {
            let result = try viewContext.fetch(request)
            let viewController = DrawingCanvasViewController.shared
            var currentData = Data()
            // if data exists, then update
            if let obj = result.first {
//                viewController.updateMyVariable(newValue:  result.first!.canvasData!,currentPage: $currentPage, previousPage: $previousPage)
                
                obj.canvasData = result.first?.canvasData
                currentData = result.first!.canvasData! // ?? Data()
                
                do {
                    try viewContext.save()
                    print("updated")
                } catch {
                    print("Error updating context: \(error)")
                }
            } else {
               
                // if data not exists, then create new
                do {
//                    viewController.updateMyVariable(newValue:  Data(),currentPage: $currentPage, previousPage: $previousPage) context?.viewController.clearCanvas()
                   print("data kosong")
                    
                    let drawn = Drawing(context: viewContext)
                    drawn.id = id
                    drawn.pdfPage = Int32(currentPage)
                    drawn.canvasData = currentData
                    try viewContext.save()
                    print("saved")
                } catch {
                    print("Error saving context: \(error)")
                }
            }
            
            context?.coordinator.updateStateVariable(newValue: currentData)
            
            viewController.updateMyVariable(newValue:  data,currentPage: $currentPage, previousPage: $previousPage)
            
            
//            viewController.updateMyVariable(newValue: result.first?.canvasData ?? Data())
            //data = result.first?.canvasData ?? Data()
               // viewController.drawingData = result.first?.canvasData ?? Data()
            
//            viewController.drawingChanged = { data in
//                clearCanvasData()
//            }
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
