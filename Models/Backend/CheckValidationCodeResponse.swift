//
//  CheckValidationCodeResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 19/09/2022.
//

import Foundation

struct CheckValidationCodeResponse: Codable {
    var statusCode: Int
    var message: String
    var error: Bool
}
