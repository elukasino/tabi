//
//  SummaryView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import SwiftUI
import Charts

struct SummaryView: View {
    @EnvironmentObject var summaryVM: SummaryVM
    @EnvironmentObject var tripVM: TripVM //TODO: proč toto nemůžu odstranit, aby SummaryVM initovalo správně?
    @EnvironmentObject var expenseVM: ExpenseVM
    @EnvironmentObject var driverVM: DriverVM
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ChartExpensesView()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .background(RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                            .shadow(color: colorScheme == .light ? .black.opacity(0.1) : .white.opacity(0.15), radius: 8.0))
                        .padding([.horizontal, .top])
                    HStack(alignment: .top, spacing: 16) {
                        ChartDriversDistanceView()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .background(RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                                .shadow(color: colorScheme == .light ? .black.opacity(0.1) : .white.opacity(0.15), radius: 8.0))
                            .padding(.leading)
                        ChartDriversExpenseView()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .background(RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                                .shadow(color: colorScheme == .light ? .black.opacity(0.1) : .white.opacity(0.15), radius: 8.0))
                            .padding(.trailing)
                    }
                }
            }
            .navigationTitle("Summary")
            .refreshable {
                Task {
                    await expenseVM.fetchAllExpenses()
                    await driverVM.fetchAllDrivers()
                    await tripVM.fetchAllTrips()
                }
            }
            .onChange(of: tripVM.trips) {
                summaryVM.updateDriversDistanceData()
                summaryVM.updateDriversExpenseData()
            }
            .onChange(of: expenseVM.expenses) {
                summaryVM.updateExpensesData()
                summaryVM.updateDriversExpenseData()
            }
            .onChange(of: driverVM.drivers) {
                summaryVM.updateDriversDistanceData()
                summaryVM.updateDriversExpenseData()
            }
            .onAppear {
                summaryVM.updateExpensesData()
                summaryVM.updateDriversDistanceData()
                summaryVM.updateDriversExpenseData()
            }
        }
    }
}

struct ChartExpensesView: View {
    @EnvironmentObject var summaryVM: SummaryVM
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 3) {
                Image(systemName: "dollarsign")
                Text("Expenses by category")
            }
            .textCase(.uppercase)
            .foregroundStyle(.gray)
            .font(.caption)
            HStack(alignment: .center, spacing: 25) {
                Chart(summaryVM.chartExpenseData) { entry in
                    SectorMark(angle: .value(entry.type.rawValue, entry.amount),
                               innerRadius: .ratio(0.618),
                               angularInset: 1.0
                    )
                    .foregroundStyle(entry.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(width: 180, height: 180)
                .animation(.easeOut, value: summaryVM.chartExpenseData)
                VStack(alignment: .leading) {
                    ForEach(summaryVM.chartExpenseData) { entry in
                        LegendView(name: entry.type.rawValue, value: entry.amount, unit: Locale.current.currency?.identifier ?? "CZK", color: entry.color)
                    }
                }
                Spacer()
            }
        }
        .padding()
    }
}

struct ChartDriversDistanceView: View {
    @EnvironmentObject var summaryVM: SummaryVM
    
    //summaryVM.chartDriverData.isEmpty ? [ChartDriverData(driver: Driver(firstName: "", lastName: "", usualLocations: []), distance: 0.001, color: .cyan)] : //READY TO DELETE TODO: here
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 3) {
                Image(systemName: "person")
                Text("Distance P.P.")
            }
            .textCase(.uppercase)
            .foregroundStyle(.gray)
            .font(.caption)
            VStack(alignment: .center, spacing: 16) {
                Chart(summaryVM.chartDriverData) { entry in
                    SectorMark(angle: .value(entry.driver.id, entry.distance),
                               innerRadius: .ratio(0.618),
                               angularInset: 1.0
                    )
                    .foregroundStyle(entry.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(width: 140, height: 140)
                .animation(.easeOut, value: summaryVM.chartDriverData)
                VStack(alignment: .leading) {
                    ForEach(summaryVM.chartDriverData) { entry in
                        LegendView(name: entry.driver.firstName.isEmpty ? entry.driver.lastName : entry.driver.firstName, value: entry.distance, unit: "km", color: entry.color)
                    }
                }
            }
        }
        .padding()
    }
}

struct ChartDriversExpenseView: View {
    @EnvironmentObject var summaryVM: SummaryVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 3) {
                Image(systemName: "creditcard")
                Text("Expenses P.P.")
            }
            .textCase(.uppercase)
            .foregroundStyle(.gray)
            .font(.caption)
            VStack(alignment: .center, spacing: 16) {
                Chart(summaryVM.chartDriverData) { entry in
                    SectorMark(angle: .value(entry.driver.id, entry.distance),
                               innerRadius: .ratio(0.618),
                               angularInset: 1.0
                    )
                    .foregroundStyle(entry.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(width: 140, height: 140)
                .animation(.easeOut, value: summaryVM.chartDriverData)
                VStack(alignment: .leading) {
                    ForEach(summaryVM.chartDriverData) { entry in
                        LegendView(name: entry.driver.firstName.isEmpty ? entry.driver.lastName : entry.driver.firstName, value: entry.distance, unit: "km", color: entry.color)
                    }
                }
            }
        }
        .padding()
    }
}

struct LegendView: View {
    let name: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack() {
            Circle()
                .fill(color.gradient)
                .frame(width: 9)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.caption)
                    .foregroundStyle(.black)
                Text("\(value, specifier: "%.0f") \(unit)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    SummaryView()
        .environmentObject(SummaryVM(dependencies: .init(tripVM: AppDependency.shared.tripVM, expenseVM: AppDependency.shared.expenseVM, driverVM: AppDependency.shared.driverVM)))
        .environmentObject(TripVM(dependencies: .init(tripService: AppDependency.shared.tripService)))
        .environmentObject(ExpenseVM(dependencies: .init(expenseService: AppDependency.shared.expenseService)))
        .environmentObject(DriverVM(dependencies: .init(tripVM: AppDependency.shared.tripVM, tripService: AppDependency.shared.tripService, driverService: AppDependency.shared.driverService)))
}

