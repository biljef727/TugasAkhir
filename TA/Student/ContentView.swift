//import SwiftUI
//import PDFKit
//
//struct ContentView: View {
//    var body: some View {
//        NavigationView {
//            VStack {
//                PDFKitView(url: Bundle.main.url(forResource: "three-pages", withExtension: "pdf")!)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                
//                DrawingOverlay()
//            }
//            .navigationTitle("PDF Viewer")
//        }
//    }
//}
//
//struct DrawingOverlay: View {
//    @State private var drawingPaths: [Int: Path] = [:]
//    @State private var isDrawing = false
//    @State private var currentPath = Path()
//    @State private var currentPage: Int = 1
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                PDFPageView(pageNumber: currentPage, drawingPath: drawingPaths[currentPage])
//                    .onTapGesture {
//                        self.isDrawing = true
//                    }
//                    .onDisappear {
//                        self.isDrawing = false
//                    }
//                
//                if let drawingPath = drawingPaths[currentPage] {
//                    drawingPath
//                        .stroke(Color.red, lineWidth: 2)
//                }
//                
//                if isDrawing {
//                    currentPath
//                        .stroke(Color.red, lineWidth: 2)
//                        .gesture(
//                            DragGesture(minimumDistance: 0)
//                                .onChanged { value in
//                                    let point = value.location
//                                    self.addPoint(point, to: currentPage)
//                                }
//                                .onEnded { _ in
//                                    self.saveDrawingPath(for: currentPage)
//                                    self.currentPath = Path()
//                                }
//                        )
//                }
//            }
//        }
//        .onAppear {
//            if self.drawingPaths[currentPage] == nil {
//                self.drawingPaths[currentPage] = Path()
//            }
//        }
//    }
//    
//    private func addPoint(_ point: CGPoint, to page: Int) {
//        currentPath.addLine(to: point)
//    }
//    
//    private func saveDrawingPath(for page: Int) {
//        drawingPaths[page] = currentPath
//    }
//}
//
//struct PDFPageView: UIViewRepresentable {
//    let pageNumber: Int
//    let drawingPath: Path?
//
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.displayMode = .singlePageContinuous
//        pdfView.autoScales = true
//        return pdfView
//    }
//    
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        if let url = Bundle.main.url(forResource: "three-pages", withExtension: "pdf"),
//           let document = PDFDocument(url: url) {
//            pdfView.document = document
//            if let page = document.page(at: pageNumber - 1) {
//                pdfView.go(to: page)
//            }
//        }
//        if let path = drawingPath {
//            let overlay = DrawingOverlayPath(path: path)
//            pdfView.addSubview(overlay)
//        }
//    }
//}
//
//struct DrawingOverlayPath: UIViewRepresentable {
//    let path: Path
//    
//    func makeUIView(context: Context) -> UIView {
//        let overlayView = UIView()
//        overlayView.backgroundColor = .clear
//        return overlayView
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//        shapeLayer.strokeColor = UIColor.red.cgColor
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineWidth = 2
//        
//        uiView.layer.addSublayer(shapeLayer)
//    }
//}
//
//struct PDFKitView: UIViewRepresentable {
//    let url: URL
//
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.document = PDFDocument(url: url)
//        return pdfView
//    }
//
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        // Update the PDFView if needed
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
