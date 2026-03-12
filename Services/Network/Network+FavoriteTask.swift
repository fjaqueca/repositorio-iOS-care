//
//  Network+FavoriteTask.swift
//  CareAssistance
//
//  Created by The App Master on 15/01/2024.
//

import Foundation
import Alamofire

extension Network {
    func getFavoriteTask(accountId: String) async -> Result<FavoriteTasksTotal, AppError> {
        await request(endpoint: .getFavoriteTask, parameters: ["paciente_id": accountId])
    }
}
