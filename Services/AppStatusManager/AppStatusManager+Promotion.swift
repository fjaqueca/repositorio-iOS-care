//
//  AppStatusManager+Promotion.swift
//  CareAssistance
//
//  Created by Lara Dubs on 23/12/2022.
//

import Foundation
import RealmSwift

extension AppStatusManager {
    static func loadPromotions() async {
        Task {
            let promotionResult = await Network.shared.getPromotions()
            switch promotionResult {
                case let .success(promotions):
                    let realm = try! Realm(queue: nil)
                    try! realm.write {
                        realm.add(promotions, update: .all)
                    }
                    return
                case let .failure(error):
                    AppStatusManager.error(error)
                    return
            }
        }
    }
}
