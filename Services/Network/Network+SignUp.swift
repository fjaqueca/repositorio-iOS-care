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
        let params: [String: Any] = ["rut": rut]
        let fullUrl = "\(baseUrl)\(Endpoint.rutValidate.urlString)"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [checkRut] REQUEST get_rut_verification")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   🌐 URL: \(fullUrl)")
        print("   📦 Body: \(params)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<RutValidateResponse, AppError> = await request(endpoint: .rutValidate, parameters: params, isAuthenticated: false)

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [checkRut] RESPONSE get_rut_verification")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        switch result {
        case .success(let response):
            print("   ✅ Success")
            print("   📄 statusCode: \(response.statusCode ?? -1)")
            print("   📄 message: \(response.message ?? "nil")")
            print("   📄 error: \(response.error ?? false)")
            print("   📄 mail: \(response.mail ?? "nil")")
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(response),
               let raw = String(data: data, encoding: .utf8) {
                print("   📄 RAW Response:\n\(raw)")
            }
        case .failure(let error):
            print("   ❌ Error: \(error)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
    }

    func sendValidationCode(rut: String) async -> Result<CodeGenerateResponse, AppError> {
        await request(method: .put, endpoint: .codeGenerate, parameters: ["sender": "PRD", "rut": rut], parametersDestination: .urlQueryString, isAuthenticated: false)
    }
    
    func checkValidationCode(rut: String, code: String) async -> Result<CheckValidationCodeResponse, AppError> {
        await request(method: .post, endpoint: .codeValidate, parameters: ["code": code, "rut": rut], parametersDestination: .urlQueryString, isAuthenticated: false)
    }
    
    func signUp(rut: String, password: String) async -> Result<SignUpResponse, AppError> {
        let sanitizedRut = rut.filter { $0.isLetter || $0.isNumber }.uppercased()
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [signUp] REQUEST sign_up")
        print("   🔹 rut original: \"\(rut)\"")
        print("   🔹 rut sanitizado: \"\(sanitizedRut)\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        return await request(method: .post, endpoint: .signUp, parameters: ["username": sanitizedRut, "password": password], isAuthenticated: false)
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
        let fullParams: [String: Any] = ["asr": values]
        let fullUrl = "\(baseUrl)\(Endpoint.signUpForm.urlString)"

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [sendSignUpForm] REQUEST sign_up_form")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   🌐 URL: \(fullUrl)")
        print("   🔑 isAuthenticated: false")
        print("   📦 values (inner):")
        for (k, v) in values.sorted(by: { $0.key < $1.key }) {
            print("      \(k): \"\(v)\"")
        }
        if let prettyData = try? JSONSerialization.data(withJSONObject: fullParams, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   📦 FULL REQUEST BODY (con wrapper asr):")
            print(prettyString)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<SignUpFormResponse, AppError> = await request(
            method: .post,
            endpoint: .signUpForm,
            parameters: fullParams,
            isAuthenticated: false
        )

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [sendSignUpForm] RESPONSE sign_up_form")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        switch result {
        case .success(let response):
            print("   ✅ Success")
            print("   📄 statusCode: \(response.statusCode)")
            print("   📄 message: \(response.message)")
            print("   📄 error: \(response.error ?? false)")
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(response),
               let raw = String(data: data, encoding: .utf8) {
                print("   📄 RAW Response:\n\(raw)")
            }
        case .failure(let error):
            print("   ❌ Error")
            print("   📄 id: \(error.id)")
            print("   📄 name: \(error.name)")
            print("   📄 message: \(error.message)")
            print("   📄 httpCode: \(error.httpCode ?? -1)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
    }
    
    func checkCognitoRut(rut: String) async -> Result<RutCognitoValidateResponse, AppError> {
        await request(method: .post,endpoint: .rutCognitoValidate, parameters: ["username": rut], isAuthenticated: false)
    }
}

