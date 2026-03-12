//
//  AppStatusManager+BrandAccount.swift
//  CareAssistance
//
//  Created by The App Master on 31/10/2023.
//

import Foundation
import RealmSwift

extension AppStatusManager {
    static func loadBrandAccount() async {
        Task {
            AppStatusManager.setLoading(true)
            let agreementId = AppStatusManager.selectedEnterprise?.empresaC
            let brandAccountResult = await Network.shared.getBrandAccount(agreementId: agreementId ?? "")
            switch brandAccountResult {
                case let .success(brands):
                    let realm = try! Realm(queue: nil)
                    try! realm.write {
                        let oldItems = realm.objects(BrandAccounts.self)
                        // Delete stored items
                        realm.delete(oldItems)
                        realm.add(brands, update: .all)
                    }
                    ClinicManager().generateClinics(from: brands)
                    AppStatusManager.setLoading(false)
                    return
                case let .failure(error):
                    AppStatusManager.error(error)
                    AppStatusManager.setLoading(false)
                    return
            }
            
        }
    }
}
