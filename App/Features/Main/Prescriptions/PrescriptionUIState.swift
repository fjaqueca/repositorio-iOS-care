//
//  PrescriptionUIState.swift
//  CareAssistance
//
//  Created by The App Master on 03/04/2024.
//

import Foundation

struct PrescriptionUIState{
    var presList = ExamListUIState()
    var presDetail = PrescriptionDetailUIState()
    var presFilter = ExamFilterUIState()
}
struct PrescriptionDetailUIState{
    var date = GreetingUIState()
    var title = GreetingUIState()
    var specialty = GreetingUIState()
    var medic = GreetingUIState()
    var medicine = ""
    var dose = ""
    var indications = ""
    var attachedPres = ""
    var subtitleAtr = GreetingUIState()
    var textAtr = GreetingUIState()
    var btnDownload = BtnMoreUIState()
    var btnShare = BtnMoreUIState()
    var btnRepeat = BtnMoreUIState()
    var imageBackground = ""
    var svgIconShowArchive = ""
    var svgIconShowArchiveBackground = ""
}
