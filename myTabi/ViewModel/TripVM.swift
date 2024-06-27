//
//  TripVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

final class TripVM: ObservableObject {
    private let tripService: TripService
    @Published var trips: [Trip] = []
    
    @Published var errorOccurred: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    @Published var duplicateFound: Bool = false
    private var alertContinuation: CheckedContinuation<Bool, Never>?
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    init(tripService: TripService) {
        self.tripService = tripService
        dateFormatter.dateStyle = .short
        timeFormatter.timeStyle = .short
    }
    
    func dateToString(date: Date, timeZone: TimeZone) -> String {
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: date)
    }
    
    func timeToString(date: Date, timeZone: TimeZone) -> String {
        timeFormatter.timeZone = timeZone
        if TimeZone.current.secondsFromGMT() != timeZone.secondsFromGMT() {
            return timeFormatter.string(from: date) + " " + (timeZone.abbreviation() ?? "")
        }
        return timeFormatter.string(from: date)
    }
    
    @MainActor
    func fetchAllTrips() async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.trips = try await tripService.fetchAllTrips()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
        
    }
    
    @MainActor
    func createTrip(startDateTime: Date, endDateTime: Date, originalTimeZone: TimeZone, startAddress: String, endAddress: String,
                    distance: Double, driverId: String?) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await tripService.createTrip(startDateTime: startDateTime, endDateTime: endDateTime, originalTimeZone: originalTimeZone, startAddress: startAddress, endAddress: endAddress, distance: distance, driverId: driverId)
            await fetchAllTrips()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    func getTrip(by tripId: String) -> Trip? {
        isLoading = true
        defer { isLoading = false }
        if let trip = trips.first(where: { $0.id == tripId }) {
            return trip
        } else {
            errorMessage = "Trip not found"
            errorOccurred = true
        }
        return nil
    }
    
    @MainActor
    func updateTripDriver(_ updatedTrip: Trip) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await tripService.updateTripDriver(tripToUpdate: updatedTrip)
            await fetchAllTrips()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    @MainActor
    func deleteTrip(by tripId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await tripService.deleteTrip(tripId: tripId)
            await fetchAllTrips()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    @MainActor
    func deleteAllTrips() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await tripService.deleteAllTrips(trips: trips)
            await fetchAllTrips()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    @MainActor
    func handleFileImport(result: Result<[URL], Error>) async {
        isLoading = true
        defer { isLoading = false }
        
        var allowDuplicates: Bool? = nil
                
        switch result {
        case .success(let urls):
            if let url = urls.first {
                do {
                    let parsedTrips = try tripService.loadTrips(fileUrl: url)
                    for trip in parsedTrips { //Parsed trips do not contain geocoded addresses (do not contain coordinates)
                        if allowDuplicates == nil || allowDuplicates == false {
                            if trips.first(where: { $0.startDateTime == trip.startDateTime }) != nil {
                                if allowDuplicates == nil {
                                    duplicateFound = true
                                    
                                    allowDuplicates = await withCheckedContinuation { continuation in
                                        self.alertContinuation = continuation //Save continuation object for later re-opening of this function
                                    }
                                    
                                    if allowDuplicates == true { //User chose to proceed with duplicates
                                        await createTrip(startDateTime: trip.startDateTime, endDateTime: trip.endDateTime, originalTimeZone: trip.originalTimeZone , startAddress: trip.startLocation.address, endAddress: trip.endLocation.address, distance: trip.distance, driverId: trip.driverId)
                                    }
                                }
                            } else {
                                await createTrip(startDateTime: trip.startDateTime, endDateTime: trip.endDateTime, originalTimeZone: trip.originalTimeZone , startAddress: trip.startLocation.address, endAddress: trip.endLocation.address, distance: trip.distance, driverId: trip.driverId)
                            }
                        } else {
                            await createTrip(startDateTime: trip.startDateTime, endDateTime: trip.endDateTime, originalTimeZone: trip.originalTimeZone , startAddress: trip.startLocation.address, endAddress: trip.endLocation.address, distance: trip.distance, driverId: trip.driverId)
                        }
                    }
                } catch {
                    errorMessage = error.localizedDescription
                    errorOccurred = true
                    print(errorMessage ?? "Loading trips error")
                }
            } else {
                errorMessage = "Invalid file path"
                errorOccurred = true
                print(errorMessage!)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            errorOccurred = true
            print(errorMessage ?? "File handling unknown error")
        }
    }
    
    func handleDuplicatesDecision(decision: Bool) {
        //Re-open saved continuation with user decision
        alertContinuation?.resume(returning: decision)
        alertContinuation = nil
    }
}

