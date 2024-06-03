//
//  SidebarTeacherView.swift
//  TA
//
//  Created by Billy Jefferson on 23/03/24.
//

import SwiftUI

struct SidebarTeacherView: View {
    @EnvironmentObject var routerView: ServiceRoute
    @Binding var userName: String
    @Binding var userID: String

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: TeacherView(userID: $userID,userName:$userName)) {
                    Label("New Exam", systemImage: "doc.badge.plus")
                }
                NavigationLink(destination: ScheduleView(userID: $userID,userName:$userName)) {
                    Label("Schedule Exam", systemImage: "doc.badge.clock")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        routerView.path.removeAll()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        } detail: {
            VStack {
                Text("Select an option from the sidebar")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
