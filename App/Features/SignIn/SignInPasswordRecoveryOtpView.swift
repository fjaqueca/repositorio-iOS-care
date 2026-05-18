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
    @State private var otpBoxScales: [CGFloat] = Array(repeating: 1.0, count: 6)

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
    @Environment(\.presentationMode) var presentation

    var body: some View {
        ZStack(alignment: .center) {
            TextField("", text: $otpCode)
                .frame(width: 0, height: 0, alignment: .center)
                .font(Font.system(size: 0))
                .accentColor(.clear)
                .foregroundColor(.clear)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
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
                // TEMPORAL: dotLottie deshabilitado, se restaura fondo dinámico desde Salesforce.
                // Para reactivar el Lottie animado, comenta el bloque CachedAsyncImage y descomenta el LottieView.
                if UIState.singInPasswordRecoveryOtpUIState.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: UIState.singInPasswordRecoveryOtpUIState.imageBackground ),
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

            // MARK: - OTP Boxes modernizadas
            otpBoxes

            Spacer()

            // MARK: - Reenviar código
            resendButton

            // MARK: - Botones Cancelar + Continuar
            HStack(spacing: 12) {
                // Cancelar
                Button {
                    HapticManager.impact(style: .light)
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    Text("Cancelar")
                        .font(Font.custom("FiraSans-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: .buttonTitleHeight)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#E74C3C"))
                .bounceOnTap()

                // Continuar
                PrimaryButton(title: "Continuar", UIStateBtn: UIState.singInPasswordRecoveryOtpUIState.btnContinue) {
                    HapticManager.impact(style: .medium)
                    checkValidationCode()
                }
                .bounceOnTap()
                .disabled(isLoading || otpCode.count != 6)
            }
        }
        .padding(.horizontal, .margin)
        .slideInFromRight()
        .isLoading(isLoading)
    }

    // MARK: - OTP Boxes

    private var otpBoxes: some View {
        HStack(spacing: 10) {
            ForEach(0..<6) { index in
                let hasFilled = otpCode.count > index
                let isActive = otpCode.count == index

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.85))
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            hasFilled ? Color(hex: "#00BBDC") :
                            isActive ? Color(hex: "#00BBDC") :
                            Color(hex: "#C8CDD2"),
                            lineWidth: isActive ? 2 : (hasFilled ? 1.5 : 1)
                        )

                    Text(self.getPin(at: index))
                        .font(Font.custom("FiraSans-Bold", size: 22))
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .textCase(.uppercase)
                }
                .frame(height: 52)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .scaleEffect(otpBoxScales[index])
            }
        }
        .onTapGesture {
            self.focusedField = .field
        }
        .animation(.easeInOut(duration: 0.15), value: otpCode)
    }

    // MARK: - Reenviar código

    private var resendButton: some View {
        Button {
            resendOtp()
            resendButtonEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 180) {
                resendButtonEnabled = true
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 13, weight: .medium))
                Text(UIState.singInPasswordRecoveryOtpUIState.btnReSend.text != "" ? UIState.singInPasswordRecoveryOtpUIState.btnReSend.text : "Reenviar código")
                    .font(Font.custom("FiraSans-Medium", size: 14))
                    .underline(resendButtonEnabled)
            }
            .foregroundColor(resendButtonEnabled ? Color(hex: "#00BBDC") : Color(hex: "#C8CDD2"))
            .frame(maxWidth: .infinity)
        }
        .disabled(!resendButtonEnabled)
        .animation(.easeInOut(duration: 0.2), value: resendButtonEnabled)
    }

    // MARK: - Helpers

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
        // Bounce en la caja que acaba de recibir dígito
        let filledIndex = otpCode.count - 1
        if filledIndex >= 0 && filledIndex < 6 {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5, blendDuration: 0.1)) {
                otpBoxScales[filledIndex] = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.1)) {
                    otpBoxScales[filledIndex] = 1.0
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
