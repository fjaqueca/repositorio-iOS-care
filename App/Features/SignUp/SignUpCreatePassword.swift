//
//  SignUpCreatePassword.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/09/2022.
//

import SwiftUI
import CachedAsyncImage

struct SignUpCreatePassword: View {
    let rut: String
    @State private var passwordField: Field = .passwordCreate
    @State private var passwordConfirmField: Field = .passwordConfirm
    @State private var isOn = false
    @State private var isLoading: Bool = false
    @State private var showTermsAndConditions: Bool = false
    @State private var showPrivacyPolicies: Bool = false
    @State private var error: AppError?
    @Binding var UIState: PreLoginUIState
    @Binding var navigation: Navigation?
    var body: some View {
        ZStack{
            
       
        VStack(spacing: .margin * 1.5) {
            Text(UIState.singUpCreatePassUIState.title.text != "" ? UIState.singUpCreatePassUIState.title.text : "¡Ya falta poco!")
                .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.singUpCreatePassUIState.title.sizeText) ?? 18)))
                .foregroundColor(UIState.singUpCreatePassUIState.title.colorText != "" ? Color(hex: UIState.singUpCreatePassUIState.title.colorText) : .primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(UIState.singUpCreatePassUIState.subTitle.text != "" ? UIState.singUpCreatePassUIState.subTitle.text : "Crea una contraseña mínimo 8 dígitos, \nuna mayúscula, un número y un carácter especial.")
                .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.singUpCreatePassUIState.subTitle.sizeText) ?? 14)))
                .foregroundColor(UIState.singUpCreatePassUIState.subTitle.colorText != "" ? Color(hex: UIState.singUpCreatePassUIState.subTitle.colorText) : .primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            FieldView(field: $passwordField)
            FieldView(field: $passwordConfirmField)
            
            Spacer()
            
            HStack {
                Toggle(isOn: $isOn) {
                    Text("")
                }
                .labelsHidden()
                .toggleStyle(CheckToggleRoundedStyle())

                Text("Acepto los [Términos y Condiciones](http://www.terms_and_conditions.com) de Care Assistance.")
                    .foregroundColor(.black)
                    .environment(\.openURL, .init(handler: { _ in
                        self.showTermsAndConditions = true
                        return .handled
                    }))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.appCaptionLarge)
            }

            PrimaryButton(title: "Registrarme", UIStateBtn: UIState.singUpCreatePassUIState.btnRegister) {
                HapticManager.impact(style: .medium)
                signUp()
            }
            .bounceOnTap()
            .disabled(isLoading || passwordField.value != passwordConfirmField.value || isOn == false || ((passwordField.value?.isEmpty) == nil) || !passwordField.isValid)
            Button {
                showPrivacyPolicies = true
            } label: {
                Text(UIState.singUpCreatePassUIState.btnPolitics.textBtn != "" ? UIState.singUpCreatePassUIState.btnPolitics.textBtn : "Políticas de privacidad")
                    .foregroundColor(UIState.singUpCreatePassUIState.btnPolitics.colorTextBtn != "" ? Color(hex:UIState.singUpCreatePassUIState.btnPolitics.colorTextBtn) : .secondaryText)
                    .font(.appCaption)
            }
        }
        
        .navigationLink(isActive: $showTermsAndConditions) {
            LegalsView(.termsAndConditions)
        }
        .navigationLink(isActive: $showPrivacyPolicies) {
            LegalsView(.privacyPolicies)
        }

        .onChange(of: error) { newValue in
            if newValue == nil {
                AppStatusManager.dismissError()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.margin)
        }
        .background(
            Group {
                    if UIState.singUpCreatePassUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.singUpCreatePassUIState.imageBackground ),
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
    
    public func signUp() {
        guard let password = passwordConfirmField.value else {
            return
        }
        isLoading = true
        Task {
            // TODO: Ask to make the signup view to return the credentials
            let result = await Network.shared.signUp(rut: rut, password: password)
            switch result {
                case .success:
                    let loginResult = await AppStatusManager.signIn(rut: rut, password: password)
                    isLoading = false
                    switch loginResult {
                        case .success:
                            print("Signed in")
                        case let .failure(error):
                            AppStatusManager.error(error)
                    }
                case let .failure(error):
                    isLoading = false
                print(error)
                if error.httpCode == 400{
                    AppStatusManager.error(AppError(id: "api.error.AllReadyExist", name: "", message: "Ya tiene contraseña, en caso de no recordarla intente restablecerla."))
                    self.navigation = .login
                }else{
                    AppStatusManager.error(error)
                }
                
            }
        }
    }
}
