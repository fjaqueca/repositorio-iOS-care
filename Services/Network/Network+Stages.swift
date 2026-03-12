//
//  Network+Stages.swift
//  CareAssistance
//
//  Created by The App Master on 25/07/2023.
//

import Foundation
import RealmSwift

extension Network {
    func getStages(progamId: String) async -> Result<Stages, AppError> {
        await request(endpoint: .stages, parameters: ["program_id": progamId])
    }
}
