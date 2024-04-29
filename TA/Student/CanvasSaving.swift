import SwiftUI
import PencilKit
import UIKit
import PDFKit

struct CanvasSaving: View {
    var examID : String?
    var userID : String?
    var body: some View {
        Home(examID: examID, userID: userID)
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
    @EnvironmentObject var routerView: ServiceRoute
    var examID : String?
    var userID : String?
    @State var canvas = PKCanvasView()
    @State var isDraw = true
    @State private var currentPage = 1
    let pdfURL = Bundle.main.url(forResource: "dummy", withExtension: "pdf")!
    @State private var screenshot: UIImage? = nil
    
    var body: some View{
        ZStack{
            PDFViewWrapper(pdfURL: pdfURL, currentPage: $currentPage)
                .aspectRatio(contentMode: .fit)
            
            DrawingView(canvas: $canvas,isDraw: $isDraw)
                .frame(width: 520, height: 720)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:HStack{
                    Button(action:{
                        isDraw = true
                    }){
                        Image(systemName: "pencil")
                    }
                    Button(action:{
                        //erase tool
                        isDraw = false
                    }){
                        Image(systemName: "eraser.fill")
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
    }
    
    func takeScreenshot() {
        // Capture the screenshot
        DispatchQueue.main.async {
            screenshot = UIApplication.shared.windows.first?.rootViewController?.view?.snapshot()
            
            // Save to Photos Album
            if let screenshot = screenshot {
                UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
            }
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

struct CanvasSaving_Previews: PreviewProvider {
    static var previews: some View {
        CanvasSaving()
    }
}
