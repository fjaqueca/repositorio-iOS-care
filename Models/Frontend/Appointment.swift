//
//  Appointment.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import Foundation
import RealmSwift

class Appointment: Object, ObjectKeyIdentifiable, Decodable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var status: Status
    @Persisted var schedStartTime: String
    @Persisted var schedEndTime: String
    @Persisted var serviceTerritoryId: String
    @Persisted var professionalName: String
    @Persisted var clinica: String
    @Persisted var workTypeGroup: String
    @Persisted var iconoAzul: String
    @Persisted var appointmentType: Kind
    
    var date: Date {
        .init(isoString: schedStartTime)
    }
}

extension Appointment {
    enum Kind: String, Decodable, PersistableEnum {
        case video = "Video"
        case phone = "Phone"
        
        var description: String {
            switch self {
                case .video:
                    return "Videollamada"
                case .phone:
                    return "Telefónica"
            }
        }
    }
}
    
    extension Appointment {
        enum Status: String, Decodable, PersistableEnum, CustomStringConvertible {
            case programado = "Programado"
            case confirmado = "Confirmado"
            case cancelado = "Cancelado"
            case noConfirmado = "No Confirmado"
            case noRealizado = "No realizado"
            case realizado = "Realizado"
            case reagendado = "Reagendado"
            case aConfirmar = "A Confirmar"
            case failure = "Fallido"
            var description: String {
                switch self {
                case .programado, .noConfirmado, .aConfirmar:
                        return "A confirmar"
                    case .confirmado:
                        return "Confirmado"
                    case .cancelado:
                        return "Cancelado"
                    case .noRealizado:
                        return "No realizado"
                    case .realizado:
                        return "Realizado"
                    case .reagendado:
                        return "Reagendado"
                    case .failure:
                        return "Fallido"
                }
            }
        }
    }

struct AppointmentDisplayData {
    let appointment: Appointment
    let displayName: String
    let displayIcon: String
}
