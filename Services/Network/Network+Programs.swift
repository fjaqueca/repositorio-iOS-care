//
//  Network+Programs.swift
//  CareAssistance
//
//  Created by The App Master on 20/07/2023.
//

import Foundation
import RealmSwift
import Alamofire

extension Network {
    func getPrograms(accountId: String) async -> Result<Programs, AppError> {
        await request(endpoint: .programs, parameters: ["account_id": accountId])
    }
    func createProgram(flowName: String, accountId: String, programName: String) async -> Result<Empty, AppError> {
        await request(method: .post, endpoint: .functionFlows, parameters: [
            "Campo_1__c": flowName,
            "Campo_2__c": accountId,
            "Campo_3__c": programName
        ])
    }
    
    
}
