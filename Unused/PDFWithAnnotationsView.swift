//import SwiftUI
//import PDFKit
//import PencilKit
//
//// Custom SwiftUI view for displaying a PDF with drawing annotations
//struct PDFWithAnnotationsView: View {
//    @State private var pdfDocument: PDFDocument?
//    @State private var isLoading = true
//    @State private var drawing = PKDrawing()
//    
//    var body: some View {
//        VStack {
//            if let document = pdfDocument {
//                ZStack(alignment: .topLeading) {
//                    PDFKitRepresentedView(document: document)
//                        .toolbar {
//                            // Button to save PDF with annotations
//                            Button("Save") {
//                                do {
//                                    // Save the PDF with annotations
//                                    if let resultData = try savePDFWithAnnotations(pdfDocument: document) {
//                                        // Handle the saved PDF data (e.g., write to a file)
//                                        // Here, you can use resultData as needed
//                                        print("PDF with annotations saved successfully")
//                                    } else {
//                                        print("Failed to save PDF with annotations")
//                                    }
//                                } catch {
//                                    print("Error saving PDF with annotations: \(error)")
//                                }
//                            }
//                        }
//                    
//                    // Drawings overlay
//                    PKCanvasView()
//                        .drawing($drawing)
//                        .frame(width: 400, height: 400) // Adjust size as needed
//                        .background(Color.white.opacity(0.001)) // Allow touch events to pass through
//
//                }
//            } else if isLoading {
//                Text("Loading PDF...")
//            } else {
//                Text("Failed to load PDF")
//            }
//        }
//        .onAppear {
//            // Load PDF document when view appears
//            if let url = Bundle.main.url(forResource: "three-pages", withExtension: "pdf") {
//                self.loadPDF(from: url)
//            }
//        }
//    }
//    
//    // Function to load the PDF document
//    private func loadPDF(from url: URL) {
//        if let pdfDocument = PDFDocument(url: url) {
//            self.pdfDocument = pdfDocument
//            isLoading = false
//        } else {
//            isLoading = false
//        }
//    }
//    
//    // Function to save the PDF with annotations
//    private func savePDFWithAnnotations(pdfDocument: PDFDocument) throws -> Data? {
//        for i in 0..<pdfDocument.pageCount {
//            if let page = pdfDocument.page(at: i) as? MyPDFPage {
//                let newAnnotation = MyPDFAnnotation(bounds: page.bounds(for: .mediaBox),
//                                                     forType: .ink,
//                                                     withProperties: nil)
//                newAnnotation.add(self.drawing)
//                page.addAnnotation(newAnnotation)
//            }
//        }
//        
//        // Save the document with annotations
//        let options = [PDFDocumentWriteOption.burnInAnnotationsOption: true]
//        return pdfDocument.dataRepresentation(options: options)
//    }
//}
//
//// Representable for integrating PDFKit view in SwiftUI
//struct PDFKitRepresentedView: UIViewRepresentable {
//    let document: PDFDocument
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.document = document
//        pdfView.autoScales = true
//        pdfView.displayMode = .singlePageContinuous
//        pdfView.displayDirection = .vertical
//        return pdfView
//    }
//    
//    func updateUIView(_ uiView: PDFView, context: Context) {
//        // Update the PDFView if needed
//    }
//}
//
//// Subclass of PDFPage for storing drawing data
//class MyPDFPage: PDFPage {
//    var drawing: PKDrawing?
//}
//
//// Custom PDF annotation for drawing
//class MyPDFAnnotation: PDFAnnotation {
//    override func draw(with box: PDFDisplayBox, in context: CGContext) {
//        UIGraphicsPushContext(context)
//        context.saveGState()
//        
//        if let drawing = self.addedDrawing {
//            drawing.image(from: drawing.bounds, scale: 1).draw(in: drawing.bounds)
//        }
//        
//        context.restoreGState()
//        UIGraphicsPopContext()
//    }
//    
//    var addedDrawing: PKDrawing? {
//        if let drawingData = self.value(forAnnotationKey: PDFAnnotationKey(rawValue: "drawingData")) as? Data {
//            do {
//                return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(drawingData) as? PKDrawing
//            } catch {
//                print("Error unarchiving drawing data: \(error)")
//            }
//        }
//        return nil
//    }
//}
//
//// Usage:
//// PDFWithAnnotationsView()
