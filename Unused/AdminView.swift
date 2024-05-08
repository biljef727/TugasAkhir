////
////  AdminView.swift
////  TA
////
////  Created by Billy Jefferson on 22/02/24.
////
//
//import SwiftUI
//
//struct AdminView: View {
//    @EnvironmentObject var routerView: ServiceRoute
//    @State var listTeacherName: [String] = ["Teacher 1", "Teacher 2", "Teacher 3", "Teacher 4", "Teacher 5", "Teacher 6", "Teacher 7", "Teacher 8", "Teacher 9", "Teacher 10", "Teacher 11", "Teacher 12"]
//    @State var listTeacherID: [String] = ["ID 1", "ID 2", "ID 3", "ID 4", "ID 5", "ID 6", "ID 7", "ID 8", "ID 9", "ID 10", "ID 11", "ID 12"]
//    @State var listTeacherPassword: [String] = ["Password 1", "Password 2", "Password 3", "Password 4", "Password 5", "Password 6", "Password 7", "Password 8", "Password 9", "Password 10", "Password 11", "Password 12"]
//    @State var listGrade: [String] = ["Class 4-A", "Class 4-B", "Class 4-C"]
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Text("Teacher List")
//                    .font(.title)
//                    .padding()
//                Spacer()
//                Button(action:{
//                    routerView.navigate(to: "newTeacher")
//                }) {
//                    Image(systemName: "plus")
//                        .font(.title)
//                        .padding()
//                }
//            }
//            ScrollView{
//                HStack{
//                    VStack(alignment: .leading){
//                        ForEach(0..<listTeacherName.count) { index in
//                            Text("\(listTeacherName[index]) | \(listTeacherID[index]) | \(listTeacherPassword[index])")
//                                .padding()
//                        }
//                    }
//                    Spacer()
//                }
//            }
//            HStack {
//                Text("Grade List")
//                    .font(.title)
//                    .padding()
//                Spacer()
//            }
//            ScrollView{
//                HStack{
//                    VStack(alignment: .leading){
//                        ForEach(0..<listGrade.count) { index in
//                            Text("\(listGrade[index])")
//                                .padding()
//                        }
//                    }
//                    Spacer()
//                }
//            }
//            HStack {
//                Text("New Student")
//                    .font(.title)
//                    .padding()
//                Spacer()
//                Button(action:{
//                }) {
//                    Image(systemName: "plus")
//                        .font(.title)
//                        .padding()
//                }
//            }
//            
//            Button(action:{
//                routerView.navigate(to: "classAdmission")
//            }) {
//                Text("Class Admission")
//                    .padding(20)
//                    .foregroundColor(Color.white)
//            }
//            .background(Color.accentColor)
//            .cornerRadius(15)
//        }
//        .navigationTitle(":HEHE")
//        .navigationBarBackButtonHidden(true)
//    }
//}
//
//
//#Preview {
//    AdminView().environmentObject(ServiceRoute())
//}
