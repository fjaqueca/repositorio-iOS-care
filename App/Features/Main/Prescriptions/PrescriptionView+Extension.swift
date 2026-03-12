//
//  PrescriptionView+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 03/04/2024.
//

import Foundation

extension PrescriptionsView{
    func loadUIState(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                //MARK: - SecMas
                if brandAccount.Name == "SecMas"{
                    //MARK: - presList
                    self.UIState.presList.imageBackground = brandAccount.valor31C ?? ""
                    self.UIState.presList.title.text = brandAccount.valor32C ?? ""
                    
                    if let valor = brandAccount.valor33C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presList.title.color = valor[0]
                        self.UIState.presList.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presList.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presList.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presList.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presList.textBrowser = brandAccount.valor34C ?? ""
                    
                    self.UIState.presList.btnDownload.textBtn = brandAccount.valor35C ?? ""
                    if let valor = brandAccount.valor36C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presList.btnDownload.colorTextBtn = valor[0]
                        self.UIState.presList.btnDownload.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presList.btnDownload.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presList.btnDownload.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presList.btnDownload.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presList.btnShare.textBtn = brandAccount.valor37C ?? ""
                    if let valor = brandAccount.valor38C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presList.btnShare.colorTextBtn = valor[0]
                        self.UIState.presList.btnShare.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presList.btnShare.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presList.btnShare.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presList.btnShare.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presList.btnSelect.textBtn = brandAccount.valor39C ?? ""
                    if let valor = brandAccount.valor310C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presList.btnSelect.colorTextBtn = valor[0]
                        self.UIState.presList.btnSelect.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presList.btnSelect.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presList.btnSelect.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presList.btnSelect.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presList.titleList.text = brandAccount.valor311C ?? ""
                    if let valor = brandAccount.valor312C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presList.titleList.color = valor[0]
                        self.UIState.presList.titleList.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presList.titleList.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presList.titleList.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presList.titleList.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor313C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presList.itemTitle.color = valor[0]
                        self.UIState.presList.itemTitle.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presList.itemTitle.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presList.itemTitle.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presList.itemTitle.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor314C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presList.itemSubTitle.color = valor[0]
                        self.UIState.presList.itemSubTitle.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presList.itemSubTitle.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presList.itemSubTitle.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presList.itemSubTitle.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presList.iconSelectColor = brandAccount.valor315C ?? ""
                    
                    self.UIState.presList.textToShare = brandAccount.valor316C ?? ""
                    
                    //MARK: - presDetail
                    self.UIState.presDetail.imageBackground = brandAccount.valor41C ?? ""
                    
                    if let valor = brandAccount.valor42C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.date.color = valor[0]
                        self.UIState.presDetail.date.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.date.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.date.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.date.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor43C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.title.color = valor[0]
                        self.UIState.presDetail.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor44C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.specialty.color = valor[0]
                        self.UIState.presDetail.specialty.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.specialty.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.specialty.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.specialty.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor45C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.medic.color = valor[0]
                        self.UIState.presDetail.medic.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.medic.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.medic.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.medic.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor46C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.presDetail.medicine = valor[0]
                        self.UIState.presDetail.dose = valor[1]
                        self.UIState.presDetail.indications = valor[2]
                        self.UIState.presDetail.attachedPres = valor[3]
                        
                    }
                    
                    if let valor = brandAccount.valor47C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.subtitleAtr.color = valor[0]
                        self.UIState.presDetail.subtitleAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.subtitleAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.subtitleAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.subtitleAtr.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor48C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.textAtr.color = valor[0]
                        self.UIState.presDetail.textAtr.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.textAtr.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.textAtr.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.textAtr.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presDetail.btnDownload.textBtn = brandAccount.valor49C ?? ""
                    if let valor = brandAccount.valor410C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.btnDownload.colorTextBtn = valor[0]
                        self.UIState.presDetail.btnDownload.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.btnDownload.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.btnDownload.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.btnDownload.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presDetail.btnShare.textBtn = brandAccount.valor411C ?? ""
                    if let valor = brandAccount.valor412C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.btnShare.colorTextBtn = valor[0]
                        self.UIState.presDetail.btnShare.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.btnShare.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.btnShare.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.btnShare.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.presDetail.btnRepeat.textBtn = brandAccount.valor413C ?? ""
                    if let valor = brandAccount.valor414C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.presDetail.btnRepeat.colorTextBtn = valor[0]
                        self.UIState.presDetail.btnRepeat.sizeTextBtn = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.presDetail.btnRepeat.fontTextBtn = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.presDetail.btnRepeat.fontTextBtn = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.presDetail.btnRepeat.fontTextBtn = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor415C?.components(separatedBy: ";"), valor.count >= 8{
                        self.UIState.presFilter.titleText = valor[0]
                        self.UIState.presFilter.btn1Text = valor[1]
                        self.UIState.presFilter.btn2Text = valor[2]
                        self.UIState.presFilter.titleColor = valor[3]
                        self.UIState.presFilter.btn1ColorBack = valor[4]
                        self.UIState.presFilter.btn1ColorText = valor[5]
                        self.UIState.presFilter.btn2ColorBack = valor[6]
                        self.UIState.presFilter.btn2ColorText = valor[7]
                        
                    }
                    
                    if let valor = brandAccount.valor516C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.presDetail.svgIconShowArchive = valor[0]
                        self.UIState.presDetail.svgIconShowArchiveBackground = valor[1]
                    }
                }
            }
        }
    }

}
