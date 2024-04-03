//
//  TabBarTeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 23/03/24.
//

import SwiftUI

struct TabBarTeacherView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @State var userName : String = "Tanti"
    
    var body: some View {
        VStack{
            TabView{
                TeacherView().tabItem {
                    Label("New Exam",systemImage: "doc.badge.plus")
                }
                ScheduleView().tabItem {
                    Label("Schedule Exam",systemImage: "doc.badge.clock")
                }
            }
        }
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
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(userName)")
            }
        }
    }
}

//#Preview {
//    TabBarTeacherView()
//}
