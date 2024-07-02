//
//  DriverVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

final class DriverVM: ObservableObject {
    struct Dependencies {
        let tripVM: TripVM
        let tripService: TripService
        let driverService: DriverService
    }
    private let tripVM: TripVM
    private let tripService: TripService
    private let driverService: DriverService
    
    @Published var drivers: [Driver] = []
    @Published var errorOccurred: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(dependencies: Dependencies) {
        tripVM = dependencies.tripVM
        tripService = dependencies.tripService
        driverService = dependencies.driverService
    }
    
    @MainActor
    func fetchAllDrivers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.drivers = try await driverService.fetchAllDrivers()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
        
    }
    
    @MainActor
    func createDriver(firstName: String, lastName: String, usualLocations : [String] = []) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await driverService.createDriver(firstName: firstName, lastName: lastName)
            await fetchAllDrivers()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    func getDriver(by driverId: String) -> Driver? {
        isLoading = true
        defer { isLoading = false }
        if let driver = drivers.first(where: { $0.id == driverId }) {
            return driver
        } else {
            errorMessage = "Driver not found"
            errorOccurred = true
        }
        return nil
    }
    
    @MainActor
    func updateDriver(_ updatedDriver: Driver) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await driverService.updateDriver(driverToUpdate: updatedDriver)
            await fetchAllDrivers()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    @MainActor
    func deleteDriver(by driverId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        if let index = drivers.firstIndex(where: { $0.id == driverId }) {
            drivers.remove(at: index)
        }
        
        do {
            try await driverService.deleteDriver(driverId: driverId)
            try await tripService.deleteDriverIdFromTrips(driverId: driverId, trips: tripVM.trips) //Remove leftover driver IDs from trips
            await fetchAllDrivers()
            await tripVM.fetchAllTrips()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
    
    @MainActor
    func deleteAllDrivers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await driverService.deleteAllDrivers(drivers: drivers)
            await fetchAllDrivers()
        } catch {
            self.errorMessage = error.localizedDescription
            errorOccurred = true
        }
    }
}
