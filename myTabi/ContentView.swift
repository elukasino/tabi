//
//  ContentView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import SwiftUI

struct ContentView: View {
    struct Dependencies {
        let summaryVM: SummaryVM
        let tripVM: TripVM
        let expenseVM: ExpenseVM
        let driverVM: DriverVM
    }
    @StateObject var summaryVM: SummaryVM
    @StateObject var tripVM: TripVM
    @StateObject var expenseVM: ExpenseVM
    @StateObject var driverVM: DriverVM
    //@StateObject var authVM: AuthVM
    
    init(dependencies: Dependencies) {
        /*_tripVM = StateObject(wrappedValue: TripVM(tripService: AppDependency.shared.tripService))
        _expenseVM = StateObject(wrappedValue: ExpenseVM(expenseService: AppDependency.shared.expenseService))
        _driverVM = StateObject(wrappedValue: DriverVM(driverService: AppDependency.shared.driverService))
        _authVM = StateObject(wrappedValue: appDependency.authVM)*/
        
        _summaryVM = StateObject(wrappedValue: dependencies.summaryVM)
        _tripVM = StateObject(wrappedValue: dependencies.tripVM)
        _expenseVM = StateObject(wrappedValue: dependencies.expenseVM)
        _driverVM = StateObject(wrappedValue: dependencies.driverVM)
    }
    
    var body: some View {
        //if authVM.user != nil {
            TabView {
                SummaryView()
                    .environmentObject(summaryVM)
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
    ContentView(dependencies: .init(summaryVM: AppDependency.shared.summaryVM,
                                    tripVM: AppDependency.shared.tripVM,
                                    expenseVM: AppDependency.shared.expenseVM,
                                    driverVM: AppDependency.shared.driverVM))
}
