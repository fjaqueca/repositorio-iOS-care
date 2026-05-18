//
//  SignUpOtpView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 10/09/2022.
//

import SwiftUI
import Combine
import CachedAsyncImage

struct SignUpOtpView: View {
    let rut: String
    let recipient: String
    let mail: String

    @State private var isLoading: Bool = false
    @State private var isPresenting = false
    @State private var resendButtonEnabled = true
    @State private var error: AppError?
    @State private var popup: Popup?
    
    @Binding var navigation: Navigation?
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    @State var otpCode: String = ""
    
    @Binding var UIState: PreLoginUIState
    var body: some View {
        ZStack(alignment: .center) {
            TextField("", text: $otpCode)
                .frame(width: 0, height: 0, alignment: .center)
                .font(Font.system(size: 0))
                .accentColor(.clear)
                .foregroundColor(.clear)
                .multilineTextAlignment(.center)
                .onReceive(Just(otpCode)) { _ in textDidUpdate() }
                .focused($focusedField, equals: .field)
                .task {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.focusedField = .field
                    }
                }
            GeometryReader { proxy in
                ScrollView {
                    contentView
                        .frame(minHeight: proxy.size.height)
                        .frame(width: proxy.size.width)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .popup(item: $popup)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Group {
                // TEMPORAL: dotLottie deshabilitado, se restaura fondo dinámico desde Salesforce.
                // Para reactivar el Lottie animado, comenta el bloque CachedAsyncImage y descomenta el LottieView.
                if UIState.singUpOtpUIState.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: UIState.singUpOtpUIState.imageBackground ),
                        content: { image in
                            image
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .aspectRatio(contentMode: .fill)
                        },
                        placeholder: { ProgressView() }
                    )
                    .eraseToAnyView()
                }
                // LottieView(
                //     animationName: "gradient_background",
                //     loopMode: .loop,
                //     contentMode: .scaleAspectFill
                // )
                // .edgesIgnoringSafeArea(.all)
            }
        )

        .navigationLink(isActive: $isPresenting) {
            SignUpCreatePassword(rut: rut,UIState: $UIState, navigation: $navigation)
        }
    }

    private var contentView: some View {
        VStack(spacing: .margin * 1.5) {
            if UIState.singUpOtpUIState.image != "" {
                CachedAsyncImage(
                    url: URL(string: UIState.singUpOtpUIState.image ),
                    content: { image in
                        image
                            .resizable()
                            .frame(width: 155.0, height: 151.0)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                .eraseToAnyView()
            }else {
                Image("validation")
            }
            Text(UIState.singUpOtpUIState.title.text != "" ? UIState.singUpOtpUIState.title.text : "Validemos \ntu identidad")
                .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.singUpOtpUIState.title.sizeText) ?? 18)))
                .foregroundColor(UIState.singUpOtpUIState.title.colorText != "" ? Color(hex: UIState.singUpOtpUIState.title.colorText) : .primaryText)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            let subAttr = UIState.singUpOtpUIState.subtitle
            let subtitleText = subAttr.text.isEmpty
                ? "Hemos enviado un código de 6 dígitos a tu email:"
                : subAttr.text
            let subFont = subAttr.font.isEmpty ? "FiraSans-Regular" : subAttr.font
            let subSize = CGFloat(Int(subAttr.sizeText) ?? 16)
            let subColor: Color = subAttr.colorText.isEmpty ? .primaryText : Color(hex: subAttr.colorText)
            if mail.isEmpty {
                Text(subtitleText)
                    .font(Font.custom(subFont, size: subSize))
                    .foregroundColor(subColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                (Text(subtitleText + " ")
                    .font(Font.custom(subFont, size: subSize))
                    .foregroundColor(subColor)
                + Text(mail)
                    .font(Font.custom("FiraSans-Bold", size: subSize))
                    .foregroundColor(subColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 7) {
                ForEach(0..<6) { index in
                    ZStack {
                        Color.otp
                            .frame(height: 50)
                            .cornerRadius(.cornerRadius)
                        Text(self.getPin(at: index))
                            .font(Font.custom("FiraSans-Semibold", size: CGFloat(Int(UIState.singUpOtpUIState.code.sizeText) ?? 16)))
                            .foregroundColor(UIState.singUpOtpUIState.code.colorText != "" ? Color(hex: UIState.singUpOtpUIState.code.colorText) : .primaryText)
                            .textCase(.uppercase)
                    }
                }
            }
            .onTapGesture {
                self.focusedField = .field
            }
            
            Spacer()
            Button {
                resendOtp()
                resendButtonEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 180) {
                    resendButtonEnabled = true
                }
            } label: {
                Text(UIState.singUpOtpUIState.btnReSend.text != "" ? UIState.singUpOtpUIState.btnReSend.text : "Reenviar código")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(UIState.singUpOtpUIState.btnReSend.colorText != "" ? Color(hex:UIState.singUpOtpUIState.btnReSend.colorText) : .secondaryText)
            }
            .disabled(!resendButtonEnabled)
            PrimaryButton(title: "Continuar", UIStateBtn: UIState.singUpOtpUIState.btnContinue) {
                HapticManager.impact(style: .medium)
                checkValidationCode()
            }
            .bounceOnTap()
            .disabled(isLoading || otpCode.count != 6)
        }
        .padding(.horizontal, .margin)
        .padding(.bottom, .margin)
        .slideInFromRight()
    }

    private func getPin(at index: Int) -> String {
        guard otpCode.count > index else {
            return ""
        }
        return otpCode[index]
    }
    
    private func textDidUpdate() {
        if otpCode.count > 6 {
            otpCode = String(otpCode.prefix(6))
        }
        
    }
    
    public func checkValidationCode() {
        isLoading = true
        if otpCode.count == 6 {
                focusedField = nil
            }
        Task {
            let result = await Network.shared.checkValidationCode(rut: rut.filter { $0.isLetter || $0.isNumber }, code: otpCode)
            isLoading = false
            switch result {
                case .success:
                    isPresenting = true
                case let .failure(error):
                    AppStatusManager.error(error)
                if otpCode.count == 6 {
                    focusedField = .field
                    }
            }
        }
    }
    
    private func resendOtp() {
        Task {
            let result = await Network.shared.sendValidationCode(rut: rut.filter { $0.isLetter || $0.isNumber })
            switch result {
                case .success:
                    popup = codePopup
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
    
    var codePopup: Popup {
        .init(
            title: "El código de validación fue enviado nuevamente",
            actionTitle: "Aceptar",
            action: {},
            isCancellable: false,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
}

