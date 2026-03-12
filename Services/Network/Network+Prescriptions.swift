//
//  Network+Prescriptions.swift
//  CareAssistance
//
//  Created by The App Master on 24/08/2023.
//

import Foundation
import Alamofire

extension Network {
    func getRecetas(accountId: String, from: String, until: String) async -> Result<Prescriptions, AppError> {
        await request(endpoint: .prescriptions, parameters: [
            "paciente_id": accountId,
            "fecha_desde": from,
            "fecha_hasta": until
        ])
    }
    func postReceta(accountId: String, prescriptionId: String) async -> Result<Empty, AppError> {
        await request(
            method: .post,
            endpoint: .repeatPrescription,
            parameters: [
                "receta_id": prescriptionId,
                "Paciente__c": accountId,
            ])
    }
}
