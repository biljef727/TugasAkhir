//
//  TeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

import SwiftUI
import Combine

struct ScheduleView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State var selectedGradeIndex = 0
    @State var selectedGradeIndex2 = 0
    @Binding var userID: String
    @State private var isAddScheduleExam = false
    
    @State var examIDs : [String] = []
    @State var scheduleExam : [String] = []
    @State var scheduleGrade : [String] =  []
    @State var scheduleGradeID : [String] =  []
    @State var scheduleStartDate :[String] = []
    @State var scheduleStartExamTime :[String] = []
    @State var scheduleEndExamTime : [String] = []
    let refreshSubject = PassthroughSubject<UUID, Never>()
    let apiManager = ApiManagerTeacher()
    var body: some View {
        VStack{
            Text("Bank Soal")
                .font(Font.custom("Times New Roman", size: 50))
            Divider()
                .frame(minHeight: 2)
                .background(Color.black)
                .padding(.vertical)
            HStack{
                Text("Scheduled Exam")
                    .font(.title)
                    .padding()
                Spacer()
                Button(action:{
                    self.isAddScheduleExam.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                }
                .sheet(isPresented: $isAddScheduleExam) {
                    ScheduleExamView(isPresented: $isAddScheduleExam, userID: $userID,refreshSubject: refreshSubject)
                }
            }
            ScrollView{
                HStack{
                    VStack(){
                        ForEach(0..<scheduleExam.count, id: \.self) { index in
                            HStack{
                                Text("\(scheduleExam[index])")
//                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: UIScreen.main.bounds.width/5)
                                Text("\(formatDate(from: scheduleStartDate[index])!)")
                                    .frame(maxWidth: UIScreen.main.bounds.width/5)
                                Text("\(formatScheduleStartTime(from: scheduleStartExamTime[index])!) - \(formatScheduleStartTime(from: scheduleEndExamTime[index])!)")
                                    .frame(maxWidth: UIScreen.main.bounds.width/5)
                                Text("\(scheduleGrade[index])")
                                    .frame(maxWidth: UIScreen.main.bounds.width/5)
                            }
                            .padding()
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing){
                        ForEach(0..<scheduleExam.count, id: \.self) { index in
                            HStack{
                                Button(action: {
                                    let examInfo = "\(scheduleExam[index])-\(examIDs[index])-\(passingFormatDate(from: scheduleStartDate[index])!)-\(scheduleGradeID[index])"
                                    routerView.navigate(to: "resultExam/\(examInfo)")
                                }) {
                                    Text("View Results")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                                .frame(maxWidth: UIScreen.main.bounds.width/5)
                            }
                        }
                    }
                    
                }
            }
        }
        .onAppear{
            fetchScheduleData()
        }
        .onReceive(refreshSubject) { _ in
            fetchScheduleData()
        }
    }
    func fetchScheduleData() {
        apiManager.getScheduleExamName(userID: self.userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (examIDs,examNames, examDates,startExamTimes,endExamTimes,classNames,classID)):
                    self.examIDs = examIDs
                    self.scheduleExam = examNames
                    self.scheduleStartDate = examDates
                    self.scheduleStartExamTime = startExamTimes
                    self.scheduleEndExamTime = endExamTimes
                    self.scheduleGrade = classNames
                    self.scheduleGradeID = classID
                case .failure(let error):
                    print("Error fetching Scheduled names: \(error)")
                }
            }
        }
    }
    
    func formatDate(from timeIntervalString: String) -> String? {
        guard let timeInterval = TimeInterval(timeIntervalString) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        
        return formatter.string(from: date)
    }
    func passingFormatDate(from timeIntervalString: String) -> String? {
        guard let timeInterval = TimeInterval(timeIntervalString) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        
        return formatter.string(from: date)
    }
    func formatScheduleStartTime(from timeInterval: String) -> String? {
        guard let timeInterval = TimeInterval(timeInterval) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        return formatter.string(from: date)
    }
}

//#Preview {
//    ScheduleView()
//}
