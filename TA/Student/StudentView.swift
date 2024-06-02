import SwiftUI
import CoreData

struct StudentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exam.examIDLast, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Exam>
    
    @EnvironmentObject var routerView: ServiceRoute
    @Binding var userID: String
    @Binding var userName: String
    @State private var examName: [String] = []
    @State private var examID: [String] = []
    @State private var scheduleDate: [String] = []
    @State private var scheduleStartExamTime: [String] = []
    @State private var scheduleEndExamTime: [String] = []
    @State private var codingNameTaken: [String] = []
    @State private var codingIDTaken: [String] = []
    @State private var codingTimeTaken: [String] = []
    @State private var scoring: String = ""
    @State private var counter: Int = 0
    @State private var showAllExams = false
    @State private var lastSeenExam: Exam? = nil

    let apiManager = ApiManagerStudent()

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("New Exam")
                HStack {
                    Text("Start Time: \(formatDate(from: scheduleDate[safe: counter] ?? "") ?? "") \(formatTime(from: scheduleStartExamTime[safe: counter] ?? "") ?? "")")
                }
                .padding(.vertical)
                HStack {
                    Text("End Time: \(formatDate(from: scheduleDate[safe: counter] ?? "") ?? "") \(formatTime(from: scheduleEndExamTime[safe: counter] ?? "") ?? "")")
                }
                .padding(.vertical)
                HStack {
                    Text("Exam Name: \(examName[safe: counter] ?? "-")")
                    Spacer()
                    Button(action: {
                        if !examID.isEmpty {
                            let examInfo = "\(examID[safe: counter] ?? "")"
                            routerView.path.append("startExam/\(examInfo)")
                            counter += 1
                        }
                    }, label: {
                        Text("Start")
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width / 4, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(15)
                    })
                    .disabled(!isExamTimeValid(counter: counter))

                }
            }
            Divider()
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Your Taken Exam")
                    VStack {
                        ForEach(0..<min(codingNameTaken.count, showAllExams ? codingNameTaken.count : 2), id: \.self) { index in
                            HStack {
                                Text("- \(codingNameTaken[safe: index] ?? "-") \(formatDate(from: codingTimeTaken[safe: index] ?? "") ?? "")")
                                Spacer()
                                Button(action: {
//                                    if !codingIDTaken.isEmpty {
//                                        fetchScore(examID: codingIDTaken[index]) { score in
//                                            saveToCoreData(examID: codingIDTaken[index], examName: codingNameTaken[index], score: score) {
//                                                lastSeenExam = fetchLastSeenExam()
//                                            }
//                                        }
//                                    }
                                    let examInfo = "\(codingIDTaken[index])"
                                    routerView.path.append("yourTakenExam/\(examInfo)")
                                }, label: {
                                    Text("See")
                                        .foregroundColor(Color.white)
                                        .frame(width: UIScreen.main.bounds.width / 10, height: 50)
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
                        } else {
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
        .onAppear {
            fetchExamNow()
            fetchExamWas()
            lastSeenExam = fetchLastSeenExam()
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
        .font(.title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    routerView.path.removeAll()
                }) {
                    Image(systemName: "square.and.arrow.up.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(userName)
            }
        }
    }
    func isExamTimeValid(counter: Int) -> Bool {
        guard let startTimeInterval = TimeInterval(scheduleStartExamTime[safe: counter] ?? ""),
              let endTimeInterval = TimeInterval(scheduleEndExamTime[safe: counter] ?? "") else {
            return false
        }

        let currentTime = Date().timeIntervalSince1970
        return currentTime >= startTimeInterval && currentTime <= endTimeInterval
    }

    func fetchExamNow() {
        apiManager.fetchExamNow(userID: userID) { result in
            switch result {
            case .success(let (startDateTime, startExamTimes, endExamTimes, examNames, examIDs)):
                DispatchQueue.main.async {
                    self.scheduleDate = startDateTime.isEmpty ? [""] : startDateTime
                    self.scheduleStartExamTime = startExamTimes.isEmpty ? [""] : startExamTimes
                    self.scheduleEndExamTime = endExamTimes.isEmpty ? [""] : endExamTimes
                    self.examName = examNames.isEmpty ? [""] : examNames
                    self.examID = examIDs.isEmpty ? [""] : examIDs
                    
                    // Check if exam is ongoing or ended and set name to "" if ended
                    for (index, endTimeString) in endExamTimes.enumerated() {
                        guard let endTimeInterval = TimeInterval(endTimeString) else {
                            continue
                        }
                        let currentTime = Date().timeIntervalSince1970
                        if currentTime > endTimeInterval {
                            self.examName[index] = ""
                            self.scheduleDate[index] = ""
                            self.scheduleStartExamTime[index] = ""
                            self.scheduleEndExamTime[index] = ""
                            self.examID[index] = ""
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching exams: \(error)")
                DispatchQueue.main.async {
                    self.scheduleDate = [""]
                    self.scheduleStartExamTime = [""]
                    self.scheduleEndExamTime = [""]
                    self.examName = [""]
                    self.examID = [""]
                }
            }
        }
    }

    
    func fetchExamWas() {
        apiManager.fetchExamWas(userID: userID) { result in
            switch result {
            case .success(let (_, startExamTimes, _, examNames, examIDs)):
                DispatchQueue.main.async {
                    self.codingTimeTaken = startExamTimes.isEmpty ? [""] : startExamTimes
                    self.codingNameTaken = examNames.isEmpty ? [""] : examNames
                    self.codingIDTaken = examIDs.isEmpty ? [""] : examIDs
                }
            case .failure(let error):
                print("Error fetching past exams: \(error)")
                DispatchQueue.main.async {
                    self.codingTimeTaken = [""]
                    self.codingNameTaken = [""]
                    self.codingIDTaken = [""]
                }
            }
        }
    }
    
    func fetchScore(examID: String, completion: @escaping (String) -> Void) {
        apiManager.fetchScore(userID: userID, examID: examID) { result in
            switch result {
            case .success(let (_, _, _, _, _, totalScore, _, _)):
                DispatchQueue.main.async {
                    completion(totalScore)
                }
            case .failure(let error):
                print("Error fetching score: \(error)")
                DispatchQueue.main.async {
                    completion("")
                }
            }
        }
    }
    
    func formatTime(from timeIntervalString: String) -> String? {
        guard let timeInterval = TimeInterval(timeIntervalString) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
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
    
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    func saveToCoreData(examID: String, examName: String, score: String, completion: @escaping () -> Void) {
        let newExam = Exam(context: viewContext)
        newExam.examIDLast = examID
        newExam.examNameLast = examName
        newExam.scoreLast = score

        do {
            try viewContext.save()
            completion()
        } catch {
            print("Error saving data to Core Data: \(error)")
            completion()
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

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
