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
        // FIX: antes el cuerpo estaba envuelto en `Task { }` detached, lo que hacía
        // que la función retornara en 0ms sin esperar el network call → quien
        // hacía `await loadBrandAccount()` no esperaba nada y seguía adelante con
        // datos faltantes. Ahora el await respeta de verdad la carga.
        AppStatusManager.setLoading(true)
        let agreementId = AppStatusManager.selectedEnterprise?.empresaC
        let brandAccountResult = await Network.shared.getBrandAccount(agreementId: agreementId ?? "")
        switch brandAccountResult {
            case let .success(brands):
                do {
                    let realm = try Realm(queue: nil)
                    try realm.write {
                        let oldItems = realm.objects(BrandAccounts.self)
                        realm.delete(oldItems)
                        realm.add(brands, update: .all)
                    }
                } catch {
                    print("❌ [Realm] Error en loadBrandAccount: \(error.localizedDescription)")
                }
                ClinicManager().generateClinics(from: brands)
                AppStatusManager.setLoading(false)
            case let .failure(error):
                AppStatusManager.error(error)
                AppStatusManager.setLoading(false)
        }
    }
}
