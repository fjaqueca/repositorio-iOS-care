//
//  Promotion.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import RealmSwift
import SwiftUI

class Promotion: Object, Identifiable, Decodable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var urlDecripcion: String
    @Persisted var url: String
}
