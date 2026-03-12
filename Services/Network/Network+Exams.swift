//
//  Network+Examens.swift
//  CareAssistance
//
//  Created by The App Master on 05/10/2023.
//

import Foundation
import Alamofire

extension Network {
    func getExams(accountId: String, from: String, until: String) async -> Result<MedicalExams, AppError> {
        await request(endpoint: .exams, parameters: [
            "paciente_id": accountId,
            "fecha_desde": from,
            "fecha_hasta": until
        ])
    }
    func postExams(examName: String, accountId: String, url1: String, url2: String, url3: String, url4: String, comment: String, id: String) async -> Result<Empty, AppError> {
        await request(
            method: .post,
            endpoint: .functionFlows,
            parameters: [
                "Campo_1__c": "SERVICIO GENERICO EXAMENES DEL PACIENTE",
                "Campo_2__c": accountId,
                "Campo_3__c": examName,
                "Campo_4__c": url1,
                "Campo_5__c": url2,
                "Campo_6__c": url3,
                "Campo_7__c": url4,
                "Campo_8__c": comment,
                "Campo_9__c": id
            ])
    }
    func getPdf(pdfName: String) async -> Result<getPDFIn64, AppError> {
        await request(endpoint: .getFileFromS3, parameters: ["id": pdfName], parametersDestination: .urlQueryString)
    }
    func getExamsForPatient(accountId: String) async -> Result<FunctionFilterExamResponse, AppError> {
        let filter = Filter(paciente: accountId, match: "equal")
        
        let dataObject = DataObject(
            apiName: "Examenes_del_Paciente__c",
            expectedFields: [
                "Id",
                "Paciente__c",
                "Nombre_del_Examen__c",
                "URL_Examen_1__c",
                "URL_Examen_2__c",
                "URL_Examen_3__c",
                "URL_Examen_4__c",
                "Comentarios__c",
                "CreatedDate",
                "Id_Orden_Medica__c"
            ],
            filters: [filter]
        )
        
        let requestBody = RequestBody(data: [dataObject])
        
        let result: Result<FunctionFilterExamResponse, Error> = await requestFunctionFilter(
                method: .post,
                endpoint: .functionFilter,
                encodableParameters: requestBody
            )
            
            // Aquí hacemos el "downcast" del Error genérico a AppError
            return result.mapError { error in
                if let appError = error as? AppError {
                    return appError
                } else {
                    return AppError(id: "request_error", name: "Error", message: error.localizedDescription)
                }
            }
    }
}
