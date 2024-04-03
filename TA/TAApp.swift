//
//  TAApp.swift
//  TA
//
//  Created by Billy Jefferson on 22/02/24.
//

import SwiftUI
import SwiftData

// TAApp.swift
@main
struct TAApp: App {
    @StateObject var routerView = ServiceRoute()

    var body: some Scene {
        WindowGroup {
            LoginView(routerView: routerView)
                .environmentObject(routerView)
        }
    }
}

