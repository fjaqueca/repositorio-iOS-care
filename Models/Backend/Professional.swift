//
//  Professional.swift
//  CareAssistance
//
//  Created by Lara Dubs on 26/10/2022.
//

import Foundation

struct Professional: Codable, Identifiable, CustomStringConvertible, Hashable {
    let serviceResourceId: String
    let serviceTerritoryId: String
    let name: String
    let role: String?

    var id: String {
        [serviceTerritoryId, serviceResourceId].joined(separator: "_")
    }

    var description: String {
        name
    }
}
