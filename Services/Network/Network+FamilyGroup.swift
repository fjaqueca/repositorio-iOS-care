//
//  Network+FamilyGroup.swift
//  CareAssistance
//
//  Created by Care Assistance on 14/04/2026.
//

import Foundation
import Alamofire

extension Network {

    // MARK: - Servicio 1: Listar miembros del grupo familiar

    /// Obtiene las cargas activas del grupo familiar del titular via function_filter.
    /// Objeto: EmpresaContactoConvenios__c con nested Paciente__r
    /// Filtros: N_Documento_Titular__c=rut, Empresa__c=empresa,
    ///          Relaci_n_Con_Asegurado__c="Carga", Activo__c=true
    func getFamilyGroupMembers(rut: String, empresa: String) async -> Result<FamilyGroupResponse, AppError> {
        let filters: [AutomatedExamFilter] = [
            AutomatedExamFilter(fieldKey: "N_Documento_Titular__c", fieldValue: rut, match: "equal"),
            AutomatedExamFilter(fieldKey: "Empresa__c", fieldValue: empresa, match: "equal"),
            AutomatedExamFilter(fieldKey: "Relaci_n_Con_Asegurado__c", fieldValue: "Carga", match: "equal"),
            AutomatedExamFilter(fieldKey: "Activo__c", fieldValue: true, match: "equal")
        ]
        let expectedFields = [
            "Paciente__c",
            "Id",
            "Paciente__r.FirstName",
            "Paciente__r.LastName",
            "Paciente__r.IdentificationId__pc",
            "Paciente__r.PersonEmail",
            "Paciente__r.Phone",
            "Paciente__r.BillingStreet",
            "Paciente__r.PersonBirthdate",
            "Paciente__r.HealthCloudGA__Gender__pc"
        ]

        guard let jsonData = buildFunctionFilterJSON(
            apiName: "EmpresaContactoConvenios__c",
            filters: filters,
            expectedFields: expectedFields
        ) else {
            return .failure(AppError(id: "api.error.encode", name: "Encode", message: "Error al construir JSON del request body"))
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] getFamilyGroupMembers REQUEST")
        print("   rut: \(rut)")
        print("   empresa: \(empresa)")
        print("   api_name: EmpresaContactoConvenios__c")
        if let rawString = String(data: jsonData, encoding: .utf8) {
            print("   REQUEST BODY RAW: \(rawString)")
        }
        if let rawJson = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: rawJson, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   REQUEST BODY (pretty):")
            print(prettyString)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<FamilyGroupResponse, AppError> = await requestWithRawBody(
            method: .post,
            endpoint: .functionFilter,
            jsonData: jsonData
        )

        switch result {
        case .success(let response):
            let members = response.data?.first?.values.first ?? []
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("👨‍👩‍👧 [GrupoFamiliar] getFamilyGroupMembers ✅ \(members.count) miembros")
            for (i, m) in members.enumerated() {
                print("   [\(i)] ECC_Id=\(m.Id ?? "") Paciente__c=\(m.pacienteC ?? "") \(m.fullName) rut=\(m.rut) email=\(m.email)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        case .failure(let error):
            print("👨‍👩‍👧 [GrupoFamiliar] getFamilyGroupMembers ❌ \(error.name) - \(error.message)")
        }

        return result
    }

    // MARK: - Servicio 3: Editar miembro del grupo familiar

    /// Modifica datos de un miembro del grupo familiar via function_flows.
    /// Campo_1__c = "MODIFICAR DATOS GRUPO FAMILIAR"
    /// Campo_2__c = Paciente__c (ID de la cuenta paciente, NO el Id del ECC)
    func editFamilyGroupMember(
        pacienteId: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        birthdate: String,
        address: String,
        gender: String
    ) async -> Result<Empty, AppError> {
        let parameters: [String: Any] = [
            "Campo_1__c": "MODIFICAR DATOS GRUPO FAMILIAR",
            "Campo_2__c": pacienteId,
            "Campo_3__c": firstName,
            "Campo_4__c": lastName,
            "Campo_5__c": email,
            "Campo_6__c": phone,
            "Campo_7__c": address,
            "Campo_8__c": birthdate,
            "Campo_9__c": gender
        ]

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] editFamilyGroupMember REQUEST")
        print("   Paciente__c (Campo_2__c): \(pacienteId)")
        print("   nombre: \(firstName) \(lastName)")
        print("   email: \(email) phone: \(phone)")
        print("   birthdate: \(birthdate) gender: \(gender) address: \(address)")
        if let prettyData = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   REQUEST BODY (pretty):")
            print(prettyString)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<Empty, AppError> = await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: parameters
        )

        switch result {
        case .success:
            print("👨‍👩‍👧 [GrupoFamiliar] editFamilyGroupMember ✅ OK")
        case .failure(let error):
            print("👨‍👩‍👧 [GrupoFamiliar] editFamilyGroupMember ❌ \(error.name) - \(error.message)")
        }
        return result
    }

    // MARK: - Servicio 4: Eliminar miembro del grupo familiar

    /// Da de baja una carga del grupo familiar via function_flows.
    /// Campo_1__c = "BAJA CARGA GRUPO FAMILIAR"
    /// Campo_2__c = Id del registro EmpresaContactoConvenios__c (NO Paciente__c)
    func deleteFamilyGroupMember(eccId: String) async -> Result<Empty, AppError> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fechaBaja = formatter.string(from: Date())

        let parameters: [String: Any] = [
            "Campo_1__c": "BAJA CARGA GRUPO FAMILIAR",
            "Campo_2__c": eccId,
            "Campo_3__c": fechaBaja,
            "Campo_4__c": "App iOS",
            "Campo_5__c": "CareAssistance"
        ]

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] deleteFamilyGroupMember REQUEST")
        print("   ECC Id (Campo_2__c): \(eccId)")
        print("   fechaBaja: \(fechaBaja)")
        if let prettyData = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   REQUEST BODY (pretty):")
            print(prettyString)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<Empty, AppError> = await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: parameters
        )

        switch result {
        case .success:
            print("👨‍👩‍👧 [GrupoFamiliar] deleteFamilyGroupMember ✅ OK — eccId: \(eccId)")
        case .failure(let error):
            print("👨‍👩‍👧 [GrupoFamiliar] deleteFamilyGroupMember ❌ \(error.name) - \(error.message)")
        }
        return result
    }
}
