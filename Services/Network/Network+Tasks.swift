//
//  Network+Tasks.swift
//  CareAssistance
//
//  Created by The App Master on 27/07/2023.
//

import Foundation

// MARK: - Network Tasks

extension Network {

    func getTasks(stageId: String) async -> Result<[StageGoalsActivityComplition], AppError> {
        await request(
            endpoint: .stageGoalsActivityComplition,
            parameters: ["id_case": stageId]
        )
    }

    // Ahora soporta CREATE y UPDATE en el mismo payload,
    // y además solo envía los ítems que realmente cambiaron.
    func postTask(
        activityData: [ActivityCompletion.Completion],
        response: [String: String],
        existingCompletionIds: [String: String] = [:] // templateId -> completionId (Task_Completion_Id)
    ) async -> Result<PostTaskResponse, AppError> {

        // 1) Detectar qué templates cambiaron (comparando contra la respuesta previa)
        let changed: [(com: ActivityCompletion.Completion, newValue: String)] = activityData.compactMap { com in
            guard let templateId = com.Id,
                  let newValue = response[templateId] else {
                return nil
            }
            // Solo considerar "cambio" si difiere del valor previo (o si antes era nil)
            if com.respuestaC == newValue {
                return nil
            }
            return (com, newValue)
        }

        // Helper para reemplazar el último segmento (Id) del url original
        func replacingLastId(in originalURL: String, with newId: String) -> String {
            if let range = originalURL.range(of: "/[^/]+$", options: .regularExpression) {
                return originalURL.replacingCharacters(in: range, with: "/\(newId)")
            }
            return originalURL
        }

        // 2) care_program_templates (solo los que cambiaron)
        var requestObjetData: [CareProgramTemplate] = changed.map { pair in
            let com = pair.com
            let respuestaC = pair.newValue

            let templateId = com.Id
            let completionId = templateId.flatMap { existingCompletionIds[$0] } // Task_Completion_Id si existe
            let esActualizacion = (completionId != nil)

            // Construir attributes.url según sea creación o actualización
            let newAttributesURL: String? = {
                if let originalURL = com.attributes?.url {
                    if let completionId = completionId {
                        // UPDATE: usar Task_Completion_Id en el URL
                        return replacingLastId(in: originalURL, with: completionId)
                    } else {
                        // CREATE: dejar el URL original del template
                        return originalURL
                    }
                } else if let completionId = completionId {
                    // Si no vino el URL original, fallback a un path estándar con v65.0
                    return "/services/data/v65.0/sobjects/Task_Completion_Template__c/\(completionId)"
                } else {
                    return com.attributes?.url
                }
            }()

            return CareProgramTemplate(
                attributes: Attributes(
                    type: com.attributes?.type,
                    // UPDATE: URL con Task_Completion_Id; CREATE: URL original del template
                    url: newAttributesURL
                ),
                // UPDATE: Id = Task_Completion_Id; CREATE: Id del template
                id: esActualizacion ? completionId : com.Id,
                ownerID: com.OwnerId,
                isDeleted: com.IsDeleted ?? false,
                name: com.nombrePersonalizadoC,
                recordTypeID: com.RecordTypeId,
                createdDate: com.CreatedDate,
                createdByID: com.CreatedById,
                lastModifiedDate: com.LastModifiedDate,
                lastModifiedByID: com.LastModifiedById,
                systemModstamp: com.SystemModstamp,
                lastActivityDate: com.LastActivityDate,
                lastViewedDate: com.LastViewedDate,
                lastReferencedDate: com.LastReferencedDate,
                actividadC: com.actividadC,
                objetivoC: com.objetivoC,
                minimoAceptableC: com.minimoAceptableC,
                requeridoC: com.requeridoC ?? false,
                carePlanTemplateTaskC: com.carePlanTemplateTaskC,
                archivoOImagenC: com.archivoOImagenC,
                nombreDeLaActividadC: com.nombreDeLaActividadC,
                tipoDeDatosC: com.tipoDeDatosC,
                posiblesValoresC: com.posiblesValoresC,
                respuestaC: respuestaC,
                // Campos adicionales que tu backend podría requerir
                editableC: com.editableC,
                contabilizableParaEscolaresC: com.contabilizableParaEscolaresC,
                agrupamientoC: com.agrupamientoC,
                ordenDeVisibilidadC: com.ordenDeVisibilidadC,
                nombrePersonalizadoC: com.nombrePersonalizadoC
            )
        }

        // 3) care_program (solo updates para los que cambiaron y tienen completionId)
        var careProgramUpdates: [CareProgramCompletionUpdate] = []
        for pair in changed {
            let com = pair.com
            let newValue = pair.newValue
            if let templateId = com.Id,
               let completionId = existingCompletionIds[templateId] {
                careProgramUpdates.append(
                    CareProgramCompletionUpdate(
                        Id: completionId,               // ← Task_Completion_Id
                        editableC: com.editableC,
                        contestadoC: true,
                        valorDeRespuestaC: newValue     // ← nueva respuesta
                    )
                )
            }
        }

        // 4) actividad_programa debe corresponder al ítem que cambió
        let actividadPrograma = changed.first?.com.actividadC ?? activityData.first?.actividadC ?? ""

        // Enviar care_program vacío [] cuando no hay updates (para que SF lo distinga de update)
        let ptsr = ParentHomeInfo(
            ptsr: Ptsr(
                actividadPrograma: actividadPrograma,
                careProgramTemplates: requestObjetData, // si está vacío, igual va []
                careProgram: careProgramUpdates         // si está vacío, igual va []
            )
        )

        // 🔎 LOG DEL PAYLOAD ENVIADO A postTask
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 POST /postTask - REQUEST BODY")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(ptsr)
            if let json = String(data: data, encoding: .utf8) {
                print(json)
            }
        } catch {
            print("⚠️ Error al serializar payload: \(error)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")

        return await request(
            method: .post,
            endpoint: .postTask,
            parameters: ptsr
        )
    }

    func postCompletado(
        taskId: String,
        SObject: String
    ) async -> Result<PostTaskResponse, AppError> {

        let parameters = [
            "registro_id": taskId,
            "SObject": SObject,
            "completado": true
        ] as [String : Any]

        // 🔎 LOG DEL PAYLOAD ENVIADO A postCompletado
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 POST /postCompletado - REQUEST BODY")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔹 Endpoint: post_completado")
        print("🔹 Task ID: \(taskId)")
        print("🔹 SObject: \(SObject)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted, .sortedKeys])
            if let json = String(data: jsonData, encoding: .utf8) {
                print("🔹 Parámetros completos:")
                print(json)
            }
        } catch {
            print("⚠️ Error al serializar parámetros: \(error)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")

        return await request(
            method: .post,
            endpoint: .postCompletado,
            parameters: parameters
        )
    }
}
