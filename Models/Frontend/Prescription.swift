//
//  Prescription.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/03/2023.
//

import SwiftUI

struct Prescriptions: Codable, Hashable  {
    let totalSize: Int?
    let done: Bool?
    let records: [Prescription]
    
    struct Prescription: Codable, Hashable {
        //let tareaR: PresTask?
        let medicamentoR: PresMedicines?
        let profesionalResponsableR: PresProfessional?
        //let programR: PresProgram?
        let Id: String?
        let Name: String?
        let desdeC: String?
        let hastaC: String?
        let etapaC: String?
        let especialidadDelResponsableC: String?
        let pacienteC: String?
        let dosisC: String?
        let indicacionesC: String?
        let tareaC: String?
        let urlDeLaRecetaC: String?
        
        
        struct PresTask: Codable, Hashable {
            let Id: String?
            let Name: String?
            let programR: PresProgram
            
            struct PresProgram: Codable, Hashable {
                let Id: String?
                let nombrePersonalizadoC: String?
                
            }
        }
        struct PresMedicines: Codable, Hashable {
            let Id: String?
            let Name: String?
        }
        struct PresProfessional: Codable, Hashable {
            let Name: String?
        }
        struct PresProgram: Codable, Hashable {
            let Id: String?
            let nombrePersonalizadoC: String?
        }
    }
    
}
