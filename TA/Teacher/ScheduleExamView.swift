//
//  ScheduleExamView.swift
//  TA
//
//  Created by Billy Jefferson on 19/03/24.
//

import SwiftUI

struct ScheduleExamView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State var listGrade: [String] = []
    
    @State var listExamName: [String] = ["Exam 1", "Exam 2", "Exam 3", "Exam 4","Exam 5","Exam 6"]
    
    @State var examDuration: String = ""
    @State var selectedGradeIndex = 0
    @State var selectedExamIndex = 0
    @State var selectedDate = Date()
    @State var formattedDate: TimeInterval?
    @State var selectedTime = Date()
    @State var formattedTimeStart: TimeInterval?
    @State var formattedTimeEnd: TimeInterval?
    @State var examName: [String] = []
    @State var examCounter :[String] = []
    
    @Binding var isPresented: Bool
    @Binding var scheduleGrade : [String]
    @Binding var scheduleExam : [String]
    @Binding var scheduleStartDate : [TimeInterval]
    @Binding var scheduleStartExamTime : [TimeInterval]
    @Binding var scheduleEndExamTime: [TimeInterval]
    @Binding var userID: String
    
    let apiManager = ApiManagerTeacher()
    var body: some View {
        VStack{
            Picker("Select Exam:", selection: $selectedExamIndex) {
                ForEach(0..<examName.count, id: \.self) { index in
                    Text("\(examName[index])").tag(index)
                }
            }
            .frame(width: UIScreen.main.bounds.width/2,height:50)
            .border(Color.black)
            .padding()
            
            DatePicker(selection: $selectedDate, displayedComponents: .date) {
                Text("Select Date:")
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width / 2, height: 50)
            .border(Color.black)
            
            DatePicker(selection: $selectedTime, displayedComponents: .hourAndMinute) {
                Text("Select Start Time:")
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width / 2, height: 50)
            .border(Color.black)
            .padding()
            
            TextField("Exam Duration", text: $examDuration)
                .padding()
                .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                .border(Color.black)
            
            Picker("Select Grade:", selection: $selectedGradeIndex) {
                ForEach(0..<listGrade.count , id: \.self) { index in
                    Text("\(listGrade[index])").tag(index)
                }
            }
            .frame(width: UIScreen.main.bounds.width/2,height:50)
            .border(Color.black)
            .padding()
            Button(action:{
                let calendar = Calendar.current
                let examDurationMinutes = Int(examDuration) ?? 0
                var examEndDate = calendar.date(byAdding: .minute, value: examDurationMinutes, to: selectedTime) ?? selectedTime
                
                scheduleGrade.append(listGrade[selectedGradeIndex])
                scheduleExam.append(listExamName[selectedExamIndex])
                
                self.formattedDate = selectedDate.timeIntervalSince1970
                self.formattedTimeStart = selectedTime.timeIntervalSince1970
                self.formattedTimeEnd = examEndDate.timeIntervalSince1970
                
                scheduleStartDate.append(formattedDate!)
                scheduleStartExamTime.append(formattedTimeStart!)
                scheduleEndExamTime.append(formattedTimeEnd!)
                
                self.isPresented = false
            }, label:{
                Text("Done")
                    .padding(.vertical,5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .font(.title)
            })
            .frame(width: UIScreen.main.bounds.width/3,height: 50)
            .background(Color.accentColor)
            .cornerRadius(15)
        }
        .onAppear{
            fetchExamNames()
            fecthClassTeacher()
        }
    }
    func fetchExamNames() {
        apiManager.fetchClassID(userID: self.userID) { result in
            switch result {
            case .success(let (examNames, examSectionCounter)):
                DispatchQueue.main.async {
                    self.examName = examNames
                    self.examCounter = examSectionCounter
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    func fecthClassTeacher(){
        apiManager.fetchClassTeacher(userID : self.userID) { result in
            switch result {
            case .success(let teacherClassID):
                DispatchQueue.main.async {
                    self.listGrade = teacherClassID
                }
            case .failure(let error):
                // Handle error, maybe show an alert
                print("Error fetching teacher names: \(error)")
            }
        }
    }
}

//#Preview {
//    ScheduleExamView()
//}
