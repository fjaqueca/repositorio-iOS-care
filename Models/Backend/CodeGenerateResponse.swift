//
//  CodeGenerateResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 17/09/2022.
//

import Foundation

struct CodeGenerateResponse: Codable {
    var recipient: String
    var message: String
    var messageId: String
}
