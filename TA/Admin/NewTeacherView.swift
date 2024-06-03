//
//  NewTeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

import SwiftUI
import Combine

struct NewTeacherView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State var nameFieldTeacher : String = ""
    @State var emailFieldTeacher : String = ""
    @State var idFieldTeacher : String = ""
    @State var passwordFieldTeacher : String = ""
    @State var checkPasswordTeacher : Bool = false
    
    @Binding var isPresented: Bool
    var refreshSubject: PassthroughSubject<Void, Never>
    
    let apiManager = APIManager()
    var body: some View {
        VStack{
            Spacer()
            Text("Add New Teacher")
                .font(Font.custom("", size: 50))
            Spacer()
            HStack{
                Image(systemName: "pencil.tip")
                TextField("Teacher Name",text: $nameFieldTeacher)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
//            Spacer()
            HStack{
                Image(systemName: "mail.fill")
                TextField("Teacher Email",text: $emailFieldTeacher)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
//            Spacer()
            HStack{
                Image(systemName: "lock.fill")
                if checkPasswordTeacher {
                    TextField("Insert your Password",text: $passwordFieldTeacher)
                } else {
                    SecureField("Insert your Password",text: $passwordFieldTeacher)
                }
//                Spacer()
                Image(systemName: checkPasswordTeacher ? "eye.slash" : "eye")
                    .foregroundColor(checkPasswordTeacher ?  Color.gray : Color.black)
                    .onTapGesture {
                        checkPasswordTeacher.toggle()
                    }
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
//            Spacer()
            HStack{
                Image(systemName: "person.fill")
                TextField("No Induk",text: $idFieldTeacher)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
            .padding(.bottom)
            Spacer()
            Button(action:{
                apiManager.addTeacher(
                    userEmail: emailFieldTeacher,
                    userPassword: passwordFieldTeacher,
                    userFullname: nameFieldTeacher,
                    userNoInduk: idFieldTeacher
                ) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isPresented = false
                            self.refreshSubject.send()
                        }
                    case .failure(let error):
                        print("Failed to add teacher: \(error.localizedDescription)")
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
//    NewTeacherView()
//}
