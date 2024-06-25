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
    @State var importingSheetPresented = false
    @State var confirmationDialogPresented = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(tripVM.trips) { trip in
                        TripView(trip: trip)
                    }
                }
            }
            .navigationTitle("Trips")
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
                    Button {
                        confirmationDialogPresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .confirmationDialog("Do you want to delete all trips?", isPresented: $confirmationDialogPresented, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            Task {
                                /*await*/ tripVM.removeAllTrips()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    
                }
            }
            .fileImporter(
                isPresented: $fileImporterPresented,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                tripVM.handleFileImport(result: result)
            }
            .alert(isPresented: $tripVM.errorOccurred) {
                Alert(title: Text("Error"), message: Text(tripVM.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    TripsView()
        .environmentObject(TripVM(tripService: AppDependency.shared.tripService))
        .environmentObject(DriverVM(driverService: AppDependency.shared.driverService))
}
