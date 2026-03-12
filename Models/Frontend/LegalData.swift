//
//  Legal.swift
//  CareAssistance
//
//  Created by Lara Dubs on 21/12/2022.
//

import Foundation
import RealmSwift

class Legal: Object, ObjectKeyIdentifiable, Decodable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var content: String
}
