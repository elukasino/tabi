//
//  TripService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import FirebaseFirestore

class TripService {
    private let csvParser: CSVParser
    private let db: Firestore

    init(csvParser: CSVParser, fireStoreDb: Firestore) {
        self.csvParser = csvParser
        self.db = fireStoreDb
    }

    func loadTrips(fileUrl: URL) throws -> [Trip] {
        return try csvParser.parseTrips(fileUrl: fileUrl)
    }
    
    //Firestore methods==============================================================
    
    func fetchAllTrips() async throws -> [Trip] {
        let snapshot = try await db.collection("trips").getDocuments()
        return snapshot.documents.compactMap { document in
            Trip(id: document.documentID,
                 startDateTime: document["startDateTime"] as? String ?? "",
                 endDateTime: document["endDateTime"] as? String ?? "",
                 startLocation: document["startLocation"] as? String ?? "",
                 endLocation: document["endLocation"] as? String ?? "",
                 distance: document["distance"] as? Double ?? 0.0,
                 driverId: document["driverId"] as? String ?? nil)
        }
    }
    
    func createTrip(startDateTime: String, endDateTime: String, startLocation: String, endLocation: String,
                    distance: Double, driverId: String?) async throws {
        try await db.collection("trips").addDocument(data: ["startDateTime" : startDateTime,
                                                            "endDateTime" : endDateTime,
                                                            "startLocation" : startLocation,
                                                            "endLocation" : endLocation,
                                                            "distance" : distance,
                                                            "driverId" : driverId ?? ""])
    }
    
    func updateTrip(tripToUpdate: Trip) async throws {
        try await db.collection("trips").document(tripToUpdate.id).setData(["startDateTime" : tripToUpdate.startDateTime,
                                                                            "endDateTime" : tripToUpdate.endDateTime,
                                                                            "startLocation" : tripToUpdate.startLocation,
                                                                            "endLocation" : tripToUpdate.endLocation,
                                                                            "distance" : tripToUpdate.distance,
                                                                            "driverId" : tripToUpdate.driverId ?? ""])
    }
    
    func deleteTrip(tripId: String) async throws {
        try await db.collection("trips").document(tripId).delete()
    }
    
    func deleteAllTrips(trips: [Trip]) async throws {
        for trip in trips { //TODO: add batch deleting
            try await db.collection("trips").document(trip.id).delete()
        }
    }
}
