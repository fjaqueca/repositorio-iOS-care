//
//  Network+FichaClinicaGeneral.swift
//  CareAssistance
//
//  Created by Assistant on 11/03/2026.
//

import Foundation
import Alamofire

extension Network {
    /// Envía el formulario de Ficha Clínica General al servicio genérico
    /// - Parameters:
    ///   - nombreFlujo: Nombre del flujo de servicio (viene de Valor_1_7__c, ej: "SERVICIO GENERICO FICHA GENERAL CREAR")
    ///   - preguntas: Array de preguntas del formulario con sus respuestas
    ///   - formulario: Objeto completo del formulario con metadata
    /// - Returns: Respuesta genérica del servidor
    func postFichaClinicaGeneral(
        nombreFlujo: String,
        preguntas: [PreguntaFormulario],
        respuestas: [UUID: RespuestaPregunta]
    ) async -> Result<GenericSuccessResponse, AppError> {
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [FichaClinicaGeneral] Iniciando POST del formulario")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔹 Nombre del flujo: \(nombreFlujo)")
        print("🔹 Total de preguntas: \(preguntas.count)")
        
        // Obtener account_id del usuario
        let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
        guard !accountId.isEmpty else {
            print("❌ [FichaClinicaGeneral] account_id vacío")
            return .failure(.init(
                id: "ficha_clinica.missing_account",
                name: "Error de usuario",
                message: "No se pudo obtener el ID de usuario"
            ))
        }
        print("🔹 Account ID: \(accountId)")
        
        // Construir el body dinámico según el formato de Android
        var body: [String: String] = [:]
        
        // Campos fijos (1, 2, 3)
        body["Campo_1__c"] = nombreFlujo
        body["Campo_2__c"] = accountId
        body["Campo_3__c"] = "App Mobile iOS" // Cambiamos para diferenciar de Android
        
        print("\n📦 [FichaClinicaGeneral] Campos fijos:")
        print("   • Campo_1__c = \(nombreFlujo)")
        print("   • Campo_2__c = \(accountId)")
        print("   • Campo_3__c = App Mobile iOS")
        
        // Campos dinámicos (4 en adelante, 2 por pregunta: respuesta + condicional)
        var campoIndex = 4
        
        print("\n📝 [FichaClinicaGeneral] Procesando respuestas:")
        
        for (index, pregunta) in preguntas.enumerated() {
            guard let respuesta = respuestas[pregunta.id] else {
                print("   ⚠️ Pregunta \(index + 1): Sin respuesta")
                // Enviar vacío si no hay respuesta (no debería pasar si validamos correctamente)
                body["Campo_\(campoIndex)__c"] = ""
                campoIndex += 1
                body["Campo_\(campoIndex)__c"] = ""
                campoIndex += 1
                continue
            }
            
            // Campo_N__c = Respuesta principal
            let respuestaPrincipal: String
            if !respuesta.opcionesSeleccionadas.isEmpty {
                // Si hay opciones seleccionadas, las unimos con punto y coma (formato: "Opcion1;Opcion2;Opcion3")
                respuestaPrincipal = respuesta.opcionesSeleccionadas.sorted().joined(separator: ";")
            } else if !respuesta.textoLibre.isEmpty {
                // Si no hay opciones pero hay texto libre
                respuestaPrincipal = respuesta.textoLibre
            } else {
                // Caso vacío (no debería pasar)
                respuestaPrincipal = ""
            }
            
            body["Campo_\(campoIndex)__c"] = respuestaPrincipal
            
            print("   • Pregunta \(index + 1): \(pregunta.texto)")
            print("     → Campo_\(campoIndex)__c = \"\(respuestaPrincipal)\"")
            
            campoIndex += 1
            
            // Campo_(N+1)__c = Respuesta condicional
            let respuestaCondicional: String
            if let regla = pregunta.regla,
               respuesta.opcionesSeleccionadas.contains(regla.respuestaActivadora) {
                // La regla está activa, enviar el valor del campo condicional
                respuestaCondicional = respuesta.campoCondicional
                if !respuestaCondicional.isEmpty {
                    print("     → Campo_\(campoIndex)__c = \"\(respuestaCondicional)\" (condicional activo)")
                } else {
                    print("     → Campo_\(campoIndex)__c = \"\" (condicional activo pero vacío)")
                }
            } else {
                // La regla no está activa o no existe, enviar vacío
                respuestaCondicional = ""
                if pregunta.regla != nil {
                    print("     → Campo_\(campoIndex)__c = \"\" (condicional inactivo)")
                } else {
                    print("     → Campo_\(campoIndex)__c = \"\" (sin regla condicional)")
                }
            }
            
            body["Campo_\(campoIndex)__c"] = respuestaCondicional
            campoIndex += 1
        }
        
        print("\n📊 [FichaClinicaGeneral] Total de campos en body: \(body.count)")
        print("   (3 fijos + \(preguntas.count * 2) dinámicos)")
        
        // Log del body completo (formateado)
        print("\n📄 [FichaClinicaGeneral] Body completo del request:")
        print("{")
        for key in body.keys.sorted() {
            let value = body[key] ?? ""
            let displayValue = value.isEmpty ? "(vacío)" : value
            // Limitar longitud para logs más limpios
            let truncatedValue = displayValue.count > 80 ? String(displayValue.prefix(77)) + "..." : displayValue
            print("  \"\(key)\": \"\(truncatedValue)\"")
        }
        print("}")
        
        print("\n🌐 [FichaClinicaGeneral] Enviando request a function_flows...")
        
        // El endpoint functionFlows ya existe y ya incluye el query parameter api_name
        // Ver Endpoint.swift línea 200: "function_flows?api_name=Servicio_Generico__c"
        
        let result: Result<GenericSuccessResponse, AppError> = await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: body
        )
        
        // Log de la respuesta
        switch result {
        case .success(let response):
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("✅ [FichaClinicaGeneral] POST exitoso")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            // Intentar serializar la respuesta completa
            if let data = try? JSONEncoder().encode(response),
               let jsonString = String(data: data, encoding: .utf8) {
                print("📥 [FichaClinicaGeneral] Respuesta del servidor:")
                print(jsonString)
            }
            
            // Guardar flag de completado
            UserDefaults.standard.set(true, forKey: "ficha_clinica_completada")
            print("💾 [FichaClinicaGeneral] Flag 'ficha_clinica_completada' guardado en UserDefaults")
            
        case .failure(let error):
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("❌ [FichaClinicaGeneral] Error en POST")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🔴 Error: \(error)")
            print("🔴 Descripción: \(error.localizedDescription)")
        }
        
        return result
    }
}

// MARK: - Modelos de respuesta

/// Respuesta genérica de éxito del servidor
/// El servicio de Android no parsea el body, solo verifica 200 OK
struct GenericSuccessResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

/// Helper para decodificar JSON dinámico
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
