//import SwiftUI
//import PDFKit
//
//struct PDFViewWrapper: UIViewRepresentable {
//    var url: URL
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        pdfView.displayMode = .singlePageContinuous
//        pdfView.displayDirection = .vertical
//        if let document = PDFDocument(url: url) {
//            pdfView.document = document
//        }
//        return pdfView
//    }
//    
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        // Update the view if needed
//    }
//}
//
//struct Testing: View {
//    var body: some View {
//        PDFViewWrapper(url: Bundle.main.url(forResource: "three-pages", withExtension: "pdf")!)
//            .navigationBarTitle("PDF Viewer")
//    }
//}
