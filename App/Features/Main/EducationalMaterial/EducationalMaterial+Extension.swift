//
//  EducationalMaterial+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 02/09/2025.
//

import Foundation

extension EducationalMaterialView{
    func loadUIState(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                //MARK: - SecMas
                if brandAccount.Name == "SecMas"{
                    //MARK: - MaterialList
                    self.UIState.materialList.title.text = brandAccount.valor61C ?? ""
                    if let valor = brandAccount.valor62C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.materialList.title.color = valor[0]
                        self.UIState.materialList.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialList.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialList.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialList.title.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.materialList.colorBackArrow = brandAccount.valor63C ?? ""
                    
                    self.UIState.materialList.listText.text = brandAccount.valor64C ?? ""
                    if let valor = brandAccount.valor65C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.materialList.listText.color = valor[0]
                        self.UIState.materialList.listText.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialList.listText.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialList.listText.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialList.listText.font = "FiraSans-Italic"
                        }
                    }
                    
                    self.UIState.materialList.placeholderSearch.text = brandAccount.valor66C ?? ""
                    if let valor = brandAccount.valor67C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.materialList.placeholderSearch.color = valor[0]
                        self.UIState.materialList.placeholderSearch.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialList.placeholderSearch.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialList.placeholderSearch.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialList.placeholderSearch.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor68C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.materialList.colorSearch.backgrountColor = valor[0]
                        self.UIState.materialList.colorSearch.iconColor = valor[1]
                    }
                    
                    if let valor = brandAccount.valor69C?.components(separatedBy: ";"), valor.count >= 3{
                        self.UIState.materialList.itemNames.color = valor[0]
                        self.UIState.materialList.itemNames.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialList.itemNames.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialList.itemNames.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialList.itemNames.font = "FiraSans-Italic"
                        }
                    }
                    
                    if let valor = brandAccount.valor610C?.components(separatedBy: ";"), valor.count >= 2{
                        self.UIState.materialList.btnFavorite.inActive = valor[0]
                        self.UIState.materialList.btnFavorite.active = valor[1]
                    }
                    
                    self.UIState.materialList.borderItem = brandAccount.valor611C ?? ""
                    
                    //MARK: - MaterialDetail
                    
                    if let valor = brandAccount.valor612C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.materialDetail.title.color = valor[0]
                        self.UIState.materialDetail.title.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialDetail.title.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialDetail.title.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialDetail.title.font = "FiraSans-Italic"
                        }
                        self.UIState.materialDetail.title.alignment = valor[3]
                    }
                    
                    if let valor = brandAccount.valor613C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.materialDetail.description.color = valor[0]
                        self.UIState.materialDetail.description.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialDetail.description.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialDetail.description.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialDetail.description.font = "FiraSans-Italic"
                        }
                        self.UIState.materialDetail.description.alignment = valor[3]
                    }
                    
                    if let valor = brandAccount.valor614C?.components(separatedBy: ";"), valor.count >= 5{
                        self.UIState.materialDetail.atrItems.color = valor[0]
                        self.UIState.materialDetail.atrItems.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialDetail.atrItems.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialDetail.atrItems.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialDetail.atrItems.font = "FiraSans-Italic"
                        }
                        self.UIState.materialDetail.atrItems.alignment = valor[3]
                        self.UIState.materialDetail.atrItems.colorFondoIcono = valor[4]
                    }
                    
                    if let valor = brandAccount.valor615C?.components(separatedBy: ";"), valor.count >= 4{
                        self.UIState.materialDetail.btnDownload.name = valor[0]
                        self.UIState.materialDetail.btnShare.name = valor[1]
                        self.UIState.materialDetail.btnDownload.show = valor[2]
                        self.UIState.materialDetail.btnShare.show = valor[3]
                    }
                    
                    if let valor = brandAccount.valor616C?.components(separatedBy: ";"), valor.count >= 7{
                        self.UIState.materialDetail.artButtonAction.color = valor[0]
                        self.UIState.materialDetail.artButtonAction.size = valor[1]
                        if valor[2] == "firasans_regular" {
                            self.UIState.materialDetail.artButtonAction.font = "FiraSans-Regular"
                        }
                        if valor[2] == "firasans_bold" {
                            self.UIState.materialDetail.artButtonAction.font = "FiraSans-Bold"
                        }
                        if valor[2] == "firasans_italic" {
                            self.UIState.materialDetail.artButtonAction.font = "FiraSans-Italic"
                        }
                        self.UIState.materialDetail.artButtonAction.alignment = valor[3]
                        self.UIState.materialDetail.artButtonAction.colorFondoIcono = valor[4]
                        self.UIState.materialDetail.artButtonAction.colorBorder = valor[5]
                        self.UIState.materialDetail.artButtonAction.colorBackground = valor[6]
                    }
                }
            }
        }
    }
}
