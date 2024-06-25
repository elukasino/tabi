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

    let authVM: AuthVM
    let fireStore: Firestore
    
    lazy var csvParser = CSVParser()
    lazy var tripService: TripService = { TripService(csvParser: csvParser, firestore: fireStore) } ()
    lazy var expenseService: ExpenseService = { ExpenseService() } ()
    lazy var driverService: DriverService = { DriverService(firestore: fireStore) } ()
    
    init() {
        self.authVM = AuthVM()
        self.fireStore = Firestore.firestore()
    }
}
