//
//  Network+Promotions.swift
//  CareAssistance
//
//  Created by Lara Dubs on 09/11/2022.
//

import Foundation

extension Network {
    func getPromotions() async -> Result<[Promotion], AppError> {
        await request(endpoint: .promotions, parameters: ["account_id": AppStatusManager.selectedEnterprise?.empresaC])
    }
}
