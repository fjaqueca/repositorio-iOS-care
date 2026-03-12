//
//  Network+API.swift
//  CareAssistance
//
//  Created by Lara Dubs on 02/01/2023.
//

import Foundation

extension Network {
    func checkAPIVersion() async -> Result<APIEnvironment, AppError> {
        await request(endpoint: .api, isAuthenticated: false)
    }
}
