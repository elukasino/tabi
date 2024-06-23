//
//  TripsView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import SwiftUI

struct TripsView: View {
    @EnvironmentObject var tripVM: TripVM
    
    @State var importingSheetPresented = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    /*List(tripVM.trips) { trip in
                        Text("\(trip.startLocation) to \(trip.endLocation) - \(trip.distance) km")
                    }*/
                    ForEach(tripVM.trips) { trip in
                        Text(trip.startLocation)
                    }
                }
            }
            .navigationTitle("Trips")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        tripVM.fileImporterPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $tripVM.fileImporterPresented,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                tripVM.handleFileImport(result: result)
            }
            .alert(item: $tripVM.appError) { error in
                Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    TripsView()
        .environmentObject(TripVM(tripService: AppDependency.shared.tripService))
}
