//
//  Field.swift
//  CareAssistance
//
//  Created by Lara Dubs on 03/08/2022.
//

import SwiftUI

struct Field: Identifiable {
    let id: String
    let description: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    var value: String?
    let validations: [Validation]

    var isValid: Bool {
        !(value ?? "").isEmpty && validationErrorMessage == nil
    }

    var validationErrorMessage: String? {
        guard let value = value, !value.isEmpty else {
            return nil
        }
        return validations.first(where: { !$0.evaluate(value) })?.errorMessage
    }
    
    init(id: String, description: String, validations: [Validation] = [], isSecure: Bool = false, keyboardType: UIKeyboardType = .default, value: String? = nil) {
        self.id = id
        self.description = description
        self.validations = validations
        self.value = value
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }
}

extension Field {
    static var identificationNumber: Self {
        identificationNumber(value: nil)
    }

    static func identificationNumber(value: String?) -> Self {
#if Premedic
        .init(id: #function, description: "Número de documento", value: value)
        
#else
        .init(id: #function, description: "Número de identificación", value: value)
#endif
    }

    static var name: Self {
        .init(id: "name", description: "Nombre")
    }
    
    static var lastName: Self {
        .init(id: #function, description: "Apellidos")
    }
    
    static var rutAccountHolder: Self {
        .init(id: #function, description: "Número de identificación del titular")
    }
    
    static var email: Self {
        .init(id: #function, description: "Email", validations: [.email], keyboardType: .emailAddress)
    }
    
    static var phone: Self {
        .init(id: #function, description: "Móvil", validations: [.phone])
    }

    static var password: Self {
        .init(id: #function, description: "Contraseña", validations: [], isSecure: true)
    }
    
    static var passwordCreate: Self {
        .init(id: #function, description: "Crear contraseña", validations: [.password], isSecure: true)
    }
    
    static var oldPassword: Self {
        .init(id: #function, description: "Contraseña actual", validations: [], isSecure: true)
    }
    
    static var newPassword: Self {
        .init(id: #function, description: "Nueva contraseña", validations: [], isSecure: true)
    }


    static var passwordConfirm: Self {
        .init(id: #function, description: "Confirmar contraseña", validations: [.password], isSecure: true)
    }

    static var enterprise: Self {
        .init(id: #function, description: "Empresa")
    }
}
