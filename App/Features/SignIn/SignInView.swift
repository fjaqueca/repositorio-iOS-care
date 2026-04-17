//
//  SignInView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 04/08/2022.
//

import SwiftUI
import CachedAsyncImage


extension String {
    fileprivate static var signInRut: String {
        "sign_in_rut"
    }
}
struct SignInView: View {
    @State private var isPresenting = false
    @State private var rutField: Field = .identificationNumber(value: UserDefaults.standard.string(forKey: .signInRut))
    @State private var passwordField: Field = .password
    @State private var isLoading: Bool = false
    @Binding var UIState: PreLoginUIState
    @Binding var navigation: Navigation?
    @State private var showCustomPopup: Bool = false
    @State var showPopup: Bool = false
    @State var showCustomPopupCreatePassword: Bool = false
    @State private var back: Bool = false
    @Environment(\.presentationMode) var presentation
    @State private var navigationInSingUp: NavigationInSignUp?
    @State var codeGenerateResponse: String = ""
    @State private var userMail: String = ""
    enum NavigationInSignUp {
        case registration(rut: String)
        case validation(rut: String, code: String)
        case emailPhoneForm(rut: String)
        case loginWithPassword(rut: String)
    }
    var body: some View {
        ZStack{
            VStack(spacing: .margin) {
                ScrollView{
                    title
                    subtitle
                    subText
                        .padding(.vertical)
                    FieldView(field: $rutField, textRut: UIState.loginUIState.lblTextFieldRut)
                    //FieldView(field: $passwordField)
                    
    //                Button {
    //                    isPresenting = true
    //                } label: {
    //                    Text(UIState.loginUIState.btnMissPassword.textBtn != "" ? UIState.loginUIState.btnMissPassword.textBtn : "¿Olvidaste tu contraseña?")
    //                        .frame(maxWidth: .infinity, alignment: .trailing)
    //                }
    //                .padding()
    //                .font(.appCallout)
    //                .foregroundColor(UIState.loginUIState.btnMissPassword.colorTextBtn != "" ? Color(hex:UIState.loginUIState.btnMissPassword.colorTextBtn) : .secondaryText)
                }
                Spacer()
                
                PrimaryButton(title: "Continuar", UIStateBtn: UIState.loginUIState.btnContinue) {
                    isUserInSalesforce()
                }
                .disabled(!rutField.isValid)
                .padding(.bottom, .margin)
    //            Button {
    //                navigation = .signUp
    //            } label: {
    //                Text(UIState.loginUIState.btnRegister.textBtn != "" ? UIState.loginUIState.btnRegister.textBtn : "Registrarme")
    //                    .frame(maxWidth: .infinity)
    //                    .foregroundColor(UIState.loginUIState.btnRegister.colorTextBtn != "" ? Color(hex:UIState.loginUIState.btnRegister.colorTextBtn) : .secondaryText)
    //            }
    //            .font(.appCallout)
    //            .tint(Color.secondaryText)
    //            .padding(.bottom, .margin)
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
//            .navigationLink(isActive: $isPresenting) {
//                SignInPasswordRecovery(UIState: $UIState, isPresenting: $isPresenting)
//            }
            .onChange(of: back){ newValue in
                if newValue {
                    self.presentation.wrappedValue.dismiss()
                }
            }
            .blur(radius: showCustomPopup || showPopup || showCustomPopupCreatePassword ? 3 : 0.00001)
            if showCustomPopup{
                CustomPopupSignUp(back: $back, showCustomPopup: $showCustomPopup, popupData: UIState.singUpUIState)
            }
            if showPopup{
                EmailValidationPopup(back: $back, showCustomPopup: $showPopup, popupData: UIState.popupWithoutEmailUIState)
            }
            if showCustomPopupCreatePassword{
                CustomPopupCreatePassword(showCustomPopupCreatePassword: $showCustomPopupCreatePassword, popupData: UIState.popupCreatePassword, buttonAction: {
                    navigationInSingUp = .validation(rut: rutField.value ?? "", code: codeGenerateResponse)
                })
            }
        }
        .navigationLink(item: $navigationInSingUp) { value in
            switch value {
                case let .registration(rut):
                SignUpFormView(rut: rut, UIState: $UIState, navigation: $navigation)
                case let .validation(rut, code):
                SignUpOtpView(rut: rut, recipient: code, mail: userMail, navigation: $navigation, UIState: $UIState)
                case .emailPhoneForm(rut: let rut):
                    SignUpContactInfoFormView(rut: rut, UIState: $UIState, navigation: $navigation)
                case .loginWithPassword(rut: let rut):
                    SignInWithPasswordView(rut: rut, UIState: $UIState)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
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
        Text(UIState.loginUIState.subTextRut.text)
            .font(Font.custom(UIState.loginUIState.subTextRut.font, size: CGFloat(Int(UIState.loginUIState.subTextRut.sizeText) ?? 14)))
            .foregroundColor(UIState.loginUIState.subTextRut.colorText != "" ? Color(hex: UIState.loginUIState.subTextRut.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
//    public func signIn() {
//        guard let rut = rutField.value, let password = passwordField.value else {
//            return
//        }
//        isLoading = true
//        Task {
//            let result = await AppStatusManager.signIn(rut: rut.filter { $0.isLetter || $0.isNumber }, password: password)
//            isLoading = false
//            switch result {
//                case .success:
//                    UserDefaults.standard.set(rut, forKey: .signInRut)
//                case let .failure(error):
//                    AppStatusManager.error(.unauthorized)
//            }
//        }
//    }
    
    public func isUserInSalesforce() {
        guard let rut = rutField.value else {
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔑 [SignIn] PASO 1: isUserInSalesforce()")
        print("   RUT: \(rut)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        FirebaseLogger.shared.log("🔑 Checking RUT in Salesforce")
        AppStatusManager.setLoading(true)

        Task {
            let result = await Network.shared.checkRut(rut: rut.filter { $0.isLetter || $0.isNumber })
            AppStatusManager.setLoading(false)
            switch result {
                case let .success(response):
                    userMail = response.mail ?? ""

                print("   ✅ RUT encontrado en Salesforce")
                print("   📧 mail: \(userMail.isEmpty ? "nil" : userMail)")
                print("   → Siguiente paso: isUserInCogito()")
                FirebaseLogger.shared.log("✅ RUT found in Salesforce")
                isUserInCogito()


                case let .failure(error):
                    if error.httpCode == 404 {
                        print("   ❌ RUT NO encontrado en Salesforce (404)")
                        print("   enabledRegister: \"\(UIState.singUpUIState.enabledRegister)\"")
                        FirebaseLogger.shared.log("⚠️ RUT not found in Salesforce (404)")
                        if UIState.singUpUIState.enabledRegister == "Si"{
                            print("   → Registro habilitado → Navegando a SignUpFormView")
                            self.navigationInSingUp = .registration(rut: rut)
                        }else{
                                print("   → Registro NO habilitado → Mostrando popup CustomPopupSignUp")
                                self.showCustomPopup = true
                                FirebaseLogger.shared.logErrorPopup(
                                    title: "Usuario no encontrado",
                                    message: "El RUT no está registrado",
                                    source: "SignInView"
                                )

                        }
                    } else {
                        print("   ❌ Error checkRut: httpCode=\(error.httpCode ?? -1) message=\(error.message)")
                        FirebaseLogger.shared.logAuthEvent(
                            action: "check_rut_salesforce",
                            success: false,
                            error: error
                        )
                        AppStatusManager.error(error)
                    }
            }
        }
    }
    public func isUserInCogito() {
        guard let rut = rutField.value else {
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔑 [SignIn] PASO 2: isUserInCogito()")
        print("   RUT: \(rut)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        FirebaseLogger.shared.log("🔑 Checking RUT in Cognito")
        AppStatusManager.setLoading(true)

        Task {
            let result = await Network.shared.checkCognitoRut(rut: rut.filter { $0.isLetter || $0.isNumber })
            AppStatusManager.setLoading(false)
            switch result {
                case let .success(response):

                print("   ✅ Cognito response:")
                print("   exists: \(response.exists ?? false)")
                print("   status: \(response.status ?? "nil")")
                print("   userData.user_status: \(response.userData?.user_status ?? "nil")")
                if let exists = response.exists, exists{
                    print("   → Usuario EXISTE en Cognito → Navegando a loginWithPassword")
                    FirebaseLogger.shared.log("✅ User exists in Cognito")
                    self.navigationInSingUp = .loginWithPassword(rut: rut)
                } else{
                    print("   → Usuario NO existe en Cognito → sendOtp()")
                    FirebaseLogger.shared.log("📝 User does not exist in Cognito, sending OTP")
                    sendOtp()
                }

                case let .failure(error):
                    print("   ❌ Error checkCognitoRut: \(error.message)")
                    FirebaseLogger.shared.logAuthEvent(
                        action: "check_rut_cognito",
                        success: false,
                        error: error
                    )
                    AppStatusManager.error(error)

            }
        }
    }
    public func sendOtp() {
        guard let rut = rutField.value else {
            return
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔑 [SignIn] PASO 3: sendOtp()")
        print("   RUT: \(rut)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        AppStatusManager.setLoading(true)
        Task {
            let result = await Network.shared.sendValidationCode(rut: rut.filter { $0.isLetter || $0.isNumber })
            AppStatusManager.setLoading(false)
            switch result {
                case let .success(value):
                print("   ✅ OTP enviado exitosamente")
                print("   recipient: \(value.recipient)")
                print("   → Mostrando popup CustomPopupCreatePassword")
                print("   (Este popup dice: 'Ya tiene contraseña, en caso de no recordarla intente restablecerla')")
                self.codeGenerateResponse = value.recipient
                self.showCustomPopupCreatePassword = true
                case let .failure(error):
                    if error.httpCode == 422 {
                        print("   ⚠️ Error 422 en sendValidationCode → Mostrando popup EmailValidationPopup")
                        print("   (No se cuenta con email registrado)")
                        self.showPopup = true
                    } else {
                        print("   ❌ Error sendOtp: \(error.message)")
                        AppStatusManager.error(error)
                    }
            }
        }
    }
    
    struct CustomPopupSignUp: View {
        @Binding var back: Bool
        @Binding var showCustomPopup: Bool
        let popupData: SingUpUIState
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 10)
                VStack(spacing: 5){
                    Text(popupData.textPopup.text.htmlToString())
                        .font(Font.custom(popupData.textPopup.font, size: CGFloat(Int(popupData.textPopup.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.textPopup.colorText))
                        .multilineTextAlignment(popupData.textPopup.alignment == "center" ? .center : .leading)
                        .padding(.bottom)
                    Button {
                        self.showCustomPopup = false
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
    struct EmailValidationPopup: View {
        @Binding var back: Bool
        @Binding var showCustomPopup: Bool
        let popupData: PopupWithoutEmailUIState
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 10)
                VStack(spacing: 5){
                    Text(popupData.title.text != "" ? popupData.title.text : "¡Ya falta poco!")
                        .font(Font.custom(popupData.title.font, size: CGFloat(Int(popupData.title.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.title.colorText))
                        .multilineTextAlignment(popupData.title.alignment == "center" ? .center : .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(popupData.msg.text != "" ? popupData.msg.text : "Hemos validado en nuestros registros\n y no contamos con tu e-mail para\n entregar tu clave inicial.")
                        .font(Font.custom(popupData.msg.font, size: CGFloat(Int(popupData.msg.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.msg.colorText))
                        .multilineTextAlignment(popupData.msg.alignment == "center" ? .center : .leading)
                    Text(popupData.msg2 != "" ? popupData.msg2 : "Por favor,\n envianos tu RUT y correo electrónico a:")
                        .font(Font.custom(popupData.msg.font, size: CGFloat(Int(popupData.msg.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.msg.colorText))
                        .multilineTextAlignment(popupData.msg.alignment == "center" ? .center : .leading)
                    Link(popupData.email != "" ? popupData.email : "contacto@careassistance.com", destination: URL(string: "mailto:\(popupData.email != "" ? popupData.email : "contacto@careassistance.com")")!)
                        .font(Font.custom(popupData.msg.font, size: CGFloat(Int(popupData.msg.sizeText) ?? 18)))
                        .multilineTextAlignment(popupData.msg.alignment == "center" ? .center : .leading)
                        

                    Text(popupData.msg3 != "" ? popupData.msg3 : "¡Te esperamos!")
                        .font(Font.custom(popupData.msg.font, size: CGFloat(Int(popupData.msg.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.msg.colorText))
                        .multilineTextAlignment(popupData.msg.alignment == "center" ? .center : .leading)
                        .padding(.bottom)
                    Button {
                        self.showCustomPopup = false
                        self.back = true
                    } label: {
                        Text(popupData.btnPopup.textBtn != "" ? popupData.btnPopup.textBtn : "Aceptar")
                            .font(Font.custom(popupData.btnPopup.font, size: CGFloat(Int(popupData.btnPopup.size) ?? 18)))
                            .foregroundColor(Color(hex: popupData.btnPopup.colorTextBtn))
                    }
                }
                .padding()
            }
            .frame(maxWidth: min(UIScreen.main.bounds.size.width * 0.9, 500), minHeight: 250)
        }
    }

    struct CustomPopupCreatePassword: View {
        @Binding var showCustomPopupCreatePassword: Bool
        let popupData: PopupCreatePassword
        let buttonAction: () -> Void
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 10)
                VStack(spacing: 5){
                    if popupData.icon != "" {
                        CachedAsyncImage(
                            url: URL(string: popupData.icon ),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 60, alignment: .leading)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                        .eraseToAnyView()
                    }
                    HStack{
                        if popupData.title.alignment.lowercased() == "left" {
                            Spacer()
                        }
                        Text(popupData.title.text)
                            .font(Font.custom(popupData.title.font, size: CGFloat(Int(popupData.title.sizeText) ?? 18)))
                            .foregroundColor(Color(hex: popupData.title.colorText))
                            .multilineTextAlignment(popupData.title.alignment == "center" ? .center : .leading)
                            .padding(.bottom)
                            .padding(.horizontal)
                        if popupData.title.alignment.lowercased() == "right" {
                            Spacer()
                        }
                    }
                    
                    HStack{
                        Text(popupData.msg.text)
                            .font(Font.custom(popupData.msg.font, size: CGFloat(Int(popupData.msg.sizeText) ?? 18)))
                            .foregroundColor(Color(hex: popupData.msg.colorText))
                            .multilineTextAlignment(popupData.msg.alignment.lowercased() == "center" ? .center : popupData.msg.alignment.lowercased() == "left" ? .leading : .trailing)
                            .padding(.bottom)
                            .padding(.horizontal)
                    }
                    HStack{
                        if popupData.btnPopup.alignment.lowercased() == "left" {
                            Spacer()
                        }
                        
                        Button {
                            buttonAction()
                            self.showCustomPopupCreatePassword = false
                        } label: {
                            Text(popupData.btnPopup.textBtn)
                                .font(Font.custom(popupData.btnPopup.font, size: CGFloat(Int(popupData.btnPopup.size) ?? 18)))
                                .foregroundColor(Color(hex: popupData.btnPopup.colorTextBtn))
                        }
                        if popupData.btnPopup.alignment.lowercased() == "right" {
                            Spacer()
                        }

                    }
                }
                .padding()
            }
            .frame(maxWidth: min(UIScreen.main.bounds.size.width * 0.9, 500), minHeight: 300)
        }
    }

}
