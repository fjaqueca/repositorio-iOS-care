//
//  SignUpView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 02/08/2022.
//

import SwiftUI
import CachedAsyncImage

struct SignUpView: View {
    @State private var rutField: Field = .identificationNumber
    @State private var navigationInSingUp: NavigationInSignUp?
    @State private var isLoading: Bool = false
    @State private var serverErrorMessage: String?
    @State private var userMail: String = ""
    @State private var showCustomPopup: Bool = false
    @State private var back: Bool = false
    @Binding var UIState: PreLoginUIState
    @Binding var navigation: Navigation?
    @Environment(\.presentationMode) var presentation
    @State var showPopup: Bool = false
    enum NavigationInSignUp {
        case registration(rut: String)
        case validation(rut: String, code: CodeGenerateResponse)
        case emailPhoneForm(rut: String)
    }
    
    var body: some View {
        ZStack{
            VStack(spacing: .margin) {
                title
                subtitle
                FieldView(field: $rutField, textRut: UIState.loginUIState.lblTextFieldRut)
                if let serverErrorMessage = serverErrorMessage {
                    Text(serverErrorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                PrimaryButton(title: "Registrarme", UIStateBtn: UIState.singUpUIState.btnRegister) {
                    signUp()
                    self.hideKeyboard()
                }
                .disabled(!rutField.isValid)
                .isLoading(isLoading)
                Button {
                    navigation = .login
                } label: {
                    Text(UIState.singUpUIState.btnAllReadyRegister.textBtn != "" ? UIState.singUpUIState.btnAllReadyRegister.textBtn : "Ya estoy registrado")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(UIState.singUpUIState.btnAllReadyRegister.colorTextBtn != "" ? Color(hex:UIState.singUpUIState.btnAllReadyRegister.colorTextBtn) : .secondaryText)
                }
                .font(.appCallout)
                .tint(Color.secondaryText)
                .padding(.bottom, .margin)
                
            }
            .onChange(of: back){ newValue in
                if newValue {
                    self.presentation.wrappedValue.dismiss()
                }
            }
            .padding(.horizontal, .margin)
            .padding(.bottom, .margin)
            .blur(radius: showPopup ? 3 : 0.00001)
            if showCustomPopup{
                CustomPopupSignUp(back: $back, showCustomPopup: $showCustomPopup, popupData: UIState.singUpUIState)
            }
            if showPopup{
                EmailValidationPopup(back: $back, showCustomPopup: $showPopup, popupData: UIState.popupWithoutEmailUIState)
            }
        }
        .background(
            Group {
                    if UIState.singUpUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.singUpUIState.imageBackground ),
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
        .navigationLink(item: $navigationInSingUp) { value in
            switch value {
                case let .registration(rut):
                SignUpFormView(rut: rut, UIState: $UIState, navigation: $navigation)
                case let .validation(rut, code):
                    SignUpOtpView(rut: rut, recipient: code.recipient, mail: userMail, navigation: $navigation, UIState: $UIState)
                case .emailPhoneForm(rut: let rut):
                    SignUpContactInfoFormView(rut: rut, UIState: $UIState, navigation: $navigation)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    public var title: some View {
        Text(UIState.singUpUIState.title.text != "" ? UIState.singUpUIState.title.text : "¡Hola, únete!")
            .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.singUpUIState.title.sizeText) ?? 14)))
            .foregroundColor(UIState.singUpUIState.title.colorText != "" ? Color(hex: UIState.singUpUIState.title.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public var subtitle: some View {
        Text(UIState.singUpUIState.subTitle.text != "" ? UIState.singUpUIState.subTitle.text : "Exploremos juntos todas las \nposibilidades para tu bienestar.")
            .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.singUpUIState.subTitle.sizeText) ?? 14)))
            .foregroundColor(UIState.singUpUIState.subTitle.colorText != "" ? Color(hex: UIState.singUpUIState.subTitle.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public func signUp() {
        guard let rut = rutField.value else {
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
                        if UIState.singUpUIState.enabledRegister == "Si"{
                            self.navigationInSingUp = .registration(rut: rut)
                        }else{
                            withAnimation {
                                self.showCustomPopup = true
                            }
                        }
                    } else {
                        AppStatusManager.error(error)
                    }
            }
        }
    }
    
    public func sendOtp() {
        guard let rut = rutField.value else {
            return
        }
        isLoading = true
        Task {
            let result = await Network.shared.sendValidationCode(rut: rut.filter { $0.isLetter || $0.isNumber })
            isLoading = false
            switch result {
                case let .success(value):
                navigationInSingUp = .validation(rut: rut, code: value)
                case let .failure(error):
                    if error.httpCode == 422 {
                        self.showPopup = true
//                        self.navigationInSingUp = .emailPhoneForm(rut: rut)
                    } else {
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
                        self.back = true
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
}

