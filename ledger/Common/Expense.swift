//
//  Item.swift
//  ledger-ios
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import Foundation
import SwiftData

@Model
final class Expense: Codable {
    var id: String
    var name: String
    var cost: Int
    var date: String
    var tag: String
    

    init(cost: Int, name: String, tag: String, date: String) {
        self.id = UUID().uuidString.lowercased()
        self.cost = cost
        self.name = name
        self.tag = tag
        self.date = date
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        cost = try container.decode(Int.self, forKey: .cost)
        name = try container.decode(String.self, forKey: .name)
        tag = try container.decode(String.self, forKey: .tag)
        date = try container.decode(String.self, forKey: .date)
    }

    enum CodingKeys: String, CodingKey {
        case id, cost, name, tag, date
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(cost, forKey: .cost)
        try container.encode(name, forKey: .name)
        try container.encode(tag, forKey: .tag)
        try container.encode(date, forKey: .date)
    }
}
