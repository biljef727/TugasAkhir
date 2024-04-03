//
//  AddStudentClass.swift
//  TA
//
//  Created by Billy Jefferson on 19/03/24.
//

import SwiftUI

struct AddStudentClass: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State var listStudentName: [String] = []
    @State var listStudentID : [String] = []
    @Binding var isPresented: Bool
    @State var selectedStudentIndex = 0
    
    @Binding var studentName : [String]
    @Binding var studentID : [String]
    let apiManager = APIManager()
    var filteredStudentNames: [String] {
        return listStudentName.filter { !studentName.contains($0) }
    }
    var filteredStudentIDs: [String] {
        return listStudentID.filter { !studentID.contains($0) }
    }
    
    var body: some View {
        VStack{
            HStack{
                if(filteredStudentNames.count < 1){
                    Text("Penuh")
                }else{
                    VStack{
                        Picker("Select Student:", selection: $selectedStudentIndex) {
                            ForEach(0..<filteredStudentNames.count, id: \.self) { index in
                                Text("\(filteredStudentNames[index])").tag(index)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width/2,height:50)
                        .border(Color.black)
                        .padding()
                        Button(action:{
                            studentName.append(filteredStudentNames[selectedStudentIndex])
                            studentID.append(filteredStudentIDs[selectedStudentIndex])
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
            fetchStudentName()
        }
    }
    private func fetchStudentName() {
        apiManager.getStudentNames { result in
            switch result {
            case .success(let (studentNames,studentIds)):
                DispatchQueue.main.async {
                    self.listStudentName = studentNames
                    self.listStudentID = studentIds
                }
            case .failure(let error):
                print("Error fetching class names: \(error)")
            }
        }
        
    }
}

//#Preview {
//    AddStudentClass(isPresented: Binding<Bool>)
//}
