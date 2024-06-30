//
//  SettingsView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 01.07.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var summaryVM: SummaryVM
    
    var body: some View {
        VStack{
            Toggle("Calculate all expenses equally", isOn: $summaryVM.calculateAllExpensesEqually)
                .padding()
                .customContainerStyle()
                .padding(.horizontal)
                .onChange(of: summaryVM.calculateAllExpensesEqually) {
                    summaryVM.updateDriversExpenseData()
                }
            Spacer()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
        .environmentObject(SummaryVM(dependencies: .init(tripVM: AppDependency.shared.tripVM, expenseVM: AppDependency.shared.expenseVM, driverVM: AppDependency.shared.driverVM)))
}
