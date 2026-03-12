//
//  SignUpContactInfoFormResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 27/06/2023.
//

import Foundation

struct SignUpContactInfoFormResponse: Codable {
    let statusCode: Int
    let data: Data
    let error: Bool
    
    struct Data: Codable {
        let message: String
    }
}
