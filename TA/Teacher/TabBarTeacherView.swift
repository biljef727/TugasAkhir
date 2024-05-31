//
//  TabBarTeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 23/03/24.
//

import SwiftUI

struct TabBarTeacherView: View {
    @EnvironmentObject var routerView : ServiceRoute
    @Binding var userName : String
    @Binding var userID: String

    var body: some View {
        VStack{
            TabView{
                TeacherView(userID: $userID).tabItem {
                    Label("New Exam",systemImage: "doc.badge.plus")
                }
                ScheduleView(userID: $userID).tabItem {
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
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(userName)")
            }
        }
    }
}
