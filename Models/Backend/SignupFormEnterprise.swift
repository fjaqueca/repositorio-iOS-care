//
//  SignupFormEnterprise.swift
//  CareAssistance
//
//  Created by Lara Dubs on 03/04/2023.
//

import Foundation

struct SignupFormEnterprise: Decodable, Identifiable, Hashable, CustomStringConvertible {
    let id: String
    let name: String

    var description: String {
        name
    }
}
