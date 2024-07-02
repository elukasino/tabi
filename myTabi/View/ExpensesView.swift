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
            Group {
                if expenseVM.expenses.isEmpty {
                    ScrollView {
                        Rectangle().opacity(0)
                    }
                    .background {
                        BackgroundIconView(symbolName: "custom.creditcard.slash")
                    }
                } else {
                    List(expenseVM.expenses) { expense in
                        NavigationLink {
                            EditExpenseView(expense: expense)
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(expense.type.rawValue):")
                                Text("\(expense.amount, specifier: "%0.0f") \(Locale.current.currency?.identifier ?? "CZK")")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                Task {
                                    await expenseVM.deleteExpense(by: expense.id)
                                }
                            }
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
                    if expenseVM.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button {
                            confirmationDialogPresented = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .confirmationDialog("Do you want to delete all expenses?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                            Button("Delete all", role: .destructive) {
                                Task {
                                    await expenseVM.deleteAllExpenses()
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .refreshable {
                Task {
                    await expenseVM.fetchAllExpenses()
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
    
    @State private var expenseDescription: String = ""
    @State private var expenseAmountString: String = ""
    @State private var expenseType: ExpenseType = .other
    
    @FocusState private var focusedField: FocusedField?
    enum FocusedField {
        case description, amount
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Picker("Expense type", selection: $expenseType) {
                        ForEach(ExpenseType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Description", text: $expenseDescription)
                        .focused($focusedField, equals: .description)
                    HStack {
                        TextField("Amount", text: $expenseAmountString)
                            .numbersOnly($expenseAmountString, includeDecimal: true)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .amount)
                        Text(Locale.current.currency?.identifier ?? "CZK")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .onAppear {
                focusedField = .amount
                UITextField.appearance().clearButtonMode = .whileEditing
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if expenseVM.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .onDisappear {
                                if !expenseVM.errorOccurred {
                                    dismiss()
                                }
                            }
                    } else {
                        Button {
                            Task {
                                await expenseVM.createExpense(description: expenseDescription, amountString: expenseAmountString ,type: expenseType)
                            }
                        } label: {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                        .disabled(expenseAmountString.isEmpty)
                    }
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
}

struct EditExpenseView: View {
    @EnvironmentObject var expenseVM: ExpenseVM
    @Environment(\.dismiss) var dismiss
    
    @State var expense: Expense
    @State private var expenseAmountString: String = ""
    @State var confirmationDialogPresented: Bool = false
    
    @FocusState private var focusedField: FocusedField?
    enum FocusedField {
        case description, amount
    }
    
    let formatter = NumberFormatter()
    
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
                        .focused($focusedField, equals: .description)
                        HStack {
                            TextField("Amount", text: $expenseAmountString)
                                .numbersOnly($expenseAmountString, includeDecimal: true)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .amount)
                                .onAppear {
                                    formatter.numberStyle = .decimal
                                    formatter.locale = Locale.current
                                    expenseAmountString = formatter.string(from: NSNumber(value: expense.amount)) ?? "NaN"
                                }
                            Text(Locale.current.currency?.identifier ?? "CZK")
                                .foregroundStyle(.gray)
                        }
                    }
                    Section {
                        Button(role: .destructive, action: {
                            confirmationDialogPresented = true
                        }, label: {
                            if expenseVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .onDisappear {
                                        if !expenseVM.errorOccurred {
                                            dismiss()
                                        }
                                    }
                            } else {
                                Text("Delete expense")
                            }
                        })
                    }
                }
            }
            .confirmationDialog("Do you want to delete this expense?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    Task {
                        await expenseVM.deleteExpense(by: expense.id)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if expenseVM.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .onDisappear {
                                if !expenseVM.errorOccurred {
                                    dismiss()
                                }
                            }
                    } else {
                        Button {
                            Task {
                                expense.amount = convertToDouble(expenseAmountString)! //TODO: Forced-unwrap, NumbersOnlyViewModifier should guarantee correct value
                                await expenseVM.updateExpense(updatedExpense: expense)
                            }
                        } label: {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                        .disabled(expenseAmountString.isEmpty)
                    }
                }
            }
            .navigationTitle("Edit expense")
        }
    }
}

#Preview {
    ExpensesView()
        .environmentObject(ExpenseVM(dependencies: .init(expenseService: AppDependency.shared.expenseService)))
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseVM(dependencies: .init(expenseService: AppDependency.shared.expenseService)))
}
