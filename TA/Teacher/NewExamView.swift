import SwiftUI
import UniformTypeIdentifiers
import Combine

struct NewExamView: View {
    @EnvironmentObject var routerView: ServiceRoute
    
    @State var textFieldExamName: String = ""
    @State var sectionCounter: Int = 1
    @State var sectionChoices: [String] = ["Multiple Choice", "Short Answer", "Essay"]
    @State var selectedChoicesSectionIndexes: [Int] = [0]
    @State var scores: [String] = ["0"]
    
    @Binding var isPresented: Bool
    @Binding var examName: [String]
    @Binding var sectionExamCounter: [Int]
    @Binding var userID: String
    var refreshSubject: PassthroughSubject<UUID, Never>
    
    let apiManager = ApiManagerTeacher()
    @State private var documentData: Data?
    @State private var documentURL: URL?
    @State private var documentName: String = "No PDF selected"
    @State private var isShowingDocumentPicker = false
    @State private var isDocumentUploaded = false
    
    var body: some View {
        VStack {
            Text("Exam Name")
                .font(.title)
            TextField("Exam Name", text: $textFieldExamName)
                .frame(width: UIScreen.main.bounds.width / 7 * 3)
                .padding()
                .cornerRadius(10)
                .font(.title)
                .border(Color.black)
            
            HStack {
                Button(action: {
                    isShowingDocumentPicker = true
                }) {
                    Text("Select Document")
                        .padding()
                }
                .sheet(isPresented: $isShowingDocumentPicker) {
                    DocumentPicker(documentData: $documentData, documentName: $documentName)
                }
                Text("Document: \(documentName)")
                    .foregroundColor(documentData != nil ? Color.black : Color.red)
                    .padding()
                    .disabled(true)
            }
            HStack {
                Text("Exam Section ( Max 3 )")
                Button(action: {
                    if sectionCounter < 3 {
                        sectionCounter += 1
                        selectedChoicesSectionIndexes.append(0)
                        scores.append("0")
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                }
                .disabled(sectionCounter >= 3)
                
                Button(action: {
                    if sectionCounter > 1 {
                        sectionCounter -= 1
                        selectedChoicesSectionIndexes.removeLast()
                        scores.removeLast()
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.title)
                        .padding()
                }
                .disabled(sectionCounter <= 1)
            }
            .font(.title)
            
            VStack(alignment: .leading) {
                ForEach(0..<sectionCounter, id: \.self) { index in
                    SectionView(sectionIndex: index, sectionChoices: sectionChoices, selectedChoiceIndex: $selectedChoicesSectionIndexes[index], score: $scores[index])
                }
            }
            
            let totalScore = scores.compactMap { Int($0) }.reduce(0, +)
            HStack {
                Text("Total Score: \(totalScore)")
                Image(systemName: "percent")
            }
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width / 4)
            .border(Color.black)
            
            Button(action: {
                let section1Score = Int(scores[0]) ?? 0
                let section2Score = sectionCounter > 1 ? Int(scores[1]) ?? 0 : 0
                let section3Score = sectionCounter > 2 ? Int(scores[2]) ?? 0 : 0

                apiManager.addNewExam(examName: textFieldExamName,
                                      section1: section1Score,
                                      section2: section2Score,
                                      section3: section3Score,
                                      file: documentData,
                                      userId: userID)
                { error in
                    if let error = error {
                        print("Error occurred: \(error)")
                    } else {
                        print("Exam added successfully")
                        DispatchQueue.main.async {
                            refreshSubject.send(UUID())
                        }
                    }
                }
                self.isPresented = false
            }) {
                Text("Submit")
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .font(.title)
            }
            .frame(width: UIScreen.main.bounds.width / 3, height: 50)
            .background(Color.accentColor)
            .cornerRadius(15)
            .disabled(!isFormValid(totalScore: totalScore))
        }
        .padding()
    }
    
    private func isFormValid(totalScore: Int) -> Bool {
        return !textFieldExamName.isEmpty && documentData != nil && totalScore == 100
    }
}

struct SectionView: View {
    var sectionIndex: Int
    var sectionChoices: [String]
    @Binding var selectedChoiceIndex: Int
    @Binding var score: String
    
    var body: some View {
        VStack {
            HStack {
                Text("\(indexToRoman(sectionIndex + 1)) : ")
                    .frame(width: 30, alignment: .leading)
                Picker("Section \(indexToRoman(sectionIndex + 1))", selection: $selectedChoiceIndex) {
                    ForEach(0..<sectionChoices.count) { index in
                        Text("\(sectionChoices[index])").tag(index)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 4)
                .border(Color.black)
                .padding()
                
                HStack {
                    TextField("Score", text: $score)
                    Image(systemName: "percent")
                }
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width / 8)
                .border(Color.black)
            }
        }
    }
    
    private func indexToRoman(_ index: Int) -> String {
        let romanNumerals = ["I", "II", "III"]
        if index <= romanNumerals.count {
            return romanNumerals[index - 1]
        } else {
            return String(index)
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var documentData: Data?
    @Binding var documentName: String
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(documentData: $documentData, documentName: $documentName)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType(filenameExtension: "docx")].compactMap { $0 }, asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var documentData: Data?
        @Binding var documentName: String
        
        init(documentData: Binding<Data?>, documentName: Binding<String>) {
            _documentData = documentData
            _documentName = documentName
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                documentData = try Data(contentsOf: url)
                documentName = url.lastPathComponent
            } catch {
                print("Error converting file to data: \(error)")
            }
        }
    }
}
