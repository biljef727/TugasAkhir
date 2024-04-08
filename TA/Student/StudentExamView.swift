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

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: pdfURL)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.isUserInteractionEnabled = false // Disable user interaction
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
    @State private var currentPage = 1 // Initialize current page to 1
    let pdfURL = Bundle.main.url(forResource: "three-pages", withExtension: "pdf")!

    var body: some View {
        VStack {
            HStack{
                Image(systemName: "pencil")
                Image(systemName: "eraser")
            }
            .font(.title)
            .padding()
            PDFViewWrapper(pdfURL: pdfURL, currentPage: $currentPage)
                .aspectRatio(contentMode: .fit)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the view takes up entire space
    }
}

#Preview {
    StudentExamView()
}

