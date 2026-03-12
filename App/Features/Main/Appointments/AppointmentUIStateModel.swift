//
//  AppointmentUIStateModel.swift
//  CareAssistance
//
//  Created by The App Master on 28/05/2024.
//

import Foundation

struct AppointmentUIStateModel {
    var appointmentUIState = AppointmentUIState()
    var newAppointmentUIState = NewAppointmentUIState()
    var selectClinicUIState = SelectClinicUIState()
    var detaillAppointmentUIState = DetailAppointmentUIState()
    var popupAppointmentUIState =  PopupAppointmentUIState()
    var popupAllreadyHaveAppointmentPerHour = PopupAllreadyHaveAppointment()
    var popupAllreadyHaveAppointmentPerClinic = PopupAllreadyHaveAppointment()
    var popupCantAgendAppointment = PopupAllreadyHaveAppointment()
}
//MARK: - AppointmentView
struct AppointmentUIState{
    var title = GreetingUIState()
    var date = GreetingUIState()
    var calendarAtr = CalendarUIState()
    var colorLineCite: String = ""
    var titleList = GreetingUIState()
    var profesionalList = GreetingUIState()
    var hour = GreetingUIState()
    var btnNew = BtnUIState()
    var separatorLineDate = BtnAppointmentUIState()
    
}
//MARK: - SelectClinicView
struct SelectClinicUIState{
    var title = GreetingUIState()
    var itemClinic = GreetingUIState()
    var colorImageBack: String = ""
    
}

//MARK: - NewAppointmentView
struct NewAppointmentUIState{
    var title = GreetingUIState()
    var labelsAtr = GreetingUIState()
    var btns = BtnAppointmentUIState()
    var labelTxtClinic: String = ""
    var btnTextFirst: String = ""
    var labelTxtProf: String = ""
    var hintTxtProf: String = ""
    var labelTxtDate: String = ""
    var hintTxtDate: String = ""
    var labelTxtHour: String = ""
    var hintTxtHour: String = ""
    var tipeOfAppointment: String = ""
    var btnPhone = BtnAppointmentUIState()
    var btnPhoneDisable: String = ""
    var btnPhoneEnable: String = ""
    var btnPhoneSelected: String = ""
    var btnVideo = BtnAppointmentUIState()
    var btnVideoDisable: String = ""
    var btnVideoEnable: String = ""
    var btnVideoSelected: String = ""
    var btnAgend = BtnUIState()
    var popupCalendar = PopupCalendarUIState()
    var isBtnPhoneHidden: String = ""
    var isBtnVideoHidden: String = ""
    
}

//MARK: - DetailAppointmentUIState
struct DetailAppointmentUIState{
    var title = GreetingUIState()
    var clinicsAtr = GreetingUIState()
    var dateAtr = GreetingUIState()
    var tipeAtr = GreetingUIState()
    var textAtr = GreetingUIState()
    var textVideo1: String = ""
    var textVideo2: String = ""
    var textVideo3: String = ""
    var btnVideo = BtnUIState()
    var msgBtnVideo = GreetingUIState()
    var textPhone1: String = ""
    var textPhone2: String = ""
    var textPhone3: String = ""
    var textPhone4: String = ""
    var textPhone5: String = ""
    var btnConfirm1: String = ""
    var btnConfirm2: String = ""
    var btnConfirmModifier = BtnUIState()
    var btnCancel = BtnUIState()
    
}
//MARK: - PopupAppointmentUIState
struct PopupAppointmentUIState{
    
    var iconCheck: String = ""
    var iconCalendar: String = ""
    var agend = PopupAppointmentUIStateModel()
    var confirm = PopupAppointmentUIStateModel()
    var cancel = PopupAppointmentUIStateModel()
    var cancel2 = PopupAppointmentUIStateModel()
    var modifier = PopupAppointmentUIStateModel()
    var titleTxt = GreetingUIState()
    var textAtr = GreetingUIState()
    var btnCancel = GreetingUIState()
    var btnConfirm = GreetingUIState()
}
struct PopupAppointmentUIStateModel{
    var text1: String = ""
    var text2: String = ""
    var btnOk: String = ""
    var btnCancel: String = ""
}

struct BtnAppointmentUIState{
    var text: String = ""
    var textColor: String = ""
    var backColor: String = ""
    var strokeColor_disableColor: String = ""
    var size: String = ""
    var font: String = ""
}

struct PopupCalendarUIState{
    var colorDate: String = ""
    var colorBtn: String = ""
}
struct CalendarUIState{
    var backColor: String = ""
    var nameDayColor: String = ""
    var numDayColor: String = ""
    var numSelectColor: String = ""
    var circleSelectColor: String = ""
    var pointColor: String = ""
}
struct PopupAllreadyHaveAppointment{
    var img: String = ""
    var title: GreetingUIState = GreetingUIState()
    var msg: GreetingUIState = GreetingUIState()
    var msg2: String = ""
    var btn: GreetingUIState = GreetingUIState()
}
