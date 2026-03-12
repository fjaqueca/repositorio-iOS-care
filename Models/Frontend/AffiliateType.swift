//
//  AffiliateType.swift
//  CareAssistance
//
//  Created by Lara Dubs on 09/08/2022.
//

import SwiftUI

enum Affiliate: CustomStringConvertible, Identifiable, Hashable {
    case holder
    case beneficiary(Beneficiary)

    var id: String {
        switch self {
            case .holder:
                return "holder"
            case let .beneficiary(beneficiary):
                return "\(beneficiary.id)"
        }
    }

    var description: String {
        switch self {
            case .holder:
                return "Titular"
            case let .beneficiary(beneficiary):
                return beneficiary.description
        }
    }

    var serverValue: String? {
        switch self {
            case .holder:
                return nil
            case let .beneficiary(beneficiary):
                return beneficiary.name
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Array where Element == Field {
    var toDictionary: [String: String] {
        var dictionary = [String: String]()
        for field in self {
            if let value = field.value {
                dictionary[field.id] = value
            }
        }
        return dictionary
    }
}
