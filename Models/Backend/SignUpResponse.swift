//
//  SignUpResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/09/2022.
//

import Foundation

struct SignUpResponse: Codable {
    var status_code: Int?
    var message: String
    var error: Bool?
}
