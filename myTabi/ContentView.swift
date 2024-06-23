//
//  ContentView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var tripVM: TripVM
    @StateObject var driverVM: DriverVM
    
    init(appDependency: AppDependency) {
        _tripVM = StateObject(wrappedValue: TripVM(tripService: appDependency.tripService))
        _driverVM = StateObject(wrappedValue: DriverVM(driverService: appDependency.driverService))
    }
    
    var body: some View {
        TabView {
            SummaryView()
                .environmentObject(tripVM)
                .tabItem {
                    Label("Summary", systemImage: "chart.pie.fill")
                }
            
            TripsView()
                .environmentObject(tripVM)
                .tabItem {
                    Label("Trips", systemImage: "map")
                }
            
            ExpensesView()
                .tabItem {
                    Label("Expenses", systemImage: "creditcard")
                }
            
            DriversView()
                .tabItem {
                    Label("Drives", systemImage: "person.2")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .indigo)
                }
        }
    }
}

#Preview {
    ContentView(appDependency: AppDependency.shared)
}
