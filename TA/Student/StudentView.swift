import SwiftUI

struct StudentView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @Binding var userID: String
    @Binding var userName: String
    @State private var showAllExams = false
    
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: StudentStartView(userID: $userID, userName: $userName)) {
                    Label("New Exam", systemImage: "doc.badge.plus")
                }
                NavigationLink(destination: StudentPastView(userID: $userID, userName: $userName)) {
                    Label("Taken Exams", systemImage: "doc.badge.clock")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        routerView.path.removeAll()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        } detail: {
            VStack {
                Text("Select an option from the sidebar")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct StudentPastView: View {
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
    
    let apiManager = ApiManagerStudent()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Spacer()
                Text("\(userName)")
                Image(systemName: "person.circle")
            }
            .padding()
            Spacer()
        ScrollView {
                VStack {
                    ForEach(0..<codingNameTaken.count, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                            HStack {
                                Text("- \(codingNameTaken[safe: index] ?? "-") \(formatDate(from: codingTimeTaken[safe: index] ?? "") ?? "")")
                                Spacer()
                                Button(action: {
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
                            .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    
                }
            }
            Spacer()
        }
        .onAppear {
            fetchExamWas()
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
                    print(examNames)
                    print(examIDs)
                    print(startExamTimes)
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
    
    func formatDate(from timeIntervalString: String) -> String? {
        guard let timeInterval = TimeInterval(timeIntervalString) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct StudentStartView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @Binding var userID: String
    @Binding var userName: String
    @State private var examName: [String] = []
    @State private var examID: [String] = []
    @State private var scheduleDate: [String] = []
    @State private var scheduleStartExamTime: [String] = []
    @State private var scheduleEndExamTime: [String] = []
    @State private var counter: Int = 0
    
    let apiManager = ApiManagerStudent()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
            VStack(alignment: .leading) {
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
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width/2,height: 200)
        .onAppear {
            fetchExamNow()
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
                        if (currentTime > endTimeInterval) {
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
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
