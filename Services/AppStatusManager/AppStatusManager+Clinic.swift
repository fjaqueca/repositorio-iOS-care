//
//  AppStatusManager+Clinic.swift
//  CareAssistance
//
//  Created by Lara Dubs on 21/10/2022.
//

import Foundation
import RealmSwift

extension AppStatusManager {
    @MainActor static func loadClinics() async {
        let agreementId = UserDefaults.standard.string(forKey: "convenio_id") ?? ""
        let clinicsResponse = await Network.shared.getClinics(convenio: agreementId)
        print(agreementId)
        switch clinicsResponse {
            case let .success(clinics):
                let realm = try! Realm(queue: nil)
                try! realm.write {
                    let oldItems = realm.objects(ClinicR1.self)
                    // Delete stored items
                    realm.delete(oldItems)
                    // Save the updated clinics
                    print(clinics)
                    realm.add(clinics, update: .modified)
                }
                return
            case let .failure(error):
                AppStatusManager.error(error)
                return
        }
    }
    
    static func loadTelemedicinaClinic() async {
        let realm = try! Realm(queue: nil)
//        guard let telemedicina = realm.objects(Clinic.self).first(where: { $0.records.first?.Name == "Telemedicina" }) else {
//            return
//        }
        //await Self.loadClinicDetails(id: telemedicina.id)
    }

    static func loadClinicDetails(id: String) async {
        let clinicDetailsResponse = await Network.shared.getClinicDetails(id: id)

        switch clinicDetailsResponse {
            case let .success(clinicDetails):
                let realm = try! Realm(queue: nil)
                try! realm.write {
                    realm.add(clinicDetails, update: .modified)
                }
                return
            case let .failure(error):
                AppStatusManager.error(error)
                return
        }
    }
}
