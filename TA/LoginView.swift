//
//  LoginView.swift
//  TA
//
//  Created by Billy Jefferson on 22/02/24.
//

import SwiftUI

struct Item:Codable {
    let userRole:String
    
    enum CodingKeys:String,CodingKey{
        case userRole = "UserRole"
    }
}
struct LoginView: View {
    @ObservedObject var routerView: ServiceRoute
    @State var textFieldText: String = ""
    @State var passwordFieldText: String = ""
    @State var checkPassword: Bool = false
    @State var loginError: String = ""
    @State var userPassRole: String = ""
    @State var userFullName: String = ""
    @State var userID: String = ""
    
    var body: some View {
        NavigationStack(path: $routerView.path) {
            VStack {
                Image("Logo IPH Hitam")
                    .padding()
                
                HStack {
                    Image(systemName: "person.fill")
                    TextField("Insert your Email", text: $textFieldText)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .frame(width: UIScreen.main.bounds.width / 7 * 3)
                .padding()
                .background(Color.white)
                .border(Color.black)
//                .cornerRadius(10)
                .font(.headline)
                
                HStack {
                    Image(systemName: "lock.fill")
                    if checkPassword {
                        TextField("Insert your Password", text: $passwordFieldText)
                    } else {
                        SecureField("Insert your Password", text: $passwordFieldText)
                    }
                    Spacer()
                    Image(systemName: checkPassword ? "eye.slash" : "eye")
                        .foregroundColor(checkPassword ? Color.gray : Color.black)
                        .onTapGesture {
                            checkPassword.toggle()
                        }
                }
                .frame(width: UIScreen.main.bounds.width / 7 * 3)
                .padding()
                .background(Color.white)
                .border(Color.black)
//                .cornerRadius(10)
                .font(.headline)
                .padding(.bottom)
                
                Text(loginError)
                    .foregroundColor(.red)
                    .padding(.bottom)
                
                Button(action: {
                    loginError = ""
                    loginUser()
                }, label: {
                    Text("Login")
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .foregroundColor(Color.white)
                        .frame(width: UIScreen.main.bounds.width / 2,height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(15)
                })
            }
            .navigationDestination(for: String.self) { val in
                if val == "admin"{
                    FixAdminView().environmentObject(routerView)
                }else if val == "classAdmission"{
                    ClassAdmissionView(classID: routerView.classID!).environmentObject(routerView)
                }else if val == "teacher"{
                    SidebarTeacherView(userName: $userFullName, userID: $userID).environmentObject(routerView)
                } else if val.hasPrefix("resultExam/") {
                    let components = val.components(separatedBy: "/")
                    if components.count > 1 {
                        let examInfo = components[1]
                        let examInfoComponents = examInfo.components(separatedBy: "-")
                        if examInfoComponents.count == 4 {
                            let examName = examInfoComponents[0]
                            let examIDs = examInfoComponents[1]
                            let examDate = examInfoComponents[2]
                            let gradeIDS = examInfoComponents[3]
                            ResultExamView(examNames: examName, examIDs: examIDs, examDates: examDate,gradeIDs : gradeIDS).environmentObject(routerView)
                        } else {
                            ResultExamView().environmentObject(routerView)
                        }
                    } else {
                        ResultExamView().environmentObject(routerView)
                    }
                }else if val == "student"{
                    StudentView(userID:$userID, userName: $userFullName).environmentObject(routerView)
                }
                //                else if val.hasPrefix("startExam/"){
                //                    let components = val.components(separatedBy: "/")
                //                    if components.count > 1 {
                //                        let examInfo = components[1]
                //                        let examInfoComponents = examInfo.components(separatedBy: "-")
                //                        if examInfoComponents.count == 2 {
                //                            let examIDs = examInfoComponents[0]
                //                            let counterExam = examInfoComponents[1]
                //                            CanvasSaving(examID: examIDs, userID:userID,counter: Int(counterExam)).environmentObject(routerView)
                //                        }
                //                    } else {
                //                        CanvasSaving().environmentObject(routerView)
                //                    }
                //                }
                else if val.hasPrefix("yourTakenExam/"){
                    let components = val.components(separatedBy: "/")
                    if components.count > 1 {
                        let examInfo = components[1]
                        let examInfoComponents = examInfo.components(separatedBy: "-")
                        if examInfoComponents.count == 1 {
                            let examIDs = examInfoComponents[0]
                            YourTakenExamView(examID: examIDs, userID:userID).environmentObject(routerView)
                        }
                    } else {
                        YourTakenExamView().environmentObject(routerView)
                    }
                }
                else if val.hasPrefix("startExam/"){
                    let components = val.components(separatedBy: "/")
                    if components.count > 1 {
                        let examInfo = components[1]
                        let examInfoComponents = examInfo.components(separatedBy: "-")
                        if examInfoComponents.count == 1 {
                            let examIDs = examInfoComponents[0]
                            StudentExamViewWrapper(studentExamView: StudentExamView(examID: examIDs, userID: userID)).environmentObject(routerView)
                        }
                    } else {
                        StudentExamViewWrapper(studentExamView: StudentExamView()).environmentObject(routerView)
                    }
                }
            }
        }
        
    }
    
    func loginUser() {
        let parameters = [
            "UserEmail": textFieldText,
            "UserPassword": passwordFieldText
        ]
        
        guard let url = URL(string: "https://indramaryati.xyz/iph_exam/public/api/login") else {
            print("Invalid URL")
            return
        }
        guard let JsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to serialize")
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = JsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request){
            (data,response,error) in
            if let error = error {
                print("error")
                return
            }
            guard let data = data else{
                print("No data")
                return
            }
            do{
                let items = try JSONDecoder().decode(Item.self, from : data)
                print(items)
            }
            catch _ {
                print("Error Decoding Json")
            }
        }.resume()
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonDict = jsonResponse as? [String: Any], let userRole = jsonDict["UserRole"] as? String, let userFullname = jsonDict["UserFullname"] as? String , let userID = jsonDict["UserID"] as? String {
                        switch userRole {
                        case "Admin":
                            DispatchQueue.main.async {
                                routerView.navigate(to:"admin")
                            }
                        case "Teacher":
                            DispatchQueue.main.async {
                                self.userFullName = userFullname
                                self.userID = userID
                                self.routerView.navigate(to: "teacher")
                            }
                        case "Student":
                            DispatchQueue.main.async {
                                self.userFullName = userFullname
                                self.userID = userID
                                self.routerView.navigate(to: "student")
                            }
                        default:
                            print("Unhandled role: \(userRole)")
                        }
                    } else {
                        print("UserRole not found in response")
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            } else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    loginError = errorMessage
                } else {
                    loginError = "Unknown error occurred."
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView(routerView: ServiceRoute()).environmentObject(ServiceRoute())
}
