//
//  ContentView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var tripVM: TripVM
    @StateObject var expenseVM: ExpenseVM
    @StateObject var driverVM: DriverVM
    //@StateObject var authVM: AuthVM
    
    init(appDependency: AppDependency) {
        _tripVM = StateObject(wrappedValue: TripVM(tripService: appDependency.tripService))
        _expenseVM = StateObject(wrappedValue: ExpenseVM(expenseService: appDependency.expenseService))
        _driverVM = StateObject(wrappedValue: DriverVM(driverService: appDependency.driverService))
        //_authVM = StateObject(wrappedValue: appDependency.authVM)
    }
    
    var body: some View {
        //if authVM.user != nil {
            TabView {
                SummaryView()
                    .environmentObject(tripVM)
                    .environmentObject(expenseVM)
                    .environmentObject(driverVM)
                    .tabItem {
                        Label("Summary", systemImage: "chart.pie.fill")
                    }
                
                TripsView()
                    .environmentObject(tripVM)
                    .environmentObject(driverVM)
                    .tabItem {
                        Label("Trips", systemImage: "map")
                    }
                
                ExpensesView()
                    .environmentObject(expenseVM)
                    .tabItem {
                        Label("Expenses", systemImage: "creditcard")
                    }
                
                DriversView()
                    .environmentObject(driverVM)
                    .tabItem {
                        Label("Drivers", systemImage: "person.2")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, .indigo)
                    }
            }
            .onAppear {
                Task {
                    await tripVM.fetchAllTrips()
                    await expenseVM.fetchAllExpenses()
                    await driverVM.fetchAllDrivers()
                }
            }
        /*}
        else {
            AuthView()
                .environmentObject(authVM)
        }*/
    }
}

#Preview {
    ContentView(appDependency: AppDependency())
}
