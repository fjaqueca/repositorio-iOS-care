//
//  Network+SignUp.swift
//  CareAssistance
//
//  Created by Lara Dubs on 15/09/2022.
//

import Foundation
import Alamofire

extension Network {
    func checkRut(rut: String) async -> Result<RutValidateResponse, AppError> {
        await request(endpoint: .rutValidate, parameters: ["rut": rut], isAuthenticated: false)
    }

    func sendValidationCode(rut: String) async -> Result<CodeGenerateResponse, AppError> {
        await request(method: .put, endpoint: .codeGenerate, parameters: ["sender": "PRD", "rut": rut], parametersDestination: .urlQueryString, isAuthenticated: false)
    }
    
    func checkValidationCode(rut: String, code: String) async -> Result<CheckValidationCodeResponse, AppError> {
        await request(method: .post, endpoint: .codeValidate, parameters: ["code": code, "rut": rut], parametersDestination: .urlQueryString, isAuthenticated: false)
    }
    
    func signUp(rut: String, password: String) async -> Result<SignUpResponse, AppError> {
        await request(method: .post, endpoint: .signUp, parameters: ["username": rut, "password": password], isAuthenticated: false)
    }
    
    func setContactInfo(_ values: [String: String]) async -> Result<SignUpContactInfoFormResponse, AppError> {
        await request(method: .post, endpoint: .signUpSetContactInfo, parameters: values, isAuthenticated: false)
    }

    func getSignupFormEnterprises(countryId: String) async -> Result<[SignupFormEnterprise], AppError> {
        await request(endpoint: .signUpFormEnterprises, parameters: ["pais_id": countryId], isAuthenticated: false)
    }
    
    func getRoles() async -> Result<BeneficiaryResponse, AppError> {
        await request(endpoint: .signUpFormRoles, isAuthenticated: false)
    }
    
    func getCountries() async -> Result<[Country], AppError> {
        await request(endpoint: .signUpFormCountries, isAuthenticated: false)
    }
    
    func sendSignUpForm(_ values: [String: String]) async -> Result<SignUpFormResponse, AppError> {
        await request(method: .post, endpoint: .signUpForm, parameters: ["asr": values], isAuthenticated: false)
    }
    
    func checkCognitoRut(rut: String) async -> Result<RutCognitoValidateResponse, AppError> {
        await request(method: .post,endpoint: .rutCognitoValidate, parameters: ["username": rut], isAuthenticated: false)
    }
}

