//
//  myTabiApp.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import SwiftUI
import FirebaseCore

@main
struct myTabiApp: App {
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/*
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
 struct YourApp: App {
   // register app delegate for Firebase setup
   @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

   var body: some Scene {
     WindowGroup {
       NavigationView {
         ContentView()
       }
     }
   }
 }
 */
