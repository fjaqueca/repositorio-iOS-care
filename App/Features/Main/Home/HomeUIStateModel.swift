//
//  HomeViewModel.swift
//  CareAssistance
//
//  Created by The App Master on 16/11/2023.
//

import Foundation

struct HomeUIState{
    var greetingUIState = GreetingUIState()
    var userUIState = UserUIState()
    var userPointUIState = UserPointUIState()
    var notificationUIState = NotificationUIState()
    var bannersUIState = BannerUIState()
    var SecondBannersUIState = BannerUIState()
    var firstLabelUIState = FirstLabelUIState()
    var secondLabelUIState = SecondLabelUIState()
    var thirtLabelUIState = ThirtLabelUIState()
    var labelSeeAllUIState = LabelSeeAllUIState()
    var labelTaskUIState = LabelTaskUIState()
    var placerholderAppointment = PlaceholderAppointment()
    var nextAppointmentUIState = NextAppointmentUIState()
    var navBar = NabVarUIState()
    var customPopupFailureProgram = CustomPopupSelectedProgram()
    var customPopupLoadingProgram = CustomPopupSelectedProgram()
    var imageLogo: String = ""
    
    var customSubHomeName: [String] = []
    var nameSubHomeText: [String] = []
}
struct GreetingUIState{
    var text: String = ""
    var font: String = ""
    var color: String = ""
    var size: String = ""
    var alignment: String = "center"
    var show: String = ""
    var colorFondoIcono : String = ""
    var colorBorder : String = ""
    var colorBackground: String = ""
}
struct NabVarUIState{
    var navBarColor: String = "#42FF01"
    var iconsNavBar = IconNameNavBarUIState()
    var sectionNameNavbar = IconNameNavBarUIState()
}
struct IconNameNavBarUIState{
    var home: String = ""
    var program: String = ""
    var diary: String = ""
    var profile: String = ""
    var more: String = ""
    var exam: String = ""
    var prescription: String = ""
    var material: String = ""
}

struct UserUIState{
    var font: String = "FiraSans-Bold"
    var color: String = "#004A99"
    var size: String = "16"
}
struct UserPointUIState{
    var background: String = "#004A99"
    var color: String = "#FFFFFF"
    var size: String = "15"
    
}
struct NotificationUIState{
    var URLWithoutNotification: String = ""
    var URLWithNotification: String = ""
}
struct BannerUIState{
    var URLBanner1: String = ""
    var URLBanner2: String = ""
    var URLBanner3: String = ""
    var URLBanner4: String = ""
    var URLBanner5: String = ""
    var URLBanner6: String = ""
    var URLValor1: String = ""
    var URLValor2: String = ""
    var URLValor3: String = ""
    var URLValor4: String = ""
    var URLValor5: String = ""
    var URLValor6: String = ""
}
struct FirstLabelUIState{
    var text: String = ""
    var font: String = "FiraSans-Bold"
    var color: String = "#004A99"
    var size: String = "18"
}
struct SecondLabelUIState{
    var text: String = ""
    var font: String = "FiraSans-Bold"
    var color: String = "#004A99"
    var size: String = "18"
}
struct ThirtLabelUIState{
    var text: String = ""
    var font: String = "FiraSans-Bold"
    var color: String = "#004A99"
    var size: String = "18"
}
struct LabelSeeAllUIState{
    var text: String = ""
    var font: String = "FiraSans-Regular"
    var color: String = "#0082C7"
    var size: String = "15"
    var title: GenericTextUIState = GenericTextUIState()
}
struct LabelTaskUIState{
    var text: String = "Tareas"
    var font: String = "FiraSans-Bold"
    var color: String = "#004A99"
    var size: String = "18"
}
struct PlaceholderAppointment{
    var background: String = "#F5F5F5"
    var URLimg: String = ""
}

struct NextAppointmentUIState{
    var backgrounOblea: String = "#F9FBF6"
    var headerOblea: String = "#004A99"
    var title: TitleInfo = TitleInfo()
    var clinic: ClinicInfo = ClinicInfo()
    var date: GeneralInfo = GeneralInfo()
    var hour: GeneralInfo = GeneralInfo()
    
    struct TitleInfo{
        var text: String = "Próxima cita"
        var font: String = "FiraSans-Regular"
        var color: String = "#004A99"
        var size: String = "16"
    }
    struct GeneralInfo{
        var font: String = "FiraSans-Regular"
        var color: String = "#004A99"
        var size: String = "16"
    }
    struct ClinicInfo{
        var font: String = "FiraSans-Bold"
        var color: String = "#004A99"
        var size: String = "18"
    }
}
struct CustomPopupSelectedProgram{
    var popupMessage: String = ""
    var popupAtr: GenericTextUIState = GenericTextUIState()
    var btnPopup: BtnUIState = BtnUIState()
    var loadingColor: String = ""
}

struct fontTextWithInit{
    var font: String = ""
    
    init?(from string: String) {
            
            switch string {
            case "firasans_regular":
                self.font = "FiraSans-Regular"
            case "firasans_bold":
                self.font = "FiraSans-Bold"
            case "firasans_italic":
                self.font = "FiraSans-Italic"
            default:
                self.font = string
            }
        }
}

struct BrandAccountText{
    var text: String = ""
    var font = fontTextWithInit(from: "")
    var color: String = ""
    var size: String = ""
    var alignment = TextAlignmentFromString(from: "center").alignment
    var show: String = ""
}
