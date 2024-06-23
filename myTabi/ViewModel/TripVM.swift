//
//  TripVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

class TripVM: ObservableObject {
    private let tripService: TripService
    @Published var trips: [Trip] = []
    
    @Published var fileImporterPresented = false
    @Published var appError: AppError?
    
    init(tripService: TripService) {
        self.tripService = tripService
    }

    func addTrip(_ trip: Trip) {
        trips.append(trip)
    }
    
    func loadTrips(fileUrl: URL) {
        let parsedTrips = tripService.loadTrips(fileUrl: fileUrl)
        trips.append(contentsOf: parsedTrips)
    }
    
    func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                loadTrips(fileUrl: url)
            }
        case .failure(let error):
            appError = .runtimeError(description: error.localizedDescription)
            print(appError ?? "File handling unknown error")
        }
    }
}

