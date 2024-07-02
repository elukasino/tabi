//
//  ExpenseVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import Foundation

final class ExpenseVM: ObservableObject {
    struct Dependencies {
        let expenseService: ExpenseService
    }
    private let expenseService: ExpenseService
    
    @Published var expenses: [Expense] = []
    @Published var errorOccurred: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(dependencies: Dependencies) {
        expenseService = dependencies.expenseService
    }
    
    @MainActor
    func fetchAllExpenses() async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.expenses = try await expenseService.fetchAllExpenses()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
        
    }
    
    @MainActor
    func createExpense(description: String? = nil, amountString: String, type: ExpenseType) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await expenseService.createExpense(description: description, amount: convertToDouble(amountString)!, type: type) //TODO: Forced-unwrap
            await fetchAllExpenses()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    func getExpense(by expenseId: String) -> Expense? {
        isLoading = true
        defer { isLoading = false }
        if let expense = expenses.first(where: { $0.id == expenseId }) {
            return expense
        } else {
            errorMessage = "Expense not found"
            errorOccurred = true
        }
        return nil
    }
    
    @MainActor
    func updateExpense(updatedExpense: Expense) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await expenseService.updateExpense(expenseToUpdate: updatedExpense)
            await fetchAllExpenses()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    @MainActor
    func deleteExpense(by expenseId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        if let index = expenses.firstIndex(where: { $0.id == expenseId }) {
            expenses.remove(at: index)
        }
        
        do {
            try await expenseService.deleteExpense(expenseId: expenseId)
            await fetchAllExpenses()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    @MainActor
    func deleteAllExpenses() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await expenseService.deleteAllExpenses(expenses: expenses)
            await fetchAllExpenses()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
}
