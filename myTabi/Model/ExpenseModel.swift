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
    var type: String
}
