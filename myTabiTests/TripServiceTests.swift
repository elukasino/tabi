//
//  TripServiceTests.swift
//  myTabiTests
//
//  Created by Lukáš Cmíral on 01.07.2024.
//

import XCTest
import FirebaseFirestore
import CoreLocation
@testable import myTabi

class TripServiceTests: XCTestCase {

    var tripService: TripService!
    var firestore: Firestore!
    var csvParser: CSVParser!

    override func setUpWithError() throws {
        firestore = AppDependency.shared.fireStoreDb
        csvParser = CSVParser()
        tripService = TripService(dependencies: .init(csvParser: csvParser, db: firestore))
    }

    override func tearDownWithError() throws {
        tripService = nil
        firestore = nil
        csvParser = nil
    }

    func testFetchAllTrips() async throws {
        // Given
        let startCoordinates = GeoPoint(latitude: 1, longitude: 1)
        let endCoordinates = GeoPoint(latitude: 2, longitude: 2)
        let commonDateTime = Date()
        let docRef = try await firestore.collection("tripsTest").addDocument(data: ["startAddress": "Praha", "endAddress": "Brno", "startCoordinates": startCoordinates, "endCoordinates": endCoordinates, "startDateTime": commonDateTime, "endDateTime": commonDateTime, "distance": 100.0, "originalTimeZone": "GMT+2"])
        
        // When
        let trips = try await tripService.fetchAllTrips(test: true)
        
        // Then
        XCTAssertEqual(trips.count, 1)
        XCTAssertEqual(trips.first?.startLocation.address, "Praha")
        XCTAssertEqual(trips.first?.startLocation.coordinate?.latitude, CLLocationCoordinate2D(latitude: 1, longitude: 1).latitude)
        XCTAssertEqual(trips.first?.startLocation.coordinate?.longitude, CLLocationCoordinate2D(latitude: 1, longitude: 1).longitude)
        XCTAssertEqual(trips.first?.endLocation.address, "Brno")
        XCTAssertEqual(trips.first?.endLocation.coordinate?.latitude, CLLocationCoordinate2D(latitude: 2, longitude: 2).latitude)
        XCTAssertEqual(trips.first?.endLocation.coordinate?.longitude, CLLocationCoordinate2D(latitude: 2, longitude: 2).longitude)
        XCTAssertEqual(trips.first?.originalTimeZone, TimeZone(abbreviation: "GMT+2"))
        XCTAssertEqual(trips.first?.distance, 100.0)
        XCTAssertEqual(trips.first?.startDateTime.timeIntervalSince1970, trips.first?.endDateTime.timeIntervalSince1970)
        
        // Clean
        try await firestore.collection("tripsTest").document(docRef.documentID).delete()
        let deletedTrip = try await firestore.collection("tripsTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedTrip.exists)
    }

    func testCreateTrip() async throws {
        // Given
        let startDateTime = Date()
        let endDateTime = startDateTime
        let originalTimeZone = TimeZone(abbreviation: "GMT+2")!
        let startAddress = "Praha"
        let endAddress = "Brno"
        let distance = 100.0
        let driverId = "driver123"
        
        // When
        try await tripService.createTrip(startDateTime: startDateTime, endDateTime: endDateTime, originalTimeZone: originalTimeZone, startAddress: startAddress, endAddress: endAddress, distance: distance, driverId: driverId, test: true)
        
        // Then
        let snapshot = try await firestore.collection("tripsTest").getDocuments()
        XCTAssertEqual(snapshot.count, 1)
        XCTAssertEqual(snapshot.documents.first!["startAddress"] as? String ?? "", startAddress)
        XCTAssertEqual(snapshot.documents.first!["endAddress"] as? String ?? "", endAddress)
        XCTAssertEqual(snapshot.documents.first!["startDateTime"] as? Timestamp, snapshot.documents.first!["endDateTime"] as? Timestamp)
        XCTAssertEqual(snapshot.documents.first!["distance"] as? Double ?? 0.0, distance)
        XCTAssertEqual(snapshot.documents.first!["driverId"] as? String ?? "", driverId)
        XCTAssertEqual(snapshot.documents.first!["originalTimeZone"] as? String ?? "", originalTimeZone.abbreviation())

        // Clean
        try await firestore.collection("tripsTest").document(snapshot.documents.first!.documentID).delete()
        let deletedTrip = try await firestore.collection("tripsTest").document(snapshot.documents.first!.documentID).getDocument()
        XCTAssertFalse(deletedTrip.exists)
    }

    func testUpdateTripDriver() async throws {
        // Given
        let startCoordinates = GeoPoint(latitude: 1, longitude: 1)
        let endCoordinates = GeoPoint(latitude: 2, longitude: 2)
        let docRef = try await firestore.collection("tripsTest").addDocument(data: ["startAddress": "Praha", "endAddress": "Brno", "startCoordinates": startCoordinates, "endCoordinates": endCoordinates, "startDateTime": Date(), "endDateTime": Date(), "distance": 100.0, "originalTimeZone": "GMT+2", "driverId": "driver123"])
        
        // When
        let tripToUpdate = Trip(id: docRef.documentID, startDateTime: Date(), endDateTime: Date(), originalTimeZone: TimeZone.current, startLocation: Location(address: "Praha", coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1)), endLocation: Location(address: "Brno", coordinate: CLLocationCoordinate2D(latitude: 2, longitude: 2)), distance: 100.0, driverId: "driver456")
        try await tripService.updateTripDriver(tripToUpdate: tripToUpdate, test: true)
        
        // Then
        let snapshot = try await firestore.collection("tripsTest").getDocuments()
        XCTAssertEqual(snapshot.count, 1)
        XCTAssertEqual(snapshot.documents.first!.documentID, docRef.documentID)
        XCTAssertEqual(snapshot.documents.first!["driverId"] as? String ?? "", "driver456")
        
        // Clean
        try await firestore.collection("tripsTest").document(docRef.documentID).delete()
        let deletedTrip = try await firestore.collection("tripsTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedTrip.exists)
    }

    func testDeleteTrip() async throws {
        // Given
        let startCoordinates = GeoPoint(latitude: 1, longitude: 1)
        let endCoordinates = GeoPoint(latitude: 2, longitude: 2)
        let docRef = try await firestore.collection("tripsTest").addDocument(data: ["startAddress": "Praha", "endAddress": "Brno", "startCoordinates": startCoordinates, "endCoordinates": endCoordinates, "startDateTime": Date(), "endDateTime": Date(), "distance": 100.0, "originalTimeZone": "GMT+2"])
        let givenTrip = try await firestore.collection("tripsTest").document(docRef.documentID).getDocument()
        XCTAssertTrue(givenTrip.exists)
        
        // When
        try await tripService.deleteTrip(tripId: docRef.documentID, test: true)
        
        // Then
        let deletedTrip = try await firestore.collection("tripsTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedTrip.exists)
    }

    func testDeleteAllTrips() async throws {
        // Given
        let startCoordinates = GeoPoint(latitude: 1, longitude: 1)
        let endCoordinates = GeoPoint(latitude: 2, longitude: 2)
        let docRef1 = try await firestore.collection("tripsTest").addDocument(data: ["startAddress": "Praha", "endAddress": "Brno", "startCoordinates": startCoordinates, "endCoordinates": endCoordinates, "startDateTime": Date(), "endDateTime": Date(), "distance": 100.0, "originalTimeZone": "GMT+2"])
        let docRef2 = try await firestore.collection("tripsTest").addDocument(data: ["startAddress": "Praha 2", "endAddress": "Brno 2", "startCoordinates": startCoordinates, "endCoordinates": endCoordinates, "startDateTime": Date(), "endDateTime": Date(), "distance": 200.0, "originalTimeZone": "GMT+2"])
        
        let trips = [
            Trip(id: docRef1.documentID, startDateTime: Date(), endDateTime: Date(), originalTimeZone: TimeZone.current, startLocation: Location(address: "Praha", coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1)), endLocation: Location(address: "Brno", coordinate: CLLocationCoordinate2D(latitude: 2, longitude: 2)), distance: 100.0, driverId: "driver123"),
            Trip(id: docRef2.documentID, startDateTime: Date(), endDateTime: Date(), originalTimeZone: TimeZone.current, startLocation: Location(address: "Praha 2", coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1)), endLocation: Location(address: "Brno 2", coordinate: CLLocationCoordinate2D(latitude: 2, longitude: 2)), distance: 200.0, driverId: "driver456")
        ]
        
        let givenTrip1 = try await firestore.collection("tripsTest").document(docRef1.documentID).getDocument()
        let givenTrip2 = try await firestore.collection("tripsTest").document(docRef2.documentID).getDocument()
        XCTAssertTrue(givenTrip1.exists)
        XCTAssertTrue(givenTrip2.exists)
        
        // When
        try await tripService.deleteAllTrips(trips: trips, test: true)
        
        // Then
        let deletedTrip1 = try await firestore.collection("tripsTest").document(docRef1.documentID).getDocument()
        let deletedTrip2 = try await firestore.collection("tripsTest").document(docRef2.documentID).getDocument()
        XCTAssertFalse(deletedTrip1.exists)
        XCTAssertFalse(deletedTrip2.exists)
    }
}
