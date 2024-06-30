//
//  SummaryVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 28.06.2024.
//

import Foundation
import SwiftUI

final class SummaryVM: ObservableObject {
    struct Dependencies {
        let tripVM: TripVM //TODO: předávám celou class TripVM, protože předání pouze pole trips by vytvořilo kopii, takto mám referenci - chápu to správně?
        let expenseVM: ExpenseVM
        let driverVM: DriverVM
    }
    var tripVM: TripVM
    var expenseVM: ExpenseVM
    var driverVM: DriverVM
    
    let colorPalette: [Color] = [.teal, .pink, .blue, .orange, .indigo, .yellow, .mint, .green]
    
    @Published var chartExpenseData: [ChartExpenseData] = [
        .init(type: .fuel, amount: 0.001, color: .pink),        //1
        .init(type: .service, amount: 0.001, color: .indigo),   //3
        .init(type: .tires, amount: 0.001, color: .blue),       //4
        .init(type: .accessories, amount: 0.001, color: .teal), //0
        .init(type: .other, amount: 0.001, color: .red),        //2
    ]
    
    //@Published var chartExpenseData: [ChartExpenseData] = [ChartExpenseData(type: .other, amount: 0.001, color: .teal)] //0.001 forces Swift Chart to load on app start when real data are not yet fetched
    @Published var chartDriverData: [ChartDriverData] = []
    @Published var chartDriversExpenseData: [ChartDriverData] = []

    init(dependencies: Dependencies) {
        tripVM = dependencies.tripVM
        expenseVM = dependencies.expenseVM
        driverVM = dependencies.driverVM
    }
    
    func updateExpensesData() {
        for expense in expenseVM.expenses {
            switch expense.type {
            case .fuel:
                chartExpenseData[0].amount += expense.amount
            case .service:
                chartExpenseData[1].amount += expense.amount
            case .tires:
                chartExpenseData[3].amount += expense.amount
            case .accessories:
                chartExpenseData[4].amount += expense.amount
            default: //other etc.
                chartExpenseData[2].amount += expense.amount
            }
        }
    }
    
    func updateDriversDistanceData() {
        var colorIndex = 0
        
        //Clear chartDriverData and initialize this array with existing drivers and zero distance (0.001 forces Swift Chart to load on app start when data are not yet fetched)
        chartDriverData.removeAll()
        for driver in driverVM.drivers {
            chartDriverData.append(ChartDriverData(driver: driver, distance: 0, color: colorPalette[(1 + colorIndex) % colorPalette.count])) //ColorPalette[0] is reserved for unassigned driver
            colorIndex += 1
        }
        //0.001 forces Swift Chart to load on when real data are not yet calculated
        //ColorPalette[0] is reserved for unassigned driver
        chartDriverData.append(ChartDriverData(driver: Driver(firstName: "Unassigned", lastName: "lastNameForUnassignedDriver", usualLocations: []), distance: 0.001, color: colorPalette[0]))
        
        //Recalculate distance for each driver
        for trip in tripVM.trips {
            if let driverId = trip.driverId {
                for index in chartDriverData.indices {
                    if chartDriverData[index].driver.id == driverId {
                        chartDriverData[index].distance += trip.distance
                    }
                }
            } else { //If no driver is assigned to a trip, sum all these distances into placeholder Unassigned driver
                if chartDriverData[chartDriverData.count - 1].driver.lastName == "lastNameForUnassignedDriver" {
                        chartDriverData[chartDriverData.count - 1].distance += trip.distance
                    }
            }
        }
    }
    
    func updateDriversExpenseData() {
        //This function is called only from SummaryView, therefore, updateExpensesData() and updateDriversDistanceData() are always called before. This function relies on data backed by these two other functions.
        
    }
}

struct ChartExpenseData: Identifiable, Equatable {
    let id = UUID()
    let type: ExpenseType
    var amount: Double
    let color: Color
}

struct ChartDriverData: Identifiable, Equatable {
    let id = UUID()
    let driver: Driver
    var distance: Double
    let color: Color
}

extension Color {
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
