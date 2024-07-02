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
    
    @Published var calculateAllExpensesEqually: Bool = true
    private let colorPalette: [Color] = [.teal, .pink, .blue, .orange, .indigo, .yellow, .mint, .green]
    
    var totalExpenses = 0.0
    private var totalFuelExpenses = 0.0
    private var unassignedDistance = 0.0
    var totalDistance = 0.0
    
    @Published var chartExpensesData: [ChartExpensesData] = []
    @Published var chartDriversDistanceData: [ChartDriversDistanceData] = []
    @Published var chartDriversExpenseData: [ChartDriversExpenseData] = []

    init(dependencies: Dependencies) {
        tripVM = dependencies.tripVM
        expenseVM = dependencies.expenseVM
        driverVM = dependencies.driverVM
    }
    
    func updateExpensesData() {
        var colorIndex = 0
        var totalExpensesLocal = 0.0
        var totalFuelExpensesLocal = 0.0
        
        chartExpensesData.removeAll()
        for type in ExpenseType.allCases {
            chartExpensesData.append(ChartExpensesData(type: type, amount: 0.001, color: colorPalette[(colorIndex) % colorPalette.count])) //0.001 forces Swift Data to display chart without data
            colorIndex += 1
        }
        for expense in expenseVM.expenses {
            totalExpensesLocal += expense.amount
            if expense.type == .fuel {
                totalFuelExpensesLocal += expense.amount
            }
            for index in chartExpensesData.indices {
                if chartExpensesData[index].type == expense.type {
                    chartExpensesData[index].amount += expense.amount
                }
            }
        }   
        totalExpenses = totalExpensesLocal
        totalFuelExpenses = totalFuelExpensesLocal
    }
    
    func updateDriversDistanceData() {
        var colorIndex = 0
        var unassignedDistanceLocal = 0.0
        var totalDistanceLocal = 0.0
        
        //Clear chartDriversDistanceData and initialize this array with existing drivers and zero distance (0.001 forces Swift Chart to load on app start when data are not yet fetched)
        chartDriversDistanceData.removeAll()
        for driver in driverVM.drivers {
            chartDriversDistanceData.append(ChartDriversDistanceData(driver: driver, distance: 0, color: colorPalette[(1 + colorIndex) % colorPalette.count])) //ColorPalette[0] is reserved for unassigned driver
            colorIndex += 1
        }
        //0.001 forces Swift Chart to load on when real data are not yet calculated
        //ColorPalette[0] is reserved for unassigned driver
        chartDriversDistanceData.append(ChartDriversDistanceData(driver: Driver(firstName: "Unassigned", lastName: "lastNameForUnassignedDriver", usualLocations: []), distance: 0.001, color: colorPalette[0]))
        
        //Recalculate distance for each driver
        for trip in tripVM.trips {
            if let driverId = trip.driverId {
                for index in chartDriversDistanceData.indices {
                    if chartDriversDistanceData[index].driver.id == driverId {
                        chartDriversDistanceData[index].distance += trip.distance
                        totalDistanceLocal += trip.distance
                    }
                }
            } else { //If no driver is assigned to a trip, sum all these distances into placeholder Unassigned driver
                if chartDriversDistanceData[chartDriversDistanceData.count - 1].driver.lastName == "lastNameForUnassignedDriver" {
                    chartDriversDistanceData[chartDriversDistanceData.count - 1].distance += trip.distance
                    unassignedDistanceLocal += trip.distance
                    totalDistanceLocal += trip.distance
                }
            }
        }
        unassignedDistance = unassignedDistanceLocal
        totalDistance = totalDistanceLocal
    }
    
    func updateDriversExpenseData() {
        //This function is called only from SummaryView, therefore, updateExpensesData() and updateDriversDistanceData() are always called before. This function relies on data backed by these two other functions.
        var colorIndex = 0
        
        //Clear chartDriversExpenseData and initialize this array with existing drivers and zero distance (0.001 forces Swift Chart to load on app start when data are not yet fetched)
        chartDriversExpenseData.removeAll()
        for driver in driverVM.drivers {
            chartDriversExpenseData.append(ChartDriversExpenseData(driver: driver, expense: 0, color: colorPalette[(1 + colorIndex) % colorPalette.count])) //ColorPalette[0] is reserved for unassigned driver
            colorIndex += 1
        }
        
        if driverVM.drivers.isEmpty || expenseVM.expenses.isEmpty {
            chartDriversExpenseData.append(ChartDriversExpenseData(driver: Driver(firstName: "Unassigned", lastName: "lastNameForUnassignedDriver", usualLocations: []), expense: 0.001, color: colorPalette[0]))
        } else {
            //Recalculate expense for each driver
            for indexDE in chartDriversExpenseData.indices {
                for indexDD in chartDriversDistanceData.indices {
                    if chartDriversExpenseData[indexDE].driver.id == chartDriversDistanceData[indexDD].driver.id {
                        if tripVM.trips.isEmpty && driverVM.drivers.count > 0 { //TODO: mozne deleni nulou
                            chartDriversExpenseData[indexDE].expense = (totalExpenses  / Double(driverVM.drivers.count))
                        } else if calculateAllExpensesEqually && totalDistance > 0 && driverVM.drivers.count != 0 { //TODO: mozne deleni nulou
                            chartDriversExpenseData[indexDE].expense = (totalExpenses / totalDistance) * (chartDriversDistanceData[indexDD].distance + (unassignedDistance / Double(driverVM.drivers.count)))
                        } else if totalDistance != 0 && driverVM.drivers.count > 0 { //TODO: mozne deleni nulou
                            chartDriversExpenseData[indexDE].expense = ((totalFuelExpenses / totalDistance) * (chartDriversDistanceData[indexDD].distance + (unassignedDistance / Double(driverVM.drivers.count))) + ((totalExpenses-totalFuelExpenses) / Double(driverVM.drivers.count)))
                        }
                    }
                }
            }
        }
    }
}

struct ChartExpensesData: Identifiable, Equatable {
    let id = UUID()
    let type: ExpenseType
    var amount: Double
    let color: Color
}

struct ChartDriversDistanceData: Identifiable, Equatable {
    let id = UUID()
    let driver: Driver
    var distance: Double
    let color: Color
}

struct ChartDriversExpenseData: Identifiable, Equatable {
    let id = UUID()
    let driver: Driver
    var expense: Double
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
