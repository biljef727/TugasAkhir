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
    @State private var selectedTeacherIndex = 0
    @State private var selectedTeacherIDS: [[String: Any]] = []
    @Binding var isPresented: Bool
    @Binding var teacherName: [String]
    @Binding var teacherID: [String]
    var classID: Int
    
    let apiManager = APIManager()
    
    var filteredTeacherNames: [String] {
        return listTeacherName.filter { teacherName in
            // Check if the teacher's user ID is not associated with the given class ID
            let teacherID = listTeacherID[listTeacherName.firstIndex(of: teacherName)!]
            return !selectedTeacherIDS.contains(where: { $0["UserID"] as? String == teacherID && $0["ClassID"] as? Int == classID })
        }
    }
    
    var filteredTeacherIDs: [String] {
        return listTeacherID.filter { teacherID in
            // Check if the teacher's user ID is not associated with the given class ID
            !selectedTeacherIDS.contains(where: { $0["UserID"] as? String == teacherID && $0["ClassID"] as? Int == classID })
        }
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
}

