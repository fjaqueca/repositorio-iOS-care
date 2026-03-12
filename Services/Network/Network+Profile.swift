//
//  Network+Profile.swift
//  CareAssistance
//
//  Created by Lara Dubs on 08/10/2022.
//

import Foundation
import Alamofire

extension Network {
    func logout(token: String) async -> Result<Empty, AppError> {
        await request(method: .post, endpoint: .logout, parameters: ["refresh_token": token])
    }
    
    func deleteAccount(rut: String) async -> Result<Empty, AppError> {
        await request(method: .delete, endpoint: .deleteAccount, parameters: ["username": rut])
    }

    func profile(rut: String) async -> Result<User, AppError> {
        await request(endpoint: .profile, parameters: ["rut": rut])
    }
    
    func changePassword(oldPassword: String, newPassword: String) async -> Result<Empty, AppError> {
        await request(method: .post, endpoint: .passwordChange, parameters: ["actual_password": oldPassword, "new_password": newPassword])
    }
    
    func updateProfile(rut: String, lastName: String?, firstName: String?, email: String?, phone: String?) async -> Result<Empty, AppError> {
        let parameters: [String: String] = [
            "rut": rut,
            "LastName": lastName,
            "FirstName": firstName,
            "Email": email,
            "Phone": phone
        ].compactMapValues { item in
            guard item?.isEmpty == false else {
                return nil
            }
            return item
        }
        return await request(method: .post, endpoint: .profileUpdate, parameters: ["asr": parameters])
    }
}
