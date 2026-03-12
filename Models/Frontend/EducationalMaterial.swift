//
//  EducationalMaterial.swift
//  CareAssistance
//
//  Created by The App Master on 08/02/2024.
//

import SwiftUI

struct EducationalMaterial: Codable, Hashable  {
    let totalSize: Int?
    let done: Bool?
    let records: [EducationalMaterialRecords]
    
    struct EducationalMaterialRecords: Codable, Hashable {
        let Id: String?
        let Name: String?
        let attributes: Attribute?
        let descripcionC: String?
        let convenioC: String?
        let paSC: String?
        let url1C: String?
        let url2C: String?
        let url3C: String?
        let url4C: String?
        let url5C: String?
        let favoritoAppC: Bool?
        let nombresC: String?
        let iconosC: String?
    }
    
}
