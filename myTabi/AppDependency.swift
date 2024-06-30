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
    static let shared = AppDependency() //TODO: rozdíl mezi shared a globální proměnnou

    let authVM: AuthVM
    let fireStoreDb: Firestore
    lazy var csvParser: CSVParser = CSVParser()
    
    lazy var summaryVM: SummaryVM = SummaryVM(dependencies: .init(tripVM: tripVM, expenseVM: expenseVM, driverVM: driverVM))
    lazy var tripVM: TripVM = TripVM(dependencies: .init(tripService: tripService))
    lazy var expenseVM: ExpenseVM = ExpenseVM(dependencies: .init(expenseService: expenseService))
    lazy var driverVM: DriverVM = DriverVM(dependencies: .init(tripVM: tripVM, tripService: tripService, driverService: driverService))
    
    lazy var tripService: TripService = TripService(dependencies: .init(csvParser: csvParser, db: fireStoreDb))
    lazy var expenseService: ExpenseService = ExpenseService(dependencies: .init(db: fireStoreDb))
    lazy var driverService: DriverService = DriverService(dependencies: .init(db: fireStoreDb))
    
    init() {
        self.authVM = AuthVM()
        self.fireStoreDb = Firestore.firestore()
    }
}
