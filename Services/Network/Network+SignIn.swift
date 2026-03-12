//
//  Network+SignIn.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/09/2022.
//

import Foundation
import Alamofire
import RealmSwift

extension Network {
    func signIn(rut: String, password: String) async -> Result<Credentials, AppError> {
        await request(method: .post, endpoint: .signIn, parameters: ["username": rut, "password": password], isAuthenticated: false)
    }
    
    func renewPassword(validationCode: String, newPassword: String, rut: String) async -> Result<Empty, AppError> {
        await request(
            method: .post,
            endpoint: .passwordRenew,
            parameters: [
                "validation_code": validationCode,
                "new_password": newPassword,
                "username": rut
            ],
            isAuthenticated: false
        )
    }
}
