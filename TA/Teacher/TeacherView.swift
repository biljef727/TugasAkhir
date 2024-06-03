import SwiftUI
import Combine
import UIKit

class DocumentInteractionHelper: NSObject, UIDocumentInteractionControllerDelegate {
    private var documentInteractionController: UIDocumentInteractionController?
    
    func openDocument(data: Data, fileName: String, from view: UIView) {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            documentInteractionController = UIDocumentInteractionController(url: fileURL)
            documentInteractionController?.delegate = self
            documentInteractionController?.presentOptionsMenu(from: view.bounds, in: view, animated: true)
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    // UIDocumentInteractionControllerDelegate methods
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
    }
}

struct TeacherView: View {
    @EnvironmentObject var routerView: ServiceRoute
    
    @Binding var userID: String
    @Binding var userName: String
    
    @State private var isAddNewExam = false
    
    @State var examName: [String] = []
    @State var examCounter: [String] = []
    @State var sectionExamCounter: [Int] = []
    @State var examFiles: [String] = []
    
    let refreshSubject = PassthroughSubject<UUID, Never>()
    let apiManager = ApiManagerTeacher()
    let documentInteractionHelper = DocumentInteractionHelper()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ZStack{
                HStack{
                    Spacer()
                    Text("\(userName)")
                    Image(systemName: "person.circle")
                }
                .padding()
                Text("Question Listed")
                    .font(Font.custom("", size: 50))
                    .bold()
            }
            Divider()
                .frame(minHeight: 2)
                .background(Color.black)
                .padding(.vertical)
            HStack {
                Text("")
                    .font(.title2)
                    .padding()
                Spacer()
                Button(action: {
                    self.isAddNewExam.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                }
                .sheet(isPresented: $isAddNewExam) {
                    NewExamView(
                        isPresented: $isAddNewExam,
                        examName: $examName,
                        sectionExamCounter: $sectionExamCounter,
                        userID: $userID,
                        refreshSubject: refreshSubject // Pass the refreshSubject
                    )
                }
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<examName.count, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                            VStack {
                                Text("\(examName[index])")
                                Text("Total Section : \(examCounter[index])")
                                Button(action: {
                                    // Call downloadPDF function when button is tapped
                                    if let url = URL(string: examFiles[index]) {
                                        downloadPDF(from: url, fileName: "\(examName[index]).pdf")
                                    }
                                }) {
                                    Text("Download")
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            fetchExamNames()
        }
        .onReceive(refreshSubject) { _ in
            fetchExamNames()
        }
    }
    
    func fetchExamNames() {
        apiManager.fetchClassID(userID: self.userID) { result in
            switch result {
            case .success(let (examNames, examSectionCounter, examFiles)):
                DispatchQueue.main.async {
                    self.examName = examNames
                    self.examCounter = examSectionCounter
                    self.examFiles = examFiles
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    
    func downloadPDF(from url: URL, fileName: String) {
        URLSession.shared.downloadTask(with: url) { (location, response, error) in
            if let error = error {
                print("Error downloading PDF: \(error.localizedDescription)")
                return
            }
            guard let location = location else {
                print("Error: No location provided for downloaded PDF.")
                return
            }
            
            do {
                let downloadsURL = try FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let iphExamFolderURL = downloadsURL.appendingPathComponent("IPH_Exam", isDirectory: true)
                try FileManager.default.createDirectory(at: iphExamFolderURL, withIntermediateDirectories: true, attributes: nil)
                let destinationURL = iphExamFolderURL.appendingPathComponent(fileName)
                
                try FileManager.default.moveItem(at: location, to: destinationURL)
                
                // PDF downloaded successfully, you can perform further operations here
                print("PDF downloaded successfully. Destination URL: \(destinationURL)")
                
                DispatchQueue.main.async {
                    // Open the downloaded PDF
                    self.documentInteractionHelper.openDocument(data: Data(), fileName: fileName, from: UIApplication.shared.windows.first!)
                }
            } catch {
                print("Error saving PDF file: \(error.localizedDescription)")
            }
        }.resume()
    }
}
