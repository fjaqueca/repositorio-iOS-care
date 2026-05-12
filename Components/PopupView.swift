//
//  PopupView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 16/11/2022.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct PopupView<Footer: View>: View {
    private let image: String?
    private let title: String
    private let message: String?
    private let footer: () -> Footer
    private let UIStateTitle: GreetingUIState?
    private let UIStateMessage: GreetingUIState?
    private let UIStateButton: GreetingUIState?
    private let UIStateCancelButton: GreetingUIState?
    
    init(image: String? = nil, title: String, message: String? = nil, UIStateTitle: GreetingUIState?, UIStateMessage: GreetingUIState?, UIStateButton: GreetingUIState?, UIStateCancelButton: GreetingUIState?, @ViewBuilder footer: @escaping () -> Footer) {
        self.image = image
        self.title = title
        self.message = message
        self.footer = footer
        self.UIStateTitle = UIStateTitle
        self.UIStateMessage = UIStateMessage
        self.UIStateButton = UIStateButton
        self.UIStateCancelButton = UIStateCancelButton
    }
    
    @State private var iconScale: CGFloat = 0.0

    var body: some View {
        VStack(spacing: UIStateButton?.show != "biggest" ? 16 : 10) {
            // Ícono con animación bounce-in
            Group {
                switch image {
                case "", "appointment-cancel", "checkmark", "exclamationmark.triangle", "appointment-clock", nil:
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#FFF3E0"))
                            .frame(width: 64, height: 64)
                        Image(systemName: image == "checkmark" ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(image == "checkmark" ? Color(hex: "#00BBDC") : Color(hex: "#FF9800"))
                    }
                    .scaleEffect(iconScale)
                    .onAppear {
                        iconScale = 0.0
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                            iconScale = 1.0
                        }
                    }
                default:
                    CachedAsyncImage(
                        url: URL(string: image ?? ""),
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 60, alignment: .leading)
                        },
                        placeholder: {
                            ProgressView()
                        })
                }
            }

            Text(title)
                .font(Font.custom(UIStateTitle?.font ?? "FiraSans-Bold", size: CGFloat(Int(UIStateTitle?.size ?? "18") ?? 18)))
                .foregroundColor(UIStateTitle?.color != "" ? Color(hex: UIStateTitle?.color ?? "#333333") : .primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let message {
                Text(message)
                    .font(Font.custom(UIStateMessage?.font ?? "FiraSans-Regular", size: CGFloat(Int(UIStateMessage?.size ?? "14") ?? 14)))
                    .foregroundColor(UIStateMessage?.color != "" ? Color(hex: UIStateMessage?.color ?? "#777777") : .primary)
                    .multilineTextAlignment(.center)
            }

            footer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        Color.gray
            .popup(item: .constant(
                .init(
                    image: "checkmark",
                    title: "Su cita se confirmó con éxito.",
                    message: "Lore ipsum bla ble bla blasdlalsdlasd a sdasd asd ads asd asd asd as dasd asd asd aas dasd asd asa sdasd as dasd",
                    actionTitle: "Aceptar",
                    action: {},
                    UIStateTitle: nil,
                    UIStateMessage: nil,
                    UIStateButton: nil,
                    UIStateCancelButton: nil
                )
            ))
    }
}
