//
//  Network+MedicalExams.swift
//  CareAssistance
//
//  Created by Lara Dubs on 04/04/2023.
//

import Foundation

extension Network {
    func getMedicalExams(dateFrom: String, dateUntil: String) async -> Result<MedicalExam, AppError> {
        await request(method: .get, endpoint: .medicalExams, parameters: [
            "username": AppStatusManager.rut,
            "date_from": dateFrom,
            "date_until": dateUntil
        ])
    }
}
