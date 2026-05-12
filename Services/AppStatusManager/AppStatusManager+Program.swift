//
//  AppStatusManager+Program.swift
//  CareAssistance
//
//  Created by The App Master on 21/07/2023.
//
import Foundation
import RealmSwift

extension AppStatusManager {
    static func loadPrograms() async {
        Task {
            let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
            let programResult = await Network.shared.getPrograms(accountId: accountId)
            switch programResult {
                case let .success(program):
                    do {
                        let realm = try Realm(queue: nil)
                        try realm.write {
                            realm.add(program, update: .all)
                        }
                    } catch {
                        print("❌ [Realm] Error en loadPrograms: \(error.localizedDescription)")
                    }
                    return
                case let .failure(error):
                    AppStatusManager.error(error)
                    return
            }
        }
    }
}
