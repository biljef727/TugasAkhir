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
                parent.clearCanvasDataOnNewPage(newPage: parent.currentPage)
            }
        }
    }
}

struct StudentExamView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var currentPage = 1
    @State var id: UUID?
    @Binding var data: Data
    let pdfURL = Bundle.main.url(forResource: "three-pages", withExtension: "pdf")!
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {

                }) {
                    Text("Submit")
                }
                .padding(.trailing,50)
            }
            ZStack {
                PDFViewWrapper(pdfURL: pdfURL, currentPage: $currentPage)
                    .aspectRatio(contentMode: .fit)
                
                DrawingCanvasView(data: $data, id: id ?? UUID(), currentPage:$currentPage)
                    .frame(width: 520, height: 720)
                    .environment(\.managedObjectContext, viewContext)
            }
            HStack{
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
    }
    
    var totalPages: Int {
        guard let pdf = PDFDocument(url: pdfURL) else { return 0 }
        return pdf.pageCount
    }
}
//
//#Preview {
//    StudentExamView()
//}

