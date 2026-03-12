//
//  CheckToggleSquareStyle.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/04/2023.
//

import SwiftUI

struct CheckToggleSquareStyle: ToggleStyle {
    let foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            ZStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(foregroundColor)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
