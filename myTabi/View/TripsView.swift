//
//  TripsView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import SwiftUI

struct TripsView: View {
    @EnvironmentObject var tripVM: TripVM
    @EnvironmentObject var driverVM: DriverVM
    
    @State var fileImporterPresented = false
    //@State var importingSheetPresented = false
    @State var confirmationDialogPresented = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    if tripVM.trips.isEmpty {
                        Rectangle().opacity(0)
                    } else {
                        ForEach(tripVM.trips) { trip in
                            TripView(trip: trip)
                        }
                    }
                }
            }
            .toolbarBackground(Visibility.automatic)
            .background {
                if tripVM.trips.isEmpty {
                    BackgroundIconView(symbolName: "custom.map.slash")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        fileImporterPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if tripVM.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button {
                            confirmationDialogPresented = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .confirmationDialog("Do you want to delete all trips?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                            Button("Delete all", role: .destructive) {
                                Task {
                                    await tripVM.deleteAllTrips()
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .navigationTitle("Trips")
            .refreshable {
                Task {
                    await driverVM.fetchAllDrivers()
                    await tripVM.fetchAllTrips()
                }
            }
            .alert(isPresented: $tripVM.errorOccurred) {
                Alert(title: Text("Error"), message: Text(tripVM.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $tripVM.duplicateFound) {
                Alert(
                    title: Text("Duplicate found"),
                    message: Text("File contains trips that are already stored in your database. Do you want to proceed and import duplicates or skip these dupliactes? Your decision will be applied to all trips in this import."),
                    primaryButton: .default(Text("Import duplicates")) {
                        tripVM.handleDuplicatesDecision(decision: true)
                    },
                    secondaryButton: .cancel(Text("Skip duplicates")) {
                        tripVM.handleDuplicatesDecision(decision: false)
                    }
                )
            }
            .fileImporter(
                isPresented: $fileImporterPresented,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                Task {
                    await tripVM.handleFileImport(result: result)
                }
            }
        }
    }
}

#Preview {
    TripsView()
        .environmentObject(TripVM(dependencies: .init(tripService: AppDependency.shared.tripService)))
        .environmentObject(DriverVM(dependencies: .init(tripVM: AppDependency.shared.tripVM, tripService: AppDependency.shared.tripService, driverService: AppDependency.shared.driverService)))
}
