//
//  AppAppearance.swift
//  ledger
//
//  Created by emblock on 6/23/25.
//

import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}
