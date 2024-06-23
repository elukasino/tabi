//
//  DriverVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

class DriverVM: ObservableObject {
    @Published var drivers: [Driver] = []

    func addDriver(_ driver: Driver) {
        drivers.append(driver)
    }
}
