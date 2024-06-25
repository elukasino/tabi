//
//  CSVParser.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation
import SwiftCSV

class CSVParser {
    func parseTrips(fileUrl: URL) throws -> [Trip] {
        guard fileUrl.startAccessingSecurityScopedResource() else {
            throw AppError.csvFileError(description: "Unable to access file")
        }
        
        var trips: [Trip] = []
        let startLocationColumn = 0 //preparation for universal CSVs
        let endLocationColumn = 2
        let startDateTimeColumn = 1
        let endDateTimeColumn = 3
        let distanceColumn = 4
        
        do {
            let csvFile: CSV = try CSV<Enumerated>(url: fileUrl, delimiter: .semicolon)

            for row in csvFile.rows {
                let startLocation = row[startLocationColumn]
                let endLocation = row[endLocationColumn]
                //TODO: format date
                let startDateTime = row[startDateTimeColumn]
                let endDateTime = row[endDateTimeColumn]
                let distance = Double(row[distanceColumn]) ?? 0.0
                
                let trip = Trip(startDateTime: startDateTime, endDateTime: endDateTime, startLocation: startLocation, endLocation: endLocation, distance: distance)
                trips.append(trip)
            }
        } catch let parseError as CSVParseError {
            switch parseError {
            case .generic(let message), .quotation(let message):
                throw AppError.csvFileError(description: "Error parsing CSV: " + message)
            }
        } catch {
            throw AppError.csvFileError(description: "Error reading trips from CSV file: " + error.localizedDescription)
        }
        return trips
    }
}
