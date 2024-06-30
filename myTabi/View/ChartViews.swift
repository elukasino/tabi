//
//  ChartViews.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 30.06.2024.
//

import SwiftUI
import Charts

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
                Chart(summaryVM.chartExpensesData) { entry in
                    SectorMark(angle: .value(entry.type.rawValue, entry.amount),
                               innerRadius: .ratio(0.618),
                               angularInset: 1.0
                    )
                    .foregroundStyle(entry.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(width: 180, height: 180)
                .animation(.easeOut, value: summaryVM.chartExpensesData)
                VStack(alignment: .leading) {
                    ForEach(summaryVM.chartExpensesData) { entry in
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
                Chart(summaryVM.chartDriversDistanceData) { entry in
                    SectorMark(angle: .value(entry.driver.id, entry.distance),
                               innerRadius: .ratio(0.618),
                               angularInset: 1.0
                    )
                    .foregroundStyle(entry.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(width: 140, height: 140)
                .animation(.easeOut, value: summaryVM.chartDriversDistanceData)
                VStack(alignment: .leading) {
                    ForEach(summaryVM.chartDriversDistanceData) { entry in
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
                Chart(summaryVM.chartDriversExpenseData) { entry in
                    SectorMark(angle: .value(entry.driver.id, entry.expense),
                               innerRadius: .ratio(0.618),
                               angularInset: 1.0
                    )
                    .foregroundStyle(entry.color.gradient)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(width: 140, height: 140)
                .animation(.easeOut, value: summaryVM.chartDriversExpenseData)
                VStack(alignment: .leading) {
                    ForEach(summaryVM.chartDriversExpenseData) { entry in
                        LegendView(name: entry.driver.firstName.isEmpty ? entry.driver.lastName : entry.driver.firstName, value: entry.expense, unit: Locale.current.currency?.identifier ?? "CZK", color: entry.color)
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
                Text("\(value, specifier: "%.0f") \(unit)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}
