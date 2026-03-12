//
//  Label+Extensions.swift
//  CareAssistance
//
//  Created by Lara Dubs on 07/09/2022.
//

import SwiftUI

extension LabelStyle where Self == InvertedLabelStyle {
    static var inverted: Self {
        InvertedLabelStyle()
    }
}

struct InvertedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

