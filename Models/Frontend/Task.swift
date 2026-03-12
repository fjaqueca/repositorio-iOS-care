//
//  Task.swift
//  CareAssistance
//
//  Created by The App Master on 27/07/2023.
//

import Foundation

struct StageGoalsActivityComplition: Codable, Hashable{
    let totalSize: Int?
    let done: Bool?
    let records: [StageGoals]
    
    struct StageGoals:  Codable, Hashable  {
        let goalsR: Goals
    }
}
struct Goals:  Codable, Hashable {
    let totalSize: Int?
    let done: Bool?
    let records: [Goal]
    
    struct Goal:  Codable, Hashable  {
        let attributes: Attribute?
        let Id: String?
        let OwnerId: String?
        let IsDeleted: Bool?
        let name: String?
        let recordTypeId: String?
        let createdDate: String?
        let createdById: String?
        let lastModifiedDate: String?
        let lastModifiedById: String?
        let systemModstamp: String?
        let lasActivityDate: String?
        let lastViewedDate: String?
        let lastReferencedDate: String?
        
        let duranteC: Float?
        let duracionEnC: String?
        let instruccionesC: String?
        let diasDeLaSemanaC: String?
        let cantDeElementosPorTareaC: Float?
        let puntosAObtenerC: Float?
        let puntosAcumuladosC: Float?
        let favoritoAppC: Bool?
        let minimoParaEtapaCumplidaC: Float?
        let cumplimientoDeLaTareaC: Float?
        let tareaCumplidaC: Bool?
        let instruccionesLinkC: String?
        let actividadesR: Activities?
        let estadoC: String?
        let nombrePersonalizadoC: String?
        let mostrarSiEsUnSoloRegistroC: Bool?
        let textoBotonC: String?
        let saltarListaDeActividadesC: Bool?
        let idInicioDeConcatenacionC: String?
        let idInicioDeConcatenacionTemplateC: String?
        let idInicioDeConcatenacionEnrolamientoC: String?
        let completarTareaC: Bool?
    }
}

struct Activities:  Codable, Hashable {
    let totalSize: Int?
    let done: Bool?
    let records: [Activity]?
    
    struct Activity:  Codable, Hashable  {
        let attributes: Attribute?
        let taskCompletionTemplateR: ActivityCompletion?
        let Id: String?
        let IsDeleted: Bool?
        let nombreC: String?
        let descripcionCortaC: String?
        let descripcionLargaC: String?
        let puntosDeLaActividadC: Float?
        let cantTaskCompletionC: Float?
        let totalTaskComTemplateC: Float?
        let totalTaskCompletion2C: Float?
        let actividadInvisibleC: Bool?
        let idActividadConcatenadaC: String?
        let idActividadConcatenadaTemplateC: String?
        let idActividadConcatenadaEnrolamientoC: String?
        let instruccionesC: String?
        let nombrePersonalizadoC: String?
    }
}

struct ActivityCompletion: Codable, Hashable {
    let totalSize: Int?
    let done: Bool?
    let records: [Completion]?
    
    struct Completion:  Codable, Hashable  {
        let attributes: Attribute?
        let Id: String?
        let OwnerId: String?
        let IsDeleted: Bool?
        let RecordTypeId: String?
        let CreatedDate: String?
        let CreatedById: String?
        let LastModifiedDate: String?
        let LastModifiedById: String?
        let SystemModstamp: String?
        let LastActivityDate: String?
        let LastViewedDate: String?
        let LastReferencedDate: String?
        let actividadC: String?
        let agrupamientoC: Float?
        let archivoOImagenC: String?
        let carePlanTemplateTaskC: String?
        let concatenacionPicklistTemplateC: String?
        let minimoAceptableC: String?
        let nombreDeLaActividadC: String?
        let objetivoC: String?
        let ordenDeVisibilidadC: Float?
        let posiblesValoresC: String?
        let requeridoC: Bool?
        let respuestaC: String?
        let tipoDeDatosC: String?
        let nombrePersonalizadoC: String?
        let concatenacionPicklistEnrolamientoC: String?
        let concatenacionPicklistC: String?
        let indicadorC: String?
        let actividadCalculadoraC: String?
        let categoriaPreguntaC: String?
        let categoriaC: String?
        let nombrePersonalizadoTAMC: String?
        let dimensionC: String?
        let dominicioC: String?
        let editableC: Bool?
        let contabilizableParaEscolaresC: Bool?
        let nombreActividadC: String?
    }
}



// MARK: - ParentHomeInfo
struct ParentHomeInfo: Codable {
    var ptsr: Ptsr?
}

// MARK: - Ptsr
struct Ptsr: Codable {
    var actividadPrograma: String?
    var careProgramTemplates: [CareProgramTemplate]?
    var careProgram: [CareProgramCompletionUpdate]? // ← NUEVO
    
    enum CodingKeys: String, CodingKey {
        case actividadPrograma = "actividad_programa"
        case careProgramTemplates = "care_program_templates"
        case careProgram = "care_program"
    }
}

// MARK: - CareProgramTemplate
struct CareProgramTemplate: Codable {
    var attributes: Attributes?
    var id, ownerID: String?
    var isDeleted: Bool
    var name, recordTypeID, createdDate, createdByID: String?
    var lastModifiedDate, lastModifiedByID, systemModstamp: String?
    var lastActivityDate: String?
    var lastViewedDate, lastReferencedDate, actividadC, objetivoC: String?
    var minimoAceptableC: String?
    var requeridoC: Bool
    var carePlanTemplateTaskC, archivoOImagenC: String?
    var nombreDeLaActividadC, tipoDeDatosC: String?
    var posiblesValoresC: String?
    var respuestaC: String?

    // Campos adicionales que puede requerir el backend (según ejemplo)
    var editableC: Bool?
    var contabilizableParaEscolaresC: Bool?
    var agrupamientoC: Float?
    var ordenDeVisibilidadC: Float?
    var nombrePersonalizadoC: String?
    
    enum CodingKeys: String, CodingKey {
        case attributes
        case id = "Id"
        case ownerID = "OwnerId"
        case isDeleted = "IsDeleted"
        case name = "Name"
        case recordTypeID = "RecordTypeId"
        case createdDate = "CreatedDate"
        case createdByID = "CreatedById"
        case lastModifiedDate = "LastModifiedDate"
        case lastModifiedByID = "LastModifiedById"
        case systemModstamp = "SystemModstamp"
        case lastActivityDate = "LastActivityDate"
        case lastViewedDate = "LastViewedDate"
        case lastReferencedDate = "LastReferencedDate"
        case actividadC = "Actividad__c"
        case objetivoC = "Objetivo__c"
        case minimoAceptableC = "Minimo_aceptable__c"
        case requeridoC = "Requerido__c"
        case carePlanTemplateTaskC = "Care_Plan_Template_Task__c"
        case archivoOImagenC = "Archivo_o_Imagen__c"
        case nombreDeLaActividadC = "Nombre_de_la_Actividad__c"
        case tipoDeDatosC = "Tipo_de_Datos__c"
        case posiblesValoresC = "Posibles_Valores__c"
        case respuestaC = "Respuesta__c"
        case editableC = "Editable__c"
        case contabilizableParaEscolaresC = "Contabilizable_para_escolares__c"
        case agrupamientoC = "Agrupamiento__c"
        case ordenDeVisibilidadC = "Orden_de_visibilidad__c"
        case nombrePersonalizadoC = "Nombre_Personalizado__c"
    }
}

// MARK: - care_program (UPDATE) item
struct CareProgramCompletionUpdate: Codable, Hashable {
    let Id: String?
    let editableC: Bool?
    let contestadoC: Bool?
    let valorDeRespuestaC: String?
    
    enum CodingKeys: String, CodingKey {
        case Id
        case editableC = "Editable__c"
        case contestadoC = "Contestado__c"
        case valorDeRespuestaC = "Valor_de_respuesta__c"
    }
}

// MARK: - Attributes
struct Attributes: Codable {
    var type, url: String?
}

