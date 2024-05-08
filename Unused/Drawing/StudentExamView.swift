////import SwiftUI
////import PDFKit
////import PencilKit
////
////struct PDFViewWrapper: UIViewRepresentable {
////    let pdfURL: URL
////    
////    @Binding var currentPage: Int
////    
////    func makeUIView(context: Context) -> PDFView {
////        let pdfView = PDFView()
////        pdfView.document = PDFDocument(url: pdfURL)
////        pdfView.autoScales = true
////        pdfView.displayMode = .singlePageContinuous
////        pdfView.displayDirection = .horizontal
////        pdfView.usePageViewController(true, withViewOptions: nil)
////        if let initialPage = pdfView.document?.page(at: currentPage - 1) {
////            pdfView.go(to: initialPage)
////        }
////        pdfView.delegate = context.coordinator
////        
////        return pdfView
////    }
////    
////    func updateUIView(_ uiView: PDFView, context: Context) {
////        // Update the current page only if the new value differs from the previous one
////        if uiView.currentPage?.pageRef?.pageNumber != currentPage - 1 {
////            uiView.go(to: uiView.document?.page(at: currentPage - 1) ?? PDFPage())
////        }
////    }
////    
////    func makeCoordinator() -> Coordinator {
////        Coordinator(self)
////    }
////    
////    class Coordinator: NSObject, PDFViewDelegate {
////        let parent: PDFViewWrapper
////        
////        init(_ parent: PDFViewWrapper) {
////            self.parent = parent
////        }
////        
////        func currentPageChanged(_ sender: PDFView) {
////            if let currentPageIndex = sender.currentPage?.pageRef?.pageNumber {
////                parent.currentPage = Int(currentPageIndex) + 1
////            }
////        }
////    }
////}
//
//struct StudentExamView: View {
//    @Environment(\.managedObjectContext) var viewContext
//    @State private var currentPage = 1
//    @State var id: UUID = UUID()
//    @State var data: Data = Data()
//    
//    var examID : String?
//    var userID : String?
//    let pdfURL = Bundle.main.url(forResource: "dummy", withExtension: "pdf")!
//    
//    let apiManager = ApiManagerStudent()
//    
//    // State to track whether to show the screenshot
//    @State private var showScreenshot = false
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Spacer()
//                Button(action: {
//                    // Take screenshot action
//                    takeScreenshot()
//                }) {
//                    Text("Submit")
//                }
//                .padding(.trailing,50)
//            }
//            ZStack {
//                PDFViewWrapper(pdfURL: pdfURL, currentPage: $currentPage)
//                    .aspectRatio(contentMode: .fit)
//                
//                DrawingCanvasView(data: $data, id: id, currentPage:$currentPage)
//                    .frame(width: 520, height: 720)
//                    .environment(\.managedObjectContext, viewContext)
//                    .opacity(showScreenshot ? 0 : 1) // Hide drawing canvas when showing screenshot
//            }
//            HStack{
//                HStack(spacing: 10) {
//                    ForEach(1..<totalPages + 1, id: \.self) { pageNumber in
//                        Button(action: {
//                            currentPage = pageNumber
//                        }) {
//                            Text("\(pageNumber)")
//                                .padding()
//                                .background(currentPage == pageNumber ? Color.blue : Color.clear)
//                                .foregroundColor(currentPage == pageNumber ? .white : .black)
//                                .cornerRadius(8)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    var totalPages: Int {
//        guard let pdf = PDFDocument(url: pdfURL) else { return 0 }
//        return pdf.pageCount
//    }
//    
//    // Function to take a screenshot
//    func takeScreenshot() {
//        // Set the flag to show the screenshot
//        showScreenshot = true
//        
//        // Capture the screenshot
//        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
//        if let window = window {
//            UIGraphicsBeginImageContextWithOptions(window.frame.size, false, 0)
//            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            // Save the image to the photo library or handle it as you wish
//            if let image = image {
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//            }
//        }
//        
//        // Reset the flag after a delay to show the original view
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            showScreenshot = false
//        }
//    }
//}
