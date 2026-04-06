//
//  Network+Examens.swift
//  CareAssistance
//
//  Created by The App Master on 05/10/2023.
//

import Foundation
import Alamofire

extension Network {
    func getExams(accountId: String, from: String, until: String) async -> Result<MedicalExams, AppError> {
        await request(endpoint: .exams, parameters: [
            "paciente_id": accountId,
            "fecha_desde": from,
            "fecha_hasta": until
        ])
    }
    func postExams(examName: String, accountId: String, url1: String, url2: String, url3: String, url4: String, comment: String, id: String) async -> Result<Empty, AppError> {
        await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: [
                "Campo_1__c": "SERVICIO GENERICO EXAMENES DEL PACIENTE",
                "Campo_2__c": accountId,
                "Campo_3__c": examName,
                "Campo_4__c": url1,
                "Campo_5__c": url2,
                "Campo_6__c": url3,
                "Campo_7__c": url4,
                "Campo_8__c": comment,
                "Campo_9__c": id
            ])
    }
    func getPdf(pdfName: String) async -> Result<getPDFIn64, AppError> {
        await request(endpoint: .getFileFromS3, parameters: ["id": pdfName], parametersDestination: .urlQueryString)
    }
    func getPresignedUrl(objectKey: String, filename: String = "") async -> Result<PresignedURLResponse, AppError> {
        var params: [String: String] = ["object_key": objectKey]
        if !filename.isEmpty {
            params["filename"] = filename
        }
        return await request(method: .post, endpoint: .getPresignedUrl, parameters: params)
    }
    /// Obtiene ordenes de examenes automatizados via function_filter
    /// api_name: Examenes_Automatizados__c, filtro por Paciente__c
    /// Usa buildFunctionFilterJSON + requestWithRawBody para garantizar orden de keys y log raw
    func getAutomatedExamOrders(accountId: String) async -> Result<FunctionFilterAutoExamOrderResponse, AppError> {
        let filters: [AutomatedExamFilter] = [
            AutomatedExamFilter(fieldKey: "Paciente__c", fieldValue: accountId, match: "equal")
        ]
        let expectedFields = [
            "Id",
            "Name",
            "Nombre_Examen__c",
            "Profesional_Responsable__c",
            "CreatedById",
            "Descripcion__c",
            "CreatedDate",
            "URL_Orden_Medica_Real__c"
        ]

        guard let jsonData = buildFunctionFilterJSON(
            apiName: "Examenes_Automatizados__c",
            filters: filters,
            expectedFields: expectedFields
        ) else {
            print("   ❌ Error al construir JSON del request body")
            return .failure(AppError(id: "api.error.encode", name: "Encode", message: "Error al construir JSON del request body"))
        }

        // LOG request
        let fullUrl = baseUrlAuthenticated + "function_filter"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] getAutomatedExamOrders REQUEST")
        print("   URL: POST \(fullUrl)")
        print("   accountId: \(accountId)")
        if let rawString = String(data: jsonData, encoding: .utf8) {
            print("   REQUEST BODY RAW:")
            print("   \(rawString)")
        }
        if let rawJson = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: rawJson, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   REQUEST BODY (pretty):")
            print(prettyString)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // requestWithRawBody ya logea el RAW RESPONSE automaticamente
        let result: Result<FunctionFilterAutoExamOrderResponse, AppError> = await requestWithRawBody(
            method: .post,
            endpoint: .functionFilter,
            jsonData: jsonData
        )

        // LOG parsed response
        switch result {
        case .success(let response):
            let count = response.data?.first?.examenesAutomatizadosC.count ?? 0
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📡 [Network] getAutomatedExamOrders PARSED RESPONSE")
            print("   ✅ SUCCESS - statusCode: \(response.statusCode ?? -1)")
            print("   records count: \(count)")
            if let records = response.data?.first?.examenesAutomatizadosC {
                for (i, record) in records.enumerated() {
                    print("   [\(i)] Id=\(record.Id ?? "nil") Name=\"\(record.Name ?? "nil")\" CreatedDate=\(record.CreatedDate ?? "nil") URL=\(record.urlOrdenMedicaRealC?.prefix(50) ?? "nil")")
                }
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        case .failure(let error):
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📡 [Network] getAutomatedExamOrders PARSED RESPONSE")
            print("   ❌ ERROR: \(error.name) - \(error.message)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }

        return result
    }

    func getExamsForPatient(accountId: String) async -> Result<FunctionFilterExamResponse, AppError> {
        let filters: [AutomatedExamFilter] = [
            AutomatedExamFilter(fieldKey: "Paciente__c", fieldValue: accountId, match: "equal")
        ]
        let expectedFields = [
            "Id",
            "Paciente__c",
            "Nombre_del_Examen__c",
            "URL_Examen_1__c",
            "URL_Examen_2__c",
            "URL_Examen_3__c",
            "URL_Examen_4__c",
            "Comentarios__c",
            "CreatedDate",
            "Id_Orden_Medica__c"
        ]

        guard let jsonData = buildFunctionFilterJSON(
            apiName: "Examenes_del_Paciente__c",
            filters: filters,
            expectedFields: expectedFields
        ) else {
            return .failure(AppError(id: "api.error.encode", name: "Encode", message: "Error al construir JSON del request body"))
        }

        let fullUrl = baseUrlAuthenticated + "function_filter"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] getExamsForPatient REQUEST")
        print("   URL: POST \(fullUrl)")
        print("   accountId: \(accountId)")
        if let rawString = String(data: jsonData, encoding: .utf8) {
            print("   REQUEST BODY RAW: \(rawString)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // requestWithRawBody logea el RAW RESPONSE automaticamente
        let result: Result<FunctionFilterExamResponse, AppError> = await requestWithRawBody(
            method: .post,
            endpoint: .functionFilter,
            jsonData: jsonData
        )

        switch result {
        case .success(let response):
            let count = response.data?.first?.examenesDelPacienteC?.count ?? 0
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📡 [Network] getExamsForPatient PARSED RESPONSE")
            print("   ✅ SUCCESS - statusCode: \(response.statusCode ?? -1)")
            print("   records count: \(count)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        case .failure(let error):
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📡 [Network] getExamsForPatient ERROR")
            print("   ❌ \(error.name) - \(error.message)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }

        return result
    }
}
