//
//  Country.swift
//  CareAssistance
//
//  Created by Lara Dubs on 26/04/2023.
//

import Foundation

struct Country: Codable, Identifiable, Hashable, CustomStringConvertible {
    let name: String
    let id: String
    
    var description: String {
        name
    }
}
