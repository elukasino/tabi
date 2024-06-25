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
    
    @MainActor
    init(tripService: TripService) {
        self.tripService = tripService
        fetchTrips()
    }
    
    @MainActor
    func fetchTrips() {
        Task {
            do {
                self.trips = try await tripService.fetchTrips()
            } catch {
                self.errorMessage = error.localizedDescription
                errorOccurred = true
            }
        }
    }
    
    @MainActor
    func saveTrip(_ trip: Trip) {
        Task {
            do {
                try await tripService.saveTrip(trip)
                fetchTrips()
            } catch {
                self.errorMessage = error.localizedDescription
                errorOccurred = true
            }
        }
    }
    
    @MainActor
    func loadTrips(fileUrl: URL) throws {
        let parsedTrips = try tripService.loadTrips(fileUrl: fileUrl)
        trips.append(contentsOf: parsedTrips)
        for trip in parsedTrips {
            saveTrip(trip)
        }
    }
    
    @MainActor
    func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                do {
                    try loadTrips(fileUrl: url)
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
    
    func removeAllTrips() {
        trips.removeAll()
    }
}

