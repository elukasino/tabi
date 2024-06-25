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

    
    init(tripService: TripService) {
        self.tripService = tripService
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
    func createTrip(startDateTime: String, endDateTime: String, startLocation: String, endLocation: String,
                    distance: Double, driverId: String?) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await tripService.createTrip(startDateTime: startDateTime, endDateTime: endDateTime, startLocation: startLocation, endLocation: endLocation, distance: distance, driverId: driverId)
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
    func updateTrip(_ updatedTrip: Trip) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await tripService.updateTrip(tripToUpdate: updatedTrip)
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
        
        switch result {
        case .success(let urls):
            if let url = urls.first {
                do {
                    let parsedTrips = try tripService.loadTrips(fileUrl: url)
                    for trip in parsedTrips {
                        await createTrip(startDateTime: trip.startDateTime, endDateTime: trip.endDateTime, startLocation: trip.startLocation, endLocation: trip.endLocation, distance: trip.distance, driverId: trip.driverId)
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
}

