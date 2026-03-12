//
//  APIResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 02/01/2023.
//

import Foundation

struct APIEnvironment: Codable {
    let production: [Endpoint]
    let qa: [Endpoint]
    let dev: [Endpoint]

    struct Endpoint: Codable {
        let version: Int
        let latest: Bool
        let urls: URLs

        struct URLs: Codable {
            let initialAuth: String
            let cognitoAuth: String
        }
    }
}
