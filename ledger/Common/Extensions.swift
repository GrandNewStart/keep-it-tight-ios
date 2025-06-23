//
//  Extensions.swift
//  ledger
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
    
    static func appPrimary(for appearance: AppAppearance) -> Color {
        switch appearance {
        case .dark:
            return Color(hex: "#227570")
        case .light:
            return Color(hex: "#009B91")
        }
    }
}

extension Binding {
    init(_ source: Binding<Value?>, replacingNilWith nilValue: Value) {
        self.init(
            get: { source.wrappedValue ?? nilValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}


extension Date {
    init(string: String) throws {
        guard let millis = Double(string) else {
            throw NSError(domain: "InvalidDateString", code: 1, userInfo: nil)
        }
        self.init(timeIntervalSince1970: millis / 1000)
    }
}
