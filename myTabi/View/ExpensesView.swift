//
//  ExpensesView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var expenseVM: ExpenseVM
    
    @State var addExpenseSheetPresented = false
    @State var confirmationDialogPresented = false
    
    var body: some View {
        NavigationStack {
            List(expenseVM.expenses) { expense in
                NavigationLink {
                    EditExpenseView(expense: expense)
                } label: {
                    Text(expense.type.rawValue)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        Task {
                            /*await*/ expenseVM.removeExpense(by: expense.id)
                        }
                    }
                }
            }
            .sheet(isPresented: $addExpenseSheetPresented) {
                NavigationView {
                    AddExpenseView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addExpenseSheetPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        confirmationDialogPresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .confirmationDialog("Do you want to delete all expenses?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            Task {
                                /*await*/ expenseVM.removeAllExpenses()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    
                }
            }
            .navigationTitle("Expenses")
            .refreshable {
                Task {
                    //await expenseVM.fetchExpenses()
                }
            }
            .alert(isPresented: $expenseVM.errorOccurred) {
                Alert(title: Text("Error"), message: Text(expenseVM.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AddExpenseView: View {
    @EnvironmentObject var expenseVM: ExpenseVM
    @Environment(\.dismiss) var dismiss
    
    @State var expenseDescription: String = ""
    @State var expenseAmount: Double = 0.0
    @State var expenseType: ExpenseType = .other
    
    var body: some View {
        VStack {
            Form {
                Picker("Expense type", selection: $expenseType) {
                    ForEach(ExpenseType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                TextField("Description", text: $expenseDescription)
                TextField("Amount", value: $expenseAmount, format: .currency(code: Locale.current.currency?.identifier ?? "Kč"))
                    .keyboardType(.decimalPad)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        /*await*/ expenseVM.addExpense(description: expenseDescription, amount: expenseAmount ,type: expenseType)
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .fontWeight(.bold)
                }
                //.disabled(expenseAmount?.isZero ?? false)
                .disabled(expenseAmount.isZero)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert(isPresented: $expenseVM.errorOccurred) {
            Alert(title: Text("Error"), message: Text(expenseVM.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Add expense")
    }
}

struct EditExpenseView: View {
    @EnvironmentObject var expenseVM: ExpenseVM
    @Environment(\.dismiss) var dismiss
    
    @State var expense: Expense
    @State var confirmationDialogPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        Picker("Expense type", selection: $expense.type) {
                            ForEach(ExpenseType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        TextField("Description", text: Binding(
                            get: { expense.description ?? "" },
                            set: { expense.description = $0.isEmpty ? nil : $0 }
                        ))
                        TextField("Amount", value: $expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "Kč"))
                            .keyboardType(.numberPad)
                    }
                    Section {
                        Button("Delete expense", role: .destructive) {
                            confirmationDialogPresented = true
                        }
                        .confirmationDialog("Do you want to delete this expense?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                Task {
                                    /*await*/ expenseVM.removeExpense(by: expense.id)
                                    dismiss()
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            /*await*/ expenseVM.updateExpense(expense)
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                            .fontWeight(.bold)
                    }
                    .disabled(expense.amount.isZero)
                    
                }
            }
            .navigationTitle("Edit expense")
        }
    }
}

#Preview {
    ExpensesView()
        .environmentObject(ExpenseVM(expenseService: AppDependency.shared.expenseService))
}