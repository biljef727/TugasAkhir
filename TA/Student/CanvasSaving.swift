import SwiftUI
import PencilKit
import UIKit
import PDFKit

struct CanvasSaving: View {
    var examID : String?
    var userID : String?
    var counter : Int?
    
    var body: some View {
        Home(examID: examID, userID: userID, counter: counter)
    }
}

struct PDFViewWrapper: UIViewRepresentable {
    let pdfURL: URL
    
    @Binding var currentPage: Int
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: pdfURL)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: nil)
        if let initialPage = pdfView.document?.page(at: currentPage - 1) {
            pdfView.go(to: initialPage)
        }
        pdfView.delegate = context.coordinator
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the current page only if the new value differs from the previous one
        if uiView.currentPage?.pageRef?.pageNumber != currentPage - 1 {
            uiView.go(to: uiView.document?.page(at: currentPage - 1) ?? PDFPage())
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        let parent: PDFViewWrapper
        
        init(_ parent: PDFViewWrapper) {
            self.parent = parent
        }
        
        func currentPageChanged(_ sender: PDFView) {
            if let currentPageIndex = sender.currentPage?.pageRef?.pageNumber {
                parent.currentPage = Int(currentPageIndex) + 1
            }
        }
    }
}


struct Home : View {
    // Other properties...
    @EnvironmentObject var routerView: ServiceRoute
    var examID : String?
    var userID : String?
    var counter : Int?
    @State var canvas = PKCanvasView()
    @State var isDraw = true
    @State private var currentPage = 1
    
    // Define pdfURL based on counter
    var pdfURL: URL {
        if counter == 1 {
            return Bundle.main.url(forResource: "Soal_1_Section", withExtension: "pdf")!
        }
        if counter == 2 {
            return Bundle.main.url(forResource: "Soal_2_Section", withExtension: "pdf")!
        }
        else{
            return Bundle.main.url(forResource: "", withExtension: "pdf")!
        }
    }
    
    @State private var screenshot: UIImage? = nil
    
    var body: some View{
        let pdfView = PDFViewWrapper(pdfURL: pdfURL, currentPage: $currentPage) // Pass pdfURL to PDFViewWrapper
        
        return ZStack{
            pdfView.aspectRatio(contentMode: .fit)
//                .frame(width: 800, height: 950)
            
            DrawingView(canvas: $canvas,isDraw: $isDraw)
                .frame(width: 520, height: 720)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:HStack{
                    Button(action:{
                        isDraw = true
                    }){
                        Image(systemName: "pencil")
                            .foregroundColor(isDraw ? Color.black : Color.blue)
                    }
                    Button(action:{
                        //erase tool
                        isDraw = false
                    }){
                        Image(systemName: "eraser.fill")
                            .foregroundColor(isDraw ? Color.blue : Color.black)
                    }
                },trailing:  Button(action:{
                    //saving
                    takeScreenshot()
                    routerView.path.removeLast()
                },label:{
                    Text("Submit")
                }))
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            disableHomeGesture()
            preventDeviceLock()
        }
    }
    
    func takeScreenshot() {
        DispatchQueue.main.async {
            if let view = UIApplication.shared.windows.first?.rootViewController?.view {
                self.screenshot = view.snapshot()
                addKerjaan()
            }
        }
    }
    
    func addKerjaan() {
        guard let screenshot = self.screenshot else {
            print("Screenshot is nil.")
            return
        }
        
        guard let imageData = screenshot.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return
        }
        // Call the API method passing the screenshot data
        let apiManager = ApiManagerStudent()
        apiManager.addKerjaan(examID: examID ?? "", section1: "0", section2: "0", section3: "0", file: imageData, userId: userID ?? "", status: "Wait") { error in
            if let error = error {
                // Handle error
                print("Error: \(error)")
            } else {
                // Success, do something if needed
            }
        }
    }
    
    func disableHomeGesture() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.window?.isMultipleTouchEnabled = false
    }
    
    func preventDeviceLock() {
        UIApplication.shared.isIdleTimerDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 30 * 60) { // 30 minutes
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

struct DrawingView : UIViewRepresentable{
    @Binding var canvas : PKCanvasView
    @Binding var isDraw : Bool
    
    let ink = PKInkingTool(.pen,color: .black)
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.tool = isDraw ? ink : eraser
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = isDraw ? ink : eraser
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: DrawingView
        
        init(_ parent: DrawingView) {
            self.parent = parent
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            // Check if the current tool is a pencil tool
            if let pencilTool = canvasView.tool as? PKInkingTool, pencilTool.inkType == .pen {
                // Allow drawing only with the pencil
                parent.isDraw = true
            } else {
                // Disable drawing with finger
                parent.isDraw = false
            }
        }
    }
}

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
