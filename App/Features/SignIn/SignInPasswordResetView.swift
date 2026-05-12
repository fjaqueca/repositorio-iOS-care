//
//  SignInPasswordResetView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/10/2022.
//

import SwiftUI
import CachedAsyncImage

struct SignInPasswordResetView: View {
    let rut: String
    @State var otpCode: String
    @State private var isLoading: Bool = false
    @State private var passwordField: Field = .passwordCreate
    @State private var passwordConfirmField: Field = .passwordConfirm
    @State private var showCustomPopup: Bool = false
    @Binding var UIState: PreLoginUIState
    @Binding var isPresenting: Bool
    var body: some View {
        ZStack{
            VStack {
                Text(UIState.singInPasswordResetUIState.title.text != "" ? UIState.singInPasswordResetUIState.title.text : "Restablece tu contraseña")
                    .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.singInPasswordResetUIState.title.sizeText) ?? 18)))
                    .foregroundColor(UIState.singInPasswordResetUIState.title.colorText != "" ? Color(hex: UIState.singInPasswordResetUIState.title.colorText) : .primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(UIState.singInPasswordResetUIState.subTitle.text != "" ? UIState.singInPasswordResetUIState.subTitle.text : "Crea una contraseña mínimo 8 dígitos, \nuna mayúscula, un número y un carácter especial.")
                    .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.singInPasswordResetUIState.subTitle.sizeText) ?? 14)))
                    .foregroundColor(UIState.singInPasswordResetUIState.subTitle.colorText != "" ? Color(hex: UIState.singInPasswordResetUIState.subTitle.colorText) : .primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                FieldView(field: $passwordField)
                FieldView(field: $passwordConfirmField)

                Spacer()
                
                PrimaryButton(title: "Aceptar", UIStateBtn: UIState.singInPasswordResetUIState.btnSend) {
                    HapticManager.impact(style: .medium)
                    renewPassword()
                }
                .bounceOnTap()
                .disabled(isLoading || passwordField.value != passwordConfirmField.value || ((passwordField.value?.isEmpty) == nil) || !passwordField.isValid)

            }
            if showCustomPopup{
                CustomPopup(showCustomPopup: $showCustomPopup, popupData: UIState.singInPasswordResetUIState, isPresenting: $isPresenting)
            }
            
        }
        .padding(.margin)
        .slideInFromRight()
        .background(
            Group {
                    if UIState.singInPasswordResetUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.singInPasswordResetUIState.imageBackground ),
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

    }
    
    public func renewPassword() {
        guard let password = passwordConfirmField.value else {
            return
        }
        isLoading = true
        Task {
            let result = await Network.shared.renewPassword(validationCode: otpCode, newPassword: password, rut: rut.filter { $0.isLetter || $0.isNumber })
            switch result {
                case .success:
                let loginResult = await AppStatusManager.signIn(rut: rut.filter { $0.isLetter || $0.isNumber }, password: password)
                    isLoading = false
                    switch loginResult {
                    case .success:
                        print("Logged in user")
                    case let .failure(error):
                        print("There was an error: \(error)")
                    }
                case let .failure(error):
                    isLoading = false
                withAnimation {
                    self.showCustomPopup = true
                }
//                    AppStatusManager.error(AppError(id: "api.error.generic", name: UIState.singInPasswordResetUIState.popupMessage != "" ? "" : "Se produjo un error." , message: UIState.singInPasswordResetUIState.popupMessage != "" ? UIState.singInPasswordResetUIState.popupMessage : "Por favor contactarse con \nAtención al Cliente." ))

            }
        }
    }
    struct CustomPopup: View {
        @Binding var showCustomPopup: Bool
        let popupData: SingInPasswordResetUIState
        @Binding var isPresenting: Bool
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 10)
                VStack(spacing: 5){
                    Text(popupData.popupMessage != "" ? popupData.popupMessage.htmlToString() : "Se produjo un error.\n\nPor favor contactarse con \nAtención al Cliente.")
                        .font(Font.custom(popupData.popupAtr.font, size: CGFloat(Int(popupData.popupAtr.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.popupAtr.colorText))
                        .multilineTextAlignment(popupData.popupAtr.alignment == "center" ? .center : .leading)
                        .padding(.bottom)
                    Button {
                        HapticManager.impact(style: .light)
                        self.showCustomPopup = false
                        self.isPresenting = false
                    } label: {
                        Text(popupData.btnPopup.textBtn)
                            .font(Font.custom(popupData.btnPopup.font, size: CGFloat(Int(popupData.btnPopup.size) ?? 18)))
                            .foregroundColor(Color(hex: popupData.btnPopup.colorTextBtn))
                    }
                }
                .padding()
            }
            .frame(maxWidth: min(UIScreen.main.bounds.size.width * 0.9, 500), minHeight: 250)
        }
    }
}

