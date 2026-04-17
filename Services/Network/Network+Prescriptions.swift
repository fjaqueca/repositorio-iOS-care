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
        let params: [String: Any] = [
            "paciente_id": accountId,
            "fecha_desde": from,
            "fecha_hasta": until
        ]
        let fullUrl = "\(baseUrlAuthenticated)\(Endpoint.prescriptions.urlString)"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [getRecetas] REQUEST get_recetas")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   🌐 URL: \(fullUrl)")
        print("   📦 Body: \(params)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result: Result<Prescriptions, AppError> = await request(endpoint: .prescriptions, parameters: params)

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [getRecetas] RESPONSE get_recetas")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        switch result {
        case .success(let response):
            print("   ✅ Success")
            print("   📄 totalSize: \(response.totalSize ?? -1)")
            print("   📄 done: \(response.done ?? false)")
            print("   📄 records count: \(response.records.count)")
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(response),
               let raw = String(data: data, encoding: .utf8) {
                print("   📄 RAW Response:\n\(raw)")
            }
        case .failure(let error):
            print("   ❌ Error: \(error)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return result
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
