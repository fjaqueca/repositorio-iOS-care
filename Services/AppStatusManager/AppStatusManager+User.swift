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
            return
        }
        let profileResponse = await Network.shared.profile(rut: rut)

        switch profileResponse {
            case let .success(user):
                let realm = try! Realm(queue: nil)
                try! realm.write {
                    
                    realm.add(user, update: .all)
                }
            UserDefaults.standard.set(user.records.first?.id, forKey: "account_id")
            AppStatusManager.setLoading(false)
                return
            case let .failure(error):
                print(error)
                // TODO: Handle Error
            AppStatusManager.setLoading(false)
                return
        }
    }
}
