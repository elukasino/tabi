//
//  DriverVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

final class DriverVM: ObservableObject {
    private let driverService: DriverService
    @Published var drivers: [Driver] = []
    
    @Published var errorOccurred: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(driverService: DriverService) {
        self.driverService = driverService
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
        do {
            try await driverService.deleteDriver(driverId: driverId)
            await fetchAllDrivers()
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
