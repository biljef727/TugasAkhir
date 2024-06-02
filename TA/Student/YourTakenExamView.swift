//
//  ResultExamView.swift
//  TA
//
//  Created by Billy Jefferson on 01/03/24.
//

import SwiftUI

struct YourTakenExamView: View {
    @EnvironmentObject var routerView : ServiceRoute
    var examID : String?
    var userID : String?
    @State var examName: String = ""
    @State var studentName: String = ""
    @State var nilai1: String = ""
    @State var nilai2: String = ""
    @State var nilai3: String = ""
    @State var nilaiTotal: String = ""
    @State var nilaiTambahan: String = ""
    @State var statusScore: String = ""
    let apiManager = ApiManagerStudent()
    var body: some View {
        VStack{
            LazyHGrid(rows: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
//                GridItem(.flexible())
            ], spacing: 10) {
                Text("ExamName").font(.headline)
                Text("Student Name").font(.headline)
                Text("Nilai Section 1").font(.headline)
                Text("Nilai Section 2").font(.headline)
                Text("Nilai Section 3").font(.headline)
                Text("Nilai Total").font(.headline)
                Text("Catatan Tambahan").font(.headline)
//                Text("Status").font(.headline)
                
                Text("\(examName)")
                Text("\(studentName)")
                Text("\(nilai1)")
                Text("\(nilai2)")
                Text("\(nilai3)")
                Text("\(nilaiTotal)")
                Text("\(nilaiTambahan)")
//                Text("\(statusScore)")
                    .padding()
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width)
//            .border(Color.black)
            .padding()
        }
        .onAppear{
            fetchScore()
        }
    }
    func fetchScore(){
        apiManager.fetchScore(userID: self.userID!,examID: self.examID!) { result in
            switch result {
            case .success(let (studentName,examName,score1,score2,score3,totalScore,nilaiTambahan,statusScore)):
                DispatchQueue.main.async {
                    self.examName = examName
                    self.studentName = studentName
                    self.nilai1 = score1
                    self.nilai2 = score2
                    self.nilai3 = score3
                    self.nilaiTotal = totalScore
                    self.nilaiTambahan = nilaiTambahan
                    self.statusScore = statusScore
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
    }
}

#Preview {
    YourTakenExamView()
}
