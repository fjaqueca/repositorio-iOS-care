//
//  ExamsUIState.swift
//  CareAssistance
//
//  Created by The App Master on 05/03/2024.
//

import Foundation

struct ExamUIState{
    var examList = ExamListUIState()
    var examDetail = ExamDetailUIState()
    var examFilter = ExamFilterUIState()
    var examWindows = ExamWindowsUIState()
    var btnAddSeeExam = AddSeeExamsUIState()
    var popupSuccessSendExam = PopupSuccessSendExamUIState()
}

struct ExamListUIState{
    var title = GreetingUIState()
    var textBrowser = ""
    var btnDownload = BtnMoreUIState()
    var btnShare = BtnMoreUIState()
    var btnSelect = BtnMoreUIState()
    var titleList = GreetingUIState()
    var itemTitle = GreetingUIState()
    var itemSubTitle = GreetingUIState()
    var textToShare = ""
    var iconSelectColor = ""
    var imageBackground = ""
}
struct ExamDetailUIState{
    var title = GreetingUIState()
    var medic = GreetingUIState()
    var prescription = GreetingUIState()
    var program = GreetingUIState()
    var indicatorTitle = GreetingUIState()
    var indicatorDescription = GreetingUIState()
    var btnDownload = BtnMoreUIState()
    var btnShare = BtnMoreUIState()
    var sendedExam = GreetingUIState()
    var sendedExamText1 = ""
    var sendedExamText2 = ""
    var iconSelectColor = ""
    var imageBackground = ""
    var svgDeletArchive = ""
    var svgIconShowArchive = ""
    var svgIconShowArchiveBackground = ""
}
struct BtnMoreUIState{
    var textBtn: String = ""
    var colorTextBtn: String = ""
    var sizeTextBtn: String = ""
    var fontTextBtn: String = ""
    var iconBtn: String = ""
    var colorButton: String = ""
}

struct ExamFilterUIState{
    var titleText: String = ""
    var btn1Text: String = ""
    var btn2Text: String = ""
    var titleColor: String = ""
    var btn1ColorBack: String = ""
    var btn1ColorText: String = ""
    var btn2ColorBack: String = ""
    var btn2ColorText: String = ""
}
struct ExamWindowsUIState{
    var titleOrderExam = WindowsUIState()
    var titlePatientExam = WindowsUIState()
    var colorLine: String = ""
    
}
struct WindowsUIState{
    var text: String = ""
    var fontActive: String = ""
    var fontInActive: String = ""
    var size: String = ""
    var colorActive: String = ""
    var colorInActive: String = ""
}
struct AddSeeExamsUIState{
    var btnAddExam = BtnMoreUIState()
    var btnSeeExam = BtnMoreUIState()
    var colorLine: String = ""
    
}

struct PopupSuccessSendExamUIState{
    var iconCheck: String = ""
    var successInfo = PopupAppointmentUIStateModel()
    var titleAtr = GreetingUIState()
    var textAtr = GreetingUIState()
    var btnAtr = GreetingUIState()
}
