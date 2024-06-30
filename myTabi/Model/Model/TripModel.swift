//
//  TripModel.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation
import MapKit

struct Trip: Identifiable, Equatable {
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id && lhs.driverId == rhs.driverId
    }
    
    var id: String = UUID().uuidString
    var startDateTime: Date
    var endDateTime: Date
    var originalTimeZone: TimeZone
    var startLocation: Location
    var endLocation: Location
    var distance: Double
    var driverId: String?
}

struct Location: Identifiable {
    var id: String = UUID().uuidString
    var address: String
    var coordinate: CLLocationCoordinate2D?
}

struct parsedTrip: Identifiable {
    var id: String = UUID().uuidString
    var startDateTime: String
    var endDateTime: String
    var startLocation: String
    var endLocation: String
    var distance: Double
    var driverId: String?
}
