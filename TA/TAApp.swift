//
//  TAApp.swift
//  TA
//
//  Created by Billy Jefferson on 22/02/24.
//

import SwiftUI
import UIKit
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

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Disable edge swiping gestures
        if let window = self.window,
           let rootViewController = window.rootViewController {
            let gestureRecognizer = UISwipeGestureRecognizer(target: nil, action: nil)
            rootViewController.view.addGestureRecognizer(gestureRecognizer)
        }
        
        return true
    }
}
