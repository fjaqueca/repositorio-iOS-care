//
//  Text+Extensions.swift
//  CareAssistance
//
//  Created by The App Master on 16/12/2024.
//
import SwiftUI

extension Text {
    func justified() -> some View {
        self.multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}
