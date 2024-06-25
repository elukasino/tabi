//
//  DriverService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import FirebaseFirestore

class DriverService {
    private let db: Firestore
    //TODO: implement timeout
    
    init(fireStoreDb: Firestore) {
        self.db = fireStoreDb
    }
    
    func fetchAllDrivers() async throws -> [Driver] {
        let snapshot = try await db.collection("drivers").getDocuments()
        return snapshot.documents.compactMap { document in
            Driver(id: document.documentID,
                   firstName: document["firstName"] as? String ?? "",
                   lastName: document["lastName"] as? String ?? "",
                   usualLocations: document["usualLocations"] as? [String] ?? [])
        }
    }
    
    func createDriver(firstName: String, lastName: String, usualLocations : [String] = []) async throws {
        try await db.collection("drivers").addDocument(data: ["firstName" : firstName, "lastName" : lastName])
    }
    
    func updateDriver(driverToUpdate: Driver) async throws {
        try await db.collection("drivers").document(driverToUpdate.id).setData(["firstName" : driverToUpdate.firstName,
                                                                                "lastName" : driverToUpdate.lastName,
                                                                                "usualLocations" : driverToUpdate.usualLocations])
    }
    
    func deleteDriver(driverId: String) async throws {
        try await db.collection("drivers").document(driverId).delete()
    }
    
    func deleteAllDrivers(drivers: [Driver]) async throws {
        for driver in drivers { //TODO: add batch deleting
            try await db.collection("drivers").document(driver.id).delete()
        }
    }
}
