//
//  DriverVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

class DriverVM: ObservableObject {
    private let driverService: DriverService
    @Published var drivers: [Driver] = []
    
    init(driverService: DriverService) {
        self.driverService = driverService
    }

    func addDriver(_ driver: Driver) {
        drivers.append(driver)
    }
}
