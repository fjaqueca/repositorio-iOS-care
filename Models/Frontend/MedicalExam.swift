//
//  MedicalExam.swift
//  CareAssistance
//
//  Created by The App Master on 05/10/2023.
//

import Foundation

enum TipoDocumento: String, Codable, Hashable {
    case ordenMedica = "Orden médica"
    case examenAutomatizado = "Examen automatizado"
    case recetaMedica = "Receta médica"

    var badgeColor: String {
        switch self {
        case .ordenMedica: return "#00BBDC"
        case .examenAutomatizado: return "#7B61FF"
        case .recetaMedica: return "#00B894"
        }
    }
}

struct MedicalExams: Codable, Hashable  {
    let totalSize: Int?
    let done: Bool?
    var records: [Exam]

    struct Exam: Codable, Hashable {
        let attributes: Attribute?
        var examenMedicoR: MedicalExamR?
        let profesionalResponsableR: ExamProfessional?
        let etapaR: EtapaExam?
        let Id: String?
        let Name: String?
        let desdeC: String?
        let hastaC: String?
        let etapaC: String?
        let actividadC: String?
        let especialidadDelResponsableC: String?
        let pacienteC: String?
        let favoritoAppC: Bool?
        let urlDeLaOrdenMedicaC: String?
        let descripcionC: String?
        var url1C: String?
        var url2C: String?
        var url3C: String?
        var url4C: String?
        var comment: String?
        var tipoDocumento: TipoDocumento?
        
        
        struct MedicalExamR: Codable, Hashable {
            let attributes: Attribute?
            let categoriaC: String?
            let Id: String?
            let Name: String?
            let descripcionC: String?
            let Owner: OwnerMedicalExam?
            var url1C: String?
            var url2C: String?
            var url3C: String?
            var url4C: String?
            
            struct OwnerMedicalExam: Codable, Hashable {
                let Id: String?
                let Name: String?
            }
        }
        struct ExamProfessional: Codable, Hashable {
            let Name: String?
        }
        struct EtapaExam: Codable, Hashable {
            let programR: ProgramExam?
        }
        struct ProgramExam: Codable, Hashable {
            let Name: String?
            let Id: String?
        }
    }
    
}
