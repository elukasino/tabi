//
//  ExpenseModel.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 22.06.2024.
//

import Foundation

struct Expense: Hashable, Identifiable, Codable {
    var id: String = UUID().uuidString
    var description: String?
    var amount: Double
    var type: ExpenseType
}

enum ExpenseType: String, Codable, CaseIterable, Identifiable {
    case fuel = "Fuel"
    case service = "Service"
    case tires = "Tires"
    case accessories = "Accessories"
    case other = "Other"
    
    var id: String { self.rawValue } //TODO: What is this?
}
