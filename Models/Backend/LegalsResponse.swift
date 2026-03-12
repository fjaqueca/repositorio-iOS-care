//
//  LegalsResponse.swift
//  CareAssistance
//
//  Created by Lara Dubs on 23/12/2022.
//

import Foundation

struct LegalsRecordsResponse: Codable{
    var totalSize: Int?
    var done: Bool?
    var records: [LegalsResponse]?
}
struct LegalsResponse: Codable {
    var politicasDePrivacidadR: Politics?
    var terminosYCondicionesR: TermsAndConditions?
}

struct Politics: Codable {
    var Name: String?
    var contentC: String?
}

struct TermsAndConditions: Codable {
    var Name: String?
    var contentC: String?
}
