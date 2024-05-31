//
//  StudentView.swift
//  TA
//
//  Created by Billy Jefferson on 22/03/24.
//

import SwiftUI
import CoreData

struct StudentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exam.examIDLast, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Exam>
    
    @EnvironmentObject var routerView : ServiceRoute
    @Binding var userID: String
    @Binding var userName : String
    @State var examName : String = ""
    @State var examID : String = ""
    @State var scheduleDate :String = ""
    @State var scheduleStartExamTime :String = ""
    @State var scheduleEndExamTime : String = ""
    @State var codingNameTaken : [String] = []
    @State var codingIDTaken : [String] = []
    @State var codingTimeTaken : [String] = []
    @State var scoring : String = ""
    @State var counter : Int = 1
    @State var showAllExams = false
    
    let apiManager = ApiManagerStudent()
    var body: some View {
        VStack{
            VStack(alignment:.leading){
                Text("Last Seen Exam")
                HStack{
                    Text("Exam Name : \(fetchLastSeenExam()?.examNameLast ?? "-")")
                }
                .padding(.vertical)
                HStack{
                    Text("Score Result :  \(fetchLastSeenExam()?.scoreLast ?? "-") ")
                    Spacer()
                    Button(action:{
                        let examInfo = "\(codingIDTaken[0])"
                        routerView.path.append("yourTakenExam/\(examInfo)")
                    }, label:{
                        Text("See Result")
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width/4,height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(15)
                    })
                }
            }
            Divider()
            if counter == 1{
                VStack(alignment:.leading){
                    Text("New Exam")
                    HStack{
                        Text("Start Time : \(formatDate(from:scheduleDate) ?? "") \(formatTime(from:scheduleStartExamTime) ?? "")")
                    }
                    .padding(.vertical)
                    HStack{
                        Text("End Time: \(formatDate(from:scheduleDate) ?? "") \(formatTime(from:scheduleEndExamTime) ?? "")")
                    }
                    .padding(.vertical)
                    HStack{
                        Text("Exam Name : \(examName)")
                        Spacer()
                        Button(action:{
                            let examInfo = "\(examID)-\(counter)"
                            routerView.path.append("startExam")
//                            counter += 1
                        }, label:{
                            Text("Start")
                                .foregroundColor(Color.white)
                                .frame(width: UIScreen.main.bounds.width/4,height: 50)
                                .background(Color.accentColor)
                                .cornerRadius(15)
                        })
                    }
                }
            }
//            if counter == 2{
//                VStack(alignment:.leading){
//                    Text("New Exam")
//                    HStack{
//                        Text("Start Time : \(formatDate(from:scheduleDate) ?? "") \(formatTime(from:scheduleStartExamTime) ?? "")")
//                    }
//                    .padding(.vertical)
//                    HStack{
//                        Text("End Time: \(formatDate(from:scheduleDate) ?? "") \(formatTime(from:scheduleEndExamTime) ?? "")")
//                    }
//                    .padding(.vertical)
//                    HStack{
//                        Text("Exam Name : \(examName)")
//                        Spacer()
//                        Button(action:{
//                            let examInfo = "\(examID)-\(counter)"
//                            routerView.path.append("startExam/\(examInfo)")
//                            counter += 1
//                        }, label:{
//                            Text("Start")
//                                .foregroundColor(Color.white)
//                                .frame(width: UIScreen.main.bounds.width/4,height: 50)
//                                .background(Color.accentColor)
//                                .cornerRadius(15)
//                        })
//                    }
//                }
//            }
//            if counter == 3{
//                VStack(alignment:.leading){
//                    Text("New Exam")
//                    HStack{
//                        Text("Start Time :")
//                    }
//                    .padding(.vertical)
//                    HStack{
//                        Text("End Time:")
//                    }
//                    .padding(.vertical)
//                    HStack{
//                        Text("Exam Name :")
//                        Spacer()
//                        Button(action:{
//                            
//                        }, label:{
//                            Text("Start")
//                                .foregroundColor(Color.white)
//                                .frame(width: UIScreen.main.bounds.width/4,height: 50)
//                                .background(Color.accentColor)
//                                .cornerRadius(15)
//                        })
//                    }
//                }
//            }
            Divider()
            ScrollView{
                VStack(alignment: .leading) {
                    Text("Your Taken Exam")
                    VStack {
                        ForEach(0..<min(codingNameTaken.count, showAllExams ? codingNameTaken.count : 2), id: \.self) { index in
                            HStack {
                                Text("- \(codingNameTaken[index]) | \(formatDate(from: codingTimeTaken[index]) ?? "")").tag(index)
                                Spacer()
                                Button(action:{
                                    fetchScore(examID: codingIDTaken[index])
                                    saveToCoreData(examID: codingIDTaken[index], examName: codingNameTaken[index], score: scoring)
                                    let examInfo = "\(codingIDTaken[index])"
                                    routerView.path.append("yourTakenExam/\(examInfo)")
                                }, label:{
                                    Text("See")
                                        .foregroundColor(Color.white)
                                        .frame(width: UIScreen.main.bounds.width/10, height: 50)
                                        .background(Color.accentColor)
                                        .cornerRadius(15)
                                })
                            }
                            .padding(.vertical)
                        }
                        if !showAllExams && codingNameTaken.count > 2 {
                            Button(action: {
                                showAllExams = true
                            }) {
                                Text("See More")
                                    .foregroundColor(Color.accentColor)
                                    .padding(.top, 10)
                            }
                        }else{
                            Button(action: {
                                showAllExams = false
                            }) {
                                Text("See Less")
                                    .foregroundColor(Color.accentColor)
                                    .padding(.top, 10)
                            }
                        }
                    }
                }
            }
        }
        .onAppear{
            fetchExamNow()
            fetchExamWas()
        }
        .frame(maxWidth: UIScreen.main.bounds.width/2)
        .font(.title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action:{
                    routerView.path.removeAll()
                }) {
                    Image(systemName: "square.and.arrow.up.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(userName)")
            }
        }
    }
    func fetchExamNow() {
        apiManager.fetchExamNow(userID: self.userID) { result in
            switch result {
            case .success(let (startDateTime,startExamTimes,endExamTimes,examNames,examIDs)):
                DispatchQueue.main.async {
                    if counter == 1{
                        self.scheduleDate = startDateTime[0]
                        self.scheduleStartExamTime = startExamTimes[0]
                        self.scheduleEndExamTime = endExamTimes[0]
                        self.examName = examNames[0]
                        self.examID = examIDs[0]
                    }
                    if counter == 2{
                        self.scheduleDate = startDateTime[1]
                        self.scheduleStartExamTime = startExamTimes[1]
                        self.scheduleEndExamTime = endExamTimes[1]
                        self.examName = examNames[1]
                        self.examID = examIDs[1]
                    }
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    func fetchExamWas() {
        apiManager.fetchExamWas(userID: self.userID) { result in
            switch result {
            case .success(let (_,startExamTimes,_,examNames,examIDs)):
                DispatchQueue.main.async {
                        self.codingTimeTaken = startExamTimes
                        self.codingNameTaken = examNames
                        self.codingIDTaken = examIDs
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    func fetchScore(examID: String){
        apiManager.fetchScore(userID: self.userID,examID: examID) { result in
            switch result {
            case .success(let (_,_,_,_,_,totalScore,_,_)):
                DispatchQueue.main.async {
                    self.scoring = totalScore
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    func formatTime(from timeIntervalString: String) -> String? {
        guard let timeInterval = TimeInterval(timeIntervalString) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        return formatter.string(from: date)
    }
    func formatDate(from timeIntervalString: String) -> String? {
        guard let timeInterval = TimeInterval(timeIntervalString) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        return formatter.string(from: date)
    }
    func saveToCoreData(examID: String, examName: String,score:String) {
        let newExam = Exam(context: viewContext)
        newExam.examIDLast = examID
        newExam.examNameLast = examName
        newExam.scoreLast = score

        do {
            try viewContext.save()
        } catch {
            print("Error saving data to Core Data: \(error)")
        }
    }
    func fetchLastSeenExam() -> Exam? {
        let fetchRequest: NSFetchRequest<Exam> = Exam.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Exam.examIDLast, ascending: false)]

        do {
            let exams = try viewContext.fetch(fetchRequest)
            return exams.first
        } catch {
            print("Error fetching last seen exam: \(error)")
            return nil
        }
    }
}
//
//#Preview {
//    StudentView()
//}
