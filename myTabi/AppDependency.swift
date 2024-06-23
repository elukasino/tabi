//
//  AppDependency.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation

final class AppDependency {
    static let shared = AppDependency()

    lazy var csvParser = CSVParser()
    lazy var tripService: TripService = { DefaultTripService(csvParser: csvParser) } ()
    lazy var driverService: DriverService = { DefaultDriverService() } ()
}
