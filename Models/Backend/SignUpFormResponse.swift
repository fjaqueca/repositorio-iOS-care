//
//  SendFormResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 26/09/2022.
//

import Foundation

struct SignUpFormResponse: Codable {
    var statusCode: Int
    var message: String
    var error: Bool?
}
