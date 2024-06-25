//
//  TripService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TripService {
    private let csvParser: CSVParser

    init(csvParser: CSVParser, firestore: Firestore) {
        self.csvParser = csvParser
        self.db = firestore
    }

    func loadTrips(fileUrl: URL) throws -> [Trip] {
        return try csvParser.parseTrips(fileUrl: fileUrl)
    }
    
    //FIRESTORE==============================================================
    
    private let db: Firestore
    
    func fetchTrips() async throws -> [Trip] {
        let snapshot = try await db.collection("trips").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Trip.self)
        }
    }
    
    func saveTrip(_ trip: Trip) async throws {
        let _ = try await db.collection("trips").document(trip.id).setData(from: trip)
    }
}
