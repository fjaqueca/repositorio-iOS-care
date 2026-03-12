//
//  FamilyGroup+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 18/07/2024.
//

import Foundation

extension FamilyGroupView{
    
    func loadUIState(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                if brandAccount.Name == "PreLogin"{
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
                        
                        //MARK: - PopupRegisterSuccessUIState
                        self.UIState.popupRegisterSuccessUIState.imageBackground = brandAccount.Valor_11_1__c ?? ""
                        
                        self.UIState.popupRegisterSuccessUIState.icon = brandAccount.Valor_11_2__c ?? ""
                        
                        self.UIState.popupRegisterSuccessUIState.msg.text = brandAccount.Valor_11_3__c ?? ""
                        if let valor114 = brandAccount.Valor_11_4__c?.components(separatedBy: ";"), valor114.count >= 2{
                            self.UIState.popupRegisterSuccessUIState.msg.colorText = valor114[0]
                            self.UIState.popupRegisterSuccessUIState.msg.sizeText = valor114[1]
                        }
                    }
                    
                }
            }
            self.isLoading = false
        }
    }
}


