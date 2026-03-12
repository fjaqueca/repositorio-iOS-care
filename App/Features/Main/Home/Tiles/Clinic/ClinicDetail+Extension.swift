//
//  ClinicDetail+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 10/04/2024.
//

import Foundation

extension ClinicDetailView{
    func loadUIState(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                //MARK: - SecMas
                if brandAccount.Name == "SecMas"{
                    //MARK: - clinicDetail
                    if let valor = brandAccount.valor71C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.clinicDetail.name.color = valor[0]
                        self.UIState.clinicDetail.name.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.clinicDetail.name.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.clinicDetail.name.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.clinicDetail.name.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor72C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.clinicDetail.shortDescription.color = valor[0]
                        self.UIState.clinicDetail.shortDescription.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.clinicDetail.shortDescription.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.clinicDetail.shortDescription.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.clinicDetail.shortDescription.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor73C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.clinicDetail.longDescription.color = valor[0]
                        self.UIState.clinicDetail.longDescription.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.clinicDetail.longDescription.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.clinicDetail.longDescription.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.clinicDetail.longDescription.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor74C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.clinicDetail.btnAppoint.textBtn = valor[0]
                        self.UIState.clinicDetail.btnAppoint.iconBtn = valor[1]
                        
                    }
                    if let valor = brandAccount.valor75C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.clinicDetail.btnCall.textBtn = valor[0]
                        self.UIState.clinicDetail.btnCall.iconBtn = valor[1]
                        
                    }
                    if let valor = brandAccount.valor76C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.clinicDetail.btnVideo.textBtn = valor[0]
                        self.UIState.clinicDetail.btnVideo.iconBtn = valor[1]
                        
                    }
                    if let valor = brandAccount.valor77C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.clinicDetail.btnWhatsApp.textBtn = valor[0]
                        self.UIState.clinicDetail.btnWhatsApp.iconBtn = valor[1]
                    }
                    
                    if let valor = brandAccount.valor78C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.clinicDetail.btnsArt.colorTextBtn = valor[0]
                        self.UIState.clinicDetail.btnsArt.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.clinicDetail.btnsArt.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.clinicDetail.btnsArt.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.clinicDetail.btnsArt.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    self.UIState.clinicDetail.btnTextColor = brandAccount.valor79C ?? ""
                    self.UIState.clinicDetail.imgGradientColor = brandAccount.valor710C ?? ""
                    self.UIState.clinicDetail.buttonBackColor = brandAccount.valor711C ?? ""
                    if let valor = brandAccount.valor712C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.clinicDetail.btnClose.textBtn = valor[0]
                        self.UIState.clinicDetail.btnClose.iconBtn = valor[1]
                    }
                }
                // MARK: - MensajesTelemedicina
                if self.clinicDetail.name == "Telemedicina"{
                    if brandAccount.Name == "MensajesTelemedicina"{
                        self.popupsTelemedicina.firstPopup.showPopup = brandAccount.valor11C ?? ""
                        self.popupsTelemedicina.firstPopup.text.text = brandAccount.valor12C?.htmlToString() ?? ""
                        if let valor = brandAccount.valor13C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.firstPopup.text.size = valor[1]
                            self.popupsTelemedicina.firstPopup.text.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.firstPopup.text.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.firstPopup.text.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.firstPopup.text.font = "FiraSans-Italic"
                            }
                        }
                        self.popupsTelemedicina.firstPopup.alignmentText = brandAccount.valor14C ?? ""
                        self.popupsTelemedicina.firstPopup.whatsAppNumber = brandAccount.valor15C ?? ""
                        if let valor = brandAccount.valor16C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.firstPopup.btnWhatsApp.text = valor[0]
                            self.popupsTelemedicina.firstPopup.btnWhatsApp.colorText = valor[1]
                            self.popupsTelemedicina.firstPopup.btnWhatsApp.colorButton = valor[2]
                            self.popupsTelemedicina.firstPopup.btnWhatsApp.icon = valor[3]
                        } else if let valor = brandAccount.valor16C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.firstPopup.btnWhatsApp.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.firstPopup.showAppointmentButton = brandAccount.valor17C ?? ""
                        if let valor = brandAccount.valor18C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.firstPopup.btnAppointmentButton.text = valor[0]
                            self.popupsTelemedicina.firstPopup.btnAppointmentButton.colorText = valor[1]
                            self.popupsTelemedicina.firstPopup.btnAppointmentButton.colorButton = valor[2]
                            self.popupsTelemedicina.firstPopup.btnAppointmentButton.icon = valor[3]
                        } else if let valor = brandAccount.valor18C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.firstPopup.btnAppointmentButton.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.firstPopup.id = brandAccount.valor19C ?? ""
                        self.popupsTelemedicina.firstPopup.clinicName = brandAccount.Valor_1_10__c ?? ""
                        if let valor = brandAccount.Valor_1_11__c?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.firstPopup.btnContinueVideoCall.text = valor[0]
                            self.popupsTelemedicina.firstPopup.btnContinueVideoCall.colorText = valor[1]
                            self.popupsTelemedicina.firstPopup.btnContinueVideoCall.colorButton = valor[2]
                            self.popupsTelemedicina.firstPopup.btnContinueVideoCall.icon = valor[3]
                        } else if let valor = brandAccount.Valor_1_11__c?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.firstPopup.btnContinueVideoCall.text = valor[0]
                        }
                        
                        if let valor = brandAccount.Valor_1_12__c?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.firstPopup.btnGoOut.text = valor[0]
                            self.popupsTelemedicina.firstPopup.btnGoOut.colorText = valor[1]
                            self.popupsTelemedicina.firstPopup.btnGoOut.colorButton = valor[2]
                            self.popupsTelemedicina.firstPopup.btnGoOut.icon = valor[3]
                        } else if let valor = brandAccount.Valor_1_12__c?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.firstPopup.btnGoOut.text = valor[0]
                        }
                        
                        
                        
                        self.popupsTelemedicina.popup1.time = brandAccount.valor21C ?? ""
                        self.popupsTelemedicina.popup1.text.text = brandAccount.valor22C?.htmlToString() ?? ""
                        if let valor = brandAccount.valor23C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.popup1.text.size = valor[1]
                            self.popupsTelemedicina.popup1.text.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.popup1.text.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.popup1.text.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.popup1.text.font = "FiraSans-Italic"
                            }
                        }
                        self.popupsTelemedicina.popup1.alignmentText = brandAccount.valor24C ?? ""
                        self.popupsTelemedicina.popup1.whatsAppNumber = brandAccount.valor25C ?? ""
                        if let valor = brandAccount.valor26C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup1.btnWhatsApp.text = valor[0]
                            self.popupsTelemedicina.popup1.btnWhatsApp.colorText = valor[1]
                            self.popupsTelemedicina.popup1.btnWhatsApp.colorButton = valor[2]
                            self.popupsTelemedicina.popup1.btnWhatsApp.icon = valor[3]
                        } else if let valor = brandAccount.valor26C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup1.btnWhatsApp.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup1.showAppointmentButton = brandAccount.valor27C ?? ""
                        if let valor = brandAccount.valor28C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup1.btnAppointmentButton.text = valor[0]
                            self.popupsTelemedicina.popup1.btnAppointmentButton.colorText = valor[1]
                            self.popupsTelemedicina.popup1.btnAppointmentButton.colorButton = valor[2]
                            self.popupsTelemedicina.popup1.btnAppointmentButton.icon = valor[3]
                        } else if let valor = brandAccount.valor28C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup1.btnAppointmentButton.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup1.id = brandAccount.valor29C ?? ""
                        self.popupsTelemedicina.popup1.clinicName = brandAccount.valor210C ?? ""
                        if let valor = brandAccount.valor211C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup1.btnContinueVideoCall.text = valor[0]
                            self.popupsTelemedicina.popup1.btnContinueVideoCall.colorText = valor[1]
                            self.popupsTelemedicina.popup1.btnContinueVideoCall.colorButton = valor[2]
                            self.popupsTelemedicina.popup1.btnContinueVideoCall.icon = valor[3]
                        } else if let valor = brandAccount.valor211C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup1.btnContinueVideoCall.text = valor[0]
                        }
                        
                        if let valor = brandAccount.valor212C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup1.btnGoOut.text = valor[0]
                            self.popupsTelemedicina.popup1.btnGoOut.colorText = valor[1]
                            self.popupsTelemedicina.popup1.btnGoOut.colorButton = valor[2]
                            self.popupsTelemedicina.popup1.btnGoOut.icon = valor[3]
                        } else if let valor = brandAccount.valor212C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup1.btnGoOut.text = valor[0]
                        }
                        
                        
                        self.popupsTelemedicina.popup2.time = brandAccount.valor31C ?? ""
                        self.popupsTelemedicina.popup2.text.text = brandAccount.valor32C?.htmlToString() ?? ""
                        if let valor = brandAccount.valor33C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.popup2.text.size = valor[1]
                            self.popupsTelemedicina.popup2.text.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.popup2.text.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.popup2.text.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.popup2.text.font = "FiraSans-Italic"
                            }
                        }
                        self.popupsTelemedicina.popup2.alignmentText = brandAccount.valor34C ?? ""
                        self.popupsTelemedicina.popup2.whatsAppNumber = brandAccount.valor35C ?? ""
                        if let valor = brandAccount.valor36C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup2.btnWhatsApp.text = valor[0]
                            self.popupsTelemedicina.popup2.btnWhatsApp.colorText = valor[1]
                            self.popupsTelemedicina.popup2.btnWhatsApp.colorButton = valor[2]
                            self.popupsTelemedicina.popup2.btnWhatsApp.icon = valor[3]
                        } else if let valor = brandAccount.valor36C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup2.btnWhatsApp.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup2.showAppointmentButton = brandAccount.valor37C ?? ""
                        if let valor = brandAccount.valor38C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup2.btnAppointmentButton.text = valor[0]
                            self.popupsTelemedicina.popup2.btnAppointmentButton.colorText = valor[1]
                            self.popupsTelemedicina.popup2.btnAppointmentButton.colorButton = valor[2]
                            self.popupsTelemedicina.popup2.btnAppointmentButton.icon = valor[3]
                        } else if let valor = brandAccount.valor38C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup2.btnAppointmentButton.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup2.id = brandAccount.valor39C ?? ""
                        self.popupsTelemedicina.popup2.clinicName = brandAccount.valor310C ?? ""
                        if let valor = brandAccount.valor311C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup2.btnContinueVideoCall.text = valor[0]
                            self.popupsTelemedicina.popup2.btnContinueVideoCall.colorText = valor[1]
                            self.popupsTelemedicina.popup2.btnContinueVideoCall.colorButton = valor[2]
                            self.popupsTelemedicina.popup2.btnContinueVideoCall.icon = valor[3]
                        } else if let valor = brandAccount.valor311C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup2.btnContinueVideoCall.text = valor[0]
                        }
                        
                        if let valor = brandAccount.valor312C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup2.btnGoOut.text = valor[0]
                            self.popupsTelemedicina.popup2.btnGoOut.colorText = valor[1]
                            self.popupsTelemedicina.popup2.btnGoOut.colorButton = valor[2]
                            self.popupsTelemedicina.popup2.btnGoOut.icon = valor[3]
                        } else if let valor = brandAccount.valor312C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup2.btnGoOut.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup3.time = brandAccount.valor41C ?? ""
                        self.popupsTelemedicina.popup3.text.text = brandAccount.valor42C?.htmlToString() ?? ""
                        if let valor = brandAccount.valor43C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.popup3.text.size = valor[1]
                            self.popupsTelemedicina.popup3.text.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.popup3.text.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.popup3.text.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.popup3.text.font = "FiraSans-Italic"
                            }
                        }
                        self.popupsTelemedicina.popup3.alignmentText = brandAccount.valor44C ?? ""
                        self.popupsTelemedicina.popup3.whatsAppNumber = brandAccount.valor45C ?? ""
                        if let valor = brandAccount.valor46C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup3.btnWhatsApp.text = valor[0]
                            self.popupsTelemedicina.popup3.btnWhatsApp.colorText = valor[1]
                            self.popupsTelemedicina.popup3.btnWhatsApp.colorButton = valor[2]
                            self.popupsTelemedicina.popup3.btnWhatsApp.icon = valor[3]
                        } else if let valor = brandAccount.valor46C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup3.btnWhatsApp.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup3.showAppointmentButton = brandAccount.valor47C ?? ""
                        if let valor = brandAccount.valor48C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup3.btnAppointmentButton.text = valor[0]
                            self.popupsTelemedicina.popup3.btnAppointmentButton.colorText = valor[1]
                            self.popupsTelemedicina.popup3.btnAppointmentButton.colorButton = valor[2]
                            self.popupsTelemedicina.popup3.btnAppointmentButton.icon = valor[3]
                        } else if let valor = brandAccount.valor48C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup3.btnAppointmentButton.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup3.id = brandAccount.valor49C ?? ""
                        self.popupsTelemedicina.popup3.clinicName = brandAccount.valor410C ?? ""
                        if let valor = brandAccount.valor411C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup3.btnContinueVideoCall.text = valor[0]
                            self.popupsTelemedicina.popup3.btnContinueVideoCall.colorText = valor[1]
                            self.popupsTelemedicina.popup3.btnContinueVideoCall.colorButton = valor[2]
                            self.popupsTelemedicina.popup3.btnContinueVideoCall.icon = valor[3]
                        } else if let valor = brandAccount.valor411C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup3.btnContinueVideoCall.text = valor[0]
                        }
                        
                        
                        if let valor = brandAccount.valor412C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup3.btnGoOut.text = valor[0]
                            self.popupsTelemedicina.popup3.btnGoOut.colorText = valor[1]
                            self.popupsTelemedicina.popup3.btnGoOut.colorButton = valor[2]
                            self.popupsTelemedicina.popup3.btnGoOut.icon = valor[3]
                        } else if let valor = brandAccount.valor412C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup3.btnGoOut.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup4.time = brandAccount.valor51C ?? ""
                        self.popupsTelemedicina.popup4.text.text = brandAccount.valor52C?.htmlToString() ?? ""
                        if let valor = brandAccount.valor53C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.popup4.text.size = valor[1]
                            self.popupsTelemedicina.popup4.text.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.popup4.text.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.popup4.text.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.popup4.text.font = "FiraSans-Italic"
                            }
                        }
                        self.popupsTelemedicina.popup4.alignmentText = brandAccount.valor54C ?? ""
                        self.popupsTelemedicina.popup4.whatsAppNumber = brandAccount.valor55C ?? ""
                        if let valor = brandAccount.valor56C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup4.btnWhatsApp.text = valor[0]
                            self.popupsTelemedicina.popup4.btnWhatsApp.colorText = valor[1]
                            self.popupsTelemedicina.popup4.btnWhatsApp.colorButton = valor[2]
                            self.popupsTelemedicina.popup4.btnWhatsApp.icon = valor[3]
                        } else if let valor = brandAccount.valor56C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup4.btnWhatsApp.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup4.showAppointmentButton = brandAccount.valor57C ?? ""
                        if let valor = brandAccount.valor58C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup4.btnAppointmentButton.text = valor[0]
                            self.popupsTelemedicina.popup4.btnAppointmentButton.colorText = valor[1]
                            self.popupsTelemedicina.popup4.btnAppointmentButton.colorButton = valor[2]
                            self.popupsTelemedicina.popup4.btnAppointmentButton.icon = valor[3]
                        } else if let valor = brandAccount.valor58C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup4.btnAppointmentButton.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup4.id = brandAccount.valor59C ?? ""
                        self.popupsTelemedicina.popup4.clinicName = brandAccount.valor510C ?? ""
                        if let valor = brandAccount.valor511C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup4.btnContinueVideoCall.text = valor[0]
                            self.popupsTelemedicina.popup4.btnContinueVideoCall.colorText = valor[1]
                            self.popupsTelemedicina.popup4.btnContinueVideoCall.colorButton = valor[2]
                            self.popupsTelemedicina.popup4.btnContinueVideoCall.icon = valor[3]
                        } else if let valor = brandAccount.valor511C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup4.btnContinueVideoCall.text = valor[0]
                        }
                        
                        if let valor = brandAccount.valor512C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup4.btnGoOut.text = valor[0]
                            self.popupsTelemedicina.popup4.btnGoOut.colorText = valor[1]
                            self.popupsTelemedicina.popup4.btnGoOut.colorButton = valor[2]
                            self.popupsTelemedicina.popup4.btnGoOut.icon = valor[3]
                        } else if let valor = brandAccount.valor512C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup4.btnGoOut.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup5.time = brandAccount.valor61C ?? ""
                        self.popupsTelemedicina.popup5.text.text = brandAccount.valor62C?.htmlToString() ?? ""
                        if let valor = brandAccount.valor63C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.popup5.text.size = valor[1]
                            self.popupsTelemedicina.popup5.text.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.popup5.text.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.popup5.text.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.popup5.text.font = "FiraSans-Italic"
                            }
                        }
                        self.popupsTelemedicina.popup5.alignmentText = brandAccount.valor64C ?? ""
                        self.popupsTelemedicina.popup5.whatsAppNumber = brandAccount.valor65C ?? ""
                        if let valor = brandAccount.valor66C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup5.btnWhatsApp.text = valor[0]
                            self.popupsTelemedicina.popup5.btnWhatsApp.colorText = valor[1]
                            self.popupsTelemedicina.popup5.btnWhatsApp.colorButton = valor[2]
                            self.popupsTelemedicina.popup5.btnWhatsApp.icon = valor[3]
                        } else if let valor = brandAccount.valor66C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup5.btnWhatsApp.text = valor[0]
                        }
                        
                        self.popupsTelemedicina.popup5.showAppointmentButton = brandAccount.valor67C ?? ""
                        if let valor = brandAccount.valor68C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup5.btnAppointmentButton.text = valor[0]
                            self.popupsTelemedicina.popup5.btnAppointmentButton.colorText = valor[1]
                            self.popupsTelemedicina.popup5.btnAppointmentButton.colorButton = valor[2]
                            self.popupsTelemedicina.popup5.btnAppointmentButton.icon = valor[3]
                        } else if let valor = brandAccount.valor68C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup5.btnAppointmentButton.text = valor[0]
                        }
                        self.popupsTelemedicina.popup5.id = brandAccount.valor69C ?? ""
                        self.popupsTelemedicina.popup5.clinicName = brandAccount.valor610C ?? ""
                        if let valor = brandAccount.valor611C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup5.btnContinueVideoCall.text = valor[0]
                            self.popupsTelemedicina.popup5.btnContinueVideoCall.colorText = valor[1]
                            self.popupsTelemedicina.popup5.btnContinueVideoCall.colorButton = valor[2]
                            self.popupsTelemedicina.popup5.btnContinueVideoCall.icon = valor[3]
                        } else if let valor = brandAccount.valor611C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup5.btnContinueVideoCall.text = valor[0]
                        }
                        
                        if let valor = brandAccount.valor612C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.popup5.btnGoOut.text = valor[0]
                            self.popupsTelemedicina.popup5.btnGoOut.colorText = valor[1]
                            self.popupsTelemedicina.popup5.btnGoOut.colorButton = valor[2]
                            self.popupsTelemedicina.popup5.btnGoOut.icon = valor[3]
                        } else if let valor = brandAccount.valor612C?.components(separatedBy: ";"), valor.count == 1 {
                            self.popupsTelemedicina.popup5.btnGoOut.text = valor[0]
                        }
                        
                        if let valor = brandAccount.valor71C?.components(separatedBy: ";"), valor.count >= 2{
                            self.popupsTelemedicina.leavePopup.iconColor = valor[0]
                            self.popupsTelemedicina.leavePopup.iconUrl = valor[1]
                        }
                        
                        self.popupsTelemedicina.leavePopup.text.text = brandAccount.valor72C?.htmlToString() ?? ""
                        if let valor = brandAccount.valor73C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.leavePopup.text.size = valor[1]
                            self.popupsTelemedicina.leavePopup.text.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.leavePopup.text.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.leavePopup.text.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.leavePopup.text.font = "FiraSans-Italic"
                            }
                        }
                        
                        self.popupsTelemedicina.leavePopup.placeholderReason.text = brandAccount.valor74C ?? ""
                        if let valor = brandAccount.valor75C?.components(separatedBy: ";"), valor.count >= 3{
                            self.popupsTelemedicina.leavePopup.placeholderReason.size = valor[1]
                            self.popupsTelemedicina.leavePopup.placeholderReason.color = valor[2]
                            if valor[0] == "firasans_regular" {
                                self.popupsTelemedicina.leavePopup.placeholderReason.font = "FiraSans-Regular"
                            }
                            if valor[0] == "firasans_bold" {
                                self.popupsTelemedicina.leavePopup.placeholderReason.font = "FiraSans-Bold"
                            }
                            if valor[0] == "firasans_italic" {
                                self.popupsTelemedicina.leavePopup.placeholderReason.font = "FiraSans-Italic"
                            }
                        }
                        
                        self.popupsTelemedicina.leavePopup.check.text = brandAccount.valor76C ?? ""
                        if let valor = brandAccount.valor77C?.components(separatedBy: ";"), valor.count >= 2{
                            self.popupsTelemedicina.leavePopup.check.size = valor[0]
                            self.popupsTelemedicina.leavePopup.check.color = valor[1]
                        }
                        
                       
                        if let valor = brandAccount.valor78C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.leavePopup.btnConfirm.text = valor[0]
                            self.popupsTelemedicina.leavePopup.btnConfirm.size = valor[2]
                            self.popupsTelemedicina.leavePopup.btnConfirm.color = valor[3]
                            if valor[1] == "firasans_regular" {
                                self.popupsTelemedicina.leavePopup.btnConfirm.font = "FiraSans-Regular"
                            }
                            if valor[1] == "firasans_bold" {
                                self.popupsTelemedicina.leavePopup.btnConfirm.font = "FiraSans-Bold"
                            }
                            if valor[1] == "firasans_italic" {
                                self.popupsTelemedicina.leavePopup.btnConfirm.font = "FiraSans-Italic"
                            }
                        }
                        
                        if let valor = brandAccount.valor79C?.components(separatedBy: ";"), valor.count >= 4{
                            self.popupsTelemedicina.leavePopup.btnCancel.text = valor[0]
                            self.popupsTelemedicina.leavePopup.btnCancel.size = valor[2]
                            self.popupsTelemedicina.leavePopup.btnCancel.color = valor[3]
                            if valor[1] == "firasans_regular" {
                                self.popupsTelemedicina.leavePopup.btnCancel.font = "FiraSans-Regular"
                            }
                            if valor[1] == "firasans_bold" {
                                self.popupsTelemedicina.leavePopup.btnCancel.font = "FiraSans-Bold"
                            }
                            if valor[1] == "firasans_italic" {
                                self.popupsTelemedicina.leavePopup.btnCancel.font = "FiraSans-Italic"
                            }
                        }
                    }
                }
            }
        }
    }
}
