//
//  Attribute.swift
//  CareAssistance
//
//  Created by The App Master on 05/10/2023.
//

import Foundation
import RealmSwift

struct Attribute: Codable, Hashable{
    let type: String
    let url: String
}

class AttributeRealm: Object, Codable{
    @Persisted var type: String?
    @Persisted var url: String?
}
