//
//  TeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

import SwiftUI
import Combine

struct TeacherView: View {
    @EnvironmentObject var routerView : ServiceRoute
    
    @Binding var userID: String
    
    @State private var isAddNewExam = false

    @State var examName: [String] = []
    @State var examCounter :[String] = []
    @State var sectionExamCounter :[Int] = []
    
    let refreshSubject = PassthroughSubject<UUID, Never>()
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
                Text("Examination")
                    .font(.title)
                    .padding()
                Spacer()
                Button(action:{
                    self.isAddNewExam.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                }
                .sheet(isPresented: $isAddNewExam) {
                    NewExamView(
                        isPresented: $isAddNewExam,
                        examName: $examName,
                        sectionExamCounter: $sectionExamCounter,
                        userID: $userID,
                        refreshSubject: refreshSubject // Pass the refreshSubject
                    )
                }
            }
            ScrollView{
                HStack{
                    VStack(alignment: .leading){
                        ForEach(0..<examName.count, id: \.self) { index in
                            Text("\(examName[index]) | Total Section : \(examCounter[index])")
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
        }
        .onAppear{
            fetchExamNames()
        }
        .onReceive(refreshSubject) { _ in // Receive UUID from refreshSubject
            fetchExamNames()
        }
    }
    func fetchExamNames() {
        apiManager.fetchClassID(userID: self.userID) { result in
            switch result {
            case .success(let (examNames, examSectionCounter)):
                DispatchQueue.main.async {
                    self.examName = examNames
                    self.examCounter = examSectionCounter
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
}
