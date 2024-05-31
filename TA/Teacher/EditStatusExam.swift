//
//  EditStatusExam.swift
//  TA
//
//  Created by Billy Jefferson on 01/03/24.
//

import SwiftUI
import Combine

struct EditStatusExam: View {
    @EnvironmentObject var routerView: ServiceRoute
    @Binding var isPresented: Bool
    @State var scores: [String] = ["0", "0", "0"]
    
    @State var studentName: String = ""
    @State var studentID:  String = ""
    @State var examCounter : Int = 0
    @State var maxScore : Int = 0
    @State var comment : String = ""
    @Binding var userID: String?
    var examIDs: String?
    var refreshSubject: PassthroughSubject<UUID, Never>
    
    var totalScore: Double {
        return scores.compactMap { Double($0) }.reduce(0, +)
    }
    
    let apiManager = ApiManagerTeacher()
    
    var body: some View {
        VStack {
            Text("\(studentName) | \(studentID)")
                .font(.title)
            
            ForEach(0..<examCounter, id: \.self) { index in
                SectionsView(index: index + 1, score: $scores[index])
            }
            HStack {
                Text("Total Score: \(totalScore, specifier: "%.0f")")
                Image(systemName: "percent")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .border(Color.black)
            
            TextField("Type your comment", text: $comment)
                .padding()
                .border(Color.black)
                .padding(.top)
            
            Button(action: {
                apiManager.editStatusScore(
                    userID: userID!,
                    examID: examIDs!,
                    NilaiSection1: Int(scores[0]) ?? 0,
                    NilaiSection2: Int(scores[1]) ?? 0,
                    NilaiSection3: Int(scores[2]) ?? 0,
                    NilaiTotal: Int(totalScore),
                    feedback: comment
                ) { error in
                    if let error = error {
                        print("Error occurred: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            refreshSubject.send(UUID())
                        }
                    }
                    self.isPresented = false
                }
            }) {
                Text("Submit")
                    .padding()
                    .foregroundColor(Color.white)
                    .font(.title)
            }
            .frame(width: UIScreen.main.bounds.width / 5, height: 40)
            .background(Color.accentColor)
            .cornerRadius(15)
        }
        .onAppear {
            getData()
            examCounters()
        }
    }
    func getData() {
        apiManager.fetchNilaiStudent(userID: self.userID!) { result in
            switch result {
            case .success(let (studentName,studentID,_,_)):
                DispatchQueue.main.async {
                    self.studentName = studentName
                    self.studentID = studentID
                }
            case .failure(let error):
                print("Error fetching student data: \(error)")
            }
        }
    }
    func examCounters(){
        apiManager.fetchExamCounter(examID: self.examIDs!){ result in
            switch result {
            case .success(let examCounter):
                DispatchQueue.main.async {
                    self.examCounter = Int(examCounter) ?? 0
                }
            case .failure(let error):
                print("Error fetching student data: \(error)")
            }
        }
    }
}

struct SectionsView: View {
    let index: Int
    @Binding var score: String
    
    var body: some View {
        HStack {
            Text("Section \(index)")
                .font(.title2)
            HStack {
                TextField("Score \(index)", text: $score)
                Image(systemName: "percent")
            }
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width / 10)
            .border(Color.black)
        }
        .padding(.top)
    }
}

//
//#Preview {
//    EditStatusExam()
//}
