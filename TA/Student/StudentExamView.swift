import SwiftUI

struct StudentExamView: View {
    @StateObject var pdfDrawer = PDFDrawer()
    var examID: String?
    var userID: String?
    @State var examFile: String = ""
    @State private var isDrawing = true
    
    let apiManager = ApiManagerStudent()
    
    var body: some View {
        ZStack {
            if !examFile.isEmpty { 
                DocumentDrawingViewControllerWrapper(examFile: examFile).environmentObject(pdfDrawer)
            } else {
                ProgressView()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: HStack {
            Button(action: {
                isDrawing = true
                pdfDrawer.setDrawingTool(.pen)
            }) {
                Image(systemName: "pencil")
            }
            Button(action: {
                isDrawing = false
                pdfDrawer.setDrawingTool(.eraser)
            }) {
                Image(systemName: "eraser.fill")
            }
        }, trailing: Button(action: {
            // Saving
            
        }, label: {
            Text("Submit")
        }))
        .environmentObject(pdfDrawer)
        .task {
            fetchFile()
        }
        .onChange(of: pdfDrawer.drawingTool) { _ in

                   print("Current Drawing Tool: \(pdfDrawer.drawingTool)")
               }
    }
    
    private func fetchFile() {
        guard let userID = userID, let examID = examID else {
            print("Error: userID or examID is nil")
            return
        }
        
        apiManager.fetchPDF(userID: userID, examID: examID) { result in
            switch result {
            case .success(let examFile):
                DispatchQueue.main.async {
                    self.examFile = examFile
                }
            case .failure(let error):
                print("Error fetching PDF file: \(error.localizedDescription)")
            }
        }
    }
    
}
