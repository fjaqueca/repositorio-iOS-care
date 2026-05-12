//
//  Network.swift
//  CareAssistance
//
//  Created by Lara Dubs on 13/09/2022.
//

import Foundation
import Alamofire

struct Network {
    static let shared = Self()
    public let baseUrl = "https://huudh3ythg.execute-api.us-east-1.amazonaws.com/prd-initial-auth/"
    public let baseUrlAuthenticated = "https://o5neq91ecd.execute-api.us-east-1.amazonaws.com/prd-cognito-auth/"
    private let manager: Alamofire.Session
    // Dev R1:baseUrl "https://l2zjbkbsw6.execute-api.us-east-1.amazonaws.com/dev-initial-auth/"
    // Dev R1:baseUrlAuthenticated "https://hd4kfs9svc.execute-api.us-east-1.amazonaws.com/dev-cognito-auth/"
    
    // PROD:baseUrl "https://huudh3ythg.execute-api.us-east-1.amazonaws.com/prd-initial-auth/"
    // PROD:baseUrlAuthenticated "https://o5neq91ecd.execute-api.us-east-1.amazonaws.com/prd-cognito-auth/"
    
    //Staging baseUrl = "https://r78t18efk3.execute-api.us-east-1.amazonaws.com/qa-initial-auth/"
    //Staging baseUrlAuthenticated = "https://a7kcyezhcd.execute-api.us-east-1.amazonaws.com/qa-cognito-auth/"
    
    init() {
        let configuration = URLSessionConfiguration.default
        //Create a non-caching configuration.
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.timeoutIntervalForRequest = 60
        //Allow cookies if needed.
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        manager = Alamofire.Session(configuration: configuration)
    }

    func request<Value: Decodable, Parameters: Encodable>(method: HTTPMethod = .get, endpoint: Endpoint, parameters: Parameters? = nil, parametersDestination: ParametersDestination = .methodDependant, isAuthenticated: Bool = true) async -> Result<Value, AppError> {
        var params: [String: Any]?

        let encoder = JSONEncoder()

        if let parameters = parameters, let data = try? encoder.encode(parameters) {
            params = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        }
        return await request(method: method, endpoint: endpoint, parameters: params, parametersDestination: parametersDestination, isAuthenticated: isAuthenticated)
    }

    /// Request con body JSON crudo (Data) — preserva orden estricto de keys
    func requestWithRawBody<Value: Decodable>(method: HTTPMethod = .post, endpoint: Endpoint, jsonData: Data, isAuthenticated: Bool = true) async -> Result<Value, AppError> {
        var url = (isAuthenticated ? baseUrlAuthenticated : baseUrl) + endpoint.urlString
        if endpoint.urlString.contains("http") {
            url = endpoint.urlString
        }

        var headers: HTTPHeaders = .init([])
        if isAuthenticated, let credentials = AppStatusManager.credentials {
            headers.add(.authorization(credentials.AccessToken))
        } else {
            headers.add(.authorization(tokenUnauthenticated))
        }
        headers.add(.contentType("application/json"))

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = endpoint.keyEncodingStrategy

        var urlRequest: URLRequest
        do {
            urlRequest = try URLRequest(url: url, method: method, headers: headers)
        } catch {
            return .failure(AppError(id: "api.error.urlRequest", name: "Network", message: error.localizedDescription))
        }
        urlRequest.httpBody = jsonData

        let response = await manager
            .request(urlRequest)
            .validate(statusCode: 200...299)
            .serializingResponse(using: .decodable(of: Value.self, decoder: decoder))
            .response

        // LOG RAW RESPONSE
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 [Network] RAW RESPONSE - \(endpoint.urlString)")
        print("   HTTP Status: \(response.response?.statusCode ?? -1)")
        if let data = response.data {
            print("   Response size: \(data.count) bytes")
            if let rawJson = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: rawJson, options: [.prettyPrinted]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("   RAW JSON:")
                print(prettyString)
            } else if let rawString = String(data: data, encoding: .utf8) {
                print("   RAW STRING: \(rawString.prefix(2000))")
            }
        } else {
            print("   ⚠️ response.data es nil")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        switch response.result {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            print("   ❌ Decode/Validation error: \(error.localizedDescription)")
            if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return .failure(AppError(id: "api.error.rawBody", name: "\(response.response?.statusCode ?? 0)", message: json["message"] as? String ?? error.localizedDescription))
            }
            return .failure(AppError(id: "api.error.rawBody", name: "Network", message: error.localizedDescription))
        }
    }

    func request<Value: Decodable>(method: HTTPMethod = .get, endpoint: Endpoint, parameters: Parameters? = nil, parametersDestination: ParametersDestination = .methodDependant, isAuthenticated: Bool = true) async -> Result<Value, AppError> {

        URLSessionConfiguration.default.urlCache = nil
        
        var url = (isAuthenticated ? baseUrlAuthenticated : baseUrl) + endpoint.urlString
        if endpoint.urlString.contains("http"){
            url = endpoint.urlString
        }
        
        var headers: HTTPHeaders = .init([])

        if isAuthenticated, let credentials = AppStatusManager.credentials {
            headers.add(.authorization(credentials.AccessToken))
        } else {
            headers.add(.authorization(tokenUnauthenticated))
        }
        
        var encoding: ParameterEncoding
        switch parametersDestination {
            case .urlQueryString:
                encoding = URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .numeric)
            case .jsonBody:
                encoding = JSONEncoding(options: .fragmentsAllowed)
            case .methodDependant:
                switch method {
                    case .get:
                        encoding = URLEncoding(destination: .queryString)
                    default:
                        encoding = JSONEncoding(options: .fragmentsAllowed)
                }
        }

        let decoder = JSONDecoder()
        if endpoint.urlString == "get_brand_account_r1" {
            decoder.keyDecodingStrategy = .useDefaultKeys
        }else{
            decoder.keyDecodingStrategy = endpoint.keyEncodingStrategy
        }
        if endpoint.urlString == "function_filter" {
            encoding = JSONEncoding.init(options: .sortedKeys)
        }

        // 🔎 LOG DEL REQUEST ENVIADO
        if endpoint.urlString == "post_completado" || endpoint.urlString.contains("post_") || endpoint.urlString == "function_filter" || endpoint.urlString.contains("function_flows") {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📤 NETWORK REQUEST - \(method.rawValue)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🔹 Nombre del Servicio: \(endpoint.urlString)")
            print("🔹 URL Completa: \(url)")
            print("🔹 Método HTTP: \(method.rawValue)")
            print("🔹 Autenticado: \(isAuthenticated)")
            if let params = parameters {
                print("🔹 Request Body:")
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted, .sortedKeys])
                    if let json = String(data: jsonData, encoding: .utf8) {
                        print(json)
                    }
                } catch {
                    print("   \(params)")
                }
            } else {
                print("🔹 Request Body: (vacío)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("")
        }

        let response = await manager
            .request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers,
                interceptor: nil
            )
            .validate(statusCode: 200...299)
            .serializingResponse(using: .decodable(of: Value.self, decoder: decoder))
            .response

        // 🔎 LOG: Verificar campos de Atributos y Valores 9.7-9.8 en BrandAccount
        if endpoint.urlString == "get_brand_account_r1" {
            if let data = response.data, let rawString = String(data: data, encoding: .utf8) {
                let hasA97 = rawString.contains("Atributo_9_7__c")
                let hasA98 = rawString.contains("Atributo_9_8__c")
                let hasV97 = rawString.contains("Valor_9_7__c")
                let hasV98 = rawString.contains("Valor_9_8__c")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔍 [BrandAccount] Verificación campos 9.7-9.8 en RAW JSON")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("   Atributo_9_7__c presente: \(hasA97)")
                print("   Atributo_9_8__c presente: \(hasA98)")
                print("   Valor_9_7__c presente: \(hasV97)")
                print("   Valor_9_8__c presente: \(hasV98)")
                if hasA97, let range = rawString.range(of: "Atributo_9_7__c") {
                    let start = rawString.index(range.lowerBound, offsetBy: -1, limitedBy: rawString.startIndex) ?? range.lowerBound
                    let end = rawString.index(range.upperBound, offsetBy: 80, limitedBy: rawString.endIndex) ?? rawString.endIndex
                    print("   Contexto Atributo_9_7: ...\(rawString[start..<end])...")
                }
                if hasA98, let range = rawString.range(of: "Atributo_9_8__c") {
                    let start = rawString.index(range.lowerBound, offsetBy: -1, limitedBy: rawString.startIndex) ?? range.lowerBound
                    let end = rawString.index(range.upperBound, offsetBy: 80, limitedBy: rawString.endIndex) ?? rawString.endIndex
                    print("   Contexto Atributo_9_8: ...\(rawString[start..<end])...")
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }
        }

        // 🔎 LOG DE LA RESPUESTA DEL SERVIDOR
        if endpoint.urlString == "post_completado" || endpoint.urlString.contains("post_") || endpoint.urlString == "function_filter" || endpoint.urlString.contains("function_flows") {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📥 NETWORK RESPONSE - \(endpoint.urlString)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🔹 Status Code: \(response.response?.statusCode ?? -1)")
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                print("🔹 Response Body:")
                if let jsonData = jsonString.data(using: .utf8),
                   let prettyPrintedData = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                   let prettyData = try? JSONSerialization.data(withJSONObject: prettyPrintedData, options: [.prettyPrinted, .sortedKeys]),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    print(prettyString)
                } else {
                    print(jsonString)
                }
            } else {
                print("🔹 Response Body: (vacío o no disponible)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("")
        }

        switch response.result {
            case let .success(value):
                // 🔎 LOG DE ÉXITO
                if endpoint.urlString == "post_completado" || endpoint.urlString.contains("post_") || endpoint.urlString == "function_filter" || endpoint.urlString.contains("function_flows") {
                    print("✅ SUCCESS: \(endpoint.urlString) - Request completado exitosamente")
                    print("")
                }
                return .success(value)
            case let .failure(error):
                // 🔎 LOG DE ERROR
                if endpoint.urlString == "post_completado" || endpoint.urlString.contains("post_") || endpoint.urlString == "function_filter" || endpoint.urlString.contains("function_flows") {
                    print("❌ ERROR: \(endpoint.urlString)")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("🔹 Error Description: \(error.localizedDescription)")
                    print("🔹 Response Code: \(error.responseCode ?? -1)")
                    if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
                        print("🔹 Error Response Body:")
                        print(errorString)
                    }
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("")
                }
                
                print(error)
                if error.responseCode == 403 {
                    // Endpoints que pueden devolver 403 legítimamente (no es error de auth)
                    let nonAuthEndpoints = ["get_ver_url_privada"]
                    let isNonAuthEndpoint = nonAuthEndpoints.contains(where: { endpoint.urlString.contains($0) })
                    if isNonAuthEndpoint {
                        print("⚠️ [Network] 403 en \(endpoint.urlString) - NO es error de auth, no se cierra sesión")
                        return .failure(AppError(id: "forbidden", name: "Acceso denegado", message: "No tiene permisos para acceder a este recurso"))
                    }
                    AppStatusManager.cleanup()
                    return .failure(AppError.unauthenticated)
                }
                if error.responseCode == 401 {
                    return .failure(AppError.unauthorized)
                    // TODO: Refresh Token Procedure
                }
                
                #if CareAssistance
                print("There was a networking error: \(error.localizedDescription)")
                #endif
            print(response.debugDescription)
                if let data = response.data, let serverError = try? decoder.decode(ServerError.self, from: data) {
                    return .failure(.init(
                        id: "server_error",
                        name: "¡Se produjo un error!",
                        message: "Por favor contactarse con \nAtención al Cliente.",
                        httpCode: response.response?.statusCode
                    ))
                }
                return .failure(.init(
                    id: "http_error",
                    name: "¡Se produjo un error!",
                    message: "Por favor contactarse con \nAtención al Cliente.",
                    httpCode: response.response?.statusCode
                ))
        }
    }
    func requestFunctionFilter<T: Encodable, R: Decodable>(
        method: HTTPMethod = .post,
        endpoint: Endpoint,
        encodableParameters: T,
        isAuthenticated: Bool = true
    ) async -> Result<R, Error> {
        
        URLSessionConfiguration.default.urlCache = nil

        var url = (isAuthenticated ? baseUrlAuthenticated : baseUrl) + endpoint.urlString
        if endpoint.urlString.contains("http") {
            url = endpoint.urlString
        }

        var headers: HTTPHeaders = .init([])
        if isAuthenticated, let credentials = AppStatusManager.credentials {
            headers.add(.authorization(credentials.AccessToken))
        } else {
            headers.add(.authorization(tokenUnauthenticated))
        }

        // 👉 Encode manualmente con JSONEncoder y opción sortedKeys
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys // ⚠️ esencial para orden alfabético
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = endpoint.keyEncodingStrategy
        do {
            let data = try encoder.encode(encodableParameters)
            
            let request = AF.request(
                url,
                method: method,
                parameters: nil,
                encoding: JSONDataEncoding(data: data), // usamos este encoding custom
                headers: headers
            )

            let response = await request
                .serializingResponse(using: .decodable(of: R.self, decoder: decoder))
                .response

            switch response.result {
            case .success(let value):
                return .success(value)
            case .failure(let error):
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
}

extension Network {
    enum ParametersDestination {
        case urlQueryString
        case jsonBody
        case methodDependant
    }

    private struct ServerError: Codable {
        let message: String
    }
    
    struct JSONDataEncoding: ParameterEncoding {
        private let data: Data

        init(data: Data) {
            self.data = data
        }

        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try urlRequest.asURLRequest()
            request.httpBody = data
            return request
        }
    }
}
