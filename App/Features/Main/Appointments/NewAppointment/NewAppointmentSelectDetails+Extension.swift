//
//  NewAppointmentSelectDetails+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 16/04/2025.
//

import Foundation

extension NewAppointmentSelectDetailsView {
    
    func configPopupConsent(){
        if let record = self.items.first?.records {
            let forms = ["ConsentimientoInformado-1", "ConsentimientoInformado-2", "ConsentimientoInformado-3", "ConsentimientoInformado-4"]
            
            for ba in record where forms.contains(ba.Name ?? "") {
                for i in 1...13 {
                    if i == 11 {
                        if let popup = buildPopupConsent(prefix: "Valor_11_", base: i, ba: ba, idClinic: nil) {
                            self.popupConsent.append(popup)
                        }
                    } else {
                        let idClinic = (i == 1) ? ba.value(forKey: "Valor_1_10__c") as? String : nil
                        if let popup = buildPopupConsent(prefix: "valor", base: i, ba: ba, idClinic: idClinic) {
                            self.popupConsent.append(popup)
                        }
                    }
                }
            }
            print(self.popupConsent)
        }
    }
    
    func buildPopupConsent(prefix: String, base: Int, ba: BrandAccount, idClinic: String?) -> PopupConsent? {
        func key(_ offset: Int) -> String {
            return prefix == "valor" ? "\(prefix)\(base)\(offset)C" : "\(prefix)\(offset)__c"
        }

        guard
            let atrTitleStr = ba.safeValue(forKey: key(3)) as? String,
            let atrTitle = atrTitleStr.components(separatedBy: ";").valid(count: 3),
            let atrTextStr = ba.safeValue(forKey: key(6)) as? String,
            let atrText = atrTextStr.components(separatedBy: ";").valid(count: 3),
            let atrBtnCancelStr = ba.safeValue(forKey: key(8)) as? String,
            let atrBtnCancel = atrBtnCancelStr.components(separatedBy: ";").valid(count: 3),
            let atrBtnAceptStr = ba.safeValue(forKey: key(9)) as? String,
            let atrBtnAcept = atrBtnAceptStr.components(separatedBy: ";").valid(count: 3)
        else {
            return nil
        }

        let setFontTitle = fontTextWithInit(from: atrTitle[0])
        let setFontText = fontTextWithInit(from: atrText[0])
        let setAlignmentTitle = TextAlignmentFromString(from: ba.safeValue(forKey: key(4)) as? String ?? "").alignment
        let setAlignmentText = TextAlignmentFromString(from: ba.safeValue(forKey: key(7)) as? String ?? "").alignment

        return PopupConsent(
            logo: ba.safeValue(forKey: key(1)) as? String ?? "",
            title: BrandAccountText(
                text: ba.safeValue(forKey: key(2)) as? String ?? "",
                font: setFontTitle,
                color: atrTitle[2],
                size: atrTitle[1],
                alignment: setAlignmentTitle,
                show: ""
            ),
            consentText: BrandAccountText(
                text: (ba.safeValue(forKey: key(5)) as? String)?.htmlToString() ?? "",
                font: setFontText,
                color: atrText[2],
                size: atrText[1],
                alignment: setAlignmentText,
                show: ""
            ),
            btnCancel: BtnUIState(
                textBtn: atrBtnCancel[0],
                colorTextBtn: atrBtnCancel[1],
                backgroundBtn: atrBtnCancel[2]
            ),
            btnAcept: BtnUIState(
                textBtn: atrBtnAcept[0],
                colorTextBtn: atrBtnAcept[1],
                backgroundBtn: atrBtnAcept[2]
            ),
            clinicId: idClinic ?? (ba.safeValue(forKey: key(10)) as? String ?? "")
        )
    }
    
}



