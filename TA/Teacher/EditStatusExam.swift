//
//  EditStatusExam.swift
//  TA
//
//  Created by Billy Jefferson on 01/03/24.
//

import SwiftUI

struct EditStatusExam: View {
    @EnvironmentObject var routerView: ServiceRoute
    @Binding var isPresented: Bool
    @State var scores: [String] = ["0", "0", "0"]

    @State var userID: String
    @State var studentName: String = ""
    @State var studentID:  String = ""
    @State var examCounter : Int = 0
    @State var maxScore : Int = 0
    
    var totalScore: Double {
        return scores.reduce(0) { $0 + (Double($1) ?? 0) }
    }
    
    let apiManager = ApiManagerTeacher()
    var body: some View {
        VStack {
//            ForEach(0..<studentName.count, id: \.self) { index in
                Text("\(studentName) | \(studentID)")
                    .font(.title)
//            }
            // Iterate over sections based on examCounter
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
            
            Button(action: {
                apiManager.editStatusScore(
                    userID: "7",
                    NilaiSection1: scores[0],
                    NilaiSection2: scores[1],
                    NilaiSection3: scores[2],
                    NilaiTotal: String(Int(totalScore))
                )
                { error  in
                    if let error = error {
                        print("Error occurred: \(error)")
                    } else {
                        print("Exam added successfully")
                        DispatchQueue.main.async {
                            self.isPresented = false
                        }
                    }
                }
            }, label: {
                Text("Submit")
                    .padding()
                    .foregroundColor(Color.white)
                    .font(.title)
            })
            .frame(width: UIScreen.main.bounds.width / 5, height: 40)
            .background(Color.accentColor)
            .cornerRadius(15)
        }
        .onAppear {
            getData()
        }
    }
    
    func getData(){
        apiManager.fetchNilaiStudent(userID: self.userID) { result in
            switch result {
            case .success(let (studentName,studentID,examName,examCounter)):
                DispatchQueue.main.async {
                    self.studentName = studentName
                    self.studentID = studentID
                    self.examCounter = Int(examCounter)!
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
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
