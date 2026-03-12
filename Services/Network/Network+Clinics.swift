//
//  Network+Clinics.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/10/2022.
//

import Foundation
import Alamofire

extension Network {
    func getClinics(convenio: String) async -> Result<ClinicR1, AppError> {
        await request(endpoint: .clinics, parameters: ["Datos_Empresa__c": convenio])
    }
    
    func getClinicDetails(id: String) async -> Result<ClinicDetail, AppError> {
        await request(endpoint: .clinicDetails, parameters: ["work_type_group_id": id, "company_id": AppStatusManager.selectedEnterprise?.empresaC ?? ""])
    }
}
