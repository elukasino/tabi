//
//  myTabiApp.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct myTabiApp: App {
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
        FirebaseApp.configure()
    }
    
    //let appDependency = AppDependency.shared
    
    var body: some Scene {
        WindowGroup {
            //ContentView(appDependency: appDependency)
            ContentView(appDependency: AppDependency())
        }
    }
}
