//
//  myTabiApp.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct myTabiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        //FirebaseApp.configure()
        Task {
            await AppDependency.shared.expenseVM.fetchAllExpenses()
            await AppDependency.shared.driverVM.fetchAllDrivers()
            await AppDependency.shared.tripVM.fetchAllTrips() //FIXME: zde nebo v AppDependency nebo v onAppear ContentView?
        }
    }
        
    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: .init(summaryVM: AppDependency.shared.summaryVM,
                                            tripVM: AppDependency.shared.tripVM,
                                            expenseVM: AppDependency.shared.expenseVM,
                                            driverVM: AppDependency.shared.driverVM))
        }
    }
}
