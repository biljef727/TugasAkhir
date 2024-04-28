//
//  StudentView.swift
//  TA
//
//  Created by Billy Jefferson on 22/03/24.
//

import SwiftUI

struct StudentView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @Binding var userID: String
    @State var examName : String = ""
    @State var examID : String = ""
    @State var scheduleStartExamTime :String = ""
    @State var scheduleEndExamTime : String = ""
    @State var codingTaken : [String] = ["Coding1","Coding2"]
    @State var codingTimeTaken : [String] = ["14 Maret 2024","17 Agustus 1945"]
    let apiManager = ApiManagerStudent()
    //    let apiManager = ApiManagerTeacher()
    var body: some View {
        VStack{
            VStack(alignment:.leading){
                Text("Last Seen Exam")
                HStack{
                    Text("Exam Name :")
                    Text("-")
                }
                .padding(.vertical)
                HStack{
                    Text("Score Result :")
                    Text("-")
                    Spacer()
                    Button(action:{
                        
                    }, label:{
                        Text("See Result")
                            .foregroundColor(Color.white)
                    })
                    .frame(width: UIScreen.main.bounds.width/4,height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                }
            }
            Divider()
            VStack(alignment:.leading){
                Text("New Exam")
                HStack{
                    Text("Start Time :")
                    Text("\(formatDate(from:scheduleStartExamTime) ?? "")")
                }
                .padding(.vertical)
                HStack{
                    Text("End Time:")
                    Text("\(formatDate(from:scheduleEndExamTime) ?? "")")
                }
                .padding(.vertical)
                HStack{
                    Text("Exam Name :")
                    Text("\(examName)")
                    Spacer()
                    Button(action:{
                        let examInfo = "\(examID)"
                        routerView.path.append("startExam/\(examInfo)")
                    }, label:{
                        Text("Start")
                            .foregroundColor(Color.white)
                    })
                    .frame(width: UIScreen.main.bounds.width/4,height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                }
            }
            Divider()
            VStack(alignment:.leading){
                Text("Your Taken Exam")
                VStack{
                    ForEach(0..<codingTaken.count, id: \.self) { index in
                        HStack{
                            Text("- \(codingTaken[index]) | \(codingTimeTaken[index])").tag(index)
                            Spacer()
                            Button(action:{
                                
                            }, label:{
                                Text("See")
                                    .foregroundColor(Color.white)
                            })
                            .frame(width: UIScreen.main.bounds.width/10,height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(15)
                        }
                        .padding(.vertical)
                    }
                }
            }
            Divider()
        }
        .onAppear{
            fetchExamNow()
        }
        .frame(maxWidth: UIScreen.main.bounds.width/2, maxHeight: UIScreen.main.bounds.height)
        //        .background(Color.red)
        .font(.title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action:{
                    routerView.path.removeAll()
                }) {
                    Image(systemName: "square.and.arrow.up.circle")
                    Text("Log Out")
                }
            }
        }
    }
    func fetchExamNow() {
        apiManager.fetchExamNow(userID: self.userID) { result in
            switch result {
            case .success(let (startExamTimes,endExamTimes,examNames,examIDs)):
                DispatchQueue.main.async {
                    self.scheduleStartExamTime = startExamTimes
                    self.scheduleEndExamTime = endExamTimes
                    self.examName = examNames
                    self.examID = examIDs
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    func formatDate(from timeIntervalString: String) -> String? {
        guard let timeInterval = TimeInterval(timeIntervalString) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy , h:mm a"
        
        return formatter.string(from: date)
    }
}
//
//#Preview {
//    StudentView()
//}
