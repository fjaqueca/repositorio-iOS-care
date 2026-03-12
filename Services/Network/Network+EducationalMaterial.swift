//
//  Network+EducationalMaterial.swift
//  CareAssistance
//
//  Created by The App Master on 09/02/2024.
//

import Foundation
import Alamofire

extension Network{
    func getEducationalMaterial(agreementId: String) async -> Result<EducationalMaterial, AppError> {
        await request(endpoint: .getEducationalMaterial, parameters: [
            "convenio_id": agreementId,
        ])
    }
}

