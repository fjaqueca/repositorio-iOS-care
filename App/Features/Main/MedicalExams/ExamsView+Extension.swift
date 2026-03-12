//
//  MedicalExams+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 03/04/2024.
//

import Foundation

extension ExamsView{
    func loadUIState(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                //MARK: - SecMas
                if brandAccount.Name == "SecMas"{
                    //MARK: - ExamList
                    self.UIState.examList.imageBackground = brandAccount.valor11C ?? ""
                    self.UIState.examList.title.text = brandAccount.valor12C ?? ""
                    
                    if let valor = brandAccount.valor13C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examList.title.color = valor[0]
                        self.UIState.examList.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examList.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examList.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examList.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.examList.textBrowser = brandAccount.valor14C ?? ""
                    
                    self.UIState.examList.btnDownload.textBtn = brandAccount.valor15C ?? ""
                    if let valor = brandAccount.valor16C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examList.btnDownload.colorTextBtn = valor[0]
                        self.UIState.examList.btnDownload.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examList.btnDownload.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examList.btnDownload.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examList.btnDownload.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.examList.btnShare.textBtn = brandAccount.valor17C ?? ""
                    if let valor = brandAccount.valor18C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examList.btnShare.colorTextBtn = valor[0]
                        self.UIState.examList.btnShare.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examList.btnShare.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examList.btnShare.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examList.btnShare.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.examList.btnSelect.textBtn = brandAccount.valor19C ?? ""
                    if let valor = brandAccount.Valor_1_10__c?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examList.btnSelect.colorTextBtn = valor[0]
                        self.UIState.examList.btnSelect.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examList.btnSelect.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examList.btnSelect.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examList.btnSelect.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.examList.titleList.text = brandAccount.Valor_1_11__c ?? ""
                    if let valor = brandAccount.Valor_1_12__c?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examList.titleList.color = valor[0]
                        self.UIState.examList.titleList.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examList.titleList.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examList.titleList.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examList.titleList.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.Valor_1_13__c?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examList.itemTitle.color = valor[0]
                        self.UIState.examList.itemTitle.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examList.itemTitle.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examList.itemTitle.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examList.itemTitle.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.Valor_1_14__c?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examList.itemSubTitle.color = valor[0]
                        self.UIState.examList.itemSubTitle.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examList.itemSubTitle.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examList.itemSubTitle.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examList.itemSubTitle.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.examList.iconSelectColor = brandAccount.Valor_1_15__c ?? ""
                    
                    self.UIState.examList.textToShare = brandAccount.Valor_1_16__c ?? ""
                    
                    //MARK: - ExamDetail
                    self.UIState.examDetail.imageBackground = brandAccount.valor21C ?? ""
                    self.UIState.examDetail.title.text = brandAccount.valor22C ?? ""
                    
                    if let valor = brandAccount.valor23C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.title.color = valor[0]
                        self.UIState.examDetail.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor24C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.medic.color = valor[0]
                        self.UIState.examDetail.medic.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.medic.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.medic.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.medic.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor25C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.prescription.color = valor[0]
                        self.UIState.examDetail.prescription.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.prescription.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.prescription.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.prescription.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor26C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.program.color = valor[0]
                        self.UIState.examDetail.program.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.program.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.program.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.program.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.examDetail.indicatorTitle.text = brandAccount.valor27C ?? ""
                    
                    if let valor = brandAccount.valor28C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.indicatorTitle.color = valor[0]
                        self.UIState.examDetail.indicatorTitle.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.indicatorTitle.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.indicatorTitle.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.indicatorTitle.font = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor29C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.indicatorDescription.color = valor[0]
                        self.UIState.examDetail.indicatorDescription.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.indicatorDescription.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.indicatorDescription.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.indicatorDescription.font = "FiraSans-Italic"
                        }
                    }
                    self.UIState.examDetail.btnDownload.textBtn = brandAccount.valor210C ?? ""
                    
                    if let valor = brandAccount.valor211C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.btnDownload.colorTextBtn = valor[0]
                        self.UIState.examDetail.btnDownload.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.btnDownload.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.btnDownload.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.btnDownload.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    self.UIState.examDetail.btnShare.textBtn = brandAccount.valor212C ?? ""
                    
                    if let valor = brandAccount.valor213C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.btnShare.colorTextBtn = valor[0]
                        self.UIState.examDetail.btnShare.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.btnShare.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.btnShare.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.btnShare.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    if let valor = brandAccount.valor214C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.examDetail.sendedExamText1 = valor[0]
                        self.UIState.examDetail.sendedExamText2 = valor[1]
                    }
                    
                    if let valor = brandAccount.valor215C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.examDetail.sendedExam.color = valor[0]
                        self.UIState.examDetail.sendedExam.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.examDetail.sendedExam.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.examDetail.sendedExam.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.examDetail.sendedExam.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor216C?.components(separatedBy: ";"), valor.count >= 8{
                        self.UIState.examFilter.titleText = valor[0]
                        self.UIState.examFilter.btn1Text = valor[1]
                        self.UIState.examFilter.btn2Text = valor[2]
                        self.UIState.examFilter.titleColor = valor[3]
                        self.UIState.examFilter.btn1ColorBack = valor[4]
                        self.UIState.examFilter.btn1ColorText = valor[5]
                        self.UIState.examFilter.btn2ColorBack = valor[6]
                        self.UIState.examFilter.btn2ColorText = valor[7]
                        
                    }
                    
                    self.UIState.examWindows.titleOrderExam.text = brandAccount.valor51C ?? ""
                    
                    if let valor = brandAccount.valor52C?.components(separatedBy: ";"), valor.count >= 5{
                        self.UIState.examWindows.titleOrderExam.colorActive = valor[0]
                        self.UIState.examWindows.titleOrderExam.colorInActive = valor[1]
                        self.UIState.examWindows.titleOrderExam.size = valor[2]
                        if valor[3] == "firasans_regular" {
                            self.UIState.examWindows.titleOrderExam.fontActive = "FiraSans-Regular"
                        }
                        if valor[3] == "firasans_bold" {
                            self.UIState.examWindows.titleOrderExam.fontActive = "FiraSans-Bold"
                        }
                        if valor[3] == "firasans_italic" {
                            self.UIState.examWindows.titleOrderExam.fontActive = "FiraSans-Italic"
                        }
                        
                        if valor[4] == "firasans_regular" {
                            self.UIState.examWindows.titleOrderExam.fontInActive = "FiraSans-Regular"
                        }
                        if valor[4] == "firasans_bold" {
                            self.UIState.examWindows.titleOrderExam.fontInActive = "FiraSans-Bold"
                        }
                        if valor[4] == "firasans_italic" {
                            self.UIState.examWindows.titleOrderExam.fontInActive = "FiraSans-Italic"
                        }
                    }
                    self.UIState.examWindows.titlePatientExam.text = brandAccount.valor53C ?? ""
                    
                    if let valor = brandAccount.valor54C?.components(separatedBy: ";"), valor.count >= 5{
                        self.UIState.examWindows.titlePatientExam.colorActive = valor[0]
                        self.UIState.examWindows.titlePatientExam.colorInActive = valor[1]
                        self.UIState.examWindows.titlePatientExam.size = valor[2]
                        if valor[3] == "firasans_regular" {
                            self.UIState.examWindows.titlePatientExam.fontActive = "FiraSans-Regular"
                        }
                        if valor[3] == "firasans_bold" {
                            self.UIState.examWindows.titlePatientExam.fontActive = "FiraSans-Bold"
                        }
                        if valor[3] == "firasans_italic" {
                            self.UIState.examWindows.titlePatientExam.fontActive = "FiraSans-Italic"
                        }
                        
                        if valor[4] == "firasans_regular" {
                            self.UIState.examWindows.titlePatientExam.fontInActive = "FiraSans-Regular"
                        }
                        if valor[4] == "firasans_bold" {
                            self.UIState.examWindows.titlePatientExam.fontInActive = "FiraSans-Bold"
                        }
                        if valor[4] == "firasans_italic" {
                            self.UIState.examWindows.titlePatientExam.fontInActive = "FiraSans-Italic"
                        }
                    }
                    self.UIState.examWindows.colorLine = brandAccount.valor55C ?? ""
                    
                    self.UIState.btnAddSeeExam.btnAddExam.textBtn = brandAccount.valor56C ?? ""
                    if let valor = brandAccount.valor57C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.btnAddSeeExam.btnAddExam.colorTextBtn = valor[0]
                        self.UIState.btnAddSeeExam.btnAddExam.colorButton = valor[1]
                        self.UIState.btnAddSeeExam.btnAddExam.sizeTextBtn = valor[2]
                        if valor[3] == "firasans_regular" {
                            self.UIState.btnAddSeeExam.btnAddExam.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[3] == "firasans_bold" {
                            self.UIState.btnAddSeeExam.btnAddExam.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[3] == "firasans_italic" {
                            self.UIState.btnAddSeeExam.btnAddExam.fontTextBtn = "FiraSans-Italic"
                        }
                        
                    }
                    
                    self.UIState.btnAddSeeExam.btnSeeExam.textBtn = brandAccount.valor58C ?? ""
                    if let valor = brandAccount.valor59C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.btnAddSeeExam.btnSeeExam.colorTextBtn = valor[0]
                        self.UIState.btnAddSeeExam.btnSeeExam.colorButton = valor[1]
                        self.UIState.btnAddSeeExam.btnSeeExam.sizeTextBtn = valor[2]
                        if valor[3] == "firasans_regular" {
                            self.UIState.btnAddSeeExam.btnSeeExam.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[3] == "firasans_bold" {
                            self.UIState.btnAddSeeExam.btnSeeExam.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[3] == "firasans_italic" {
                            self.UIState.btnAddSeeExam.btnSeeExam.fontTextBtn = "FiraSans-Italic"
                        }
                        
                    }
                    self.UIState.examDetail.svgDeletArchive = brandAccount.valor514C ?? ""
                    
                    if let valor = brandAccount.valor515C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.examDetail.svgIconShowArchive = valor[0]
                        self.UIState.examDetail.svgIconShowArchiveBackground = valor[1]
                    }
                    
                    
                    //MARK: - SuccessPopup
                    
                    self.UIState.popupSuccessSendExam.iconCheck = brandAccount.valor81C ?? ""
                    
                    self.UIState.popupSuccessSendExam.successInfo.text1 = brandAccount.valor82C ?? ""
                    
                    if let valor = brandAccount.valor83C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupSuccessSendExam.titleAtr.color = valor[0]
                        self.UIState.popupSuccessSendExam.titleAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupSuccessSendExam.titleAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupSuccessSendExam.titleAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupSuccessSendExam.titleAtr.font = "FiraSans-Italic"
                        }
                        self.UIState.popupSuccessSendExam.titleAtr.alignment = valor[3]
                    }
                    
                    self.UIState.popupSuccessSendExam.successInfo.text2 = brandAccount.valor84C?.htmlToString() ?? ""
                    
                    if let valor = brandAccount.valor85C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupSuccessSendExam.textAtr.color = valor[0]
                        self.UIState.popupSuccessSendExam.textAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupSuccessSendExam.textAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupSuccessSendExam.textAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupSuccessSendExam.textAtr.font = "FiraSans-Italic"
                        }
                        self.UIState.popupSuccessSendExam.textAtr.alignment = valor[3]
                    }
                    
                    self.UIState.popupSuccessSendExam.successInfo.btnOk = brandAccount.valor86C ?? ""
                    self.UIState.popupSuccessSendExam.btnAtr.show = "biggest"
                    if let valor = brandAccount.valor87C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.popupSuccessSendExam.btnAtr.color = valor[0]
                        self.UIState.popupSuccessSendExam.btnAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.popupSuccessSendExam.btnAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.popupSuccessSendExam.btnAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.popupSuccessSendExam.btnAtr.font = "FiraSans-Italic"
                        }
                        self.UIState.popupSuccessSendExam.btnAtr.alignment = valor[3]
                    }
                }
            }
        }
    }
}
