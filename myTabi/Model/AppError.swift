//
//  AppError.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 23.06.2024.
//

import Foundation

enum AppError: LocalizedError, Identifiable {
    var id: String { UUID().uuidString }
    
    case runtimeError(description: String)
    case csvFileError(description: String)
    
    var errorDescription: String? {
            switch self {
            case .csvFileError(let description):
                //return "CSV file error: \(description)"
                return description
            case .runtimeError(let description):
                return "Unknown error: \(description)"
            }
        }
}

