//
//  Network+AutomatedExams.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import Foundation
import Alamofire

// MARK: - Request Models para function_filter

/// Filtro individual: { "Campo__c": valor, "match": "equal" }
/// El campo de dato SIEMPRE va primero, match SIEMPRE al final (el backend parsea posicionalmente)
struct AutomatedExamFilter {
    let fieldKey: String
    let fieldValue: Any   // Bool o String
    let match: String
}

/// Construye el JSON del request body manualmente para garantizar orden estricto de keys.
/// JSONEncoder NO garantiza orden de keys en KeyedEncodingContainer.
/// El backend de Salesforce/Lambda parsea posicionalmente, por lo que el orden es crítico:
///   data[].api_name → filters → expected_fields
///   filters[].{campo} → match
func buildFunctionFilterJSON(
    apiName: String,
    filters: [AutomatedExamFilter],
    expectedFields: [String]
) -> Data? {
    // Construir cada filtro manualmente: campo primero, match último
    var filterStrings: [String] = []
    for filter in filters {
        let valueStr: String
        if let boolVal = filter.fieldValue as? Bool {
            valueStr = boolVal ? "true" : "false"
        } else if let strVal = filter.fieldValue as? String {
            // Escapar comillas en el string
            let escaped = strVal.replacingOccurrences(of: "\"", with: "\\\"")
            valueStr = "\"\(escaped)\""
        } else {
            valueStr = "null"
        }
        // Orden estricto: campo dinámico PRIMERO, match ÚLTIMO
        let filterJSON = "{\"\(filter.fieldKey)\":\(valueStr),\"match\":\"\(filter.match)\"}"
        filterStrings.append(filterJSON)
    }

    // Construir expected_fields
    let fieldsStr = expectedFields.map { "\"\($0)\"" }.joined(separator: ",")

    // Construir data item: api_name → filters → expected_fields (orden estricto)
    let filtersStr = filterStrings.joined(separator: ",")
    let dataItem = "{\"api_name\":\"\(apiName)\",\"filters\":[\(filtersStr)],\"expected_fields\":[\(fieldsStr)]}"

    // Body final
    let body = "{\"data\":[\(dataItem)]}"
    return body.data(using: .utf8)
}

// MARK: - Response Models para function_filter (Paso 3)

/// Response del endpoint function_filter para examenes automatizados
/// Estructura: { "statusCode": 200, "data": [ { "Lista_Examenes_Automaticos__c": [...] } ] }
struct AutomatedExamFilterResponse: Codable {
    let statusCode: Int?
    let data: [[String: [AutomatedExamRecord]]]?
}

/// Record individual de examen automatizado de Salesforce
struct AutomatedExamRecord: Codable, Identifiable, Hashable {
    var id: String { Id }
    let Id: String
    let Name: String?
    let Nombre_Examen__c: String?
    let Pais_Examen__c: String?
    let Sexo__c: String?
    let Tipo_de_Examen__c: String?
    let Edad_Inicio__c: String?
    let Edad_Fin__c: String?
    let attributes: AutomatedExamAttributes?

    // Hashable: excluir attributes
    static func == (lhs: AutomatedExamRecord, rhs: AutomatedExamRecord) -> Bool {
        lhs.Id == rhs.Id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(Id)
    }
}

struct AutomatedExamAttributes: Codable {
    let type: String?
    let url: String?
}

struct AutomatedExamGenerateResponse: Codable {
    let statusCode: Int?
    let message: String?
    let data: AutomatedExamGenerateData?
}

struct AutomatedExamGenerateData: Codable {
    let ordenId: String?
    let estado: String?

    enum CodingKeys: String, CodingKey {
        case ordenId = "OrdenId"
        case estado = "Estado"
    }
}

struct AutomatedExamGenericResponse: Codable {
    let statusCode: Int?
    let message: String?
    let success: Bool?
    let status: String?
    let id: String?
    let errors: [String]?

    var isSuccess: Bool {
        (success == true) || (status?.lowercased() == "success")
    }

    var errorMessage: String? {
        errors?.first ?? message
    }
}

// AutomatedExamLatestOrderResponse eliminado — ahora usa FunctionFilterAutoExamOrderResponse
// que devuelve records completos via function_filter (igual que Android)

// MARK: - Network Extension

extension Network {

    /// Paso 3: Busca examenes disponibles por categoria via function_filter
    /// Endpoint: POST /function_filter
    /// api_name: Lista_Examenes_Automaticos__c
    /// Filtros dinamicos: categoriaKey (ej: "Categoria_1__c" = true), paisExamen, tipoExamen
    func searchAutomatedExams(
        categoriaKey: String,
        paisExamen: String,
        tipoExamen: String
    ) async -> Result<AutomatedExamFilterResponse, AppError> {
        // Construir filtros con orden estricto: campo dinamico primero, luego match
        var filters: [AutomatedExamFilter] = [
            AutomatedExamFilter(fieldKey: categoriaKey, fieldValue: true, match: "equal")
        ]
        if !paisExamen.isEmpty {
            filters.append(AutomatedExamFilter(fieldKey: "Pais_Examen__c", fieldValue: paisExamen, match: "equal"))
        }
        if !tipoExamen.isEmpty {
            filters.append(AutomatedExamFilter(fieldKey: "Tipo_de_Examen__c", fieldValue: tipoExamen, match: "equal"))
        }

        let expectedFields = [
            "Edad_Fin__c",
            "Edad_Inicio__c",
            "Id",
            "Name",
            "Nombre_Examen__c",
            "Pais_Examen__c",
            "Sexo__c",
            "Tipo_de_Examen__c"
        ]

        // Construir JSON manualmente para garantizar orden estricto de keys
        guard let jsonData = buildFunctionFilterJSON(
            apiName: "Lista_Examenes_Automaticos__c",
            filters: filters,
            expectedFields: expectedFields
        ) else {
            print("   ❌ Error al construir JSON del request body")
            return .failure(AppError(id: "api.error.encode", name: "Encode", message: "Error al construir JSON del request body"))
        }

        // LOG detallado del request
        let fullUrl = baseUrlAuthenticated + "function_filter"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] searchAutomatedExams REQUEST")
        print("   URL: POST \(fullUrl)")
        print("   CategoriaKey: \(categoriaKey)")
        print("   PaisExamen: \"\(paisExamen)\"")
        print("   TipoExamen: \"\(tipoExamen)\"")
        print("   Filters count: \(filters.count)")
        // Log del JSON real que se enviará (pretty print manual)
        if let rawJson = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: rawJson, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   REQUEST BODY (pretty para log):")
            print(prettyString)
        }
        // Log del JSON RAW real (el que va al servidor)
        if let rawString = String(data: jsonData, encoding: .utf8) {
            print("   REQUEST BODY RAW (tal cual se envía):")
            print("   \(rawString)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // Usar requestWithRawBody para preservar el orden de keys
        let result: Result<AutomatedExamFilterResponse, AppError> = await requestWithRawBody(
            method: .post,
            endpoint: .functionFilter,
            jsonData: jsonData
        )

        // LOG detallado del response
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] searchAutomatedExams RESPONSE")
        switch result {
        case .success(let response):
            print("   ✅ SUCCESS")
            if let dataArray = response.data {
                print("   data.count: \(dataArray.count)")
                for (i, dict) in dataArray.enumerated() {
                    for (key, records) in dict {
                        print("   data[\(i)][\"\(key)\"]: \(records.count) records")
                        for (j, rec) in records.enumerated() {
                            print("      [\(j)] Id=\(rec.Id) Name=\"\(rec.Name ?? "")\" NombreExamen=\"\(rec.Nombre_Examen__c ?? "")\" Sexo=\(rec.Sexo__c ?? "N/A") Edad=\(rec.Edad_Inicio__c ?? "0")-\(rec.Edad_Fin__c ?? "999") Pais=\(rec.Pais_Examen__c ?? "") Tipo=\(rec.Tipo_de_Examen__c ?? "")")
                        }
                    }
                }
            } else {
                print("   ⚠️ data es nil")
            }
        case .failure(let error):
            print("   ❌ ERROR: \(error.name) - \(error.message)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
    }

    /// Paso 6: Actualiza datos personales del paciente
    /// Campo_1 = "ACTUALIZAR DATOS PERSONALES PACIENTE EXAMENES"
    func updatePatientDataForExams(
        accountId: String,
        nombre: String,
        apellido: String,
        fechaNacimiento: String,
        direccion: String
    ) async -> Result<AutomatedExamGenericResponse, AppError> {
        let params: [String: String] = [
            "Campo_1__c": "ACTUALIZAR DATOS PERSONALES PACIENTE EXAMENES",
            "Campo_2__c": accountId,
            "Campo_3__c": nombre,
            "Campo_4__c": apellido,
            "Campo_5__c": fechaNacimiento,
            "Campo_6__c": direccion
        ]

        let fullUrl = baseUrlAuthenticated + "function_flows?api_name=Servicio_Generico__c"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] updatePatientDataForExams REQUEST")
        print("   URL: POST \(fullUrl)")
        for (key, value) in params.sorted(by: { $0.key < $1.key }) {
            print("   \(key): \"\(value)\"")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<AutomatedExamGenericResponse, AppError> = await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: params
        )

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] updatePatientDataForExams RESPONSE")
        switch result {
        case .success(let response):
            print("   success: \(response.success ?? false)")
            print("   status: \"\(response.status ?? "(nil)")\"")
            print("   id: \"\(response.id ?? "(nil)")\"")
            print("   isSuccess: \(response.isSuccess)")
            print("   statusCode: \(response.statusCode ?? -1)")
            print("   message: \"\(response.message ?? "(nil)")\"")
            if let errors = response.errors, !errors.isEmpty {
                print("   errors: \(errors)")
            }
        case .failure(let error):
            print("   ❌ HTTP ERROR: \(error.name) - \(error.message)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
    }

    /// Paso 8: Actualiza correo del paciente para examenes
    /// Campo_1 = "ACTUALIZAR CORREO PACIENTE POR EXAMENES AUTOMATIZADOS"
    func updateEmailForExams(
        accountId: String,
        email: String
    ) async -> Result<AutomatedExamGenericResponse, AppError> {
        let params: [String: String] = [
            "Campo_1__c": "ACTUALIZAR CORREO PACIENTE POR EXAMENES AUTOMATIZADOS",
            "Paciente__c": accountId,
            "Campo_2__c": accountId,
            "Campo_3__c": email
        ]

        let fullUrl = baseUrlAuthenticated + "function_flows?api_name=Servicio_Generico__c"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] updateEmailForExams REQUEST")
        print("   URL: POST \(fullUrl)")
        for (key, value) in params.sorted(by: { $0.key < $1.key }) {
            print("   \(key): \"\(value)\"")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<AutomatedExamGenericResponse, AppError> = await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: params
        )

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] updateEmailForExams RESPONSE")
        switch result {
        case .success(let response):
            print("   ✅ SUCCESS - statusCode: \(response.statusCode ?? -1) message: \(response.message ?? "(nil)")")
        case .failure(let error):
            print("   ❌ ERROR: \(error.name) - \(error.message)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
    }

    /// Paso 10: Genera una orden de examenes automatizados
    /// Campo_1 = "GENERAR ORDEN DE EXAMEN AUTOMATIZADO"
    /// Los examenes se envian agrupados por categoria en Campo_6..Campo_37
    /// Fórmula: Categoria_N → Campo_(N+5)__c
    /// Formato: "NombreCategoria;examId1;examId2;..."
    func generateAutomatedExams(
        accountId: String,
        cartItems: [ExamenItem]
    ) async -> Result<AutomatedExamGenerateResponse, AppError> {
        let convenioId = AppStatusManager.selectedEnterprise?.Id ?? ""

        // Agrupar items por categoriaNum
        var grouped: [Int: (name: String, ids: [String])] = [:]
        for item in cartItems {
            let num = item.categoriaNum
            if grouped[num] == nil {
                grouped[num] = (name: item.categoria, ids: [])
            }
            grouped[num]!.ids.append(item.codigo)
        }

        // Construir params base
        var params: [String: Any] = [
            "Campo_1__c": "GENERAR ORDEN DE EXAMEN AUTOMATIZADO",
            "Campo_2__c": accountId,
            "Paciente__c": accountId,
            "Campo_3__c": convenioId,
            "Campo_4__c": "App Mobile iOS",
            "Campo_5__c": "CareAssistance"
        ]

        // Mapear Categoria_N → Campo_(N+5)__c (N=1..32 → Campo_6..37)
        for n in 1...32 {
            let campoKey = "Campo_\(n + 5)__c"
            if let cat = grouped[n] {
                // "NombreCategoria;id1;id2;..."
                let value = ([cat.name] + cat.ids).joined(separator: ";")
                params[campoKey] = value
            } else {
                params[campoKey] = NSNull()
            }
        }

        let fullUrl = baseUrlAuthenticated + "function_flows?api_name=Servicio_Generico__c"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] generateAutomatedExams REQUEST")
        print("   URL: POST \(fullUrl)")
        print("   AccountId: \(accountId)")
        print("   ConvenioId: \(convenioId)")
        print("   CartItems: \(cartItems.count)")
        print("   Categorias agrupadas: \(grouped.count)")
        for (num, cat) in grouped.sorted(by: { $0.key < $1.key }) {
            print("   Categoria_\(num) → Campo_\(num + 5)__c = \"\(cat.name);\(cat.ids.joined(separator: ";"))\"")
        }
        if let prettyData = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   REQUEST BODY (pretty):")
            print(prettyString)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<AutomatedExamGenerateResponse, AppError> = await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: params
        )

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] generateAutomatedExams RESPONSE")
        switch result {
        case .success(let response):
            print("   ✅ SUCCESS - statusCode: \(response.statusCode ?? -1) message: \(response.message ?? "(nil)")")
            print("   OrdenId: \(response.data?.ordenId ?? "(nil)")")
            print("   Estado: \(response.data?.estado ?? "(nil)")")
        case .failure(let error):
            print("   ❌ ERROR: \(error.name) - \(error.message)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
    }

    /// Paso 10 (post-generacion): Busca la orden mas reciente del paciente para obtener la URL del PDF
    /// Busca la orden de examen automatizado más reciente del paciente via function_filter
    /// Usa el mismo endpoint y modelo que getAutomatedExamOrders (como Android)
    /// Retorna la URL del PDF de la orden más reciente
    func getLatestAutomatedExamOrder(accountId: String) async -> Result<FunctionFilterAutoExamOrderResponse, AppError> {
        let filters: [AutomatedExamFilter] = [
            AutomatedExamFilter(fieldKey: "Paciente__c", fieldValue: accountId, match: "equal")
        ]
        let expectedFields = [
            "Id",
            "Name",
            "Nombre_Examen__c",
            "CreatedDate",
            "URL_Orden_Medica_Real__c"
        ]

        guard let jsonData = buildFunctionFilterJSON(
            apiName: "Examenes_Automatizados__c",
            filters: filters,
            expectedFields: expectedFields
        ) else {
            return .failure(AppError(id: "api.error.encode", name: "Encode", message: "Error al construir JSON del request body"))
        }

        let fullUrl = baseUrlAuthenticated + "function_filter"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] getLatestAutomatedExamOrder REQUEST (function_filter)")
        print("   URL: POST \(fullUrl)")
        print("   accountId: \(accountId)")
        if let rawString = String(data: jsonData, encoding: .utf8) {
            print("   REQUEST BODY RAW: \(rawString)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<FunctionFilterAutoExamOrderResponse, AppError> = await requestWithRawBody(
            method: .post,
            endpoint: .functionFilter,
            jsonData: jsonData
        )

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [Network] getLatestAutomatedExamOrder RESPONSE")
        switch result {
        case .success(let response):
            let records = response.data?.first?.examenesAutomatizadosC ?? []
            print("   ✅ SUCCESS - statusCode: \(response.statusCode ?? -1)")
            print("   Records count: \(records.count)")
            if let latest = records.sorted(by: { ($0.CreatedDate ?? "") > ($1.CreatedDate ?? "") }).first {
                print("   Latest: Id=\(latest.Id ?? "(nil)") CreatedDate=\(latest.CreatedDate ?? "(nil)") URL_PDF=\"\(latest.urlOrdenMedicaRealC?.prefix(80) ?? "(nil)")\"")
            }
        case .failure(let error):
            print("   ❌ ERROR: \(error.name) - \(error.message)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
    }
}
