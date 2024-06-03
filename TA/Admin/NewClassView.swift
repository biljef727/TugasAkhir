import SwiftUI
import Combine

struct NewClassView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State private var selectedGradeIndex = 0
    @State private var selectedSemesterIndex = 0
    
    @Binding var isPresented: Bool
    var refreshSubject: PassthroughSubject<Void, Never>
    @Binding var className: [String]

    let listGrade: [String] = ["4-A", "4-B", "5-A","5-B", "6-A", "6-B","10-AB"]
    let listSemester: [String] = ["1", "2"]
    
    let apiManager = APIManager()

    var body: some View {
        VStack {
            Spacer()
            Text("Add New Class")
                .font(Font.custom("", size: 50))
            Spacer()
            Text("Select Grade :")
            Picker("Select Grade:", selection: $selectedGradeIndex) {
                ForEach(0..<listGrade.count) { index in
                    Text("\(listGrade[index])").tag(index)
                }
            }
            .frame(width: UIScreen.main.bounds.width/2, height: 50)
            .border(Color.black)
            .padding()
//            Spacer()
            Text("Select Semester")
            Picker("Select Semester:", selection: $selectedSemesterIndex) {
                ForEach(0..<listSemester.count) { index in
                    Text("\(self.formattedYear())-\(listSemester[index])").tag(index)
                }
            }
            .frame(width: UIScreen.main.bounds.width/2, height: 50)
            .border(Color.black)
            .padding()
            Spacer()
            Button(action: {
                apiManager.addClass(
                    className: listGrade[selectedGradeIndex],
                    classSemester: "\(self.formattedYear())-\(listSemester[selectedSemesterIndex])"
                ) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isPresented = false
                            self.refreshSubject.send()
                        }
                    case .failure(let error):
                        print("Failed to add class: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Done")
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width/3,height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
            }
            Spacer()
        }
    }

    func formattedYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
}
