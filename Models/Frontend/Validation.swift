//
//  Validation.swift
//  CareAssistance
//
//  Created by Lara Dubs on 03/08/2022.
//

import SwiftUI

struct Validation {
    let regex: String
    let errorMessage: String

    func evaluate(_ value: String) -> Bool {
        value.range(of: regex, options: .regularExpression) != nil
    }
}

extension Validation {
    static var email: Self {
        .init(
            regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
            errorMessage: "El campo ingresado no es un email válido."
        )
    }

    static var phone: Self {
        .init(
            regex: "^[0-9+]{0,1}+[0-9]{5,16}$",
              errorMessage: "El campo ingresado no es un telefono válido."
        )
    }
    
    static var password: Self {
        .init(
            regex: "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$%^&*()_+\\-={}\\[\\]:;\"'<>,.?/]).{8,25}$",
            errorMessage: "El campo ingresado no es una contraseña válida."
        )
    }
}


