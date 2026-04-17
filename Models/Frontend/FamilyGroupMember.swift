//
//  FamilyGroupMember.swift
//  CareAssistance
//
//  Created by Care Assistance on 14/04/2026.
//

import Foundation

/// Modelo de un miembro del grupo familiar (carga) obtenido de Salesforce via function_filter.
/// Objeto: EmpresaContactoConvenios__c con nested Paciente__r
struct FamilyGroupMember: Codable, Identifiable, Hashable {
    let attributes: FamilyGroupAttribute?
    /// Id del registro EmpresaContactoConvenios__c (se usa para ELIMINAR)
    let Id: String?
    /// Id de la cuenta paciente (se usa para EDITAR)
    let pacienteC: String?
    /// Datos del paciente (nested relationship)
    let pacienteR: FamilyGroupPatient?

    var id: String { Id ?? UUID().uuidString }

    var firstName: String { pacienteR?.FirstName ?? "" }
    var lastName: String { pacienteR?.LastName ?? "" }
    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    var initials: String {
        let first = firstName.prefix(1).uppercased()
        let last = lastName.prefix(1).uppercased()
        return "\(first)\(last)"
    }
    var email: String { pacienteR?.PersonEmail ?? "" }
    var phone: String { pacienteR?.Phone ?? "" }
    var rut: String { pacienteR?.identificationIdPc ?? "" }
    var birthdate: String { pacienteR?.PersonBirthdate ?? "" }
    var address: String { pacienteR?.BillingStreet ?? "" }
    var gender: String { pacienteR?.healthCloudGenderPc ?? "" }

    enum CodingKeys: String, CodingKey {
        case attributes
        case Id
        case pacienteC = "Paciente__c"
        case pacienteR = "Paciente__r"
    }
}

/// Datos nested del paciente dentro de EmpresaContactoConvenios__c
struct FamilyGroupPatient: Codable, Hashable {
    let FirstName: String?
    let LastName: String?
    let identificationIdPc: String?
    let PersonEmail: String?
    let Phone: String?
    let BillingStreet: String?
    let PersonBirthdate: String?
    let healthCloudGenderPc: String?

    enum CodingKeys: String, CodingKey {
        case FirstName
        case LastName
        case identificationIdPc = "IdentificationId__pc"
        case PersonEmail
        case Phone
        case BillingStreet
        case PersonBirthdate
        case healthCloudGenderPc = "HealthCloudGA__Gender__pc"
    }
}

struct FamilyGroupAttribute: Codable, Hashable {
    let type: String?
    let url: String?
}

/// Response del function_filter para grupo familiar
struct FamilyGroupResponse: Codable {
    let statusCode: Int?
    let data: [[String: [FamilyGroupMember]]]?
}
