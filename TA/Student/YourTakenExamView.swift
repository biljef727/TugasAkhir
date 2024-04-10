//
//  ResultExamView.swift
//  TA
//
//  Created by Billy Jefferson on 01/03/24.
//

import SwiftUI

struct YourTakenExamView: View {
    @EnvironmentObject var routerView : ServiceRoute
    
    var body: some View {
        VStack{
//            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    Text("ExamName").font(.headline)
                    Text("Student Name").font(.headline)
                    Text("Nilai Section 1").font(.headline)
                    Text("Nilai Section 2").font(.headline)
                    Text("Nilai Section 3").font(.headline)
                    Text("Nilai Total").font(.headline)
                    Text("Nilai Catatan Tambahan").font(.headline)
                    Text("Status Score").font(.headline)

                    Text("Coding")
                    Text("Billy Jefferson")
                    Text("70")
                    Text("20")
                    Text("10")
                    Text("100")
                    Text("0")
                    Text("Done")
                        .padding()
 
                }
                .border(Color.black)
                .padding()
//            }
        }
    }
}

#Preview {
    YourTakenExamView()
}
