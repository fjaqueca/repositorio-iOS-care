//
//  Network+BrandAccount.swift
//  CareAssistance
//
//  Created by The App Master on 07/11/2023.
//

import Foundation

extension Network {
    func getBrandAccount(agreementId: String) async -> Result<BrandAccounts, AppError> {
        await request(endpoint: .getBrandAccount, parameters: ["convenio_id": agreementId], isAuthenticated: false)
    }
}
