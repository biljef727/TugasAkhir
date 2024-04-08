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
    @State var scheduleStartDate :[String] = []
    @State var scheduleStartExamTime :[String] = []
    @State var scheduleEndExamTime : [String] = []
    
    let refreshSubject = PassthroughSubject<Void, Never>()
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
                    VStack(alignment: .leading){
                        ForEach(0..<scheduleExam.count, id: \.self) { index in
                            HStack{
                                Text("\(scheduleExam[index]) | \(formatDate(from: scheduleStartDate[index])!) | \(formatScheduleStartTime(from: scheduleStartExamTime[index])!) - \(formatScheduleStartTime(from: scheduleEndExamTime[index])!) | \(scheduleGrade[index])")
                                    .padding()
                                Button(action: {
                                    routerView.path.append("resultExam")
                                }) {
                                    Text("View Results")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            }
                        }
                    }
                    Spacer()
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
                case .success(let (examNames, examDates,startExamTimes,endExamTimes,classNames)):
                    self.scheduleExam = examNames
                    self.scheduleStartDate = examDates
                    self.scheduleStartExamTime = startExamTimes
                    self.scheduleEndExamTime = endExamTimes
                    self.scheduleGrade = classNames
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
