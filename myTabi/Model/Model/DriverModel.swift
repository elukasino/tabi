//
//  DriverModel.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

struct Driver: Identifiable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var firstName: String
    var lastName: String
    var usualLocations: [String]
}
