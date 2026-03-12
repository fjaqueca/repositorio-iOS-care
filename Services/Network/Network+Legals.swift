//
//  Network+Legals.swift
//  CareAssistance
//
//  Created by Lara Dubs on 21/12/2022.
//

import Foundation
import Alamofire

extension Network {
    func getLegalInformation(agreement: String) async -> Result<LegalsRecordsResponse, AppError> {
        await request(endpoint: .legals, parameters: ["convenio_id": agreement], isAuthenticated: false)
    }
}
