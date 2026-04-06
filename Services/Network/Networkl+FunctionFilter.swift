//
//  Networkl+FunctionFilter.swift
//  CareAssistance
//
//  Creado por The App Master el 10/02/2025.
//

import Foundation
import Alamofire

extension Network {
    // Obtiene acuerdo por defecto a partir del RUT usando function_filter
    func getDefaultAgreement(rut: String) async -> Result<FunctionFilterResponse, AppError> {
        // Importante: este diccionario debe usar sintaxis válida de Swift (no JSON crudo)
        let parameters: [String: Any] = [
            "data": [
                [
                    "api_name": "Account",
                    "filters": [
                        [
                            "IdentificationId__pc": rut,
                            "match": "equal"
                        ]
                    ],
                    "expected_fields": [
                        "FirstName",
                        "LastName",
                        "PersonBirthdate",
                        "HealthCloudGA__Gender__pc",
                        "PersonEmail",
                        "IdentificationId__pc",
                        "BillingStreet",
                        "Beneficio_Yapp_Activo__c",
                        "Acompanamiento_Integral__c",
                        "EmpresaActual__c",
                        "Oncologico_Activo__c"
                    ]
                ]
            ]
        ]
        
        return await request(method: .post, endpoint: .functionFilter, parameters: parameters)
    }
    
    // Obtiene datos del perfil del paciente (FirstName, LastName, PersonBirthdate, etc.)
    // Réplica de getDefaultAgreement pero uso exclusivo para datos personales del paciente
    func getProfileFields(rut: String) async -> Result<FunctionFilterResponse, AppError> {
        let parameters: [String: Any] = [
            "data": [
                [
                    "api_name": "Account",
                    "filters": [
                        [
                            "IdentificationId__pc": rut,
                            "match": "equal"
                        ]
                    ],
                    "expected_fields": [
                        "FirstName",
                        "LastName",
                        "PersonBirthdate",
                        "HealthCloudGA__Gender__pc",
                        "PersonEmail",
                        "IdentificationId__pc",
                        "BillingStreet",
                        "Beneficio_Yapp_Activo__c",
                        "Acompanamiento_Integral__c",
                        "EmpresaActual__c",
                        "Oncologico_Activo__c"
                    ]
                ]
            ]
        ]

        return await request(method: .post, endpoint: .functionFilter, parameters: parameters)
    }

    func getActivityCompletions(id_activity: String) async -> Result<FunctionFilterResponse2, AppError> {
        // Importante: este diccionario debe usar sintaxis válida de Swift (no JSON crudo)
        let parameters: [String: Any] = [
            "data": [
                [
                    "api_name": "Task_Completion_Template__c",
                    "filters": [
                        [
                            "Actividad__c": id_activity,
                            "match": "equal"
                        ]
                    ],
                    "expected_fields": [
                        "Name",
                        "Id",
                        "CreatedDate",
                        "Editable__c",
                        "Contabilizable_para_escolares__c",
                        "Tipo_de_Datos__c",
                        "Posibles_Valores__c",
                        "Agrupamiento__c",
                        "Orden_de_visibilidad__c",
                        "Requerido__c",
                        "Concatenacion_Picklist_Enrolamiento__c",
                        "Concatenacion_Picklist_Template__c",
                        "Concatenacion_Picklist__c",
                        "Nombre_Personalizado__c",
                        "Nombre_de_la_Actividad__c"
                    ]
                ],
                [
                    "api_name": "Task_Completion__c",
                    "filters": [
                        [
                            "Actividad__c": id_activity,
                            "match": "equal"
                        ]
                    ],
                    "expected_fields": [
                        "Name",
                        "Id",
                        "CreatedDate",
                        "Valor_de_respuesta__c",
                        "Tipo_de_Datos__c",
                        "Nombre_Personalizado__c",
                        "Nombre_de_la_Actividad__c"
                    ]
                ],
                
            ]
        ]
        
        return await request(method: .post, endpoint: .functionFilter, parameters: parameters)
    }
    
    // NUEVO: Consulta de ficha clínica general por Account__c usando function_filter
    func fichaClinicaGeneralService(accountId: String) async -> Result<FunctionFilterResponse2, AppError> {
        // Logs de inicio
        print("🩺 [FunctionFilter] Iniciando fichaClinicaGeneralService con Account__c: \(accountId)")
        
        let parameters: [String: Any] = [
            "data": [
                [
                    "api_name": "Ficha_Clinica_General__c",
                    "filters": [
                        [
                            "Account__c": accountId,
                            "match": "equal"
                        ]
                    ],
                    "expected_fields": [
                        "Name",
                        "Id",
                        "Account__c",
                        "Canal__c"
                    ]
                ]
            ]
        ]
        
        // Debug: cuerpo del request
        if let data = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted]),
           let jsonBody = String(data: data, encoding: .utf8) {
            print("📤 [FunctionFilter] Body fichaClinicaGeneralService:\n\(jsonBody)")
        }
        
        let result: Result<FunctionFilterResponse2, AppError> = await request(
            method: .post,
            endpoint: .functionFilter,
            parameters: parameters
        )
        
        // Logs del resultado
        switch result {
        case .success(let response):
            let totalBlocks = response.data.count
            print("✅ [FunctionFilter] fichaClinicaGeneralService OK. Bloques en data: \(totalBlocks)")
            if let first = response.data.first {
                let count = first["Ficha_Clinica_General__c"]?.count ?? -1
                print("📦 [FunctionFilter] Ficha_Clinica_General__c count: \(count)")
            } else {
                print("ℹ️ [FunctionFilter] data.first es nil")
            }
        case .failure(let error):
            print("❌ [FunctionFilter] Error en fichaClinicaGeneralService: \(error)")
        }
        
        return result
    }
}
