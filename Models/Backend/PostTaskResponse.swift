//
//  PostTaskResponse.swift
//  CareAssistance
//
//  Created by The App Master on 11/10/2023.
//

import Foundation

struct PostTaskResponse: Codable {
    var statusCode: Int?
    var message: String?
    var error: Bool?
}
