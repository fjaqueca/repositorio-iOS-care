//
//  AppError.swift
//  CareAssistance
//
//  Created by Lara Dubs on 13/09/2022.
//

import Foundation

public struct AppError: Error, LocalizedError, Equatable {
    let id: String
    let name: String
    let message: String
    let httpCode: Int?

    public init(id: String, name: String, message: String, httpCode: Int? = nil) {
        self.id = id
        self.name = name
        self.message = message
        self.httpCode = httpCode
    }

    public var errorDescription: String? {
        name
    }

    public var failureReason: String? {
        message
    }
}

extension AppError {
    static var generic: Self {
        .init(id: "api.error.generic", name: "Se produjo un error.", message: "Por favor contactarse con \nAtención al Cliente.")
    }

    static var parsingError: Self {
        .init(id: "api.error.parsing", name: "Se produjo un error.", message: "Por favor contactarse con \nAtención al Cliente.")
    }
    
    static var unauthenticated: Self {
        .init(id: "api.error.unauthenticated", name: "", message: "Su sesión se cerró por seguridad. Por favor vuelva a loguearse.", httpCode: 403)
    }
    
    static var unauthorized: Self {
        .init(id: "api.error.unauthorized", name: "Se produjo un error.", message: "El usuario/contraseña es incorrecto.", httpCode: 401)
    }
}
