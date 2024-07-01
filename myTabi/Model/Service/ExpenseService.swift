//
//  ExpenseService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import Foundation
import FirebaseFirestore

class ExpenseService {
    struct Dependencies {
        let db: Firestore
    }
    private let db: Firestore //TODO: implement timeout
    
    private let path = "expenses"
    
    init(dependencies: Dependencies) {
        db = dependencies.db
    }
    
    func fetchAllExpenses(test: Bool = false) async throws -> [Expense] {
        let snapshot = try await db.collection(test ? path+"Test" : path).order(by: "timestamp").getDocuments()
        return snapshot.documents.compactMap { document in
            Expense(id: document.documentID,
                    description: document["description"] as? String ?? nil,
                    amount: document["amount"] as? Double ?? 0.0,
                    type: ExpenseType(rawValue: document["type"] as? String ?? "Other") ?? .other)
        }
    }
    
    func createExpense(description: String? = nil, amount: Double, type: ExpenseType, test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).addDocument(data: ["description" : description ?? "", "amount" : amount, "type" : type.rawValue, "timestamp" : Date()])
    }
    
    func updateExpense(expenseToUpdate: Expense, test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).document(expenseToUpdate.id).setData(["description" : expenseToUpdate.description ?? "",
                                                                                  "amount" : expenseToUpdate.amount,
                                                                                  "type" : expenseToUpdate.type.rawValue], merge: true)
    }
    
    func deleteExpense(expenseId: String, test: Bool = false) async throws {
        try await db.collection(test ? path+"Test" : path).document(expenseId).delete()
    }
    
    func deleteAllExpenses(expenses: [Expense], test: Bool = false) async throws {
        for expense in expenses { //TODO: add batch deleting
            try await db.collection(test ? path+"Test" : path).document(expense.id).delete()
        }
    }
}
