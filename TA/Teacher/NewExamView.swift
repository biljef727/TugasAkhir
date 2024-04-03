//
//  NewExamView.swift
//  TA
//
//  Created by Billy Jefferson on 01/03/24.
//

import SwiftUI
import UniformTypeIdentifiers

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
    
    // Document picker states
    @State private var documentURL: URL?
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
                    DocumentPicker(documentURL: $documentURL, isDocumentUploaded: $isDocumentUploaded)
                }
                
                TextField("Document: \(isDocumentUploaded ? "Done" : "Not Uploaded")", text: .constant(""))
                    .foregroundColor(isDocumentUploaded ? Color.red : Color.black)
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
            .frame(width: UIScreen.main.bounds.width / 8)
            .border(Color.black)
            
            Button(action: {
                examName.append(textFieldExamName)
                sectionExamCounter.append(sectionCounter)
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
        }
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
                .frame(width: UIScreen.main.bounds.width / 10)
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
    @Binding var documentURL: URL?
    @Binding var isDocumentUploaded: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(documentURL: $documentURL, isDocumentUploaded: $isDocumentUploaded)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType(filenameExtension: "docx")].compactMap { $0 }, asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var documentURL: URL?
        @Binding var isDocumentUploaded: Bool
        
        init(documentURL: Binding<URL?>, isDocumentUploaded: Binding<Bool>) {
            _documentURL = documentURL
            _isDocumentUploaded = isDocumentUploaded
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            documentURL = url
            isDocumentUploaded = true
        }
    }
}

//#Preview {
//    NewExamView()
//}
