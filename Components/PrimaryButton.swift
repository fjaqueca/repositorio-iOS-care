//
//  PrimaryButton.swift
//  CareAssistance
//
//  Created by Lara Dubs on 04/08/2022.
//

import SwiftUI

struct PrimaryButton: View {
    @Environment(\.isLoading) private var isLoading: Bool

    private let title: String
    private var backgroundColor: Color
    let UIStateBtn: BtnUIState?
    private let action: () -> Void
    private var haveImage: Bool

    init(title: String, backgroundColor: Color = .secondary, UIStateBtn: BtnUIState? = nil, haveImage: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.UIStateBtn = UIStateBtn
        self.action = action
        self.haveImage = haveImage
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
                    HStack{
                        if haveImage{
                            Image("video")
                                .renderingMode(.template)
                                .foregroundColor(UIStateBtn?.colorTextBtn != "" ? Color(hex:UIStateBtn?.colorTextBtn ?? "#ffffff") : .white)
                        }
                    
                        Text(UIStateBtn?.textBtn != "" ? UIStateBtn?.textBtn ?? title : title)
                        .font(Font.custom((UIStateBtn?.font ?? "FiraSans-Bold"), size: CGFloat(Int(UIStateBtn?.size ?? "18") ?? 18)))
                            .foregroundColor(UIStateBtn?.colorTextBtn != "" ? Color(hex:UIStateBtn?.colorTextBtn ?? "#ffffff") : .white)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .tint(.gray)
            .frame(height: .buttonTitleHeight)
        }
        .buttonStyle(.borderedProminent)
        // TEMPORAL: color de fondo dinámico (UIStateBtn.backgroundBtn) reemplazado
        // por hardcode #0857A0 para evaluar contraste sobre el fondo gradiente
        // animado en pre-login/onboarding. Revertir descomentando la línea original.
        // .tint(UIStateBtn?.backgroundBtn != "" ? Color(hex:UIStateBtn?.backgroundBtn ?? "#57BAAF") : backgroundColor)
        .tint(Color(hex: "#0857A0"))
        .disabled(isLoading)
        
    }
}
