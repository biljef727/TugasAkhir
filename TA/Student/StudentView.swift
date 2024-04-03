//
//  StudentView.swift
//  TA
//
//  Created by Billy Jefferson on 22/03/24.
//

import SwiftUI

struct StudentView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State var examName : String = "Coding"
    @State var codingTaken : [String] = ["Coding1","Coding2"]
    @State var codingTimeTaken : [String] = ["14 Maret 2024","17 Agustus 1945"]
    var body: some View {
        VStack{
            VStack(alignment:.leading){
                Text("Last Seen Exam")
                HStack{
                    Text("Exam Name :")
                    Text("coding")
                }
                .padding(.vertical)
                HStack{
                    Text("Score Result :")
                    Text("90")
                    Spacer()
                    Button(action:{
                        
                    }, label:{
                        Text("See Result")
                            .foregroundColor(Color.white)
                    })
                    .frame(width: UIScreen.main.bounds.width/4,height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                }
            }
            Divider()
            VStack(alignment:.leading){
                Text("New Exam")
                HStack{
                    Text("Start Time :")
                    Text("15 Maret 2020 14.00")
                }
                .padding(.vertical)
                HStack{
                    Text("End Time:")
                    Text("15 Maret 2020 15.00")
                }
                .padding(.vertical)
                HStack{
                    Text("Exam Name :")
                    Text("coding")
                    Spacer()
                    Button(action:{
                        
                    }, label:{
                        Text("Start")
                            .foregroundColor(Color.white)
                    })
                    .frame(width: UIScreen.main.bounds.width/4,height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                }
            }
            Divider()
            VStack(alignment:.leading){
                Text("Your Taken Exam")
                VStack{
                    ForEach(0..<codingTaken.count, id: \.self) { index in
                        HStack{
                            Text("- \(codingTaken[index]) | \(codingTimeTaken[index])").tag(index)
                            Spacer()
                            Button(action:{
                                
                            }, label:{
                                Text("See")
                                    .foregroundColor(Color.white)
                            })
                            .frame(width: UIScreen.main.bounds.width/10,height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(15)
                        }
                        .padding(.vertical)
                    }
                }
            }
            Divider()
        }
        .frame(maxWidth: UIScreen.main.bounds.width/2, maxHeight: UIScreen.main.bounds.height)
        //        .background(Color.red)
        .font(.title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action:{
                    routerView.path.removeAll()
                }) {
                    Image(systemName: "square.and.arrow.up.circle")
                    Text("Log Out")
                }
            }
        }
    }
}

#Preview {
    StudentView()
}
