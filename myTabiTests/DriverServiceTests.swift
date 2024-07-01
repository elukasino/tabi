//
//  DriverServiceTests.swift
//  myTabiTests
//
//  Created by Lukáš Cmíral on 01.07.2024.
//

import XCTest
import FirebaseFirestore
@testable import myTabi

class DriverServiceTests: XCTestCase {

    var driverService: DriverService!
    var firestore: Firestore!

    override func setUpWithError() throws {
        firestore = AppDependency.shared.fireStoreDb
        driverService = DriverService(dependencies: .init(db: firestore))
    }

    override func tearDownWithError() throws {
        driverService = nil
        firestore = nil
    }

    func testFetchAllDrivers() async throws {
        // Given
        let docRef = try await firestore.collection("driversTest").addDocument(data: ["firstName": "John", "lastName": "Appleseed", "timestamp": Date()])
        
        // When
        let drivers = try await driverService.fetchAllDrivers(test: true)
        
        // Then
        XCTAssertEqual(drivers.count, 1)
        XCTAssertEqual(drivers.first?.firstName, "John")
        XCTAssertEqual(drivers.first?.lastName, "Appleseed")
        
        // Clean
        try await firestore.collection("driversTest").document(docRef.documentID).delete()
        let deletedDriver = try await firestore.collection("driversTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedDriver.exists)
    }

    func testCreateDriver() async throws {
        // When
        try await driverService.createDriver(firstName: "John", lastName: "Appleseed", test: true)
        
        // Then
        let snapshot = try await firestore.collection("driversTest").getDocuments()
        XCTAssertEqual(snapshot.count, 1)
        XCTAssertEqual(snapshot.documents.first!["firstName"] as? String ?? "", "John")
        XCTAssertEqual(snapshot.documents.first!["lastName"] as? String ?? "", "Appleseed")

        // Clean
        try await firestore.collection("driversTest").document(snapshot.documents.first!.documentID).delete()
        let deletedDriver = try await firestore.collection("driversTest").document(snapshot.documents.first!.documentID).getDocument()
        XCTAssertFalse(deletedDriver.exists)
    }

    func testUpdateDriver() async throws {
        // Given
        let docRef = try await firestore.collection("driversTest").addDocument(data: ["firstName": "John", "lastName": "Appleseed", "timestamp": Date()])
        
        // When
        let driverToUpdate = Driver(id: docRef.documentID, firstName: "John", lastName: "Smith", usualLocations: [])
        try await driverService.updateDriver(driverToUpdate: driverToUpdate, test: true)
        
        // Then
        let snapshot = try await firestore.collection("driversTest").getDocuments()
        XCTAssertEqual(snapshot.count, 1)
        XCTAssertEqual(snapshot.documents.first!.documentID, docRef.documentID)
        XCTAssertEqual(snapshot.documents.first!["firstName"] as? String ?? "", "John")
        XCTAssertEqual(snapshot.documents.first!["lastName"] as? String ?? "", "Smith")
        
        // Clean
        try await firestore.collection("driversTest").document(docRef.documentID).delete()
        let deletedDriver = try await firestore.collection("driversTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedDriver.exists)
    }

    func testDeleteDriver() async throws {
        // Given
        let docRef = try await firestore.collection("driversTest").addDocument(data: ["firstName": "John", "lastName": "Appleseed", "timestamp": Date()])
        let givenDriver = try await firestore.collection("driversTest").document(docRef.documentID).getDocument()
        XCTAssertTrue(givenDriver.exists)
        
        // When
        try await driverService.deleteDriver(driverId: docRef.documentID, test: true)
        
        // Then
        let deletedDriver = try await firestore.collection("driversTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedDriver.exists)
    }

    func testDeleteAllDrivers() async throws {
        // Given
        let docRef1 = try await firestore.collection("driversTest").addDocument(data: ["firstName": "John", "lastName": "Appleseed", "timestamp": Date()])
        let docRef2 = try await firestore.collection("driversTest").addDocument(data: ["firstName": "Jane", "lastName": "Appleseed", "timestamp": Date()])
        let drivers = [
            Driver(id: docRef1.documentID, firstName: "John", lastName: "Appleseed", usualLocations: []),
            Driver(id: docRef2.documentID, firstName: "Jane", lastName: "Appleseed", usualLocations: [])
        ]
        let givenDriver1 = try await firestore.collection("driversTest").document(docRef1.documentID).getDocument()
        let givenDriver2 = try await firestore.collection("driversTest").document(docRef2.documentID).getDocument()
        XCTAssertTrue(givenDriver1.exists)
        XCTAssertTrue(givenDriver2.exists)
        
        // When
        try await driverService.deleteAllDrivers(drivers: drivers, test: true)
        
        // Then
        let deletedDriver1 = try await firestore.collection("driversTest").document(docRef1.documentID).getDocument()
        let deletedDriver2 = try await firestore.collection("driversTest").document(docRef2.documentID).getDocument()
        XCTAssertFalse(deletedDriver1.exists)
        XCTAssertFalse(deletedDriver2.exists)
    }
}
