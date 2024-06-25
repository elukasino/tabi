//
//  ExpenseVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import Foundation

final class ExpenseVM: ObservableObject {
    private let expenseService: ExpenseService
    @Published var expenses: [Expense] = []
    
    @Published var errorOccurred: Bool = false
    @Published var errorMessage: String?
    
    init(expenseService: ExpenseService) {
        self.expenseService = expenseService
    }
    
    func getExpense(by expenseId: String) -> Expense? {
        if let expense = expenses.first(where: { $0.id == expenseId }) {
            return expense
        } else {
            errorMessage = "Expense not found"
            errorOccurred = true
        }
        return nil
    }
    
    func addExpense(description: String = "", amount: Double, type: ExpenseType) {
        expenses.append(Expense(description: description == "" ? nil : description, amount: amount, type: type))
    }
    
    func updateExpense(_ updatedExpense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            expenses[index] = updatedExpense
        } else {
            errorMessage = "Expense not found"
            errorOccurred = true
        }
    }
    
    func removeExpense(by expenseId: String) {
        if let index = expenses.firstIndex(where: { $0.id == expenseId }) {
            expenses.remove(at: index)
        } else {
            errorMessage = "Expense not found"
            errorOccurred = true
        }
    }
    
    func removeAllExpenses() {
        expenses.removeAll()
    }
}
