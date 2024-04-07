import SwiftUI

struct ClassAdmissionView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State private var isAddTeacherClassPresented = false
    @State private var isAddStudentClassPresented = false
    
    @State var listTeacherName : [String] = []
    @State var listStudentName : [String] = []
    @State var listTeacherID : [String] = []
    @State var listStudentID : [String] = []
    
    @State var classID: Int
    
    let apiManager = APIManager()
    init(classID: Int) {
        _classID = State(initialValue: classID)
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("Teacher List")
                    .font(.title)
                    .padding()
                Spacer()
                if (listTeacherName.count < 1){
                    Text("")
                }else if(listTeacherName.count == 1){
                    Text("\(listTeacherName.count) teacher")
                }
                else{
                    Text("\(listTeacherName.count) teachers")
                }
                Spacer()
                Button(action:{
                    self.isAddTeacherClassPresented.toggle()
                }) {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.title)
                        .padding()
                }
                .sheet(isPresented: $isAddTeacherClassPresented) {
                    AddTeacherClass(isPresented: $isAddTeacherClassPresented,teacherName: $listTeacherName, teacherID: $listTeacherID, classID: classID)
                }
            }
            ScrollView{
                HStack{
                    VStack(alignment: .leading){
                        ForEach(0..<listTeacherName.count, id: \.self) { index in
                            Text("\(listTeacherName[index]) | \(listTeacherID[index])")
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
            HStack{
                Text("Student List")
                    .font(.title)
                    .padding()
                Spacer()
                if (listStudentName.count < 1){
                    Text("")
                }else if(listStudentName.count == 1){
                    Text("\(listStudentName.count) student")
                }
                else{
                    Text("\(listStudentName.count) students")
                }
                Spacer()
                Button(action:{
                    self.isAddStudentClassPresented.toggle()
                }) {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.title)
                        .padding()
                }
                .sheet(isPresented: $isAddStudentClassPresented) {
                    AddStudentClass(isPresented: $isAddStudentClassPresented,studentName: $listStudentName, studentID: $listStudentID)
                }
            }
            ScrollView{
                HStack{
                    VStack(alignment: .leading){
                        ForEach(0..<listStudentName.count, id: \.self) { index in
                            //                            Text("\(listStudentName[index]) | \(listStudentID[index]) | \(listStudentPassword[index])")
                            Text("\(listStudentName[index]) | \(listStudentID[index])")
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
            Button(action:{
                for studentID in listStudentID{
                        apiManager.admissionStudent(classID: classID, userID: Int(studentID) ?? 0) { result in
                            switch result {
                            case .success:
                                print("Student admitted successfully")
                            case .failure(let error):
                                print("Error admitting student: \(error.localizedDescription)")
                            }
                        }
                    }
                for teacherID in listTeacherID {
                        apiManager.admissionTeacher(classID: classID, userID: Int(teacherID) ?? 0) { result in
                            switch result {
                            case .success:
                                print("Teacher admitted successfully")
                            case .failure(let error):
                                print("Error admitting teacher: \(error.localizedDescription)")
                            }
                        }
                    }
                DispatchQueue.main.async{
                    routerView.path.removeLast()
                }
            }, label:{
                Text("Done")
                    .padding(.vertical,5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .font(.title)
            })
            .frame(width: UIScreen.main.bounds.width/3,height: 50)
            .background(Color.accentColor)
            .cornerRadius(15)
        }
        .onAppear {
            fetchTeacherInsideClass()
        }
    }
    func fetchTeacherInsideClass(){
        apiManager.fetchAlreadyTeacher(ClassID: String(classID)) { result in
            switch result {
            case .success(let (teacherNamesInsideClass,teacherIDInsideClass)):
                DispatchQueue.main.async {
                    self.listTeacherName = teacherNamesInsideClass
                    self.listTeacherID = teacherIDInsideClass
                }
            case .failure(let error):
                // Handle error, maybe show an alert
                print("Error fetching teacher names: \(error)")
            }
        }
    }
    
}
