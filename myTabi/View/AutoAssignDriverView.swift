//
//  AutoAssignDriverView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 01.07.2024.
//

import SwiftUI

struct AutoAssignDriverView: View {
    @EnvironmentObject var tripVM: TripVM
    @EnvironmentObject var driverVM: DriverVM
    @Environment(\.dismiss) var dismiss
    
    private let tripDemo = Trip(startDateTime: Date(), endDateTime: Date(), originalTimeZone: TimeZone.current, startLocation: Location(address: "CTU FIT, Thákurova 9, Prague", coordinate: .init(latitude: 50.10505557022301, longitude: 14.389751498673581)), endLocation: Location(address: "Vaclav Havel Airport, Prague", coordinate: .init(latitude: 50.10545929479469, longitude: 14.267687631695269)), distance: 12.3, autoAssignedDriver: false)
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Spacer()
                Text("Auto-assign drivers")
                    .font(.title)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.vertical)
                Text("The application can attempt to automatically assign driver to each ride.")
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                TripView(trip: tripDemo, demoOnly: true)
                Text("Automatic assignment will be marked with wand symbol.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .font(.caption)
                    .padding(.top)
                Text("The automatic assignment tries to match location of the trip with each driver's usual places. You can configure usual places for individual drivers in drivers list.")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                Spacer()
                Button {
                    Task {
                        await tripVM.autoAssignDrivers()
                    }
                } label: {
                    if tripVM.isLoading {
                        ProgressView(value: tripVM.loadingProgress, total: Double(tripVM.trips.count))
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.vertical, 8)
                            .onDisappear {
                                if !tripVM.errorOccurred {
                                    dismiss()
                                }
                            }
                    } else {
                        Text("Start auto-assigning drivers")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(tripVM.isLoading ? /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/ : false)
                .controlSize(.large)
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                }
                .padding(.top)
            }
            .padding(.horizontal)
            .toolbarBackground(Visibility.automatic)
            
            
        }
    }
}

#Preview {
    AutoAssignDriverView()
        .environmentObject(TripVM(dependencies: .init(tripService: AppDependency.shared.tripService)))
        .environmentObject(DriverVM(dependencies: .init(tripVM: AppDependency.shared.tripVM, tripService: AppDependency.shared.tripService, driverService: AppDependency.shared.driverService)))
}
