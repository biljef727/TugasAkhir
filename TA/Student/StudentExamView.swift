import SwiftUI

struct StudentExamView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @StateObject var pdfDrawer = PDFDrawer()
    var examID: String?
    var userID: String?
    @State var examFile: String = ""
    @State private var isDrawing = true
    @State private var screenshot: UIImage? = nil
    
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
            takeScreenshot()
        }, label: {
            Text("Submit")
        }))
        .environmentObject(pdfDrawer)
        .task {
            fetchFile()
            preventDeviceLock()
        }
    }
    func takeScreenshot() {
        DispatchQueue.main.async {
            if let view = UIApplication.shared.windows.first?.rootViewController?.view {
                self.screenshot = view.snapshot()
                routerView.path.removeLast()
            }
        }
    }
    func preventDeviceLock() {
        UIApplication.shared.isIdleTimerDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 30 * 60) { // 30 minutes
            UIApplication.shared.isIdleTimerDisabled = false
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

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
