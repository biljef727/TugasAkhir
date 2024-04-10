//
//  StudentExamView.swift
//  TA
//
//  Created by Billy Jefferson on 02/04/24.
//
import SwiftUI
import PDFKit

struct PDFViewWrapper: UIViewRepresentable {
    let pdfURL: URL
    @Binding var currentPage: Int
    @Binding var isDrawing: Bool // Add binding for drawing mode

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
        
        // Toggle drawing mode
        if isDrawing {
            uiView.isUserInteractionEnabled = true // Enable user interaction
        } else {
            uiView.isUserInteractionEnabled = false // Disable user interaction
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
    @State private var isDrawing = false
    @State var id: UUID?
    @State var data: Data?
    @State var title: String?
    let pdfURL = Bundle.main.url(forResource: "three-pages", withExtension: "pdf")!

    var body: some View {
        VStack {
            HStack{
                Spacer()
                Button(action: {
            
                }) {
                    Image(systemName: "arrow.right")
                }
                .padding(.trailing,50)
            }
            ZStack{
                PDFViewWrapper(pdfURL: pdfURL, currentPage: $currentPage, isDrawing: $isDrawing)
                    .aspectRatio(contentMode: .fit)
                
                DrawingCanvasView(data: data ?? Data(), id: id ?? UUID())
                .frame(width: 520, height: 720)
                    .environment(\.managedObjectContext, viewContext)
            }
            HStack{
                Button(action: {
                    if self.currentPage > 1 {
                        self.currentPage -= 1
                    }
                }) {
                    Image(systemName: "arrow.left")
                }
                .padding()
                
                Text("Page: \(currentPage)")
                
                Button(action: {
                    if let pdfDocument = PDFDocument(url: pdfURL) {
                        let totalPages = pdfDocument.pageCount
                        if self.currentPage < totalPages {
                            self.currentPage += 1
                        }
                    }
                }) {
                    Image(systemName: "arrow.right")
                }
                .padding()
            }
            
        }
    }
}

#Preview {
    StudentExamView()
}

