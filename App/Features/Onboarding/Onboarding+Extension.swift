//
//  Onboarding+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 30/01/2024.
//

import Foundation

extension OnboardingView {
    func loadUIState(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                if brandAccount.Name == "PreLogin"{
                    // RAW dump de todos los elementos del PreLogin
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("📋 [PreLogin] RAW BrandAccount - Todos los elementos")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    let elements: [(Int, String?, [(Int, String?)])] = [
                        (1, brandAccount.nombreElemento1C, [
                            (1, brandAccount.valor11C), (2, brandAccount.valor12C), (3, brandAccount.valor13C),
                            (4, brandAccount.valor14C), (5, brandAccount.valor15C), (6, brandAccount.valor16C),
                            (7, brandAccount.valor17C), (8, brandAccount.valor18C), (9, brandAccount.valor19C)
                        ]),
                        (2, brandAccount.nombreElemento2C, [
                            (1, brandAccount.valor21C), (2, brandAccount.valor22C), (3, brandAccount.valor23C),
                            (4, brandAccount.valor24C), (5, brandAccount.valor25C), (6, brandAccount.valor26C),
                            (7, brandAccount.valor27C), (8, brandAccount.valor28C), (9, brandAccount.valor29C),
                            (10, brandAccount.valor210C), (11, brandAccount.valor211C), (12, brandAccount.valor212C),
                            (13, brandAccount.valor213C), (14, brandAccount.valor214C), (15, brandAccount.valor215C),
                            (16, brandAccount.valor216C)
                        ]),
                        (3, brandAccount.nombreElemento3C, [
                            (1, brandAccount.valor31C), (2, brandAccount.valor32C), (3, brandAccount.valor33C),
                            (4, brandAccount.valor34C), (5, brandAccount.valor35C), (6, brandAccount.valor36C),
                            (7, brandAccount.valor37C), (8, brandAccount.valor38C), (9, brandAccount.valor39C),
                            (10, brandAccount.valor310C), (11, brandAccount.valor311C), (12, brandAccount.valor312C),
                            (13, brandAccount.valor313C), (14, brandAccount.valor314C), (15, brandAccount.valor315C),
                            (16, brandAccount.valor316C)
                        ]),
                        (4, brandAccount.nombreElemento4C, [
                            (1, brandAccount.valor41C), (2, brandAccount.valor42C), (3, brandAccount.valor43C),
                            (4, brandAccount.valor44C), (5, brandAccount.valor45C), (6, brandAccount.valor46C),
                            (7, brandAccount.valor47C), (8, brandAccount.valor48C), (9, brandAccount.valor49C),
                            (10, brandAccount.valor410C), (11, brandAccount.valor411C), (12, brandAccount.valor412C),
                            (13, brandAccount.valor413C), (14, brandAccount.valor414C), (15, brandAccount.valor415C),
                            (16, brandAccount.valor416C)
                        ]),
                        (5, brandAccount.nombreElemento5C, [
                            (1, brandAccount.valor51C), (2, brandAccount.valor52C), (3, brandAccount.valor53C),
                            (4, brandAccount.valor54C), (5, brandAccount.valor55C), (6, brandAccount.valor56C),
                            (7, brandAccount.valor57C), (8, brandAccount.valor58C), (9, brandAccount.valor59C),
                            (10, brandAccount.valor510C), (11, brandAccount.valor511C), (12, brandAccount.valor512C),
                            (13, brandAccount.valor513C), (14, brandAccount.valor514C), (15, brandAccount.valor515C),
                            (16, brandAccount.valor516C)
                        ]),
                        (6, brandAccount.nombreElemento6C, [
                            (1, brandAccount.valor61C), (2, brandAccount.valor62C), (3, brandAccount.valor63C),
                            (4, brandAccount.valor64C), (5, brandAccount.valor65C), (6, brandAccount.valor66C),
                            (7, brandAccount.valor67C), (8, brandAccount.valor68C), (9, brandAccount.valor69C),
                            (10, brandAccount.valor610C), (11, brandAccount.valor611C), (12, brandAccount.valor612C),
                            (13, brandAccount.valor613C), (14, brandAccount.valor614C), (15, brandAccount.valor615C),
                            (16, brandAccount.valor616C)
                        ]),
                        (7, brandAccount.nombreElemento7C, [
                            (1, brandAccount.valor71C), (2, brandAccount.valor72C), (3, brandAccount.valor73C),
                            (4, brandAccount.valor74C), (5, brandAccount.valor75C), (6, brandAccount.valor76C),
                            (7, brandAccount.valor77C), (8, brandAccount.valor78C), (9, brandAccount.valor79C),
                            (10, brandAccount.valor710C), (11, brandAccount.valor711C), (12, brandAccount.valor712C),
                            (13, brandAccount.valor713C), (14, brandAccount.valor714C), (15, brandAccount.valor715C),
                            (16, brandAccount.valor716C)
                        ]),
                        (8, brandAccount.nombreElemento8C, [
                            (1, brandAccount.valor81C), (2, brandAccount.valor82C), (3, brandAccount.valor83C),
                            (4, brandAccount.valor84C), (5, brandAccount.valor85C), (6, brandAccount.valor86C),
                            (7, brandAccount.valor87C), (8, brandAccount.valor88C), (9, brandAccount.valor89C),
                            (10, brandAccount.valor810C), (11, brandAccount.valor811C), (12, brandAccount.valor812C),
                            (13, brandAccount.valor813C), (14, brandAccount.valor814C), (15, brandAccount.valor815C),
                            (16, brandAccount.valor816C)
                        ]),
                        (9, brandAccount.nombreElemento9C, [
                            (1, brandAccount.valor91C), (2, brandAccount.valor92C), (3, brandAccount.valor93C),
                            (4, brandAccount.valor94C), (5, brandAccount.valor95C), (6, brandAccount.valor96C),
                            (7, brandAccount.valor97C), (8, brandAccount.valor98C), (9, brandAccount.valor99C),
                            (10, brandAccount.valor910C), (11, brandAccount.valor911C), (12, brandAccount.valor912C),
                            (13, brandAccount.valor913C), (14, brandAccount.valor914C), (15, brandAccount.valor915C),
                            (16, brandAccount.valor916C)
                        ]),
                        (10, brandAccount.nombreElemento10C, [
                            (1, brandAccount.valor101C), (2, brandAccount.valor102C), (3, brandAccount.valor103C),
                            (4, brandAccount.valor104C), (5, brandAccount.valor105C), (6, brandAccount.valor106C),
                            (7, brandAccount.valor107C), (8, brandAccount.valor108C), (9, brandAccount.valor109C),
                            (10, brandAccount.valor1010C), (11, brandAccount.valor1011C), (12, brandAccount.valor1012C),
                            (13, brandAccount.valor1013C), (14, brandAccount.valor1014C), (15, brandAccount.valor1015C),
                            (16, brandAccount.valor1016C)
                        ]),
                        (11, brandAccount.nombreElemento11C, [
                            (1, brandAccount.Valor_11_1__c), (2, brandAccount.Valor_11_2__c), (3, brandAccount.Valor_11_3__c),
                            (4, brandAccount.Valor_11_4__c), (5, brandAccount.Valor_11_5__c), (6, brandAccount.Valor_11_6__c),
                            (7, brandAccount.Valor_11_7__c), (8, brandAccount.Valor_11_8__c), (9, brandAccount.Valor_11_9__c),
                            (10, brandAccount.Valor_11_10__c), (11, brandAccount.Valor_11_11__c), (12, brandAccount.Valor_11_12__c),
                            (13, brandAccount.Valor_11_13__c), (14, brandAccount.Valor_11_14__c), (15, brandAccount.Valor_11_15__c),
                            (16, brandAccount.Valor_11_16__c)
                        ]),
                        (12, brandAccount.nombreElemento12C, [
                            (1, brandAccount.valor121C), (2, brandAccount.valor122C), (3, brandAccount.valor123C),
                            (4, brandAccount.valor124C), (5, brandAccount.valor125C), (6, brandAccount.valor126C),
                            (7, brandAccount.valor127C), (8, brandAccount.valor128C), (9, brandAccount.valor129C),
                            (10, brandAccount.valor1210C), (11, brandAccount.valor1211C), (12, brandAccount.valor1212C),
                            (13, brandAccount.valor1213C), (14, brandAccount.valor1214C), (15, brandAccount.valor1215C),
                            (16, brandAccount.valor1216C)
                        ]),
                        (13, brandAccount.nombreElemento13C, [
                            (1, brandAccount.valor131C), (2, brandAccount.valor132C), (3, brandAccount.valor133C),
                            (4, brandAccount.valor134C), (5, brandAccount.valor135C), (6, brandAccount.valor136C),
                            (7, brandAccount.valor137C), (8, brandAccount.valor138C), (9, brandAccount.valor139C),
                            (10, brandAccount.valor1310C), (11, brandAccount.valor1311C), (12, brandAccount.valor1312C),
                            (13, brandAccount.valor1313C), (14, brandAccount.valor1314C), (15, brandAccount.valor1315C),
                            (16, brandAccount.valor1316C)
                        ])
                    ]
                    for (elemNum, elemName, valores) in elements {
                        let name = elemName ?? "nil"
                        let hasValues = valores.contains { $0.1 != nil }
                        if hasValues || elemName != nil {
                            print("┌─ Elemento \(elemNum): Nombre=\"\(name)\"")
                            for (valNum, val) in valores {
                                if let v = val {
                                    print("│  [\(elemNum).\(valNum)] → \"\(v)\"")
                                }
                            }
                            print("└────────────────────────────────────────────────")
                        }
                    }
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                    //MARK: - OnboardingUIState
                    self.UIState.onboardingUIState.imageBackground = brandAccount.valor11C ?? ""
                    
                    self.UIState.onboardingUIState.nav1.imgNav = brandAccount.valor12C ?? ""
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("🖼️ [Onboarding] URLs de imágenes del carousel:")
                    print("   Imagen 1: \(brandAccount.valor12C ?? "vacío")")
                    print("   Imagen 2: \(brandAccount.valor15C ?? "vacío")")
                    print("   Imagen 3: \(brandAccount.valor18C ?? "vacío")")
                    print("   Fondo:    \(brandAccount.valor11C ?? "vacío")")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    self.UIState.onboardingUIState.nav1.textNav = brandAccount.valor13C ?? ""
                    if let valor14 = brandAccount.valor14C?.components(separatedBy: ";"), valor14.count >= 2{
                        self.UIState.onboardingUIState.nav1.colorTextNav = valor14[0]
                        self.UIState.onboardingUIState.nav1.sizeTextNav = valor14[1]
                    }
                    
                    self.UIState.onboardingUIState.nav2.imgNav = brandAccount.valor15C ?? ""
                    self.UIState.onboardingUIState.nav2.textNav = brandAccount.valor16C ?? ""
                    if let valor17 = brandAccount.valor17C?.components(separatedBy: ";"), valor17.count >= 2{
                        self.UIState.onboardingUIState.nav2.colorTextNav = valor17[0]
                        self.UIState.onboardingUIState.nav2.sizeTextNav = valor17[1]
                    }
                    
                    self.UIState.onboardingUIState.nav3.imgNav = brandAccount.valor18C ?? ""
                    self.UIState.onboardingUIState.nav3.textNav = brandAccount.valor19C ?? ""
                    if let valor110 = brandAccount.Valor_1_10__c?.components(separatedBy: ";"), valor110.count >= 2{
                        self.UIState.onboardingUIState.nav3.colorTextNav = valor110[0]
                        self.UIState.onboardingUIState.nav3.sizeTextNav = valor110[1]
                    }
                    
                    self.UIState.onboardingUIState.btnLogin.textBtn = brandAccount.Valor_1_11__c ?? ""
                    if let valor112 = brandAccount.Valor_1_12__c?.components(separatedBy: ";"), valor112.count >= 3{
                        self.UIState.onboardingUIState.btnLogin.colorTextBtn = valor112[0]
                        self.UIState.onboardingUIState.btnLogin.backgroundBtn = valor112[1]
                        self.UIState.onboardingUIState.btnLogin.backgroundPressBtn = valor112[2]
                    }
                    
                    self.UIState.onboardingUIState.btnRegister.textBtn = brandAccount.Valor_1_13__c ?? ""
                    if let valor114 = brandAccount.Valor_1_14__c?.components(separatedBy: ";"), valor114.count >= 3{
                        self.UIState.onboardingUIState.btnRegister.colorTextBtn = valor114[0]
                        self.UIState.onboardingUIState.btnRegister.backgroundBtn = valor114[1]
                        self.UIState.onboardingUIState.btnRegister.backgroundPressBtn = valor114[2]
                    }
                    
                    //MARK: - LoginUIState
                    self.UIState.loginUIState.imageBackground = brandAccount.valor21C ?? ""
                    
                    self.UIState.loginUIState.title.text = brandAccount.valor22C ?? ""
                    if let valor23 = brandAccount.valor23C?.components(separatedBy: ";"), valor23.count >= 2{
                        self.UIState.loginUIState.title.colorText = valor23[0]
                        self.UIState.loginUIState.title.sizeText = valor23[1]
                    }
                    
                    self.UIState.loginUIState.subTitle.text = brandAccount.valor24C ?? ""
                    if let valor25 = brandAccount.valor25C?.components(separatedBy: ";"), valor25.count >= 2{
                        self.UIState.loginUIState.subTitle.colorText = valor25[0]
                        self.UIState.loginUIState.subTitle.sizeText = valor25[1]
                    }
                    
                    self.UIState.loginUIState.btnMissPassword.textBtn = brandAccount.valor26C ?? ""
                    self.UIState.loginUIState.btnMissPassword.colorTextBtn = brandAccount.valor27C ?? ""
                    
                    self.UIState.loginUIState.btnLogin.textBtn = brandAccount.valor28C ?? ""
                    if let valor29 = brandAccount.valor29C?.components(separatedBy: ";"), valor29.count >= 3{
                        self.UIState.loginUIState.btnLogin.colorTextBtn = valor29[0]
                        self.UIState.loginUIState.btnLogin.backgroundBtn = valor29[1]
                        self.UIState.loginUIState.btnLogin.backgroundPressBtn = valor29[2]
                    }
                    self.UIState.loginUIState.btnContinue.textBtn = brandAccount.valor210C ?? ""
                    if let valor = brandAccount.valor211C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.loginUIState.btnContinue.colorTextBtn = valor[0]
                        self.UIState.loginUIState.btnContinue.backgroundBtn = valor[1]
                        self.UIState.loginUIState.btnContinue.backgroundPressBtn = valor[2]
                    }
                    
                    self.UIState.loginUIState.lblTextFieldRut = brandAccount.valor212C ?? ""
                    self.UIState.loginUIState.subTextRut.text = brandAccount.valor213C ?? ""
                    self.UIState.loginUIState.subTextPassword.text = brandAccount.valor214C ?? ""
                    
                    if let valor = brandAccount.valor215C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.loginUIState.subTextRut.colorText = valor[0]
                        self.UIState.loginUIState.subTextPassword.colorText = valor[0]
                        self.UIState.loginUIState.subTextRut.sizeText = valor[1]
                        self.UIState.loginUIState.subTextPassword.sizeText = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.loginUIState.subTextRut.font = "FiraSans-Regular"
                            self.UIState.loginUIState.subTextPassword.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.loginUIState.subTextRut.font = "FiraSans-Bold"
                            self.UIState.loginUIState.subTextPassword.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.loginUIState.subTextRut.font = "FiraSans-Italic"
                            self.UIState.loginUIState.subTextPassword.font = "FiraSans-Italic"
                        }
                    }
                    //MARK: - PasswordRecovreyUIState
                    self.UIState.recoveryUIState.imageBackground = brandAccount.valor31C ?? ""
                    
                    self.UIState.recoveryUIState.title.text = brandAccount.valor32C ?? ""
                    if let valor33 = brandAccount.valor33C?.components(separatedBy: ";"), valor33.count >= 2{
                        self.UIState.recoveryUIState.title.colorText = valor33[0]
                        self.UIState.recoveryUIState.title.sizeText = valor33[1]
                    }
                    
                    self.UIState.recoveryUIState.btnContinue.textBtn = brandAccount.valor34C ?? ""
                    if let valor35 = brandAccount.valor35C?.components(separatedBy: ";"), valor35.count >= 3{
                        self.UIState.recoveryUIState.btnContinue.colorTextBtn = valor35[0]
                        self.UIState.recoveryUIState.btnContinue.backgroundBtn = valor35[1]
                        self.UIState.recoveryUIState.btnContinue.backgroundPressBtn = valor35[2]
                    }
                    
                    //MARK: - PopUpCreatePassword
                    self.UIState.popupCreatePassword.icon = brandAccount.valor36C ?? ""
                    
                    self.UIState.popupCreatePassword.title.text = brandAccount.valor37C ?? ""
                    if let valor = brandAccount.valor38C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupCreatePassword.title.colorText = valor[0]
                        self.UIState.popupCreatePassword.title.sizeText = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupCreatePassword.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupCreatePassword.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupCreatePassword.title.font = "FiraSans-Italic"
                        }
                        self.UIState.popupCreatePassword.title.alignment = valor[3]
                    }
                    
                    self.UIState.popupCreatePassword.msg.text = brandAccount.valor39C?.htmlToString() ?? ""
                    if let valor = brandAccount.valor310C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupCreatePassword.msg.colorText = valor[0]
                        self.UIState.popupCreatePassword.msg.sizeText = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupCreatePassword.msg.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupCreatePassword.msg.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupCreatePassword.msg.font = "FiraSans-Italic"
                        }
                        self.UIState.popupCreatePassword.msg.alignment = valor[3]
                    }
                    
                    self.UIState.popupCreatePassword.btnPopup.textBtn = brandAccount.valor311C ?? ""
                    if let valor = brandAccount.valor312C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.popupCreatePassword.btnPopup.colorTextBtn = valor[0]
                        self.UIState.popupCreatePassword.btnPopup.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupCreatePassword.btnPopup.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupCreatePassword.btnPopup.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupCreatePassword.btnPopup.font = "FiraSans-Italic"
                        }
                        self.UIState.popupCreatePassword.btnPopup.alignment = valor[3]
                    }
                    
                    
                    //MARK: - SingUpUIState
                    self.UIState.singUpUIState.imageBackground = brandAccount.valor41C ?? ""
                    
                    self.UIState.singUpUIState.title.text = brandAccount.valor42C ?? ""
                    if let valor43 = brandAccount.valor43C?.components(separatedBy: ";"), valor43.count >= 2{
                        self.UIState.singUpUIState.title.colorText = valor43[0]
                        self.UIState.singUpUIState.title.sizeText = valor43[1]
                    }
                    
                    self.UIState.singUpUIState.subTitle.text = brandAccount.valor44C ?? ""
                    if let valor45 = brandAccount.valor45C?.components(separatedBy: ";"), valor45.count >= 2{
                        self.UIState.singUpUIState.subTitle.colorText = valor45[0]
                        self.UIState.singUpUIState.subTitle.sizeText = valor45[1]
                    }
                    
                    self.UIState.singUpUIState.btnRegister.textBtn = brandAccount.valor46C ?? ""
                    if let valor47 = brandAccount.valor47C?.components(separatedBy: ";"), valor47.count >= 3{
                        self.UIState.singUpUIState.btnRegister.colorTextBtn = valor47[0]
                        self.UIState.singUpUIState.btnRegister.backgroundBtn = valor47[1]
                        self.UIState.singUpUIState.btnRegister.backgroundPressBtn = valor47[2]
                    }
                    
                    self.UIState.singUpUIState.btnAllReadyRegister.textBtn = brandAccount.valor48C ?? ""
                    self.UIState.singUpUIState.btnAllReadyRegister.colorTextBtn = brandAccount.valor49C ?? ""
                    
                    self.UIState.singUpUIState.enabledRegister = brandAccount.valor410C ?? ""
                    self.UIState.singUpUIState.textPopup.text = brandAccount.valor411C ?? ""
                    if let valor = brandAccount.valor412C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.singUpUIState.textPopup.colorText = valor[0]
                        self.UIState.singUpUIState.textPopup.sizeText = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.singUpUIState.textPopup.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.singUpUIState.textPopup.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.singUpUIState.textPopup.font = "FiraSans-Italic"
                        }
                        self.UIState.singUpUIState.textPopup.alignment = valor[3]
                    }
                    self.UIState.singUpUIState.btnPopup.textBtn = brandAccount.valor413C ?? ""
                    if let valor = brandAccount.valor414C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.singUpUIState.btnPopup.colorTextBtn = valor[0]
                        self.UIState.singUpUIState.btnPopup.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.singUpUIState.btnPopup.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.singUpUIState.btnPopup.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.singUpUIState.btnPopup.font = "FiraSans-Italic"
                        }
                    }
                    
                    
                    //MARK: - SingUpUIState
                    self.UIState.singUpFormUIState.imageBackground = brandAccount.valor51C ?? ""
                    
                    self.UIState.singUpFormUIState.title.text = brandAccount.valor52C ?? ""
                    if let valor53 = brandAccount.valor53C?.components(separatedBy: ";"), valor53.count >= 2{
                        self.UIState.singUpFormUIState.title.colorText = valor53[0]
                        self.UIState.singUpFormUIState.title.sizeText = valor53[1]
                    }
                    
                    self.UIState.singUpFormUIState.btnSend.textBtn = brandAccount.valor54C ?? ""
                    if let valor55 = brandAccount.valor55C?.components(separatedBy: ";"), valor55.count >= 3{
                        self.UIState.singUpFormUIState.btnSend.colorTextBtn = valor55[0]
                        self.UIState.singUpFormUIState.btnSend.backgroundBtn = valor55[1]
                        self.UIState.singUpFormUIState.btnSend.backgroundPressBtn = valor55[2]
                    }
                    
                    //MARK: - SingUpOtpUIState
                    self.UIState.singUpOtpUIState.imageBackground = brandAccount.valor61C ?? ""
                    
                    self.UIState.singUpOtpUIState.image = brandAccount.valor62C ?? ""
                    
                    self.UIState.singUpOtpUIState.title.text = brandAccount.valor63C ?? ""
                    if let valor64 = brandAccount.valor64C?.components(separatedBy: ";"), valor64.count >= 2{
                        self.UIState.singUpOtpUIState.title.colorText = valor64[0]
                        self.UIState.singUpOtpUIState.title.sizeText = valor64[1]
                    }
                    
                    if let valor65 = brandAccount.valor65C?.components(separatedBy: ";"), valor65.count >= 2{
                        self.UIState.singUpOtpUIState.msg.colorText = valor65[0]
                        self.UIState.singUpOtpUIState.msg.sizeText = valor65[1]
                    }
                    
                    if let valor66 = brandAccount.valor66C?.components(separatedBy: ";"), valor66.count >= 2{
                        self.UIState.singUpOtpUIState.code.colorText = valor66[0]
                        self.UIState.singUpOtpUIState.code.sizeText = valor66[1]
                    }
                    
                    self.UIState.singUpOtpUIState.btnReSend.text = brandAccount.valor67C ?? ""
                    if let valor68 = brandAccount.valor68C?.components(separatedBy: ";"), valor68.count >= 2{
                        self.UIState.singUpOtpUIState.btnReSend.colorText = valor68[0]
                        self.UIState.singUpOtpUIState.btnReSend.sizeText = valor68[1]
                    }
                    
                    self.UIState.singUpOtpUIState.btnContinue.textBtn = brandAccount.valor69C ?? ""
                    if let valor610 = brandAccount.valor610C?.components(separatedBy: ";"), valor610.count >= 3{
                        self.UIState.singUpOtpUIState.btnContinue.colorTextBtn = valor610[0]
                        self.UIState.singUpOtpUIState.btnContinue.backgroundBtn = valor610[1]
                        self.UIState.singUpOtpUIState.btnContinue.backgroundPressBtn = valor610[2]
                    }
                    
                    self.UIState.singUpOtpUIState.btnCancel.textBtn = brandAccount.valor611C ?? ""
                    self.UIState.singUpOtpUIState.btnCancel.colorTextBtn = brandAccount.valor612C ?? ""

                    self.UIState.singUpOtpUIState.subtitle.text = brandAccount.valor613C ?? ""
                    if let valor614 = brandAccount.valor614C?.components(separatedBy: ";"), valor614.count >= 2 {
                        self.UIState.singUpOtpUIState.subtitle.colorText = valor614[0]
                        self.UIState.singUpOtpUIState.subtitle.sizeText = valor614[1]
                        if valor614.count >= 3 {
                            let fontRaw = valor614[2].lowercased().trimmingCharacters(in: .whitespaces)
                            switch fontRaw {
                            case "firasans_bold":   self.UIState.singUpOtpUIState.subtitle.font = "FiraSans-Bold"
                            case "firasans_italic": self.UIState.singUpOtpUIState.subtitle.font = "FiraSans-Italic"
                            case "firasans_medium": self.UIState.singUpOtpUIState.subtitle.font = "FiraSans-Medium"
                            default:                self.UIState.singUpOtpUIState.subtitle.font = "FiraSans-Regular"
                            }
                        }
                    }

                    //MARK: - SingUpCreatePassUIState
                    self.UIState.singUpCreatePassUIState.imageBackground = brandAccount.valor71C ?? ""
                    
                    self.UIState.singUpCreatePassUIState.title.text = brandAccount.valor72C ?? ""
                    if let valor73 = brandAccount.valor73C?.components(separatedBy: ";"), valor73.count >= 2{
                        self.UIState.singUpCreatePassUIState.title.colorText = valor73[0]
                        self.UIState.singUpCreatePassUIState.title.sizeText = valor73[1]
                    }
                    
                    self.UIState.singUpCreatePassUIState.subTitle.text = brandAccount.valor74C ?? ""
                    if let valor75 = brandAccount.valor75C?.components(separatedBy: ";"), valor75.count >= 2{
                        self.UIState.singUpCreatePassUIState.subTitle.colorText = valor75[0]
                        self.UIState.singUpCreatePassUIState.subTitle.sizeText = valor75[1]
                    }
                    
                    self.UIState.singUpCreatePassUIState.btnRegister.textBtn = brandAccount.valor76C ?? ""
                    if let valor77 = brandAccount.valor77C?.components(separatedBy: ";"), valor77.count >= 3{
                        self.UIState.singUpCreatePassUIState.btnRegister.colorTextBtn = valor77[0]
                        self.UIState.singUpCreatePassUIState.btnRegister.backgroundBtn = valor77[1]
                        self.UIState.singUpCreatePassUIState.btnRegister.backgroundPressBtn = valor77[2]
                    }
                    
                    self.UIState.singUpCreatePassUIState.btnPolitics.textBtn = brandAccount.valor78C ?? ""
                    self.UIState.singUpCreatePassUIState.btnPolitics.colorTextBtn = brandAccount.valor79C ?? ""
                    
                    //MARK: - SelectedAgreementUIState
                    self.UIState.selectAgreementUIState.imageBackground = brandAccount.valor81C ?? ""
                    
                    self.UIState.selectAgreementUIState.title.text = brandAccount.valor82C ?? ""
                    if let valor83 = brandAccount.valor83C?.components(separatedBy: ";"), valor83.count >= 2{
                        self.UIState.selectAgreementUIState.title.colorText = valor83[0]
                        self.UIState.selectAgreementUIState.title.sizeText = valor83[1]
                    }
                    
                    self.UIState.selectAgreementUIState.btnGetInto.textBtn = brandAccount.valor84C ?? ""
                    if let valor85 = brandAccount.valor85C?.components(separatedBy: ";"), valor85.count >= 3{
                        self.UIState.selectAgreementUIState.btnGetInto.colorTextBtn = valor85[0]
                        self.UIState.selectAgreementUIState.btnGetInto.backgroundBtn = valor85[1]
                        self.UIState.selectAgreementUIState.btnGetInto.backgroundPressBtn = valor85[2]
                    }
                    
                    self.UIState.selectAgreementUIState.footer.text = brandAccount.valor86C ?? ""
                    if let valor87 = brandAccount.valor87C?.components(separatedBy: ";"), valor87.count >= 2{
                        self.UIState.selectAgreementUIState.footer.colorText = valor87[0]
                        self.UIState.selectAgreementUIState.footer.sizeText = valor87[1]
                    }
                    
                    //MARK: - SingInPasswordRecoveryOtpUIState
                    self.UIState.singInPasswordRecoveryOtpUIState.imageBackground = brandAccount.valor91C ?? ""
                    
                    self.UIState.singInPasswordRecoveryOtpUIState.image = brandAccount.valor92C ?? ""
                    
                    self.UIState.singInPasswordRecoveryOtpUIState.title.text = brandAccount.valor93C ?? ""
                    if let valor94 = brandAccount.valor94C?.components(separatedBy: ";"), valor94.count >= 2{
                        self.UIState.singInPasswordRecoveryOtpUIState.title.colorText = valor94[0]
                        self.UIState.singInPasswordRecoveryOtpUIState.title.sizeText = valor94[1]
                    }
                    
                    if let valor95 = brandAccount.valor95C?.components(separatedBy: ";"), valor95.count >= 2{
                        self.UIState.singInPasswordRecoveryOtpUIState.msg.colorText = valor95[0]
                        self.UIState.singInPasswordRecoveryOtpUIState.msg.sizeText = valor95[1]
                    }
                    
                    if let valor96 = brandAccount.valor96C?.components(separatedBy: ";"), valor96.count >= 2{
                        self.UIState.singInPasswordRecoveryOtpUIState.code.colorText = valor96[0]
                        self.UIState.singInPasswordRecoveryOtpUIState.code.sizeText = valor96[1]
                    }
                    //MARK: - Check with Pablo in Saleforce
                    self.UIState.singInPasswordRecoveryOtpUIState.btnReSend.text = brandAccount.valor97C ?? ""
                    if let valor98 = brandAccount.valor98C?.components(separatedBy: ";"), valor98.count >= 2{
                        self.UIState.singInPasswordRecoveryOtpUIState.btnReSend.colorText = valor98[0]
                        self.UIState.singInPasswordRecoveryOtpUIState.btnReSend.sizeText = valor98[1]
                    }
                    
                    self.UIState.singInPasswordRecoveryOtpUIState.btnContinue.textBtn = brandAccount.valor99C ?? ""
                    if let valor910 = brandAccount.valor910C?.components(separatedBy: ";"), valor910.count >= 3{
                        self.UIState.singInPasswordRecoveryOtpUIState.btnContinue.colorTextBtn = valor910[0]
                        self.UIState.singInPasswordRecoveryOtpUIState.btnContinue.backgroundBtn = valor910[1]
                        self.UIState.singInPasswordRecoveryOtpUIState.btnContinue.backgroundPressBtn = valor910[2]
                    }
                    
                    self.UIState.singInPasswordRecoveryOtpUIState.btnCancel.textBtn = brandAccount.valor911C ?? ""
                    self.UIState.singInPasswordRecoveryOtpUIState.btnCancel.colorTextBtn = brandAccount.valor912C ?? ""

                    self.UIState.singInPasswordRecoveryOtpUIState.subtitle.text = brandAccount.valor913C ?? ""
                    if let valor914 = brandAccount.valor914C?.components(separatedBy: ";"), valor914.count >= 2 {
                        self.UIState.singInPasswordRecoveryOtpUIState.subtitle.colorText = valor914[0]
                        self.UIState.singInPasswordRecoveryOtpUIState.subtitle.sizeText = valor914[1]
                        if valor914.count >= 3 {
                            let fontRaw = valor914[2].lowercased().trimmingCharacters(in: .whitespaces)
                            switch fontRaw {
                            case "firasans_bold":   self.UIState.singInPasswordRecoveryOtpUIState.subtitle.font = "FiraSans-Bold"
                            case "firasans_italic": self.UIState.singInPasswordRecoveryOtpUIState.subtitle.font = "FiraSans-Italic"
                            case "firasans_medium": self.UIState.singInPasswordRecoveryOtpUIState.subtitle.font = "FiraSans-Medium"
                            default:                self.UIState.singInPasswordRecoveryOtpUIState.subtitle.font = "FiraSans-Regular"
                            }
                        }
                    }

                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("📋 [PreLogin] Elemento 9 - SingInPasswordRecoveryOtp")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("   [9.1]  imageBackground: \(brandAccount.valor91C ?? "nil")")
                    print("   [9.2]  image: \(brandAccount.valor92C ?? "nil")")
                    print("   [9.3]  title.text: \(brandAccount.valor93C ?? "nil")")
                    print("   [9.4]  title.atr (color;size): \(brandAccount.valor94C ?? "nil")")
                    print("   [9.5]  msg.atr (color;size): \(brandAccount.valor95C ?? "nil")")
                    print("   [9.6]  code.atr (color;size): \(brandAccount.valor96C ?? "nil")")
                    print("   [9.7]  btnReSend.text: \(brandAccount.valor97C ?? "nil")")
                    print("   [9.8]  btnReSend.atr (color;size): \(brandAccount.valor98C ?? "nil")")
                    print("   [9.9]  btnContinue.text: \(brandAccount.valor99C ?? "nil")")
                    print("   [9.10] btnContinue.atr (color;bg;bgPress): \(brandAccount.valor910C ?? "nil")")
                    print("   [9.11] btnCancel.text: \(brandAccount.valor911C ?? "nil")")
                    print("   [9.12] btnCancel.colorText: \(brandAccount.valor912C ?? "nil")")
                    print("   [9.13] subtitle.text: \(brandAccount.valor913C ?? "nil")")
                    print("   [9.14] subtitle.atr (color;size): \(brandAccount.valor914C ?? "nil")")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("   📌 Valores parseados del subtitle:")
                    print("      text: \"\(self.UIState.singInPasswordRecoveryOtpUIState.subtitle.text)\"")
                    print("      colorText: \"\(self.UIState.singInPasswordRecoveryOtpUIState.subtitle.colorText)\"")
                    print("      sizeText: \"\(self.UIState.singInPasswordRecoveryOtpUIState.subtitle.sizeText)\"")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                    //MARK: - SingInPasswordResetUIState
                    self.UIState.singInPasswordResetUIState.imageBackground = brandAccount.valor101C ?? ""
                    
                    self.UIState.singInPasswordResetUIState.title.text = brandAccount.valor102C ?? ""
                    if let valor103 = brandAccount.valor103C?.components(separatedBy: ";"), valor103.count >= 2{
                        self.UIState.singInPasswordResetUIState.title.colorText = valor103[0]
                        self.UIState.singInPasswordResetUIState.title.sizeText = valor103[1]
                    }
                    
                    self.UIState.singInPasswordResetUIState.subTitle.text = brandAccount.valor104C ?? ""
                    if let valor105 = brandAccount.valor105C?.components(separatedBy: ";"), valor105.count >= 2{
                        self.UIState.singInPasswordResetUIState.subTitle.colorText = valor105[0]
                        self.UIState.singInPasswordResetUIState.subTitle.sizeText = valor105[1]
                    }
                    
                    self.UIState.singInPasswordResetUIState.btnSend.textBtn = brandAccount.valor106C ?? ""
                    if let valor107 = brandAccount.valor107C?.components(separatedBy: ";"), valor107.count >= 3{
                        self.UIState.singInPasswordResetUIState.btnSend.colorTextBtn = valor107[0]
                        self.UIState.singInPasswordResetUIState.btnSend.backgroundBtn = valor107[1]
                        self.UIState.singInPasswordResetUIState.btnSend.backgroundPressBtn = valor107[2]
                    }
                    self.UIState.singInPasswordResetUIState.popupMessage = brandAccount.valor108C ?? ""
                    if let valor = brandAccount.valor109C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.singInPasswordResetUIState.popupAtr.colorText = valor[0]
                        self.UIState.singInPasswordResetUIState.popupAtr.sizeText = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.singInPasswordResetUIState.popupAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.singInPasswordResetUIState.popupAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.singInPasswordResetUIState.popupAtr.font = "FiraSans-Italic"
                        }
                        self.UIState.singInPasswordResetUIState.popupAtr.alignment = valor[3]
                    }
                    self.UIState.singInPasswordResetUIState.btnPopup.textBtn = brandAccount.valor1010C ?? "Aceptar"
                    if let valor = brandAccount.valor1011C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.singInPasswordResetUIState.btnPopup.colorTextBtn = valor[0]
                        self.UIState.singInPasswordResetUIState.btnPopup.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.singInPasswordResetUIState.btnPopup.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.singInPasswordResetUIState.btnPopup.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.singInPasswordResetUIState.btnPopup.font = "FiraSans-Italic"
                        }
                    }
                    //MARK: - PopupRegisterSuccessUIState
                    self.UIState.popupRegisterSuccessUIState.imageBackground = brandAccount.Valor_11_1__c ?? ""
                    
                    self.UIState.popupRegisterSuccessUIState.icon = brandAccount.Valor_11_2__c ?? ""
                    
                    self.UIState.popupRegisterSuccessUIState.msg.text = brandAccount.Valor_11_3__c ?? ""
                    if let valor114 = brandAccount.Valor_11_4__c?.components(separatedBy: ";"), valor114.count >= 2{
                        self.UIState.popupRegisterSuccessUIState.msg.colorText = valor114[0]
                        self.UIState.popupRegisterSuccessUIState.msg.sizeText = valor114[1]
                    }
                    
                    //MARK: - PopupWithoutEmailUIState
                    self.UIState.popupWithoutEmailUIState.title.text = brandAccount.Valor_11_5__c ?? ""
                    if let valor = brandAccount.Valor_11_6__c?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupWithoutEmailUIState.title.colorText = valor[0]
                        self.UIState.popupWithoutEmailUIState.title.sizeText = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupWithoutEmailUIState.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupWithoutEmailUIState.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupWithoutEmailUIState.title.font = "FiraSans-Italic"
                        }
                        self.UIState.popupWithoutEmailUIState.title.alignment = valor[3]
                    }
                    if let valor = brandAccount.Valor_11_7__c?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupWithoutEmailUIState.msg.text = valor[0]
                        self.UIState.popupWithoutEmailUIState.msg2 = valor[1]
                        self.UIState.popupWithoutEmailUIState.email = valor[2]
                        self.UIState.popupWithoutEmailUIState.msg3 = valor[3]
                    }
                    if let valor = brandAccount.Valor_11_8__c?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupWithoutEmailUIState.msg.colorText = valor[0]
                        self.UIState.popupWithoutEmailUIState.msg.sizeText = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupWithoutEmailUIState.msg.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupWithoutEmailUIState.msg.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupWithoutEmailUIState.msg.font = "FiraSans-Italic"
                        }
                        self.UIState.popupWithoutEmailUIState.msg.alignment = valor[3]
                    }
                    self.UIState.popupWithoutEmailUIState.btnPopup.textBtn = brandAccount.Valor_11_9__c ?? ""
                    if let valor = brandAccount.Valor_11_10__c?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.popupWithoutEmailUIState.btnPopup.colorTextBtn = valor[0]
                        self.UIState.popupWithoutEmailUIState.btnPopup.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupWithoutEmailUIState.btnPopup.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupWithoutEmailUIState.btnPopup.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupWithoutEmailUIState.btnPopup.font = "FiraSans-Italic"
                        }
                    }
                }
            }
            self.isLoading = false
        }
    }
}
