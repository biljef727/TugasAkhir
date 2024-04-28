import SwiftUI
import PDFKit

struct PDFViewWrapper: UIViewRepresentable {
    let pdfDocument: PDFDocument
    
    @Binding var currentPage: Int
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
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

struct StudentExamView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var currentPage = 1
    @State private var pdfData: Data?
    @State private var fetchError: Error?
    @State var id: UUID = UUID()
    @State var data: Data = Data()
    var examID: String?
    var userID: String?
    
    let apiManager = ApiManagerStudent()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("Submit")
                }
                .padding(.trailing, 50)
            }
            ZStack {
                if let pdfData = pdfData, let pdf = PDFDocument(data: pdfData) {
                    PDFViewWrapper(pdfDocument: pdf, currentPage: $currentPage)
                        .aspectRatio(contentMode: .fit)
                } else if let fetchError = fetchError {
                    Text("Failed to fetch PDF: \(fetchError.localizedDescription)")
                } else {
                    ProgressView()
                }
                
                DrawingCanvasView(data: $data, id: id, currentPage: $currentPage)
                    .frame(width: 520, height: 720)
                    .environment(\.managedObjectContext, viewContext)
            }
            HStack {
                HStack(spacing: 10) {
                    ForEach(1..<totalPages + 1, id: \.self) { pageNumber in
                        Button(action: {
                            currentPage = pageNumber
                        }) {
                            Text("\(pageNumber)")
                                .padding()
                                .background(currentPage == pageNumber ? Color.blue : Color.clear)
                                .foregroundColor(currentPage == pageNumber ? .white : .black)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Fetch PDF data when the view appears
            fetchPDFData()
        }
    }
    
    var totalPages: Int {
        guard let pdfData = pdfData, let pdf = PDFDocument(data: pdfData) else { return 0 }
        return pdf.pageCount
    }
    
    func fetchPDFData() {
        apiManager.fetchPDF(userID: self.userID!, examID: self.examID!) { result in
            switch result {
            case .success(let pdfData):
                self.pdfData = pdfData
            case .failure(let error):
                // Set fetch error
                self.fetchError = error
            }
        }
    }
}
