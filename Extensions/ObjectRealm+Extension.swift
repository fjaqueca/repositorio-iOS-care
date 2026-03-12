//
//  ObjectRealm+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 21/04/2025.
//

import RealmSwift

extension Object {
    func safeValue(forKey key: String) -> Any? {
        if self.objectSchema.properties.contains(where: { $0.name == key }) {
            return self.value(forKey: key)
        }
        return nil
    }
}
