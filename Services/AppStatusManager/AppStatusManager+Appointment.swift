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
                let realm = try! Realm(queue: nil)
                try! realm.write {
                    let oldItems = realm.objects(Appointment.self)
                    // Delete stored items
                    realm.delete(oldItems)
//                    let oldObjects = realm.objects(Appointment.self)
//                    let ids = appointments.map(\.id)
                    realm.add(appointments, update: .all)
//                    realm.delete(oldObjects.filter({ !ids.contains($0.id) }))
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
