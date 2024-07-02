//
//  DriverService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import FirebaseFirestore

class DriverService {
    struct Dependencies {
        let db: Firestore
    }
    private let db: Firestore //TODO: implement timeout
    
    private let path = "drivers"
    
    init(dependencies: Dependencies) {
        db = dependencies.db
    }
    
    func fetchAllDrivers(test: Bool = false) async throws -> [Driver] {
        let snapshot = try await db.collection(test ? path+"Test" : path).order(by: "timestamp").getDocuments()
        return snapshot.documents.compactMap { document in
            Driver(id: document.documentID,
                   firstName: document["firstName"] as? String ?? "",
                   lastName: document["lastName"] as? String ?? "",
                   usualLocations: document["usualLocations"] as? [String] ?? [])
        }
    }
    
    func createDriver(firstName: String, lastName: String, usualLocations : [String] = [], test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).addDocument(data: ["firstName" : firstName, "lastName" : lastName, "timestamp" : Date(), "usualLocations" : usualLocations])
    }
    
    func updateDriver(driverToUpdate: Driver, test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).document(driverToUpdate.id).setData(["firstName" : driverToUpdate.firstName,
                                                                                                "lastName" : driverToUpdate.lastName,
                                                                                                "usualLocations" : driverToUpdate.usualLocations], merge: true)
    }
    
    func deleteDriver(driverId: String, test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).document(driverId).delete()
    }
    
    func deleteAllDrivers(drivers: [Driver], test: Bool = false) async throws {
        for driver in drivers { //TODO: add batch deleting
            try await db.collection(test ? path+"Test" : path).document(driver.id).delete()
        }
    }
}
