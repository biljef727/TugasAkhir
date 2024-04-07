//
//  TeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State var selectedGradeIndex = 0
    @State var selectedGradeIndex2 = 0
    @Binding var userID: String
    @State private var isAddScheduleExam = false
    
    @State var scheduleExam : [String] = []
    @State var scheduleGrade : [String] =  []
    @State var scheduleStartDate :[TimeInterval] = []
    @State var scheduleStartExamTime :[TimeInterval] = []
    @State var scheduleEndExamTime : [TimeInterval] = []
    
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
                    ScheduleExamView(isPresented: $isAddScheduleExam, scheduleGrade: $scheduleGrade,scheduleExam: $scheduleExam,scheduleStartDate: $scheduleStartDate,scheduleStartExamTime: $scheduleStartExamTime,scheduleEndExamTime: $scheduleEndExamTime, userID: $userID)
                }
            }
            ScrollView{
                HStack{
                    VStack(alignment: .leading){
                        ForEach(0..<scheduleExam.count, id: \.self) { index in
                            HStack{
                                Text("\(scheduleExam[index]) | \(formatDate(from: scheduleStartDate[index])) | \(formatScheduleStartTime(from: scheduleStartExamTime[index])) - \(formatScheduleStartTime(from: scheduleEndExamTime[index])) | \(scheduleGrade[index])")
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
    }
    func formatDate(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        return formatter.string(from: date)
    }
    func formatScheduleStartTime(from timeInterval: TimeInterval) -> String {
        let startDate = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startDate)
    }
    
    //    var dateFormatter: DateFormatter {
    //           let formatter = DateFormatter()
    //           formatter.dateFormat = "EEEE, MMMM dd, yyyy"
    //           return formatter
    //       }
    //    var timeFormatter: DateFormatter {
    //           let formatter = DateFormatter()
    //            formatter.dateFormat = "h:mm a"
    //           return formatter
    //       }
}

//#Preview {
//    ScheduleView()
//}
