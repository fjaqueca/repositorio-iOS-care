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
    @State var navigation: (rut: String, response: CodeGenerateResponse)?
    @State private var serverErrorMessage: String?
    @Binding var UIState: PreLoginUIState
    @Binding var isPresenting: Bool
    var body: some View {
        VStack {
            Text(UIState.recoveryUIState.title.text != "" ? UIState.recoveryUIState.title.text : "Restablece tu contraseña")
                .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.recoveryUIState.title.sizeText) ?? 16)))
                .foregroundColor(UIState.recoveryUIState.title.colorText != "" ? Color(hex: UIState.recoveryUIState.title.colorText) : .primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            FieldView(field: $identificationNumberField, textRut: UIState.loginUIState.lblTextFieldRut)
            if let serverErrorMessage = serverErrorMessage {
                Text(serverErrorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            PrimaryButton(title: "Continuar", UIStateBtn: UIState.recoveryUIState.btnContinue) {
                recoverPassword()
            }
            .disabled(!identificationNumberField.isValid)
        }
        .padding(.margin)
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
            SignInPasswordRecoveryOtpView(rut: value.rut, code: value.response, UIState: $UIState, isPresenting: $isPresenting)
        }
        .isLoading(isLoading)
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
                case .success:
                    // TODO: Handle not validate user for now it goes through.
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
                    navigation = (rut, value)
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}
