//
//  TagManager.swift
//  ledger
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import Foundation

struct TagManager {
    static private let key = "tags"

    static var tags: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: key) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    static func add(_ tag: String) {
        var current = tags
        if !current.contains(tag) {
            current.append(tag)
            tags = current
        }
    }

    static func remove(_ tag: String) {
        tags = tags.filter { $0 != tag }
    }
    
    static func clear() {
        tags = []
    }
}
