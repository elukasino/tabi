//
//  ExpenseService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import Foundation
import FirebaseFirestore

class ExpenseService {
    private let db: Firestore
    //TODO: implement timeout
    
    init(fireStoreDb: Firestore) {
        self.db = fireStoreDb
    }
    
    func fetchAllExpenses() async throws -> [Expense] {
        let snapshot = try await db.collection("expenses").order(by: "timestamp").getDocuments()
        return snapshot.documents.compactMap { document in
            Expense(id: document.documentID,
                    description: document["description"] as? String ?? nil,
                    amount: document["amount"] as? Double ?? 0.0,
                    type: ExpenseType(rawValue: document["type"] as? String ?? "Other") ?? .other)
        }
    }
    
    func createExpense(description: String? = nil, amount: Double, type: ExpenseType) async throws {
        try await db.collection("expenses").addDocument(data: ["description" : description ?? "", "amount" : amount, "type" : type.rawValue, "timestamp" : Date()])
    }
    
    func updateExpense(expenseToUpdate: Expense) async throws {
        try await db.collection("expenses").document(expenseToUpdate.id).setData(["description" : expenseToUpdate.description ?? "",
                                                                                  "amount" : expenseToUpdate.amount,
                                                                                  "type" : expenseToUpdate.type.rawValue], merge: true)
    }
    
    func deleteExpense(expenseId: String) async throws {
        try await db.collection("expenses").document(expenseId).delete()
    }
    
    func deleteAllExpenses(expenses: [Expense]) async throws {
        for expense in expenses { //TODO: add batch deleting
            try await db.collection("expenses").document(expense.id).delete()
        }
    }
}
