//
//  SecondaryButton.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/03/2023.
//

import SwiftUI

struct SecondaryButton: View {
    private let title: String
    private var backgroundColor: Color
    private let action: () -> Void
    
    init(title: String, backgroundColor: Color = .secondary, action: @escaping () -> Void) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .tint(.white)
                .font(.appCaptionLarge)
                .frame(height: .buttonSecondaryTitleHeight)
        }
        .tint(backgroundColor)
        .buttonStyle(.borderedProminent)
    }
}
