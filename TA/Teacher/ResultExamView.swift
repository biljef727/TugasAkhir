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
    @State var listStudentName: [String] = ["Student 1", "Student 2", "Student 3", "Student 4", "Student 5", "Student 6", "Student 7", "Student 8", "Student 9", "Student 10", "Student 11", "Student 12"]
    @State var listStudentID: [String] = ["ID 1", "ID 2", "ID 3", "ID 4", "ID 5", "ID 6", "ID 7", "ID 8", "ID 9", "ID 10", "ID 11", "ID 12"]
    @State var examName: String = "Matematika"
    @State var dateStartExam : String = "01-03-2024"
    @State var dateDoneExam : String = "01-03-2024"
    @State var studentScore : [Int] = [100, 85, 100, 100, 100, 100, 100, 100, 75, 100, 100, 40]
    @State var studentStatusExam : [String] = ["Done","Wait","Done","Wait","Done","Wait","Done","Wait","Done","Wait","Done","Wait"]
    
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
                    Text("ID").font(.headline)
                    Text("Exam Name").font(.headline)
                    Text("Start Date").font(.headline)
                    Text("End Date").font(.headline)
                    Text("Score").font(.headline)
                    Text("Status").font(.headline)
                    Text("Edit").font(.headline)
                    
                    ForEach(0..<listStudentName.count, id:\.self) { index in
                        Text(listStudentName[index])
                        Text(listStudentID[index])
                        Text(examName)
                        Text(dateStartExam)
                        Text(dateDoneExam)
                        Text(String(studentScore[index]))
                        Text(studentStatusExam[index])
                        Button(action: {
                            self.isEditExamStatus.toggle()
                        }) {
                            Text("Edit")
                        }.sheet(isPresented: $isEditExamStatus) {
                            EditStatusExam(isPresented: $isEditExamStatus)
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
    }
}

#Preview {
    ResultExamView()
}
