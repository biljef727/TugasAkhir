//
//  AddTeacherClass.swift
//  TA
//
//  Created by Billy Jefferson on 19/03/24.
//

import SwiftUI

struct AddTeacherClass: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State private var listTeacherName: [String] = []
    @State private var listTeacherID: [String] = []
//    
//    @State private var listSelectedID: [String]
//    @State private var listSelectedName: [String]
    
    @State private var selectedTeacherIndex = 0
    @State private var selectedTeacherIDS: [[String: Any]] = []
    @Binding var isPresented: Bool
    @Binding var teacherName: [String]
    @Binding var teacherID: [String]
    var classID: Int
    
    let apiManager = APIManager()
    
    var filteredTeacherNames: [String] {
            return listTeacherName.filter { !teacherName.contains($0) }
        }
        var filteredTeacherIDs: [String] {
            return listTeacherID.filter { !teacherID.contains($0) }
        }
    
    var body: some View {
        VStack {
            HStack{
                if(filteredTeacherNames.count < 1){
                    Text("Penuh")
                }else{
                    VStack{
                        Picker("Select Teacher:", selection: $selectedTeacherIndex) {
                            ForEach(0..<filteredTeacherNames.count, id: \.self) { index in
                                Text("\(filteredTeacherNames[index])").tag(index)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width/2,height:50)
                        .border(Color.black)
                        .padding()
                        Button(action:{
                            teacherName.append(filteredTeacherNames[selectedTeacherIndex])
                            teacherID.append(filteredTeacherIDs[selectedTeacherIndex])
                            self.isPresented = false
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
                }
            }
        }
        .onAppear {
//            resetData()
            fetchTeacherName()
        }
    }
    
    private func fetchTeacherName() {
        apiManager.getTeacherNames(ClassID: String(classID)) { result in
            switch result {
            case .success(let (teacherNames,teacherIds)):
                DispatchQueue.main.async {
                    self.listTeacherName = teacherNames
                    self.listTeacherID = teacherIds
                }
            case .failure(let error):
                // Handle error, maybe show an alert
                print("Error fetching teacher names: \(error)")
            }
        }
    }
//    func resetData(){
//        self.listSelectedID.append(listTeacherID[selectedTeacherIndex])
//        self.listSelectedName.append(listTeacherName[selectedTeacherIndex])
//    }
}

