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
    
    @MainActor
    init(driverService: DriverService) {
        self.driverService = driverService
        fetchDrivers()
    }
    
    @MainActor
    func fetchDrivers() {
        Task {
            do {
                self.drivers = try await driverService.fetchDrivers()
            } catch {
                self.errorMessage = error.localizedDescription
                errorOccurred = true
            }
        }
    }
    
    @MainActor
    func saveDriver(_ driver: Driver) {
        Task {
            do {
                try await driverService.saveDriver(driver)
                fetchDrivers()
            } catch {
                self.errorMessage = error.localizedDescription
                errorOccurred = true
            }
        }
    }
    
    @MainActor
    func getDriver(by driverId: String) -> Driver? {
        if let driver = drivers.first(where: { $0.id == driverId }) {
            return driver
        } else {
            errorMessage = "Driver not found"
            errorOccurred = true
        }
        return nil
    }
    
    func addDriver(firstName: String, lastName: String) {
        drivers.append(Driver(firstName: firstName, lastName: lastName, usualLocations: []))
    }
    
    func updateDriver(_ updatedDriver: Driver) {
        if let index = drivers.firstIndex(where: { $0.id == updatedDriver.id }) {
            drivers[index] = updatedDriver
        } else {
            errorMessage = "Driver not found"
            errorOccurred = true
        }
    }
    
    func removeDriver(by driverId: String) {
        if let index = drivers.firstIndex(where: { $0.id == driverId }) {
            drivers.remove(at: index)
        } else {
            errorMessage = "Driver not found"
            errorOccurred = true
        }
    }
    
    func removeAllDrivers() {
        drivers.removeAll()
    }
}
