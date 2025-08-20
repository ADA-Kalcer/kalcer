//
//  RGB.swift
//  Kalcer
//
//  Created by Tude Maha on 19/08/2025.
//

import SwiftUI

extension Color {
    static func rgb(red: Double, green: Double, blue: Double) -> Color {
        return Color(red: red / 255, green: green / 255, blue: blue / 255)
    }
    
    static func rgba(red: Double, green: Double, blue: Double, alpha: Double) -> Color {
        return Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha)
    }
}
