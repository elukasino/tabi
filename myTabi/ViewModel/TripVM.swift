//
//  TripVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

class TripVM: ObservableObject {
    @Published var trips: [Trip] = []

    private let csvParser = CSVParser()

    func addTrip(_ trip: Trip) {
        trips.append(trip)
    }

    func loadTrips(from csvString: String) {
        let parsedTrips = csvParser.parseTrips(from: csvString)
        trips.append(contentsOf: parsedTrips)
    }
}

