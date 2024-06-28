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
        let startLocationColumn = 0 //Preparation for universal CSVs
        let endLocationColumn = 2
        let startDateTimeColumn = 1
        let endDateTimeColumn = 3
        let distanceColumn = 4
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        do {
            let csvFile: CSV = try CSV<Enumerated>(url: fileUrl, delimiter: .semicolon)

            for row in csvFile.rows {
                let startLocation = Location(address: row[startLocationColumn])
                let endLocation = Location(address: row[endLocationColumn])
                
                let startDateTime: Date
                if let date = formatter.date(from: row[startDateTimeColumn]) {
                    startDateTime = date
                } else {
                    throw AppError.csvFileError(description: "Error parsing date or time")
                }
                
                let endDateTime: Date
                if let date = formatter.date(from: row[endDateTimeColumn]) {
                    endDateTime = date
                } else {
                    throw AppError.csvFileError(description: "Error parsing date or time")
                }
                
                let originalTimeZone: TimeZone = TimeZone(iso8601String: row[startDateTimeColumn]) ?? TimeZone.current
                
                let distance = convertToDouble(row[distanceColumn]) ?? 0.0
                let trip = Trip(startDateTime: startDateTime, endDateTime: endDateTime, originalTimeZone: originalTimeZone, startLocation: startLocation, endLocation: endLocation, distance: distance)
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
    
    func convertToDouble(_ string: String) -> Double? {
        let normalizedString = string.replacingOccurrences(of: ",", with: ".")
        return Double(normalizedString)
    }
}

extension TimeZone {
    init?(iso8601String: String) {
        //Check that the string is at least 6 characters long
        guard iso8601String.count >= 6 else {
            return nil
        }
        
        //Extract the last 6 characters for the timezone offset
        let timeZoneString = String(iso8601String.suffix(6))
        
        //Verify that the first character is + or -
        let sign = String(timeZoneString.prefix(1))
        guard sign == "+" || sign == "-" else {
            return nil
        }
        
        //Filter out digits
        let fullTimeString = timeZoneString.filter("0123456789".contains)
        
        //Check that the length of the digits is 4 (hhmm)
        guard fullTimeString.count == 4 else {
            return nil
        }
        
        //Extract hours and minutes
        guard let hours = Int(sign + fullTimeString.prefix(2)), let minutes = Int(sign + fullTimeString.suffix(2)) else {
            return nil
        }
        
        //Validate the range for hours and minutes
        guard hours >= -23 && hours <= 23 && minutes >= -59 && minutes <= 59 else {
            return nil
        }
        
        //Calculate seconds from GMT
        let secondsFromGMT = hours * 3600 + minutes * 60
        
        //Initialize TimeZone
        self.init(secondsFromGMT: secondsFromGMT)
    }
}
