//
//  AppointmentsResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 06/11/2022.
//

import Foundation

struct AppointmentsResponse: Codable {
    let id: String
    let status: String
    let schedStartTime: String
    let schedEndTime: String
    let serviceTerritoryId: String
    let professionalName: String
    let clinica: String
    let workTypeGroup: String
}
