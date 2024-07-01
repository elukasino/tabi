//
//  TripService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import MapKit

class TripService {
    struct Dependencies {
        let csvParser: CSVParser
        let db: Firestore
    }
    private let csvParser: CSVParser
    private let db: Firestore
    
    private let path = "trips"

    init(dependencies: Dependencies) {
        csvParser = dependencies.csvParser
        db = dependencies.db
    }

    func loadTrips(fileUrl: URL) throws -> [Trip] {
        return try csvParser.parseTrips(fileUrl: fileUrl)
    }
    
    //Firestore methods==============================================================
    
    func fetchAllTrips(test: Bool = false) async throws -> [Trip] {
        let snapshot = try await db.collection(test ? path+"Test" : path).order(by: "startDateTime").getDocuments()
        return snapshot.documents.compactMap { document in
            let startAddress: String = document["startAddress"] as? String ?? ""
            let endAddress: String = document["endAddress"] as? String ?? ""
            let startCoordinates: GeoPoint = document["startCoordinates"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0) //TODO: coalescing to 0, 0 position
            let endCoordinates: GeoPoint = document["endCoordinates"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
            
            let startTimestamp = document["startDateTime"] as? Timestamp
            let endTimestamp = document["endDateTime"] as? Timestamp
            
            let driverIdString: String = document["driverId"] as? String ?? ""
            let driverId: String? = driverIdString.isEmpty ? nil : driverIdString
            
            return Trip(id: document.documentID,
                        startDateTime: startTimestamp?.dateValue() ?? Date(), //TODO: coalescing to current date
                        endDateTime: endTimestamp?.dateValue() ?? Date(),
                        originalTimeZone: TimeZone(abbreviation: document["originalTimeZone"] as? String ?? "") ?? TimeZone.current,
                        startLocation: Location(address: startAddress, coordinate: CLLocationCoordinate2D(latitude: startCoordinates.latitude, longitude: startCoordinates.longitude)),
                        endLocation: Location(address: endAddress, coordinate: CLLocationCoordinate2D(latitude: endCoordinates.latitude, longitude: endCoordinates.longitude)),
                        distance: document["distance"] as? Double ?? 0.0,
                        driverId: driverId)
        }
    }
    
    func createTrip(startDateTime: Date, endDateTime: Date, originalTimeZone: TimeZone, startAddress: String, endAddress: String,
                    distance: Double, driverId: String?, test: Bool = false) async throws {
        let startCoordinates: CLLocationCoordinate2D = try await convertAddressToCoordinates(address: startAddress) ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let endCoordinates: CLLocationCoordinate2D = try await convertAddressToCoordinates(address: endAddress) ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        let originalTimeZoneAbbr = originalTimeZone.abbreviation()
        
        try await db.collection(test ? path+"Test" : path).addDocument(data: ["startDateTime" : startDateTime,
                                                            "endDateTime" : endDateTime,
                                                            "originalTimeZone": originalTimeZoneAbbr ?? "",
                                                            "startAddress" : startAddress,
                                                            "endAddress" : endAddress,
                                                            "startCoordinates" : GeoPoint(latitude: startCoordinates.latitude, longitude: startCoordinates.longitude),
                                                            "endCoordinates" : GeoPoint(latitude: endCoordinates.latitude, longitude: endCoordinates.longitude),
                                                            "distance" : distance,
                                                            "driverId" : driverId ?? ""])
    }
    
    func updateTripDriver(tripToUpdate: Trip, test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).document(tripToUpdate.id).setData(["driverId" : tripToUpdate.driverId ?? ""], merge: true)
    }
    
    func deleteTrip(tripId: String, test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).document(tripId).delete()
    }
    
    func deleteAllTrips(trips: [Trip], test: Bool = false) async throws {
        for trip in trips { //TODO: add batch deleting
            try await db.collection(test ? path+"Test" : path).document(trip.id).delete()
        }
    }
    
    func deleteDriverIdFromTrips(driverId: String, trips: [Trip], test: Bool = false) async throws {
        for trip in trips {
            if trip.driverId == driverId {
                try await db.collection(test ? path+"Test" : path).document(trip.id).setData(["driverId" : ""], merge: true)
            }
        }
    }

    func convertAddressToCoordinates(address: String, test: Bool = false) async throws -> CLLocationCoordinate2D? { //ASYNC AWAIT
        let geocoder = CLGeocoder()
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let location = placemarks?.first?.location else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: location.coordinate)
            }
        }
    }

}
