//
//  Color+Extensions.swift
//  CareAssistance
//
//  Created by Lara Dubs on 02/08/2022.
//

import SwiftUI

extension Color {
    static let buttonPrimaryBackground = Color("primary")
    static let secondary = Color("secondary")
    static let primaryText = Color("secondary-dark")
    static let secondaryText = Color("primary")
    static let textSecondary = Color("gray-text")
    static let backgroundSecondary = Color("secondary-light")
    static let orangeText = Color("orange-text")
    static let otp = Color("otp")
    static let grayBackground = Color("gray")
    static let darkGray = Color("gray-dark")
    static let negativeSentiment = Color("red-text")
    static let shadowLight = Color("shadow-light")
    static let darkGreen = Color("dark-green")
    static let grayDisabled = Color("gray-disabled")
    static let grayLight = Color("gray-light")
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

