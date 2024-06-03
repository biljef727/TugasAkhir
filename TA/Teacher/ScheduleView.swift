import SwiftUI
import Combine

struct ScheduleView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State var selectedGradeIndex = 0
    @State var selectedGradeIndex2 = 0
    @Binding var userID: String
    @Binding var userName: String
    @State private var isAddScheduleExam = false
    
    @State var examIDs: [String] = []
    @State var scheduleExam: [String] = []
    @State var scheduleGrade: [String] = []
    @State var scheduleGradeID: [String] = []
    @State var scheduleStartDate: [String] = []
    @State var scheduleStartExamTime: [String] = []
    @State var scheduleEndExamTime: [String] = []
    
    let refreshSubject = PassthroughSubject<UUID, Never>()
    let apiManager = ApiManagerTeacher()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ZStack{
                HStack{
                    Spacer()
                    Text("\(userName)")
                    Image(systemName: "person.circle")
                }
                .padding()
                Text("Scheduled Exam")
                    .font(Font.custom("", size: 50))
                    .bold()
            }
            Divider()
                .frame(minHeight: 2)
                .background(Color.black)
                .padding(.vertical)
            HStack {
                Text("")
                    .font(.title)
                    .padding()
                Spacer()
                Button(action: {
                    self.isAddScheduleExam.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                }
                .sheet(isPresented: $isAddScheduleExam) {
                    ScheduleExamView(isPresented: $isAddScheduleExam, userID: $userID, refreshSubject: refreshSubject)
                }
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<scheduleExam.count, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                            VStack(alignment:.leading) {
                                Text("\(scheduleExam[index])")
                                Text("\(formatDate(from: scheduleStartDate[index])!)")
                                Text("\(formatScheduleStartTime(from: scheduleStartExamTime[index])!) - \(formatScheduleStartTime(from: scheduleEndExamTime[index])!)")
                                Text("\(scheduleGrade[index])")
                                Button(action: {
                                    let examInfo = "\(scheduleExam[index])-\(examIDs[index])-\(passingFormatDate(from: scheduleStartDate[index])!)-\(scheduleGradeID[index])"
                                    routerView.navigate(to: "resultExam/\(examInfo)")
                                }) {
                                    Text("View Results")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
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
                case .success(let (examIDs, examNames, examDates, startExamTimes, endExamTimes, classNames, classID)):
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
