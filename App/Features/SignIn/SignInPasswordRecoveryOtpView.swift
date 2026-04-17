//
//  SignInPasswordRecoveryOtpView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/10/2022.
//

import SwiftUI
import Combine
import CachedAsyncImage

struct SignInPasswordRecoveryOtpView: View {
    let rut: String
    let code: CodeGenerateResponse
    let mail: String
    @State private var isLoading: Bool = false
    @State private var navigation: Navigation?
    @State private var popup: Popup?
    @State private var resendButtonEnabled = true
    
    enum Navigation {
        case passwordCreation
        case cancelation
    }
    
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    @State var otpCode: String = ""
    
    @Binding var UIState: PreLoginUIState
    @Binding var isPresenting: Bool
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
        .background(
            Group {
                    if UIState.singInPasswordRecoveryOtpUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.singInPasswordRecoveryOtpUIState.imageBackground ),
                            content: { image in
                                image
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .aspectRatio(contentMode: .fill)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                        .eraseToAnyView()
                    }
                }
        )
        .navigationLink(item: $navigation) { value in
            switch value {
                case .passwordCreation:
                SignInPasswordResetView(rut: rut, otpCode: otpCode, UIState: $UIState,isPresenting: $isPresenting)
                case .cancelation:
                    EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var contentView: some View {
        VStack(spacing: .margin * 1.5) {
            if UIState.singInPasswordRecoveryOtpUIState.image != "" {
                CachedAsyncImage(
                    url: URL(string: UIState.singInPasswordRecoveryOtpUIState.image ),
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
            Text(UIState.singInPasswordRecoveryOtpUIState.title.text != "" ? UIState.singInPasswordRecoveryOtpUIState.title.text : "Validemos \ntu identidad")
                .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.singInPasswordRecoveryOtpUIState.title.sizeText) ?? 18)))
                .foregroundColor(UIState.singInPasswordRecoveryOtpUIState.title.colorText != "" ? Color(hex: UIState.singInPasswordRecoveryOtpUIState.title.colorText) : .primaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            let subAttr = UIState.singInPasswordRecoveryOtpUIState.subtitle
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
            } else {
                (Text(subtitleText + " ")
                    .font(Font.custom(subFont, size: subSize))
                    .foregroundColor(subColor)
                + Text(mail)
                    .font(Font.custom("FiraSans-Bold", size: subSize))
                    .foregroundColor(subColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: 7) {
                ForEach(0..<6) { index in
                    ZStack {
                        Color.otp
                            .frame(height: 50)
                            .cornerRadius(.cornerRadius)
                        Text(self.getPin(at: index))
                            .font(Font.custom("FiraSans-Semibold", size: CGFloat(Int(UIState.singInPasswordRecoveryOtpUIState.code.sizeText) ?? 16)))
                            .foregroundColor(UIState.singInPasswordRecoveryOtpUIState.code.colorText != "" ? Color(hex: UIState.singInPasswordRecoveryOtpUIState.code.colorText) : .primaryText)
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
                Text(UIState.singInPasswordRecoveryOtpUIState.btnReSend.text != "" ? UIState.singInPasswordRecoveryOtpUIState.btnReSend.text : "Reenviar código")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(UIState.singInPasswordRecoveryOtpUIState.btnReSend.colorText != "" ? Color(hex:UIState.singInPasswordRecoveryOtpUIState.btnReSend.colorText) : .secondaryText)
            }
            .disabled(!resendButtonEnabled)
           
            PrimaryButton(title: "Continuar", UIStateBtn: UIState.singInPasswordRecoveryOtpUIState.btnContinue) {
                checkValidationCode()
            }
            .disabled(otpCode.count != 6)
        }
        .padding(.horizontal, .margin)
        .isLoading(isLoading)
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
                    navigation = .passwordCreation
                case let .failure(error):
                    AppStatusManager.error(error)
                if otpCode.count == 6 {
                    focusedField = .field
                    }

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
