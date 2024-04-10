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
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            LoginView(routerView: routerView)
                .environmentObject(routerView)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

