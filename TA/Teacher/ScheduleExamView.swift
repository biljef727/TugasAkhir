import SwiftUI
import Combine

struct ScheduleExamView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State var listGrade: [String] = []
    @State var listGradeID: [String] = []
    
    @State var examDuration: String = ""
    @State var selectedGradeIndex = 0
    @State var selectedExamIndex = 0
    @State var selectedDate = Date()
    @State var selectedTime = Date()
    @State var formattedDate: TimeInterval?
    @State var formattedTimeStart: TimeInterval?
    @State var formattedTimeEnd: TimeInterval?
    @State var examName: [String] = []
    @State var examID :[String] = []
    
    @Binding var isPresented: Bool
    @Binding var userID: String
    var refreshSubject: PassthroughSubject<UUID, Never>
    
    let apiManager = ApiManagerTeacher()
    
    var body: some View {
        VStack {
            Picker("Select Exam:", selection: $selectedExamIndex) {
                ForEach(0..<examName.count, id: \.self) { index in
                    Text("\(examName[index])").tag(index)
                }
            }
            .frame(width: UIScreen.main.bounds.width/2, height: 50)
            .border(Color.black)
            .padding()
            
            DatePicker("Select Date:", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .padding()
                .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                .border(Color.black)
            
            DatePicker("Select Start Time:", selection: $selectedTime, in: getMinimumTime()..., displayedComponents: .hourAndMinute)
                .padding()
                .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                .border(Color.black)
                .padding()
            
            ZStack {
                TextField("Exam Duration", text: $examDuration)
                    .keyboardType(.numberPad)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                    .border(Color.black)
                HStack {
                    Spacer()
                    Text("Minutes")
                        .padding(.trailing, 25)
                }
            }
            
            Picker("Select Grade:", selection: $selectedGradeIndex) {
                ForEach(0..<listGrade.count, id: \.self) { index in
                    Text("\(listGrade[index])").tag(index)
                }
            }
            .frame(width: UIScreen.main.bounds.width / 2, height: 50)
            .border(Color.black)
            .padding()
            
            Button(action: {
                let calendar = Calendar.current
                let examDurationMinutes = Int(examDuration) ?? 0
                let examEndDate = calendar.date(byAdding: .minute, value: examDurationMinutes, to: selectedTime) ?? selectedTime
                self.formattedDate = selectedDate.timeIntervalSince1970
                self.formattedTimeStart = selectedTime.timeIntervalSince1970
                self.formattedTimeEnd = examEndDate.timeIntervalSince1970
                
                apiManager.addNewScheduleExam(examID: examID[selectedExamIndex],
                                              classID: listGradeID[selectedGradeIndex],
                                              examDate: formattedDate!,
                                              startExamTime: formattedTimeStart!,
                                              endExamTime: formattedTimeEnd!)
                { error in
                    if let error = error {
                        print("Error occurred: \(error)")
                    } else {
                        print("Exam added successfully")
                        DispatchQueue.main.async {
                            refreshSubject.send(UUID())
                        }
                    }
                }
                self.isPresented = false
            }, label: {
                Text("Done")
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .font(.title)
                    .frame(width: UIScreen.main.bounds.width / 3, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
            })
        }
        .onAppear {
            fetchExamNames()
            fecthClassTeacher()
        }
    }
    
    func fetchExamNames() {
        apiManager.fetchClassIDandNames(userID: self.userID) { result in
            switch result {
            case .success(let (examNames, examID)):
                DispatchQueue.main.async {
                    self.examName = examNames
                    self.examID = examID
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
    
    func fecthClassTeacher() {
        apiManager.fetchClassTeacher(userID: self.userID) { result in
            switch result {
            case .success(let (teacherClassID, classID)):
                DispatchQueue.main.async {
                    self.listGrade = teacherClassID
                    self.listGradeID = classID
                }
            case .failure(let error):
                print("Error fetching teacher names: \(error)")
            }
        }
    }
    
    private func getMinimumTime() -> Date {
        let currentDate = Date()
        let calendar = Calendar.current
        let minimumTime = calendar.date(byAdding: .minute, value: 1, to: currentDate) ?? currentDate
        
        if calendar.isDate(selectedDate, inSameDayAs: currentDate) {
            return minimumTime
        } else {
            return calendar.startOfDay(for: selectedDate)
        }
    }
}

//#Preview {
//    ScheduleExamView()
//}
