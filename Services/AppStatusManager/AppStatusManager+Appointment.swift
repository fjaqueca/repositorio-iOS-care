//
//  AppStatusManager+Appointment.swift
//  CareAssistance
//
//  Created by Lara Dubs on 06/11/2022.
//

import Foundation
import RealmSwift

extension AppStatusManager {
    static func loadAppointments() async {
        guard let rut = self.rut else {
            return
        }
        AppStatusManager.setLoading(true)
        let appointmentsResponse = await Network.shared.getNextAppointments(rut: rut)
        
        switch appointmentsResponse {
            case let .success(appointments):
                // 📝 NUEVO: Log de la respuesta raw de appointments
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📦 [Appointments] Respuesta del servicio (parseada)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("   • Total appointments: \(appointments.count)")
                print("")
                
                // Imprimir cada appointment con sus campos
                for (index, appointment) in appointments.enumerated() {
                    print("   📅 Appointment #\(index + 1):")
                    print("      • id: \(appointment.id)")
                    print("      • status: \(appointment.status.rawValue)")
                    print("      • schedStartTime: \(appointment.schedStartTime)")
                    print("      • schedEndTime: \(appointment.schedEndTime)")
                    print("      • professionalName: \(appointment.professionalName)")
                    print("      • clinica: \(appointment.clinica)")
                    print("      • workTypeGroup: \(appointment.workTypeGroup)")
                    print("      • appointmentType: \(appointment.appointmentType.rawValue)")
                    print("      • serviceTerritoryId: \(appointment.serviceTerritoryId)")
                    print("      • iconoAzul: \(appointment.iconoAzul)")
                    print("")
                    print("      📄 Representación JSON:")
                    print("      {")
                    print("        \"id\": \"\(appointment.id)\",")
                    print("        \"status\": \"\(appointment.status.rawValue)\",")
                    print("        \"schedStartTime\": \"\(appointment.schedStartTime)\",")
                    print("        \"schedEndTime\": \"\(appointment.schedEndTime)\",")
                    print("        \"professionalName\": \"\(appointment.professionalName)\",")
                    print("        \"clinica\": \"\(appointment.clinica)\",")
                    print("        \"workTypeGroup\": \"\(appointment.workTypeGroup)\",")
                    print("        \"appointmentType\": \"\(appointment.appointmentType.rawValue)\",")
                    print("        \"serviceTerritoryId\": \"\(appointment.serviceTerritoryId)\",")
                    print("        \"iconoAzul\": \"\(appointment.iconoAzul)\"")
                    print("      }")
                    print("")
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
                
                do {
                    let realm = try Realm(queue: nil)
                    try realm.write {
                        let oldItems = realm.objects(Appointment.self)
                        // Delete stored items
                        realm.delete(oldItems)
//                        let oldObjects = realm.objects(Appointment.self)
//                        let ids = appointments.map(\.id)
                        realm.add(appointments, update: .all)
//                        realm.delete(oldObjects.filter({ !ids.contains($0.id) }))
                    }
                } catch {
                    print("❌ [Realm] Error en loadAppointments: \(error.localizedDescription)")
                }
            AppStatusManager.setLoading(false)
                return
            case let .failure(error):
                AppStatusManager.error(error)
            AppStatusManager.setLoading(false)
                return
        }
    }
}
