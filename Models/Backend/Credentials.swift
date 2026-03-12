//
//  Credentials.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/09/2022.
//

import Foundation

public struct Credentials: Codable {
    let AccessToken: String
    //let IdToken: String      // ✅ AGREGAR
    let ExpiresIn: String
    let RefreshToken: String
}
