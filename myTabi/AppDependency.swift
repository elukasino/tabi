//
//  AppDependency.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import Firebase
import FirebaseFirestore

final class AppDependency {
    static let shared = AppDependency()

    //let authVM: AuthVM
    let fireStoreDb: Firestore
    
    lazy var csvParser = CSVParser()
    lazy var tripService: TripService = { TripService(csvParser: csvParser, fireStoreDb: fireStoreDb) } ()
    lazy var expenseService: ExpenseService = { ExpenseService(fireStoreDb: fireStoreDb) } ()
    lazy var driverService: DriverService = { DriverService(fireStoreDb: fireStoreDb) } ()
    
    init() {
        //self.authVM = AuthVM()
        self.fireStoreDb = Firestore.firestore()
    }
}
