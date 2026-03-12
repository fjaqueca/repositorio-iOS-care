//
//  Network+Company.swift
//  CareAssistance
//
//  Created by The App Master on 08/11/2024.
//

import Foundation
import RealmSwift
import Alamofire

extension Network {
    func sendCompanyToSalesforce(accountId: String, agreementId: String) async -> Result<Empty, AppError> {
        var appName: String = "CareAssistance"
#if CareAssistance
        appName = "CareAssistance"
#elseif Wellbeing
        appName = "WTW"
#elseif BCI
        appName = "BCI"
#elseif PharmaBenefits
        appName = "PharmaBenefits"
#elseif VCContigo
        appName = "VCContigo"
#elseif CareAssistanceMX
        appName = "CareAssistanceMX"
#elseif Premedic
        appName = "Premedic"
#elseif ContigoSalud
        appName = "Contigo+Salud"
#endif
        return await request(method: .post, endpoint: .functionFlows, parameters: [
            "Campo_1__c": "Seleccionar ECC Servicio Generico",
            "Campo_2__c": accountId,
            "Campo_3__c": agreementId,
            "Campo_4__c": "iOS",
            "Campo_5__c": appName
        ], parametersDestination: .jsonBody)
    }
}
