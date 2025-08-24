//
//  SheetManager.swift
//  Arca
//
//  Created by Fuad Fajri on 24/08/25.
//

import Foundation

// Enum to manage which sheet is currently active
enum ActiveSheet: Identifiable {
    case search, patungDetail, recent, bookmark

    var id: Int {
        hashValue
    }
}
