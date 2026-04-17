//
//  RutValidateResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/09/2022.
//

import Foundation

struct RutValidateResponse: Codable {
    var statusCode: Int?
    var message: String?
    var error: Bool?
    var mail: String?
}

struct RutCognitoValidateResponse: Codable {
    var status: String?
    var message: String?
    var exists: Bool?
    var userData: userDataCognito?
    var error: Bool?
    
    
    struct userDataCognito: Codable {
        var username: String?
        var enable: Bool?
        var user_status: String?
    }

}
