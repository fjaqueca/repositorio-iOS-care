//
//  TransparentButton.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/09/2022.
//

import SwiftUI

struct TransparentButton: View {
    @Environment(\.isLoading) private var isLoading: Bool
    
    private let title: String
    private let action: () -> Void
    let UIStateBtn: BtnUIState?
    
    init(title: String, UIStateBtn: BtnUIState? = nil, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.UIStateBtn = UIStateBtn
    }
    
    var body: some View {
        Button {
            if !isLoading {
                action()
            }
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    Text(UIStateBtn?.textBtn != "" ? UIStateBtn?.textBtn ?? title : title)
                }
            }
            .frame(maxWidth: .infinity)
            .tint(.gray)
            .frame(height: .buttonTitleHeight)
        }
        .buttonStyle(.plain)
        .font(Font.custom(UIStateBtn?.font ?? "FiraSans-Bold", size: CGFloat(Int(UIStateBtn?.size ?? "18") ?? 18)))
        .foregroundColor(UIStateBtn?.colorTextBtn != "" ? Color(hex:UIStateBtn?.colorTextBtn ?? "#004A99") : .primaryText)
        .disabled(isLoading)
    }
}

