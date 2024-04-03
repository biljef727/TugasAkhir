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
    @State var scoreIndex1: String = "0"
    @State var scoreIndex2: String = "0"
    @State var scoreIndex3: String = "0"
    
    var totalScore: Double {
        let score1 = Double(scoreIndex1) ?? 0
        let score2 = Double(scoreIndex2) ?? 0
        let score3 = Double(scoreIndex3) ?? 0
        return score1 + score2 + score3
    }
    
    var body: some View {
        VStack {
            Text("Nama | ID")
                .font(.title)
            // Iterate over sections
            HStack {
                Text("Section 1")
                    .font(.title2)
                HStack {
                    TextField("Score 1", text: $scoreIndex1)
                    Image(systemName: "percent")
                }
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width / 10)
                .border(Color.black)
            }
            .padding(.top)
            
            HStack {
                Text("Total Score: \(totalScore, specifier: "%.0f")")
                Image(systemName: "percent")
            }
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width / 4)
            .border(Color.black)
            .padding()
            
            Button(action: {
                self.isPresented = false
            }, label: {
                Text("Submit")
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .font(.title)
            })
            .frame(width: UIScreen.main.bounds.width / 5, height: 40)
            .background(Color.accentColor)
            .cornerRadius(15)
        }
    }
}

//
//#Preview {
//    EditStatusExam()
//}
