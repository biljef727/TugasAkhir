//
//  NewStudentView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

import SwiftUI
import Combine

struct NewStudentView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State var nameFieldStudent : String = ""
    @State var emailFieldStudent : String = ""
    @State var idFieldStudent : String = ""
    @State var passwordFieldStudent : String = ""
    @State var checkPasswordStudent : Bool = false
    
    @Binding var isPresented: Bool
    var refreshSubject: PassthroughSubject<Void, Never>
    
    let apiManager = APIManager()
    var body: some View {
        VStack{
            Spacer()
            Text("Add New Student")
                .font(Font.custom("", size: 50))
            Spacer()
            HStack{
                Image(systemName: "pencil.tip")
                TextField("Student Name",text: $nameFieldStudent)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
//            Spacer()
            HStack{
                Image(systemName: "mail.fill")
                TextField("Student Email",text: $emailFieldStudent)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
//            Spacer()
            HStack{
                Image(systemName: "lock.fill")
                if checkPasswordStudent {
                    TextField("Insert your Password",text: $passwordFieldStudent)
                } else {
                    SecureField("Insert your Password",text: $passwordFieldStudent)
                }
                Spacer()
                Image(systemName: checkPasswordStudent ? "eye.slash" : "eye")
                    .foregroundColor(checkPasswordStudent ?  Color.gray : Color.black)
                    .onTapGesture {
                        checkPasswordStudent.toggle()
                    }
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
//            Spacer()
            HStack{
                Image(systemName: "person.fill")
                TextField("No Induk",text: $idFieldStudent)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
            .padding(.bottom)
            Spacer()
            Button(action:{
                apiManager.addStudent(
                    userEmail: emailFieldStudent,
                    userPassword: passwordFieldStudent,
                    userFullname: nameFieldStudent,
                    userNoInduk: idFieldStudent
                ) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isPresented = false
                            self.refreshSubject.send()
                        }
                    case .failure(let error):
                        print("Failed to add Student: \(error.localizedDescription)")
                    }
                }
            }, label:{
                Text("Input")
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width/3,height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
            })
            Spacer()
        }
    }
}
//
//#Preview {
//    NewStudentView()
//}
