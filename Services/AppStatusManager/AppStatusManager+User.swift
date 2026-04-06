//
//  AppStatusManager+User.swift
//  CareAssistance
//
//  Created by Lara Dubs on 21/10/2022.
//

import Foundation
import RealmSwift

extension AppStatusManager {
    static func loadUser() async {
        AppStatusManager.setLoading(true)
        guard let rut = self.rut else {
            print("⚠️ [loadUser] RUT no disponible, abortando")
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [loadUser] REQUEST - get_account_settings_r1")
        print("   RUT: '\(rut)'")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let profileResponse = await Network.shared.profile(rut: rut)

        switch profileResponse {
            case let .success(user):
                let record = user.records.first
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📡 [loadUser] RESPONSE - get_account_settings_r1")
                print("   ✅ SUCCESS")
                print("   Id:        '\(record?.Id ?? "(nil)")'")
                print("   Nombre:    '\(record?.FirstName ?? "(nil)")'")
                print("   Apellido:  '\(record?.LastName ?? "(nil)")'")
                print("   Email:     '\(record?.PersonEmail ?? "(nil)")'")
                print("   RUT:       '\(record?.RUT ?? "(nil)")'")
                print("   Telefono:  '\(record?.Phone ?? "(nil)")'")
                print("   Records:   \(user.records.count)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                let realm = try! Realm(queue: nil)
                try! realm.write {
                    realm.add(user, update: .all)
                }
                UserDefaults.standard.set(record?.id, forKey: "account_id")
                AppStatusManager.setLoading(false)
                return
            case let .failure(error):
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📡 [loadUser] RESPONSE - get_account_settings_r1")
                print("   ❌ ERROR: \(error.name) - \(error.message)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                // TODO: Handle Error
                AppStatusManager.setLoading(false)
                return
        }
    }
}
