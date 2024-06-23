//
//  ContentView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TripVM()
    
    var body: some View {
        NavigationView {
            List(viewModel.trips) { trip in
                Text("\(trip.startLocation) to \(trip.endLocation)")
            }
            .navigationTitle("Trips")
        }
    }
}

#Preview {
    ContentView()
}
