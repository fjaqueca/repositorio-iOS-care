//
//  AppStatusManager+FavoriteTask.swift
//  CareAssistance
//
//  Created by The App Master on 15/01/2024.
//

import Foundation
import RealmSwift

extension AppStatusManager {
    static func loadFavoriteTask() async {
        Task {
            AppStatusManager.setLoading(true)
            let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
            let favoriteTaskResult = await Network.shared.getFavoriteTask(accountId: accountId)
            switch favoriteTaskResult {
                case let .success(tasks):
                    do {
                        let realm = try Realm(queue: nil)
                        try realm.write {
                            let oldItems = realm.objects(FavoriteTasksTotal.self)
                            // Delete stored items
                            realm.delete(oldItems)
                            realm.add(tasks, update: .all)
                        }
                    } catch {
                        print("❌ [Realm] Error en loadFavoriteTask: \(error.localizedDescription)")
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
}
