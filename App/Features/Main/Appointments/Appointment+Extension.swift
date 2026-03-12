//
//  Appointment+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 20/08/2024.
//

import Foundation

extension HomeView {
    func loadUIStateAppoint(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                //MARK: - AppointmentView
                if brandAccount.Name == "Agenda"{
                    self.UIStateAppoint.appointmentUIState.title.text = brandAccount.valor11C ?? ""
                    
                    if let valor = brandAccount.valor12C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.appointmentUIState.title.color = valor[0]
                        self.UIStateAppoint.appointmentUIState.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.appointmentUIState.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.appointmentUIState.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.appointmentUIState.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor13C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.appointmentUIState.date.color = valor[0]
                        self.UIStateAppoint.appointmentUIState.date.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.appointmentUIState.date.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.appointmentUIState.date.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.appointmentUIState.date.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor14C?.components(separatedBy: ";"), valor.count >= 6{
                        self.UIStateAppoint.appointmentUIState.calendarAtr.backColor = valor[0]
                        self.UIStateAppoint.appointmentUIState.calendarAtr.nameDayColor = valor[1]
                        self.UIStateAppoint.appointmentUIState.calendarAtr.numDayColor = valor[2]
                        self.UIStateAppoint.appointmentUIState.calendarAtr.numSelectColor = valor[3]
                        self.UIStateAppoint.appointmentUIState.calendarAtr.circleSelectColor = valor[4]
                        self.UIStateAppoint.appointmentUIState.calendarAtr.pointColor = valor[5]
                    }
                    self.UIStateAppoint.appointmentUIState.colorLineCite = brandAccount.valor15C ?? ""
                    
                    if let valor = brandAccount.valor16C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.appointmentUIState.titleList.color = valor[0]
                        self.UIStateAppoint.appointmentUIState.titleList.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.appointmentUIState.titleList.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.appointmentUIState.titleList.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.appointmentUIState.titleList.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor17C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.appointmentUIState.profesionalList.color = valor[0]
                        self.UIStateAppoint.appointmentUIState.profesionalList.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.appointmentUIState.profesionalList.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.appointmentUIState.profesionalList.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.appointmentUIState.profesionalList.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor18C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.appointmentUIState.hour.color = valor[0]
                        self.UIStateAppoint.appointmentUIState.hour.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.appointmentUIState.hour.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.appointmentUIState.hour.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.appointmentUIState.hour.font = "FiraSans-Italic"
                        }
                    }
                    self.UIStateAppoint.appointmentUIState.btnNew.textBtn = brandAccount.valor19C ?? ""
                    if let valor = brandAccount.Valor_1_10__c?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.appointmentUIState.btnNew.colorTextBtn = valor[0]
                        self.UIStateAppoint.appointmentUIState.btnNew.backgroundBtn = valor[1]
                        self.UIStateAppoint.appointmentUIState.btnNew.size = valor[2]
                        if valor[3] == "firasans_regular" {
                            self.UIStateAppoint.appointmentUIState.btnNew.font = "FiraSans-Regular"
                        }
                        if valor[3] == "firasans_bold" {
                            self.UIStateAppoint.appointmentUIState.btnNew.font = "FiraSans-Bold"
                        }
                        if valor[3] == "firasans_italic" {
                            self.UIStateAppoint.appointmentUIState.btnNew.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.Valor_1_11__c?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.appointmentUIState.separatorLineDate.backColor = valor[0]
                        self.UIStateAppoint.appointmentUIState.separatorLineDate.textColor = valor[1]
                        self.UIStateAppoint.appointmentUIState.separatorLineDate.size = valor[2]
                        if valor[3] == "firasans_regular" {
                            self.UIStateAppoint.appointmentUIState.separatorLineDate.font = "FiraSans-Regular"
                        }
                        if valor[3] == "firasans_bold" {
                            self.UIStateAppoint.appointmentUIState.separatorLineDate.font = "FiraSans-Bold"
                        }
                        if valor[3] == "firasans_italic" {
                            self.UIStateAppoint.appointmentUIState.separatorLineDate.font = "FiraSans-Italic"
                        }
                    }
                    
                    //MARK: - SelectClinic
                    self.UIStateAppoint.selectClinicUIState.title.text = brandAccount.valor21C ?? ""
                    
                    if let valor = brandAccount.valor22C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.selectClinicUIState.title.color = valor[0]
                        self.UIStateAppoint.selectClinicUIState.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.selectClinicUIState.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.selectClinicUIState.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.selectClinicUIState.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor23C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.selectClinicUIState.itemClinic.color = valor[0]
                        self.UIStateAppoint.selectClinicUIState.itemClinic.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.selectClinicUIState.itemClinic.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.selectClinicUIState.itemClinic.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.selectClinicUIState.itemClinic.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIStateAppoint.selectClinicUIState.colorImageBack = brandAccount.valor24C ?? ""
                    
                    //MARK: - NewAppointment
                    
                    self.UIStateAppoint.newAppointmentUIState.title.text = brandAccount.valor31C ?? ""
                    
                    if let valor = brandAccount.valor32C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.newAppointmentUIState.title.color = valor[0]
                        self.UIStateAppoint.newAppointmentUIState.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.newAppointmentUIState.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.newAppointmentUIState.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.newAppointmentUIState.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor33C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.newAppointmentUIState.labelsAtr.color = valor[0]
                        self.UIStateAppoint.newAppointmentUIState.labelsAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.newAppointmentUIState.labelsAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.newAppointmentUIState.labelsAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.newAppointmentUIState.labelsAtr.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor34C?.components(separatedBy: ";"), valor.count >= 5{
                        self.UIStateAppoint.newAppointmentUIState.btns.textColor = valor[0]
                        self.UIStateAppoint.newAppointmentUIState.btns.backColor = valor[1]
                        self.UIStateAppoint.newAppointmentUIState.btns.strokeColor_disableColor = valor[2]
                        self.UIStateAppoint.newAppointmentUIState.btns.size = valor[3]
                        if valor[4] == "firasans_regular" {
                            self.UIStateAppoint.newAppointmentUIState.btns.font = "FiraSans-Regular"
                        }
                        if valor[4] == "firasans_bold" {
                            self.UIStateAppoint.newAppointmentUIState.btns.font = "FiraSans-Bold"
                        }
                        if valor[4] == "firasans_italic" {
                            self.UIStateAppoint.newAppointmentUIState.btns.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIStateAppoint.newAppointmentUIState.labelTxtClinic = brandAccount.valor35C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.btnTextFirst = brandAccount.valor36C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.labelTxtProf = brandAccount.valor37C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.hintTxtProf = brandAccount.valor38C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.labelTxtDate = brandAccount.valor39C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.hintTxtDate = brandAccount.valor310C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.labelTxtHour = brandAccount.valor311C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.hintTxtHour = brandAccount.valor312C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.tipeOfAppointment = brandAccount.valor313C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.btnPhone.text = brandAccount.valor314C ?? ""
                    if let valor = brandAccount.valor315C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.newAppointmentUIState.btnPhone.textColor = valor[0]
                        self.UIStateAppoint.newAppointmentUIState.btnPhone.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.newAppointmentUIState.btnPhone.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.newAppointmentUIState.btnPhone.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.newAppointmentUIState.btnPhone.font = "FiraSans-Italic"
                        }
                    }
                    self.UIStateAppoint.newAppointmentUIState.btnPhoneDisable = brandAccount.valor316C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.btnPhoneEnable = brandAccount.valor41C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.btnPhoneSelected = brandAccount.valor42C ?? ""
                    
                    self.UIStateAppoint.newAppointmentUIState.btnVideo.text = brandAccount.valor43C ?? ""
                    if let valor = brandAccount.valor44C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.newAppointmentUIState.btnVideo.textColor = valor[0]
                        self.UIStateAppoint.newAppointmentUIState.btnVideo.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.newAppointmentUIState.btnVideo.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.newAppointmentUIState.btnVideo.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.newAppointmentUIState.btnVideo.font = "FiraSans-Italic"
                        }
                    }
                    self.UIStateAppoint.newAppointmentUIState.btnVideoDisable = brandAccount.valor45C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.btnVideoEnable = brandAccount.valor46C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.btnVideoSelected = brandAccount.valor47C ?? ""
                    
                    self.UIStateAppoint.newAppointmentUIState.btnAgend.textBtn = brandAccount.valor48C ?? ""
                    if let valor = brandAccount.valor49C?.components(separatedBy: ";"), valor.count >= 5{
                        self.UIStateAppoint.newAppointmentUIState.btnAgend.colorTextBtn = valor[0]
                        self.UIStateAppoint.newAppointmentUIState.btnAgend.backgroundPressBtn = valor[1]
                        self.UIStateAppoint.newAppointmentUIState.btnAgend.backgroundBtn = valor[2]
                        self.UIStateAppoint.newAppointmentUIState.btnAgend.size = valor[3]
                        if valor[4] == "firasans_regular" {
                            self.UIStateAppoint.newAppointmentUIState.btnAgend.font = "FiraSans-Regular"
                        }
                        if valor[4] == "firasans_bold" {
                            self.UIStateAppoint.newAppointmentUIState.btnAgend.font = "FiraSans-Bold"
                        }
                        if valor[4] == "firasans_italic" {
                            self.UIStateAppoint.newAppointmentUIState.btnAgend.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor49C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIStateAppoint.newAppointmentUIState.popupCalendar.colorDate = valor[0]
                        self.UIStateAppoint.newAppointmentUIState.popupCalendar.colorBtn = valor[1]
                    }
                    
                    self.UIStateAppoint.newAppointmentUIState.isBtnPhoneHidden = brandAccount.valor411C ?? ""
                    self.UIStateAppoint.newAppointmentUIState.isBtnVideoHidden = brandAccount.valor412C ?? ""
                    
                    
                    //MARK: - DetailAppointment
                    
                    self.UIStateAppoint.detaillAppointmentUIState.title.text = brandAccount.valor51C ?? ""
                    
                    if let valor = brandAccount.valor52C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.detaillAppointmentUIState.title.color = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor53C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.detaillAppointmentUIState.clinicsAtr.color = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.clinicsAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.clinicsAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.clinicsAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.clinicsAtr.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor54C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.detaillAppointmentUIState.dateAtr.color = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.dateAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.dateAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.dateAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.dateAtr.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor55C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.detaillAppointmentUIState.tipeAtr.color = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.tipeAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.tipeAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.tipeAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.tipeAtr.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor56C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.detaillAppointmentUIState.textAtr.color = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.textAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.textAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.textAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.textAtr.font = "FiraSans-Italic"
                        }
                    }
                    self.UIStateAppoint.detaillAppointmentUIState.textVideo1 = brandAccount.valor57C ?? ""
                    self.UIStateAppoint.detaillAppointmentUIState.textVideo2 = brandAccount.valor58C ?? ""
                    self.UIStateAppoint.detaillAppointmentUIState.textVideo3 = brandAccount.valor59C ?? ""
                    if let valor = brandAccount.valor510C?.components(separatedBy: ";"), valor.count >= 6{
                        self.UIStateAppoint.detaillAppointmentUIState.btnVideo.colorTextBtn = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.btnVideo.backgroundPressBtn = valor[1]
                        self.UIStateAppoint.detaillAppointmentUIState.btnVideo.backgroundBtn = valor[2]
                        self.UIStateAppoint.detaillAppointmentUIState.btnVideo.textBtn = valor[3]
                        self.UIStateAppoint.detaillAppointmentUIState.btnVideo.size = valor[4]
                        if valor[5] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnVideo.font = "FiraSans-Regular"
                        }
                        if valor[5] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnVideo.font = "FiraSans-Bold"
                        }
                        if valor[5] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnVideo.font = "FiraSans-Italic"
                        }
                    }
                    self.UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.text = brandAccount.valor511C ?? ""
                    if let valor = brandAccount.valor512C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.color = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.font = "FiraSans-Italic"
                        }
                    }
                    self.UIStateAppoint.detaillAppointmentUIState.textPhone1 = brandAccount.valor513C ?? ""
                    self.UIStateAppoint.detaillAppointmentUIState.textPhone2 = brandAccount.valor514C ?? ""
                    self.UIStateAppoint.detaillAppointmentUIState.textPhone3 = brandAccount.valor515C ?? ""
                    self.UIStateAppoint.detaillAppointmentUIState.textPhone4 = brandAccount.valor516C ?? ""
                    self.UIStateAppoint.detaillAppointmentUIState.textPhone5 = brandAccount.valor61C ?? ""
                    if let valor = brandAccount.valor62C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIStateAppoint.detaillAppointmentUIState.btnConfirm1 = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.btnConfirm2 = valor[1]
                    }
                    
                    if let valor = brandAccount.valor63C?.components(separatedBy: ";"), valor.count >= 5{
                        self.UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.colorTextBtn = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.backgroundPressBtn = valor[1]
                        self.UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.backgroundBtn = valor[2]
                        self.UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.size = valor[3]
                        if valor[4] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.font = "FiraSans-Regular"
                        }
                        if valor[4] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.font = "FiraSans-Bold"
                        }
                        if valor[4] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIStateAppoint.detaillAppointmentUIState.btnCancel.textBtn = brandAccount.valor64C ?? ""
                    
                    if let valor = brandAccount.valor65C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.detaillAppointmentUIState.btnCancel.colorTextBtn = valor[0]
                        self.UIStateAppoint.detaillAppointmentUIState.btnCancel.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnCancel.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnCancel.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.detaillAppointmentUIState.btnCancel.font = "FiraSans-Italic"
                        }
                    }
                    
                    //MARK: - PopupAppointments
                    
                    self.UIStateAppoint.popupAppointmentUIState.iconCheck = brandAccount.valor71C ?? ""
                    self.UIStateAppoint.popupAppointmentUIState.iconCalendar = brandAccount.valor72C ?? ""
                    if let valor = brandAccount.valor73C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAppointmentUIState.agend.text1 = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.agend.text2 = valor[1]
                        self.UIStateAppoint.popupAppointmentUIState.agend.btnOk = valor[2]
                    }
                    if let valor = brandAccount.valor74C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIStateAppoint.popupAppointmentUIState.confirm.text1 = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.confirm.btnOk = valor[1]
                    }
                    
                    if let valor = brandAccount.valor75C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAppointmentUIState.cancel.text1 = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.cancel.btnCancel = valor[1]
                        self.UIStateAppoint.popupAppointmentUIState.cancel.btnOk = valor[2]
                    }
                    if let valor = brandAccount.valor76C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIStateAppoint.popupAppointmentUIState.cancel2.text1 = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.cancel2.btnOk = valor[1]
                    }
                    if let valor = brandAccount.valor77C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIStateAppoint.popupAppointmentUIState.modifier.text1 = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.modifier.btnOk = valor[1]
                    }
                    
                    if let valor = brandAccount.valor78C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAppointmentUIState.titleTxt.color = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.titleTxt.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAppointmentUIState.titleTxt.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAppointmentUIState.titleTxt.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAppointmentUIState.titleTxt.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor79C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAppointmentUIState.textAtr.color = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.textAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAppointmentUIState.textAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAppointmentUIState.textAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAppointmentUIState.textAtr.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor710C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAppointmentUIState.btnCancel.color = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.btnCancel.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAppointmentUIState.btnCancel.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAppointmentUIState.btnCancel.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAppointmentUIState.btnCancel.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor711C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAppointmentUIState.btnConfirm.color = valor[0]
                        self.UIStateAppoint.popupAppointmentUIState.btnConfirm.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAppointmentUIState.btnConfirm.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAppointmentUIState.btnConfirm.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAppointmentUIState.btnConfirm.font = "FiraSans-Italic"
                        }
                    }
                    //MARK: - PopupAllreadyHaveAppointment
                    
                    self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.text = brandAccount.valor81C ?? "¡Atención!"
                    if let valor = brandAccount.valor82C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.color = valor[0]
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.font = "FiraSans-Italic"
                        }
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.alignment = valor[3]
                    }
                    
                    self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.text = brandAccount.valor83C?.htmlToString() ?? ""
                    if let valor = brandAccount.valor84C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.color = valor[0]
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.font = "FiraSans-Italic"
                        }
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.alignment = valor[3]
                    }
                    
                    self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn.text = brandAccount.valor85C ?? "Entendido"
                    if let valor = brandAccount.valor86C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn.color = valor[0]
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.text = brandAccount.valor87C ?? "¡Atención!"
                    if let valor = brandAccount.valor88C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.color = valor[0]
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.font = "FiraSans-Italic"
                        }
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.alignment = valor[3]
                    }
                    
                    if let valor = brandAccount.valor89C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.text = valor[0]
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg2 = valor[1]
                    }
                    
                    if let valor = brandAccount.valor810C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.color = valor[0]
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.font = "FiraSans-Italic"
                        }
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.alignment = valor[3]
                    }
                    
                    self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn.text = brandAccount.valor811C ?? "Entendido"
                    if let valor = brandAccount.valor812C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn.color = valor[0]
                        self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn.font = "FiraSans-Italic"
                        }
                    }
                    
                    //MARK: -Popup Validation Appoinment
                    
                    self.UIStateAppoint.popupCantAgendAppointment.img = brandAccount.valor91C ?? ""
                    
                    self.UIStateAppoint.popupCantAgendAppointment.title.text = brandAccount.valor92C ?? ""
                    if let valor = brandAccount.valor93C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.popupCantAgendAppointment.title.color = valor[0]
                        self.UIStateAppoint.popupCantAgendAppointment.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupCantAgendAppointment.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupCantAgendAppointment.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupCantAgendAppointment.title.font = "FiraSans-Italic"
                        }
                        self.UIStateAppoint.popupCantAgendAppointment.title.alignment = valor[3]
                    }
                    
                    self.UIStateAppoint.popupCantAgendAppointment.msg.text = brandAccount.valor94C?.htmlToString() ?? ""
                    if let valor = brandAccount.valor95C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.popupCantAgendAppointment.msg.color = valor[0]
                        self.UIStateAppoint.popupCantAgendAppointment.msg.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupCantAgendAppointment.msg.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupCantAgendAppointment.msg.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupCantAgendAppointment.msg.font = "FiraSans-Italic"
                        }
                        self.UIStateAppoint.popupCantAgendAppointment.msg.alignment = valor[3]
                    }
                    
                    self.UIStateAppoint.popupCantAgendAppointment.btn.text = brandAccount.valor96C ?? ""
                    if let valor = brandAccount.valor97C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIStateAppoint.popupCantAgendAppointment.btn.color = valor[0]
                        self.UIStateAppoint.popupCantAgendAppointment.btn.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIStateAppoint.popupCantAgendAppointment.btn.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIStateAppoint.popupCantAgendAppointment.btn.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIStateAppoint.popupCantAgendAppointment.btn.font = "FiraSans-Italic"
                        }
                        self.UIStateAppoint.popupCantAgendAppointment.btn.alignment = valor[3]
                    }
                }
            }
        }
    }
}
