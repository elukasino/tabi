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
    @EnvironmentObject var tripVM: TripVM //FIXME: proč toto nemůžu odstranit, aby SummaryVM initovalo správně?
    @EnvironmentObject var expenseVM: ExpenseVM
    @EnvironmentObject var driverVM: DriverVM
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GeneralSummaryView()
                        .customContainerStyle()
                        .padding([.horizontal, .top])
                    ChartExpensesView()
                        .customContainerStyle()
                        .padding([.horizontal])
                    HStack(alignment: .top, spacing: 16) {
                        ChartDriversDistanceView()
                            //.frame(maxHeight: .infinity)
                            .customContainerStyle()
                            .padding(.leading)
                        ChartDriversExpenseView()
                            //.frame(maxHeight: .infinity)
                            .customContainerStyle()
                            .padding(.trailing)
                    }
                    //.fixedSize(horizontal: false, vertical: true)
                    Toggle("Calculate all expenses equally", isOn: $summaryVM.calculateAllExpensesEqually)
                        .padding()
                        .customContainerStyle()
                        .padding(.horizontal)
                        .onChange(of: summaryVM.calculateAllExpensesEqually) {
                            summaryVM.updateDriversExpenseData()
                        }
                }
            }
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
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

struct GeneralSummaryView: View {
    @EnvironmentObject var summaryVM: SummaryVM
    @EnvironmentObject var tripVM: TripVM
    
    let currency = Locale.current.currency?.identifier ?? "CZK"
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                if !tripVM.trips.isEmpty {
                    Text("Data range: " + tripVM.dateToString(date: tripVM.trips.first!.startDateTime, timeZone: tripVM.trips.first!.originalTimeZone) + " – " + tripVM.dateToString(date: tripVM.trips.first!.endDateTime, timeZone: tripVM.trips.first!.originalTimeZone))
                } else {
                    Text("Data range: no data")
                }
                Text("Total distance: \(summaryVM.totalDistance, specifier: "%0.0f") km")
                HStack(spacing: 0) {
                    Text("Total expenses:")
                    Text(" \(summaryVM.totalExpenses, specifier: "%0.0f") \(currency)")
                        .foregroundStyle(.blue)
                }
            }
            Spacer()
        }
        .foregroundStyle(.gray)
        .font(.headline)
        .padding()
    }
}

#Preview {
    SummaryView()
        .environmentObject(SummaryVM(dependencies: .init(tripVM: AppDependency.shared.tripVM, expenseVM: AppDependency.shared.expenseVM, driverVM: AppDependency.shared.driverVM)))
        .environmentObject(TripVM(dependencies: .init(tripService: AppDependency.shared.tripService)))
        .environmentObject(ExpenseVM(dependencies: .init(expenseService: AppDependency.shared.expenseService)))
        .environmentObject(DriverVM(dependencies: .init(tripVM: AppDependency.shared.tripVM, tripService: AppDependency.shared.tripService, driverService: AppDependency.shared.driverService)))
}

