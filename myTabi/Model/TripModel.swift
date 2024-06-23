//
//  TripModel.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

struct Trip: Hashable, Identifiable, Codable {
    var id: String = UUID().uuidString
    var startDateTime: String
    var endDateTime: String
    var startLocation: String
    var endLocation: String
    var distance: Double
    var driverID: String?
}
