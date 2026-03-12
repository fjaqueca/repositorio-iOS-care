//
//  SignInWithPasswordView.swift
//  CareAssistance
//
//  Created by The App Master on 19/11/2025.
//

import SwiftUI
import CachedAsyncImage

extension String {
    fileprivate static var signInRut: String {
        "sign_in_rut"
    }
}
struct SignInWithPasswordView: View {
    @State private var isPresenting = false
    @State var rut: String
    @State private var passwordField: Field = .password
    @State private var isLoading: Bool = false
    @Binding var UIState: PreLoginUIState
    @State private var showCustomPopup: Bool = false
    @State private var back: Bool = false
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        ZStack{
            VStack(spacing: .margin) {
                ScrollView{
                    title
                    subtitle
                    subText
                        .padding(.vertical)
                    FieldView(field: $passwordField)
                    
                    Button {
                        isPresenting = true
                    } label: {
                        Text(UIState.loginUIState.btnMissPassword.textBtn != "" ? UIState.loginUIState.btnMissPassword.textBtn : "¿Olvidaste tu contraseña?")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .font(.appCallout)
                    .foregroundColor(UIState.loginUIState.btnMissPassword.colorTextBtn != "" ? Color(hex:UIState.loginUIState.btnMissPassword.colorTextBtn) : .secondaryText)
                }
                Spacer()
                
                PrimaryButton(title: "Iniciar Sesion", UIStateBtn: UIState.loginUIState.btnLogin) {
                    signIn()
                }
                .disabled(((passwordField.value?.isEmpty) == nil))
                .padding(.bottom, .margin)
            }
            .padding(.horizontal, .margin)
            .padding(.bottom, .margin)
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Group {
                    if UIState.loginUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.loginUIState.imageBackground ),
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
            .navigationLink(isActive: $isPresenting) {
                SignInPasswordRecovery(UIState: $UIState, isPresenting: $isPresenting)
            }
            
            
        }
    }
    public var title: some View {
        Text(UIState.loginUIState.title.text != "" ? UIState.loginUIState.title.text : "¡Hola de nuevo!")
            .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.loginUIState.title.sizeText) ?? 14)))
            .foregroundColor(UIState.loginUIState.title.colorText != "" ? Color(hex: UIState.loginUIState.title.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public var subtitle: some View {
        Text(UIState.loginUIState.subTitle.text != "" ? UIState.loginUIState.subTitle.text : "Bienvenido, descubramos juntos cómo vivir sano y saludable.")
            .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.loginUIState.subTitle.sizeText) ?? 14)))
            .foregroundColor(UIState.loginUIState.subTitle.colorText != "" ? Color(hex: UIState.loginUIState.subTitle.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public var subText: some View {
        Text(UIState.loginUIState.subTextPassword.text)
            .font(Font.custom(UIState.loginUIState.subTextPassword.font, size: CGFloat(Int(UIState.loginUIState.subTextPassword.sizeText) ?? 14)))
            .foregroundColor(UIState.loginUIState.subTextPassword.colorText != "" ? Color(hex: UIState.loginUIState.subTextPassword.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public func signIn() {
        guard let password = passwordField.value else {
            return
        }
        isLoading = true
        Task {
            let result = await AppStatusManager.signIn(rut: rut.filter { $0.isLetter || $0.isNumber }, password: password)
            isLoading = false
            switch result {
                case .success:
                    UserDefaults.standard.set(rut, forKey: .signInRut)
                case let .failure(error):
                    AppStatusManager.error(.unauthorized)
            }
        }
    }
}
