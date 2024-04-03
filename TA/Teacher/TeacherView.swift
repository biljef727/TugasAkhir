//
//  TeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

import SwiftUI

struct TeacherView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State private var isAddNewExam = false
    
    @State var selectedGradeIndex = 0
    @State var selectedGradeIndex2 = 0
    
    @State var examName: [String] = []
    @State var sectionExamCounter :[Int] = []
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
                    NewExamView(isPresented: $isAddNewExam,examName: $examName,sectionExamCounter: $sectionExamCounter)
                }
            }
            ScrollView{
                HStack{
                    VStack(alignment: .leading){
                        ForEach(0..<examName.count, id: \.self) { index in
                            Text("\(examName[index]) | Total Section : \(sectionExamCounter[index])")
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
//
//#Preview {
//    TeacherView()
//}
