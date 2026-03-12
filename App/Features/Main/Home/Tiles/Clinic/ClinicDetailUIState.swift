//
//  ClinicDetailUIState.swift
//  CareAssistance
//
//  Created by The App Master on 10/04/2024.
//

import Foundation

struct ClinicUIState{
    var clinicDetail = ClinicDetailUIState()
}
struct ClinicDetailUIState{
    var name = GreetingUIState()
    var shortDescription = GreetingUIState()
    var longDescription = GreetingUIState()
    var btnAppoint = BtnMoreUIState()
    var btnCall = BtnMoreUIState()
    var btnVideo = BtnMoreUIState()
    var btnWhatsApp = BtnMoreUIState()
    var btnsArt = BtnMoreUIState()
    var imgGradientColor = ""
    var buttonBackColor = ""
    var btnTextColor = ""
    var textWaitingMsg = ""
    var firstWaitingTime = 5
    var secondWaitingTime = 10
    var btnClose = BtnMoreUIState()
}

struct PopupsTelemedicina{
    var firstPopup = PopupData()
    var popup1 = PopupData()
    var popup2 = PopupData()
    var popup3 = PopupData()
    var popup4 = PopupData()
    var popup5 = PopupData()
    var leavePopup = LeavePopup()
    
    
    struct PopupData{
        var showPopup = ""
        var time = ""
        var text = GreetingUIState()
        var alignmentText = ""
        var whatsAppNumber = ""
        var btnWhatsApp = AtrButtonsPopup()
        var showAppointmentButton = ""
        var btnAppointmentButton = AtrButtonsPopup()
        var id = ""
        var clinicName = ""
        var btnContinueVideoCall = AtrButtonsPopup()
        var btnCallMoreLate = AtrButtonsPopup()
        var btnGoOut = AtrButtonsPopup()
        
        
    }
    struct LeavePopup{
        var iconUrl = ""
        var iconColor = ""
        var text = GreetingUIState()
        var placeholderReason = GreetingUIState()
        var check = GreetingUIState()
        var btnConfirm = GreetingUIState()
        var btnCancel = GreetingUIState()
    }
}

struct AtrButtonsPopup{
    var text = ""
    var colorText = ""
    var colorButton = ""
    var icon = ""
}
