//
//  ResultExamView.swift
//  TA
//
//  Created by Billy Jefferson on 01/03/24.
//

import SwiftUI

struct ResultExamView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State private var isEditExamStatus = false
    @State var listStudentName: [String] = []
    @State var listStudentID: [String] = []
    @State var studentScore : [String] = []
    @State var studentStatusExam : [String] = []
    
    var examNames : String?
    var examIDs : String?
    var examDates : String?
    var gradeIDs : String?
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
                        Text(listStudentName[index])
                        Text(listStudentID[index])
                        Text(examNames ?? "")
                        Text(examDates ?? "")
                        Text(String(studentScore[index]))
                        
                        Button(action: {
                            //downloadsoal
                        }) {
                            Text("File Soal")
                        }
                        Text(studentStatusExam[index])
//                        Text("Done")
                        
                        Button(action: {
                            self.isEditExamStatus.toggle()
                        }) {
                            Text("Edit")
                        }.sheet(isPresented: $isEditExamStatus) {
                            EditStatusExam(isPresented: $isEditExamStatus, userID: listStudentID[index])
                        }
                        
                    }
                }
                .border(Color.black)
                .padding()
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
    }
    func fetchStudentNameAndID(){
        apiManager.fetchStudentIDandNames(classID: self.gradeIDs!, examID: self.examIDs!) { result in
            switch result {
            case .success(let (studentNames, studentID,nilaiTotal,statusScore)):
                DispatchQueue.main.async {
                    self.listStudentName = studentNames
                    self.listStudentID = studentID
                    self.studentScore = nilaiTotal
                    self.studentStatusExam = statusScore
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
}

#Preview {
    ResultExamView()
}
