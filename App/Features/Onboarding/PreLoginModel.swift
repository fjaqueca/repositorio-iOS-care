//
//  PreLoginModel.swift
//  CareAssistance
//
//  Created by The App Master on 26/01/2024.
//

import Foundation
import SwiftUI

struct PreLoginUIState{
    var onboardingUIState = OnboardingUIState()
    var loginUIState = LoginUIState()
    var recoveryUIState =  PasswordRecoveryUIState()
    var singUpUIState = SingUpUIState()
    var singUpFormUIState = SingUpFormUIState()
    var singUpOtpUIState = SingUpOtpUIState()
    var singUpCreatePassUIState = SingUpCreatePassUIState()
    var selectAgreementUIState = SelectAgreementUIState()
    var singInPasswordRecoveryOtpUIState = SingInPasswordRecoveryOtpUIState()
    var singInPasswordResetUIState = SingInPasswordResetUIState()
    var popupRegisterSuccessUIState = PopupRegisterSuccessUIState()
    var popupWithoutEmailUIState = PopupWithoutEmailUIState()
    var popupCreatePassword = PopupCreatePassword()
}
//MARK: - OnboardingView
struct OnboardingUIState{
    var imageBackground: String = ""
    var nav1: NavUIState = NavUIState()
    var nav2: NavUIState = NavUIState()
    var nav3: NavUIState = NavUIState()
    var btnLogin: BtnUIState = BtnUIState()
    var btnRegister: BtnUIState = BtnUIState()
    var iOSVersionBA: Int = 1
    var idAppStore: String = ""
    var iOSVersionApp: Int = 1
    
}
struct NavUIState{
    var imgNav: String = ""
    var textNav: String = ""
    var colorTextNav: String = ""
    var sizeTextNav: String = "18"
}
struct BtnUIState{
    var textBtn: String = ""
    var colorTextBtn: String = ""
    var backgroundBtn: String = ""
    var backgroundPressBtn: String = "18"
    var size: String = ""
    var font: String = "FiraSans-Bold"
    var alignment: String = ""
}
//MARK: - LoginView
struct LoginUIState{
    var imageBackground: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var subTitle: GenericTextUIState = GenericTextUIState()
    var subTextRut: GenericTextUIState = GenericTextUIState()
    var subTextPassword: GenericTextUIState = GenericTextUIState()
    var btnMissPassword: BtnUIState = BtnUIState()
    var btnContinue: BtnUIState = BtnUIState()
    var btnLogin: BtnUIState = BtnUIState()
    var lblTextFieldRut: String = ""
}
struct GenericTextUIState{
    var text: String = ""
    var colorText: String = ""
    var sizeText: String = "18"
    var alignment: String = ""
    var font: String = ""
}

//MARK: - PasswordRecoveryView
struct PasswordRecoveryUIState{
    var imageBackground: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var btnContinue: BtnUIState = BtnUIState()
}

//MARK: - SingUpView
struct SingUpUIState{
    var imageBackground: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var subTitle: GenericTextUIState = GenericTextUIState()
    var btnRegister: BtnUIState = BtnUIState()
    var btnAllReadyRegister: BtnUIState = BtnUIState()
    var enabledRegister: String = ""
    var textPopup: GenericTextUIState = GenericTextUIState()
    var btnPopup: BtnUIState = BtnUIState()
}

//MARK: - SingUpFormView
struct SingUpFormUIState{
    var imageBackground: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var btnSend: BtnUIState = BtnUIState()
}

//MARK: - SingUpOtpView
struct SingUpOtpUIState{
    var imageBackground: String = ""
    var image: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var subtitle: GenericTextUIState = GenericTextUIState()
    var msg: GenericTextUIState = GenericTextUIState()
    var code: GenericTextUIState = GenericTextUIState()
    var btnReSend: GenericTextUIState = GenericTextUIState()
    var btnContinue: BtnUIState = BtnUIState()
    var btnCancel: BtnUIState = BtnUIState()
}

//MARK: - SingUpCreatePasswordView
struct SingUpCreatePassUIState{
    var imageBackground: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var subTitle: GenericTextUIState = GenericTextUIState()
    var btnRegister: BtnUIState = BtnUIState()
    var btnPolitics: BtnUIState = BtnUIState()
}

//MARK: - SelectedAgreementView
struct SelectAgreementUIState{
    var imageBackground: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var btnGetInto: BtnUIState = BtnUIState()
    var footer: GenericTextUIState = GenericTextUIState()
    var seleccionAgreementColor: String = ""
    var defaultAgreementColor: String = ""
}

struct SingInPasswordRecoveryOtpUIState{
    var imageBackground: String = ""
    var image: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var subtitle: GenericTextUIState = GenericTextUIState()
    var msg: GenericTextUIState = GenericTextUIState()
    var code: GenericTextUIState = GenericTextUIState()
    var btnReSend: GenericTextUIState = GenericTextUIState()
    var btnContinue: BtnUIState = BtnUIState()
    var btnCancel: BtnUIState = BtnUIState()
}

//MARK: - SingInPasswordResetView
struct SingInPasswordResetUIState{
    var imageBackground: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var subTitle: GenericTextUIState = GenericTextUIState()
    var btnSend: BtnUIState = BtnUIState()
    var popupMessage: String = ""
    var popupAtr: GenericTextUIState = GenericTextUIState()
    var btnPopup: BtnUIState = BtnUIState()
}
//MARK: - PopupRegisterSuccessView
struct PopupRegisterSuccessUIState{
    var imageBackground: String = ""
    var icon: String = ""
    var msg: GenericTextUIState = GenericTextUIState()
}

//MARK: - PopupRegisterSuccessView
struct PopupWithoutEmailUIState{
    var title: GenericTextUIState = GenericTextUIState()
    var msg: GenericTextUIState = GenericTextUIState()
    var email: String = ""
    var msg2: String = ""
    var msg3: String = ""
    var btnPopup: BtnUIState = BtnUIState()
}

struct PopupCreatePassword{
    var icon: String = ""
    var title: GenericTextUIState = GenericTextUIState()
    var msg: GenericTextUIState = GenericTextUIState()
    var btnPopup: BtnUIState = BtnUIState()
}


struct PopupAllAgreementFalse{
    var logo: String = ""
    var title: BrandAccountText = BrandAccountText()
    var onlyWeb: BrandAccountText = BrandAccountText()
    var btnAcept: NewBtnUIState = NewBtnUIState()
}
struct NewBtnUIState{
    var textBtn: String = ""
    var colorTextBtn: String = ""
    var backgroundBtn: String = ""
    var backgroundPressBtn: String = "18"
    var size: String = ""
    var font = fontTextWithInit(from: "")
}

struct TextAlignmentFromString {
    let alignment: TextAlignment

    init(from string: String) {
        switch string.lowercased() {
        case "left":
            self.alignment = .leading
        case "center":
            self.alignment = .center
        case "right":
            self.alignment = .trailing
        default:
            self.alignment = .leading // Valor por defecto seguro
        }
    }
}
