//
//  ExpenseServiceTests.swift
//  myTabiTests
//
//  Created by Lukáš Cmíral on 01.07.2024.
//

import XCTest
import FirebaseFirestore
@testable import myTabi

class ExpenseServiceTests: XCTestCase {

    var expenseService: ExpenseService!
    var firestore: Firestore!

    override func setUpWithError() throws {
        firestore = AppDependency.shared.fireStoreDb
        expenseService = ExpenseService(dependencies: .init(db: firestore))
    }

    override func tearDownWithError() throws {
        expenseService = nil
        firestore = nil
    }

    func testFetchAllExpenses() async throws {
        // Given
        let docRef = try await firestore.collection("expensesTest").addDocument(data: ["description": "Shell", "amount": 10.0, "type": "Fuel", "timestamp": Date()])
        
        // When
        let expenses = try await expenseService.fetchAllExpenses(test: true)
        
        // Then
        XCTAssertEqual(expenses.count, 1)
        XCTAssertEqual(expenses.first?.description, "Shell")
        XCTAssertEqual(expenses.first?.amount, 10.0)
        XCTAssertEqual(expenses.first?.type, .fuel)
        
        // Clean
        try await firestore.collection("expensesTest").document(docRef.documentID).delete()
        let deletedExpense = try await firestore.collection("expensesTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedExpense.exists)
    }

    func testCreateExpense() async throws {
        // When
        try await expenseService.createExpense(description: "Shell", amount: 10.0, type: .fuel, test: true)
        
        // Then
        let snapshot = try await firestore.collection("expensesTest").getDocuments()
        XCTAssertEqual(snapshot.count, 1)
        XCTAssertEqual(snapshot.documents.first!["description"] as? String ?? "", "Shell")
        XCTAssertEqual(snapshot.documents.first!["amount"] as? Double ?? 0.0, 10.0)
        XCTAssertEqual(snapshot.documents.first!["type"] as? String ?? "", "Fuel")

        // Clean
        try await firestore.collection("expensesTest").document(snapshot.documents.first!.documentID).delete()
        let deletedExpense = try await firestore.collection("expensesTest").document(snapshot.documents.first!.documentID).getDocument()
        XCTAssertFalse(deletedExpense.exists)
    }

    func testUpdateExpense() async throws {
        // Given
        let docRef = try await firestore.collection("expensesTest").addDocument(data: ["description": "Lunch", "amount": 10.0, "type": "Food", "timestamp": Date()])
        
        // When
        let expenseToUpdate = Expense(id: docRef.documentID, description: "Shell", amount: 15.0, type: .fuel)
        try await expenseService.updateExpense(expenseToUpdate: expenseToUpdate, test: true)
        
        // Then
        let snapshot = try await firestore.collection("expensesTest").getDocuments()
        XCTAssertEqual(snapshot.count, 1)
        XCTAssertEqual(snapshot.documents.first!.documentID, docRef.documentID)
        XCTAssertEqual(snapshot.documents.first!["description"] as? String ?? "", "Shell")
        XCTAssertEqual(snapshot.documents.first!["amount"] as? Double ?? 0.0, 15.0)
        XCTAssertEqual(snapshot.documents.first!["type"] as? String ?? "", "Fuel")
        
        // Clean
        try await firestore.collection("expensesTest").document(docRef.documentID).delete()
        let deletedExpense = try await firestore.collection("expensesTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedExpense.exists)
    }

    func testDeleteExpense() async throws {
        // Given
        let docRef = try await firestore.collection("expensesTest").addDocument(data: ["description": "Shell", "amount": 10.0, "type": "Fuel", "timestamp": Date()])
        let givenExpense = try await firestore.collection("expensesTest").document(docRef.documentID).getDocument()
        XCTAssertTrue(givenExpense.exists)
        
        // When
        try await expenseService.deleteExpense(expenseId: docRef.documentID, test: true)
        
        // Then
        let deletedExpense = try await firestore.collection("expensesTest").document(docRef.documentID).getDocument()
        XCTAssertFalse(deletedExpense.exists)
    }

    func testDeleteAllExpenses() async throws {
        // Given
        let docRef1 = try await firestore.collection("expensesTest").addDocument(data: ["description": "Shell", "amount": 10.0, "type": "Fuel", "timestamp": Date()])
        let docRef2 = try await firestore.collection("expensesTest").addDocument(data: ["description": "Jarov", "amount": 15.0, "type": "Tires", "timestamp": Date()])
        let expenses = [
            Expense(id: docRef1.documentID, description: "Shell", amount: 10.0, type: .fuel),
            Expense(id: docRef2.documentID, description: "Jarov", amount: 15.0, type: .tires)
        ]
        let givenExpense1 = try await firestore.collection("expensesTest").document(docRef1.documentID).getDocument()
        let givenExpense2 = try await firestore.collection("expensesTest").document(docRef2.documentID).getDocument()
        XCTAssertTrue(givenExpense1.exists)
        XCTAssertTrue(givenExpense2.exists)
        
        // When
        try await expenseService.deleteAllExpenses(expenses: expenses, test: true)
        
        // Then
        let deletedExpense1 = try await firestore.collection("expensesTest").document(docRef1.documentID).getDocument()
        let deletedExpense2 = try await firestore.collection("expensesTest").document(docRef2.documentID).getDocument()
        XCTAssertFalse(deletedExpense1.exists)
        XCTAssertFalse(deletedExpense2.exists)
    }
}

