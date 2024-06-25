//
//  DriverService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class DriverService {
    private let db: Firestore
    
    init(firestore: Firestore) {
        self.db = firestore
    }
    
    func fetchDrivers() async throws -> [Driver] {
        let snapshot = try await db.collection("drivers").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Driver.self)
        }
    }
    
    func saveDriver(_ driver: Driver) async throws {
        let _ = try await db.collection("drivers").document(driver.id).setData(from: driver)
    }
}
