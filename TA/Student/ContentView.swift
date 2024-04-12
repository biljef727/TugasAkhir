//import SwiftUI
//import PencilKit
//import PDFKit
//
//struct ContentView: View {
//    @State private var currentPageIndex = 0
//    @State private var pdfDocument: PDFDocument?
//    @State private var pdfImages: [UIImage] = []
//
//    var body: some View {
//        ZStack {
//            if let pdfDocument = pdfDocument {
//                PDFViewer(pdfDocument: pdfDocument, currentPageIndex: $currentPageIndex)
//                    .onAppear {
//                        loadPDF()
//                    }
//            }
//
//            if !pdfImages.isEmpty {
//                PKCanvasStack(pdfImages: pdfImages)
//            }
//        }
//    }
//
//    func loadPDF() {
//        if let path = Bundle.main.path(forResource: "three-pages", ofType: "pdf") {
//            if let document = PDFDocument(url: URL(fileURLWithPath: path)) {
//                pdfDocument = document
//                generatePDFImages()
//            }
//        }
//    }
//
//    func generatePDFImages() {
//        guard let pdfDocument = pdfDocument else { return }
//
//        var images: [UIImage] = []
//        for i in 0..<pdfDocument.pageCount {
//            if let page = pdfDocument.page(at: i) {
//                let pageSize = page.bounds(for: .mediaBox).size
//                UIGraphicsBeginImageContextWithOptions(pageSize, false, 0.0)
//                let context = UIGraphicsGetCurrentContext()!
//                context.setFillColor(UIColor.white.cgColor)
//                context.fill(CGRect(origin: .zero, size: pageSize))
//                context.translateBy(x: 0.0, y: pageSize.height)
//                context.scaleBy(x: 1.0, y: -1.0)
//                page.draw(with: .mediaBox, to: context)
//                let image = UIGraphicsGetImageFromCurrentImageContext()!
//                UIGraphicsEndImageContext()
//                images.append(image)
//            }
//        }
//
//        pdfImages = images
//    }
//}
//
//struct PDFViewer: View {
//    var pdfDocument: PDFDocument
//    @Binding var currentPageIndex: Int
//
//    var body: some View {
//        VStack {
//            PDFViewRepresented(pdfDocument: pdfDocument, currentPageIndex: $currentPageIndex)
//            Spacer()
//        }
//    }
//}
//
//struct PDFViewRepresented: UIViewRepresentable {
//    var pdfDocument: PDFDocument
//    @Binding var currentPageIndex: Int
//
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.document = pdfDocument
//        pdfView.autoScales = true
//        pdfView.displayMode = .singlePageContinuous
//        pdfView.usePageViewController(true, withViewOptions: nil)
//        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        pdfView.backgroundColor = UIColor.white
//        pdfView.delegate = context.coordinator
//        return pdfView
//    }
//
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        if let page = pdfDocument.page(at: currentPageIndex) {
//            pdfView.go(to: page)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, PDFViewDelegate {
//        var parent: PDFViewRepresented
//
//        init(_ parent: PDFViewRepresented) {
//            self.parent = parent
//        }
//
//        func pdfViewPageChanged(_ pdfView: PDFView) {
//            if let currentPageIndex = pdfView.document?.index(for: pdfView.currentPage ?? PDFPage()) {
//                parent.currentPageIndex = currentPageIndex
//            }
//        }
//    }
//}
//
//
//struct PKCanvasStack: View {
//    var pdfImages: [UIImage]
//
//    var body: some View {
//        TabView {
//            ForEach(0..<pdfImages.count, id: \.self) { index in
//                PKCanvasViewWrapper(image: pdfImages[index])
//                    .tabItem {
//                        Text("Page \(index + 1)")
//                    }
//            }
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
//    }
//}
//
//struct PKCanvasViewWrapper: UIViewRepresentable {
//    var image: UIImage
//
//    func makeUIView(context: Context) -> PKCanvasView {
//        let canvasView = PKCanvasView()
//        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
//        
//        do {
//            canvasView.drawing = try PKDrawing(data: image.pngData() ?? Data())
//        } catch {
//            // Handle error here
//            print("Error creating PKDrawing from image data: \(error)")
//        }
//        
//        return canvasView
//    }
//
//    func updateUIView(_ uiView: PKCanvasView, context: Context) {
//        // Update canvas view if needed
//    }
//}
//
//#Preview {
//    ContentView()
//}
