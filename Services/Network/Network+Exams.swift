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
    /// POST /function_flows?api_name=Servicio_Generico__c
    /// Sube (o elimina si todas las URLs y nombres vienen vacíos) un examen del paciente.
    ///
    /// Contrato nuevo (12 campos), alineado con web/Android:
    ///  - Campo_3__c  : nombre del registro padre (ej. "EXÁMENES AUTOMATIZADOS 23/03/2026_2") — sin uppercase.
    ///  - Campo_4..7  : URLs S3 compactadas (los primeros N slots consecutivos, resto "").
    ///  - Campo_9__c  : idOrdenExamen SOLO si NO es Examen Automatizado (mutex con 12).
    ///  - Campo_10__c : nombres de los archivos unidos por ";" (mismo orden que las URLs), "" al eliminar.
    ///  - Campo_11__c : tipo de documento (picklist tal cual, sin uppercase).
    ///  - Campo_12__c : idOrdenExamen SOLO si SÍ es Examen Automatizado (mutex con 9).
    ///
    /// - Parameter urls: array compactado (sin huecos) de hasta 4 URLs S3.
    /// - Parameter nombresArchivos: nombres en el mismo orden que `urls`. Debe tener igual count.
    func postExams(
        accountId: String,
        nombreOrdenPadre: String,
        urls: [String],
        nombresArchivos: [String],
        tipoDocumentoPicklist: String,
        idOrdenExamen: String,
        esExamenAutomatizado: Bool
    ) async -> Result<Empty, AppError> {
        // Mutex Campo_9__c ⇄ Campo_12__c
        let campo9  = esExamenAutomatizado ? "" : idOrdenExamen
        let campo12 = esExamenAutomatizado ? idOrdenExamen : ""

        // Padding del array a 4 slots para mapear a Campo_4..7
        var urlsPadded = urls
        while urlsPadded.count < 4 { urlsPadded.append("") }
        if urlsPadded.count > 4 {
            print("⚠️ [SubirExamen] urls.count > 4 (\(urls.count)) — se truncará a 4.")
            urlsPadded = Array(urlsPadded.prefix(4))
        }

        // Campo_10__c: nombres unidos por ";"
        let campo10 = nombresArchivos.joined(separator: ";")

        let parameters: [String: Any] = [
            "Campo_1__c":  "SERVICIO GENERICO EXAMENES DEL PACIENTE",
            "Campo_2__c":  accountId,
            "Campo_3__c":  nombreOrdenPadre,
            "Campo_4__c":  urlsPadded[0],
            "Campo_5__c":  urlsPadded[1],
            "Campo_6__c":  urlsPadded[2],
            "Campo_7__c":  urlsPadded[3],
            "Campo_8__c":  "",
            "Campo_9__c":  campo9,
            "Campo_10__c": campo10,
            "Campo_11__c": tipoDocumentoPicklist,
            "Campo_12__c": campo12
        ]

        // LOG estructurado del request (parity con Android tag SubirExamen)
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [SubirExamen] postExams REQUEST")
        print("   tipoDocumento (Campo_11__c): \"\(tipoDocumentoPicklist)\"")
        print("   esExamenAutomatizado: \(esExamenAutomatizado)")
        print("   nombreOrdenPadre (Campo_3__c): \"\(nombreOrdenPadre)\"")
        print("   archivos count: \(urls.count)")
        print("   nombresArchivos (Campo_10__c): \"\(campo10)\"")
        print("   idOrdenExamen → \(esExamenAutomatizado ? "Campo_12__c" : "Campo_9__c") = \"\(idOrdenExamen)\"")
        print("   urls compactadas: \(urls)")
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
            print("📤 [SubirExamen] postExams ✅ OK")
        case .failure(let error):
            print("📤 [SubirExamen] postExams ❌ \(error.name) - \(error.message)")
        }
        return result
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

    /// DELETE /function_flows?api_name=Servicio_Generico__c
    /// Elimina un examen del paciente por su ID de Salesforce.
    ///
    /// Contrato (3 campos):
    ///  - Campo_1__c: "ELIMINAR EXAMEN DEL PACIENTE" (literal fijo)
    ///  - Campo_2__c: ID del registro Salesforce del examen a eliminar
    ///  - Campo_3__c: "" (vacío, requerido por el tipo)
    func deletePatientExam(examId: String) async -> Result<Empty, AppError> {
        let parameters: [String: Any] = [
            "Campo_1__c": "ELIMINAR EXAMEN DEL PACIENTE",
            "Campo_2__c": examId,
            "Campo_3__c": ""
        ]

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🗑️ [EliminarExamen] deletePatientExam REQUEST")
        print("   examId (Campo_2__c): \"\(examId)\"")
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
            print("🗑️ [EliminarExamen] deletePatientExam ✅ OK — examId: \(examId)")
        case .failure(let error):
            print("🗑️ [EliminarExamen] deletePatientExam ❌ \(error.name) - \(error.message)")
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
            "Id_Orden_Medica__c",
            "Id_Examenes_Automatizados__c",
            "Tipo_de_Archivo__c"
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
