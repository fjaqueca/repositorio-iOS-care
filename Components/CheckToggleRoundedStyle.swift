//
//  CheckToggleStyle.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/09/2022.
//

import SwiftUI

struct CheckToggleRoundedStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
                    .lineLimit(2)
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(.secondaryText)
                    .font(.system(size: 32))
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
