//
//  BrandButtonTile.swift
//  CareAssistance
//
//  Created by The App Master on 29/04/2025.
//

import Foundation

struct BrandButton {
    let imageUrl: String
    let tipoElemento: TipoElemento
    let subHomeId: String
    let name: String
    let typeId: String
    let logo: String
    let customName: String
    let clinicProperties: ClinicDetail
    let programName: String
    let programFlow: String
    let archiveUrl: String
    let itemSelected: Int
}

enum TipoElemento: String {
    case subHome = "S"
    case clinic = "C"
    case program = "P"
    case archive = "B"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "S": self = .subHome
        case "C": self = .clinic
        case "P": self = .program
        case "B": self = .archive
        default:  self = .unknown
        }
    }
}
