//
//  NewTeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 27/02/24.
//

import SwiftUI

struct NewTeacherView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @State var nameFieldTeacher : String = ""
    @State var emailFieldTeacher : String = ""
    @State var idFieldTeacher : String = ""
    @State var passwordFieldTeacher : String = ""
    @State var checkPasswordTeacher : Bool = false
    
    let apiManager = APIManager()
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "pencil.tip")
                TextField("Teacher Name",text: $nameFieldTeacher)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
            HStack{
                Image(systemName: "mail.fill")
                TextField("Teacher Email",text: $emailFieldTeacher)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
            HStack{
                Image(systemName: "lock.fill")
                if checkPasswordTeacher {
                    TextField("Insert your Password",text: $passwordFieldTeacher)
                } else {
                    SecureField("Insert your Password",text: $passwordFieldTeacher)
                }
                Spacer()
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
            HStack{
                Image(systemName: "person.fill")
                TextField("No Induk",text: $idFieldTeacher)
            }
            .frame(width: UIScreen.main.bounds.width/7*3)
            .padding()
            .background(Color.black.opacity(0.3).cornerRadius(10))
            .font(.headline)
            .padding(.bottom)
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
                            routerView.path.removeLast()
                        }
                    case .failure(let error):
                        print("Failed to add teacher: \(error.localizedDescription)")
                    }
                }
            }, label:{
                Text("Input")
                    .padding(.vertical,5)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
            })
            .frame(width: UIScreen.main.bounds.width/3)
            .background(Color.accentColor)
            .cornerRadius(15)
        }
    }
}

#Preview {
    NewTeacherView()
}
