//
//  FunctionFilter.swift
//  CareAssistance
//
//  Created by The App Master on 10/02/2025.
//

import Foundation

struct FunctionFilterResponse: Codable {
    let statusCode: Int?
    let data: [AccountFilter]
    
    
    struct AccountFilter: Codable {
        let Account: [CompanyFilter?]
    }
    
    struct CompanyFilter: Codable{
        let attributes: Attributes
        let empresaactualC: String?
        let Id: String?
        let beneficioYappActivoC: Bool?
        let acompanamientoIntegralC: Bool?
    }

}


struct FunctionFilterResponse2: Codable {
    let statusCode: Int?
    let data: [[String: [CompanyFilter]]]
    
    struct CompanyFilter: Codable {
        let attributes: Attributes3?
        let Id: String?
        let name: String?
        let createdDate: String?
        
        // Campos de Template
        let editableC: Bool?
        let contabilizableParaEscolaresC: Bool?
        let tipoDeDatosC: String?
        let agrupamientoC: Float?
        let ordenDeVisibilidadC: Float?
        let requeridoC: Bool?
        let nombrePersonalizadoC: String?
        let nombreDeLaActividadC: String?
        let posiblesValoresC: String?
        let concatenacionPicklistEnrolamientoC: String?
        let concatenacionPicklistTemplateC: String?
        let concatenacionPicklistC: String?
        
        // Campos de Completion
        let valorDeRespuestaC: String?

        // 1. CodingKeys con los nombres EXACTOS de Salesforce para el Print
        enum CodingKeys: String, CodingKey {
            case attributes, Id
            case name = "Name"
            case createdDate = "CreatedDate"
            case editableC = "Editable__c"
            case contabilizableParaEscolaresC = "Contabilizable_para_escolares__c"
            case tipoDeDatosC = "Tipo_de_Datos__c"
            case agrupamientoC = "Agrupamiento__c"
            case ordenDeVisibilidadC = "Orden_de_visibilidad__c"
            case requeridoC = "Requerido__c"
            case nombrePersonalizadoC = "Nombre_Personalizado__c"
            case nombreDeLaActividadC = "Nombre_de_la_Actividad__c"
            case posiblesValoresC = "Posibles_Valores__c"
            case concatenacionPicklistEnrolamientoC = "Concatenacion_Picklist_Enrolamiento__c"
            case concatenacionPicklistTemplateC = "Concatenacion_Picklist_Template__c"
            case concatenacionPicklistC = "Concatenacion_Picklist__c"
            case valorDeRespuestaC = "Valor_de_respuesta__c"
        }

        struct DynamicKeys: CodingKey {
            var stringValue: String
            var intValue: Int?
            init?(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { return nil }
        }

        // INIT (Detective): Mantiene la robustez para leer el JSON
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dynamicContainer = try decoder.container(keyedBy: DynamicKeys.self)
            let allKeys = dynamicContainer.allKeys

            self.attributes = try container.decodeIfPresent(Attributes3.self, forKey: .attributes)
            self.Id = try container.decodeIfPresent(String.self, forKey: .Id)

            func findValue<T: Decodable>(_ target: String) -> T? {
                let targetClean = target.lowercased().replacingOccurrences(of: "_", with: "")
                if let foundKey = allKeys.first(where: {
                    let currentKey = $0.stringValue.lowercased().replacingOccurrences(of: "_", with: "")
                    return currentKey == targetClean
                }) {
                    return try? dynamicContainer.decodeIfPresent(T.self, forKey: foundKey)
                }
                return nil
            }

            self.name = findValue("Name")
            self.createdDate = findValue("CreatedDate")
            self.tipoDeDatosC = findValue("Tipo_de_Datos__c")
            self.nombreDeLaActividadC = findValue("Nombre_de_la_Actividad__c")
            self.editableC = findValue("Editable__c")
            self.contabilizableParaEscolaresC = findValue("Contabilizable_para_escolares__c")
            self.agrupamientoC = findValue("Agrupamiento__c")
            self.ordenDeVisibilidadC = findValue("Orden_de_visibilidad__c")
            self.requeridoC = findValue("Requerido__c")
            self.nombrePersonalizadoC = findValue("Nombre_Personalizado__c")
            self.posiblesValoresC = findValue("Posibles_Valores__c")
            self.concatenacionPicklistEnrolamientoC = findValue("Concatenacion_Picklist_Enrolamiento__c")
            self.concatenacionPicklistTemplateC = findValue("Concatenacion_Picklist_Template__c")
            self.concatenacionPicklistC = findValue("Concatenacion_Picklist__c")
            self.valorDeRespuestaC = findValue("Valor_de_respuesta__c")
        }

        // ENCODE: Esto es lo que hace que el PRINT se vea bonito y original
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(attributes, forKey: .attributes)
            try container.encodeIfPresent(Id, forKey: .Id)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encodeIfPresent(createdDate, forKey: .createdDate)
            try container.encodeIfPresent(tipoDeDatosC, forKey: .tipoDeDatosC)
            try container.encodeIfPresent(nombreDeLaActividadC, forKey: .nombreDeLaActividadC)
            try container.encodeIfPresent(agrupamientoC, forKey: .agrupamientoC)
            try container.encodeIfPresent(contabilizableParaEscolaresC, forKey: .contabilizableParaEscolaresC)
            try container.encodeIfPresent(ordenDeVisibilidadC, forKey: .ordenDeVisibilidadC)
            try container.encodeIfPresent(nombrePersonalizadoC, forKey: .nombrePersonalizadoC)
            try container.encodeIfPresent(concatenacionPicklistEnrolamientoC, forKey: .concatenacionPicklistEnrolamientoC)
            try container.encodeIfPresent(concatenacionPicklistTemplateC, forKey: .concatenacionPicklistTemplateC)
            
            
            
            // Solo codifica si el valor no es nil (mantiene el print limpio)
            if editableC != nil { try container.encodeIfPresent(editableC, forKey: .editableC) }
            if requeridoC != nil { try container.encodeIfPresent(requeridoC, forKey: .requeridoC) }
            if valorDeRespuestaC != nil { try container.encodeIfPresent(valorDeRespuestaC, forKey: .valorDeRespuestaC) }
            // ... repetir para los demás campos si deseas verlos todos en el print
        }
    }
}

// Asegúrate de tener esto definido en algún lugar de tu proyecto
struct Attributes3: Codable {
    let type: String?
    let url: String?
}

struct FunctionFilterExamResponse: Codable, Hashable {
    let statusCode: Int?
    let data: [PatientFilter]
    
    
    struct PatientFilter: Codable, Hashable {
        let examenesDelPacienteC: [PatientExams]
    }
    
    struct PatientExams: Codable, Hashable {
        let attributes: Attribute?
        let pacienteC: String?
        let Id: String?
        let nombreDelExamenC: String?
        let urlExamen1C: String?
        let urlExamen2C: String?
        let urlExamen3C: String?
        let urlExamen4C: String?
        let comentariosC: String?
        let CreatedDate: String?
        let idOrdenMedicaC: String?
        
    }
}

struct Filter: Encodable {
    let paciente: String
    let match: String

    enum CodingKeys: String, CodingKey {
        case paciente = "Paciente__c"
        case match
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Orden forzado
        try container.encode(paciente, forKey: .paciente)
        try container.encode(match, forKey: .match)
    }
}


struct DataObject: Encodable {
    let apiName: String
    let expectedFields: [String]
    let filters: [Filter]
    enum CodingKeys: String, CodingKey {
        case apiName = "api_name"
        case expectedFields = "expected_fields"
        case filters
    }
}

struct RequestBody: Encodable {
    let data: [DataObject]
}




