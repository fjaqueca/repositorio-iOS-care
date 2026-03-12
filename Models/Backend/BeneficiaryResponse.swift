//
//  BeneficiaryResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 27/12/2022.
//

import Foundation

struct BeneficiaryResponse: Codable {
    var statusCode: Int
    var data: [Beneficiary]
    var error: Bool
}
