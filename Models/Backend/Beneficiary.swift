//
//  AffiliateType.swift
//  CareAssistance
//
//  Created by Lara Dubs on 27/12/2022.
//

import Foundation

struct Beneficiary: Codable, Identifiable {
    var id: String
    var name: String

    public var description: String {
        name
    }
}
