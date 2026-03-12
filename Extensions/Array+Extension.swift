//
//  Array+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 21/04/2025.
//

import Foundation

extension Array where Element == String {
    func valid(count: Int) -> [String]? {
        self.count >= count ? self : nil
    }
}
