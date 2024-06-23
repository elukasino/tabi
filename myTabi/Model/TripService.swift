//
//  TripService.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation

protocol TripService {
    func loadTrips(fileUrl: URL) -> [Trip]
}

class DefaultTripService: TripService {
    private let csvParser: CSVParser

    init(csvParser: CSVParser) {
        self.csvParser = csvParser
    }

    func loadTrips(fileUrl: URL) -> [Trip] {
        return csvParser.parseTrips(fileUrl: fileUrl)
    }
}
