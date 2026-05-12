//
//  SignInPasswordRecovery.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/10/2022.
//

import SwiftUI
import CachedAsyncImage

struct SignInPasswordRecovery: View {
    @State private var identificationNumberField: Field = .identificationNumber
    @State private var isLoading: Bool = false
    @State var navigation: (rut: String, response: CodeGenerateResponse, mail: String)?
    @State private var serverErrorMessage: String?
    @State private var userMail: String = ""
    @FocusState private var isRutFocused: Bool
    @Binding var UIState: PreLoginUIState
    @Binding var isPresenting: Bool

    var body: some View {
        VStack {
            Text(UIState.recoveryUIState.title.text != "" ? UIState.recoveryUIState.title.text : "Restablece tu contraseña")
                .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.recoveryUIState.title.sizeText) ?? 16)))
                .foregroundColor(UIState.recoveryUIState.title.colorText != "" ? Color(hex: UIState.recoveryUIState.title.colorText) : .primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 22)

            rutInputField

            if let serverErrorMessage = serverErrorMessage {
                Text(serverErrorMessage)
                    .foregroundColor(.red)
            }

            Spacer()

            PrimaryButton(title: "Continuar", UIStateBtn: UIState.recoveryUIState.btnContinue) {
                HapticManager.impact(style: .medium)
                recoverPassword()
            }
            .bounceOnTap()
            .disabled(!identificationNumberField.isValid)
        }
        .padding(.margin)
        .slideInFromRight()
        .background(
            Group {
                    if UIState.recoveryUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.recoveryUIState.imageBackground ),
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
            SignInPasswordRecoveryOtpView(rut: value.rut, code: value.response, mail: value.mail, UIState: $UIState, isPresenting: $isPresenting)
        }
        .isLoading(isLoading)
    }

    // MARK: - Input RUT modernizado

    private var rutInputField: some View {
        let hasValue = !(identificationNumberField.value ?? "").isEmpty
        let isError = identificationNumberField.validationErrorMessage != nil
        let placeholder = UIState.loginUIState.lblTextFieldRut != "" ? UIState.loginUIState.lblTextFieldRut : "Ej: 12345678-9"
        let accentColor = Color(hex: "#00BBDC")
        let borderColor = isError ? Color(hex: "#E74C3C") :
                          (isRutFocused || hasValue) ? accentColor :
                          Color(hex: "#C8CDD2")

        return VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                HStack(spacing: 12) {
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isRutFocused ? accentColor : Color(hex: "#8A9199"))

                    TextField(placeholder, text: Binding(
                        get: { identificationNumberField.value ?? "" },
                        set: { identificationNumberField.value = $0 }
                    ))
                    .font(Font.custom("FiraSans-Regular", size: 16))
                    .foregroundColor(Color(hex: "#2C3E50"))
                    .focused($isRutFocused)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    if isError {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#E74C3C"))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: isRutFocused ? 1.5 : 1)
                )

                // Label flotante en el borde
                Text(" Número de identificación ")
                    .font(Font.custom("FiraSans-Medium", size: 12))
                    .foregroundColor(isRutFocused ? accentColor : Color(hex: "#6B7680"))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.97))
                    )
                    .padding(.leading, 14)
                    .offset(y: -8)
            }
            .animation(.easeInOut(duration: 0.2), value: isRutFocused)
            .animation(.easeInOut(duration: 0.2), value: isError)

            if let error = identificationNumberField.validationErrorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                    Text(error)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                }
                .foregroundColor(Color(hex: "#E74C3C"))
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: identificationNumberField.validationErrorMessage != nil)
    }

    public func recoverPassword() {
        guard let rut = identificationNumberField.value else {
            return
        }
        isLoading = true
        Task {
            let result = await Network.shared.checkRut(rut: rut.filter { $0.isLetter || $0.isNumber })
            isLoading = false
            switch result {
                case let .success(response):
                    userMail = response.mail ?? ""
                    sendOtp()
                case let .failure(error):
                    if error.httpCode == 404 {
                        // TODO handle this
                    } else {
                        AppStatusManager.error(error)
                    }
            }
        }
    }

    public func sendOtp() {
        guard let rut = identificationNumberField.value else {
            return
        }
        isLoading = true
        Task {
            let result = await Network.shared.sendValidationCode(rut: rut.filter { $0.isLetter || $0.isNumber })
            isLoading = false
            switch result {
                case let.success(value):
                    navigation = (rut, value, userMail)
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}
