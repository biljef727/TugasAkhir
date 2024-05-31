//
//  TeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

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
    
    @State private var isAddNewExam = false
    
    @State var examName: [String] = []
    @State var examCounter: [String] = []
    @State var sectionExamCounter: [Int] = []
    @State var examFiles: [Data] = []
    
    let refreshSubject = PassthroughSubject<UUID, Never>()
    let apiManager = ApiManagerTeacher()
    let documentInteractionHelper = DocumentInteractionHelper()
    
    var body: some View {
        VStack {
            Text("Bank Soal")
                .font(Font.custom("Times New Roman", size: 50))
            Divider()
                .frame(minHeight: 2)
                .background(Color.black)
                .padding(.vertical)
            HStack {
                Text("Examination")
                    .font(.title)
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
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(0..<examName.count, id: \.self) { index in
                            HStack {
                                Text("\(examName[index]) | Total Section : \(examCounter[index])")
                                    .padding()
                                Button(action: {
                                    let fileData = examFiles[index]
                                    let fileName = "\(examName[index]).pdf"
                                    if let rootView = UIApplication.shared.windows.first?.rootViewController?.view {
                                        documentInteractionHelper.openDocument(data: fileData, fileName: fileName, from: rootView)
                                    }
                                }) {
                                    Text("Download \(examName[index]).pdf")
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            fetchExamNames()
        }
        .onReceive(refreshSubject) { _ in // Receive UUID from refreshSubject
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
}
