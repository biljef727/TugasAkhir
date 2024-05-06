//
//  ResultExamView.swift
//  TA
//
//  Created by Billy Jefferson on 01/03/24.
//

import SwiftUI
import Combine

struct ResultExamView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State private var isEditExamStatus = false
    @State var listStudentName: [String] = []
    @State var listStudentID: [String] = []
    @State var studentScore : [String] = []
    @State var selectedID: String? = nil
    @State var studentStatusExam : [String] = []
    @State var nilaiFile :[String] = []
    var examNames : String?
    var examIDs : String?
    var examDates : String?
    var gradeIDs : String?
    let refreshSubject = PassthroughSubject<UUID, Never>()
    let apiManager = ApiManagerTeacher()
    var body: some View {
        VStack{
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    Text("Name").font(.headline)
                    Text("Student ID").font(.headline)
                    Text("Exam Name").font(.headline)
                    Text("Exam Date").font(.headline)
                    Text("Score").font(.headline)
                    Text("File").font(.headline)
                    Text("Status").font(.headline)
                    Text("Edit Stauts").font(.headline)
                    
                    ForEach(0..<listStudentName.count, id:\.self) { index in
                        let selectedUserID = listStudentID[index]
                        Text(listStudentName[index])
                        Text(listStudentID[index])
                        Text(examNames ?? "")
                        Text(examDates ?? "")
                        Text(String(studentScore[index]))
                        
                        Button(action: {
                            //downloadsoal
                            convertAndDownload(datafile: nilaiFile[index])
                        }) {
                            Text("FileSoal")
                        }
                        
                        Text(studentStatusExam[index])
                        
                        if (studentStatusExam[index] == "Wait"){
                            Button(action: {
                                print("Selected userID:", selectedUserID)
                                self.selectedID = listStudentID[index]
                                self.isEditExamStatus.toggle()
                            }) {
                                Text("Edit")
                            }
                        }
                        else{
                            Text("Already Edited")
                        }
                    }
                }
                .border(Color.black)
                .padding()
                .sheet(isPresented: $isEditExamStatus) {
                    EditStatusExam(isPresented: $isEditExamStatus, userID: $selectedID,refreshSubject: refreshSubject)
                }
            }
            VStack(alignment: .leading){
                Spacer()
                Text("Lowest Score")
                let sortedStudents = Array(zip(listStudentName, studentScore)).sorted { $0.1 < $1.1 }
                let lowestThreeStudents = Array(sortedStudents.prefix(3))
                ForEach(lowestThreeStudents, id: \.0) { student in
                    Text("\(student.0) - \(student.1)")
                }
                .frame(width: UIScreen.main.bounds.width/3*2)
                .border(Color.black)
                Spacer()
            }
            .font(.title)
        }
        .onAppear{
            fetchStudentNameAndID()
        }
        .onReceive(refreshSubject) { _ in
            fetchStudentNameAndID()
        }

    }
    func fetchStudentNameAndID(){
        apiManager.fetchStudentIDandNames(classID: self.gradeIDs!, examID: self.examIDs!) { result in
            switch result {
            case .success(let (studentNames, studentID,nilaiTotal,statusScore,nilaiFile)):
                DispatchQueue.main.async {
                    self.listStudentName = studentNames
                    self.listStudentID = studentID
                    self.studentScore = nilaiTotal
                    self.studentStatusExam = statusScore
                    self.nilaiFile = nilaiFile
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    func convertAndDownload(datafile: String) {
        guard let data = Data(base64Encoded: datafile) else {
            print("Failed to decode base64 data.")
            return
        }

        guard let image = UIImage(data: data) else {
            print("Failed to create UIImage from data.")
            return
        }

        // Save image to file
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert UIImage to JPEG data.")
            return
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = documentsPath.appendingPathComponent("downloaded_image.jpg")

        do {
            try imageData.write(to: imagePath)
            print("Image downloaded and saved successfully at: \(imagePath)")
        } catch {
            print("Failed to save image: \(error)")
        }
    }

}

#Preview {
    ResultExamView()
}
