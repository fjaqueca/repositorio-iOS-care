//
//  Stage.swift
//  CareAssistance
//
//  Created by The App Master on 25/07/2023.
//

import Foundation

struct Stages:  Codable, Hashable {
    let totalSize: Int?
    let done: Bool?
    let records: [Stage]
    
    struct Stage:  Codable, Hashable  {
        let Id: String?
        let IsDeleted: Bool?
        let nombrePersonalizadoC: String?
        let etapaCumplidaC: Bool?
        let puntosAObtenerC: Float?
        let puntosAcumuladosC: Float?
        let cantDeTareasC: Float?
        let cumplimientoDeLaEtapaC: Float?
        let estadoC: String?
        let minimoParaEtapaCumplidaC: Float?
        let Description: String?
        let mostrarSiEsUnSoloRegistroC: Bool?
        
    }
}

