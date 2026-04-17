//
//  ClinicDetailView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 23/08/2022.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import WebKit
import Combine

struct ClinicDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var UIState: ClinicUIState = ClinicUIState()
    @State var popupsTelemedicina = PopupsTelemedicina()
    @ObservedResults(BrandAccounts.self) var items
    @Binding var clinicDetail: ClinicDetail
    @Binding var selectedTab: Tab
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @State private var showNewAppointmentSelectDetails = false
    @State private var showOnDemandVideoCall = false
    @State private var showWebView = false
    @State var urlWebView: String = ""
    @State private var showPopupPreviusVideoCall = false
    @State private var showCustomPopupDinamicButton = false
    var publisher = PassthroughSubject<Void, Never>()
    
    
    var body: some View {
        contentView(clinicDetail)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.template)
                            .tint(Color(hex: UIState.clinicDetail.buttonBackColor))
                    }
                }
            }
            .onReceive(publisher, perform: { _ in
                       
                                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.selectedTab = .appointments
                    }
                        
                    })
            .tabBarHidden(true)
            .task{
                loadUIState()
                
            }
    }
    @ViewBuilder
    func contentView(_ clinic: ClinicDetail) -> some View {
        GeometryReader { proxy in
            ZStack{
                VStack {
                    topView(clinic)
                        .frame(width: proxy.size.width, height: proxy.size.height * 0.5, alignment: .leading)
                        .background(topImage(clinic))
                        .clipped()
                    bottomView(clinic)
                        .frame(width: proxy.size.width, height: proxy.size.height * 0.5, alignment: .leading)
                        .padding(.bottom, .margin / 2)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .blur(radius: showPopupPreviusVideoCall || showCustomPopupDinamicButton ? 3 : 0.000000001)
                .disabled(showPopupPreviusVideoCall || showCustomPopupDinamicButton)
                if showPopupPreviusVideoCall{
                    CustomPreviusVideoCallPopupView(showNewAppointmentSelectDetails: $showNewAppointmentSelectDetails, showPopupPreviusVideoCall: $showPopupPreviusVideoCall, showOnDemandVideoCall: $showOnDemandVideoCall, popupData: popupsTelemedicina.firstPopup)
                }
                if showCustomPopupDinamicButton {
                        CustomPopupDinamicButton(showPopup: $showCustomPopupDinamicButton, UIState: $UIState, dinamicButton: clinic.dinamicButton ?? "", textPopup: clinic.textPopup ?? "", atr: clinic.atrTextPopup ?? "", btnClose: UIState.clinicDetail.btnClose)
                }
                
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    func topView(_ clinic: ClinicDetail) -> some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(clinic.name)
                .font(Font.custom(UIState.clinicDetail.name.font, size: CGFloat(Int(UIState.clinicDetail.name.size) ?? 18)))
                .foregroundColor(Color(hex: UIState.clinicDetail.name.color))
            Text(clinic.descShort ?? "")
                .font(Font.custom(UIState.clinicDetail.shortDescription.font, size: CGFloat(Int(UIState.clinicDetail.shortDescription.size) ?? 12)))
                .foregroundColor(Color(hex: UIState.clinicDetail.shortDescription.color))
        }
        .padding(.margin)
    }
    
    func topImage(_ clinic: ClinicDetail) -> some View {
        ZStack {
            GeometryReader { geometry in
                    let deviceWidth = geometry.size.width
                    let deviceHeight = geometry.size.height

                    CachedAsyncImage(
                        url: URL(string: clinic.brandBanner ?? ""),
                        content: { image in
                            image
                                .resizable()
                                .scaledToFill() // La imagen llena todo el espacio sin dejar bordes
                                .frame(width: deviceWidth, height: deviceHeight)
                                .clipped() // Asegura que no haya desbordes fuera del contenedor
                        },
                        placeholder: {
                            Color.clear
                        }
                    )
                }
#if BCI
        

                    // Formas geométricas posicionadas respecto al dispositivo
                    VStack {
                        Spacer()
                        HStack {
                            Rectangle()
                                .foregroundColor(.red)
                                .frame(width: 60, height: 20)
                                .padding(.leading, 100) // Relativo al ancho del dispositivo
                            Spacer()
                        }
                    }

                    VStack {
                        HStack {
                            Spacer()
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 150, height: 15)
                                .padding(.trailing, 50) // Relativo al ancho del dispositivo
                        }
                        Spacer()
                    }

                    HStack {
                        VStack {
                            Image("semiCircle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 80)
                                .padding(.top, 50) // Relativo al alto del dispositivo
                            Spacer()
                        }
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Image("triangle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 80)
                            Spacer()
                        }
                    }
#endif
            Rectangle()
                .foregroundColor(.clear)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, Color(hex: UIState.clinicDetail.imgGradientColor)]), startPoint: .center, endPoint: .bottom))
                
        }
    }
   
    
    func bottomView(_ clinic: ClinicDetail) -> some View {
        VStack {
//            TextView(text: clinic.descLong ?? "", UIState: $UIState)
//                .onAppear{
//                    print(clinic)
//                }
            ScrollView{
                Text(.init(clinic.descLong ?? ""))
                    .font(Font.custom(UIState.clinicDetail.longDescription.font, size: CGFloat(Int(UIState.clinicDetail.longDescription.size) ?? 12)))
                    .foregroundColor(Color(hex: UIState.clinicDetail.longDescription.color))
                
            }
            Spacer()
            
            HStack(alignment: .top,spacing:10) {
                if clinic.appointmentAvalible == "Si" {
                    ClinicContactButton(title: UIState.clinicDetail.btnAppoint.textBtn, image: UIState.clinicDetail.btnAppoint.iconBtn, UIState: $UIState) {
                        showNewAppointmentSelectDetails.toggle()
                    }
                }

                if let phone = clinic.phoneNumber, phone != "No" {
                    ClinicContactButton(title: UIState.clinicDetail.btnCall.textBtn, image: UIState.clinicDetail.btnCall.iconBtn, UIState: $UIState) {
                        UIApplication.shared.open(URL(string: "tel:\(phone)")!)
                    }
                }

                if clinic.videocallAvalible == "Si" {
                    ClinicContactButton(title: UIState.clinicDetail.btnVideo.textBtn, image: UIState.clinicDetail.btnVideo.iconBtn, UIState: $UIState) {
                        if popupsTelemedicina.firstPopup.showPopup == "Si"{
                            withAnimation {
                                showPopupPreviusVideoCall.toggle()
                            }
                        }else{
                            showOnDemandVideoCall.toggle()
                        }
                        
                    }
                }

//                ClinicContactButton(title: "Chat", image: "chat") {
//                    showWebView.toggle()
//                }
//                .frame(width: 75)

                if let whatsapp = clinic.whatsapp, whatsapp != "No" {
                    ClinicContactButton(title: UIState.clinicDetail.btnWhatsApp.textBtn, image: UIState.clinicDetail.btnWhatsApp.iconBtn, UIState: $UIState) {
                        let cleanPhone = whatsapp.replacingOccurrences(of: "+", with: "")
                        if let url = URL(string: "whatsapp://send?phone=\(cleanPhone)") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                // Si no está instalada la app, abrimos la versión web
                                if let webUrl = URL(string: "https://api.whatsapp.com/send?phone=\(cleanPhone)") {
                                    UIApplication.shared.open(webUrl)
                                }
                            }
                        }
                    }
                }
                if let dinamicButton = clinic.dinamicButton, dinamicButton != "No" {
                    let valor = dinamicButton.components(separatedBy: ";")
                    if valor.count >= 4 {
                        let text = valor[0]
                        let icon = valor[1]
                        let url = valor[2]
                        let popup = valor[3]
                        ClinicContactButton(title: text, image: icon, UIState: $UIState) {
                            if popup == "No" {
                                openArchive(myUrl: url)
                            } else {
                                withAnimation {
                                    showCustomPopupDinamicButton.toggle()
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.margin)
        .navigationLink(isActive: $showNewAppointmentSelectDetails) {
            NewAppointmentSelectDetailsView(UIStateAppoint: $UIStateAppoint, id: clinic.id, clinic: clinic, publisher: self.publisher, selectedTab: $selectedTab).rootPresentation {
                showNewAppointmentSelectDetails = false
            }
        }
        .navigationLink(isActive: $showOnDemandVideoCall) {
            ClinicOnDemandVideoCall(id: clinic.id, clinic: clinic, waitingMsg: UIState.clinicDetail.textWaitingMsg, firstWaitingTime: UIState.clinicDetail.firstWaitingTime, secondWaitingTime: UIState.clinicDetail.secondWaitingTime, customPopups: popupsTelemedicina, showNewAppointment: $showNewAppointmentSelectDetails, selectedTab: $selectedTab, UIStateAppoint: $UIStateAppoint )
        }
        .onChange(of: urlWebView, perform: { newValue in
            if newValue != ""{
                self.showWebView.toggle()
            }
        })
        .sheet(isPresented: $showWebView) {
            if let _ = urlWebView.getCleanedURL() {
                SafariWebView(url: urlWebView)
            }
        }
    }
    func openArchive(myUrl: String) {
        if self.urlWebView != "", self.urlWebView == myUrl{
            self.showWebView.toggle()
        }else{
            if myUrl != "" {
                if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
                    self.urlWebView = myUrl
                    print("URL a abrir:", urlWebView)
                }
            }
        }
    }
}

struct CustomPreviusVideoCallPopupView: View {
    @Binding var showNewAppointmentSelectDetails: Bool
    @Binding var showPopupPreviusVideoCall: Bool
    @Binding var showOnDemandVideoCall : Bool
    let popupData: PopupsTelemedicina.PopupData
    var body: some View {
        ZStack{
            VStack(spacing: 5){
                Text(popupData.text.text)
                    .font(Font.custom(popupData.text.font, size: CGFloat(Int(popupData.text.size) ?? 18)))
                    .foregroundColor(Color(hex: popupData.text.color))
                    .multilineTextAlignment(popupData.alignmentText == "Center" ? .center : .leading)
                    .padding(.bottom)
                HStack(spacing: 5){
                    if popupData.showAppointmentButton == "Si"{
                        ClinicPopupButton(title: popupData.btnAppointmentButton.text, image: popupData.btnAppointmentButton.icon, UIState: popupData.btnAppointmentButton) {
                            
                                showNewAppointmentSelectDetails.toggle()
                                showPopupPreviusVideoCall.toggle()
                            
                        }
                        .frame(width: 75)
                    }
                    if popupData.btnContinueVideoCall.text != "No"{
                        ClinicPopupButton(title: popupData.btnContinueVideoCall.text, image: popupData.btnContinueVideoCall.icon, UIState: popupData.btnContinueVideoCall) {
                            
                                showOnDemandVideoCall.toggle()
                                showPopupPreviusVideoCall.toggle()
                            
                            
                        }
                        .frame(width: 75)
                    }
                    if popupData.whatsAppNumber != "No"{
                        ClinicPopupButton(title: popupData.btnWhatsApp.text, image: popupData.btnWhatsApp.icon, UIState: popupData.btnWhatsApp) {
                            let cleanPhone = popupData.whatsAppNumber.replacingOccurrences(of: "+", with: "")
                            if let url = URL(string: "whatsapp://send?phone=\(cleanPhone)") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else {
                                    // Si no está instalada la app, abrimos la versión web
                                    if let webUrl = URL(string: "https://api.whatsapp.com/send?phone=\(cleanPhone)") {
                                        UIApplication.shared.open(webUrl)
                                    }
                                }
                            }
                            
                        }
                        .frame(width: 75)
                        
                    }
                    if popupData.btnGoOut.text != "No"{
                        ClinicPopupButton(title: popupData.btnGoOut.text, image: popupData.btnGoOut.icon, UIState: popupData.btnGoOut) {
                               showPopupPreviusVideoCall.toggle()
                            
                        }
                        .frame(width: 75)
                    }
                }
                    
            }
            .padding()
        }
        .padding()
        .background {
            Color.white
        }
        .cornerRadius(10)
    }
}

struct CustomPopupDinamicButton: View {
    @Binding var showPopup : Bool
    @Binding var UIState: ClinicUIState
    let dinamicButton: String
    let textPopup: String
    let atr: String
    var artObjet: GreetingUIState {
        let valor = atr.components(separatedBy: ";")
        if valor.count >= 5 {
            var font = ""
            switch valor[0]{
            case "firasans_regular":
                font = "FiraSans-Regular"
            case "firasans_bold":
                font = "FiraSans-Bold"
            case "firasans_italic":
                font = "FiraSans-Italic"
            default:
                font = "FiraSans-Regular"
            }
            let size = valor[1]
            let color = valor[2]
            let position = valor[3]
            let show = valor[4]
            return GreetingUIState(font: font, color: color, size: size, alignment: position, show: show)
        }
        return GreetingUIState()
    }
    let btnClose: BtnMoreUIState
    @State private var showWebView = false
    @State var urlWebView: String = ""
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 10)
            VStack(spacing: 5){
                Text(textPopup.htmlToString())
                    .font(Font.custom(artObjet.font, size: CGFloat(Int(artObjet.size) ?? 18)))
                    .foregroundColor(Color(hex: artObjet.color))
                    .multilineTextAlignment(artObjet.alignment == "Center" ? .center : .leading)
                    .padding(.bottom)
                HStack(alignment: .top,spacing: 5){
                    if artObjet.show == "Si"{
                        let valor = dinamicButton.components(separatedBy: ";")
                        if valor.count >= 4 {
                            let text = valor[0]
                            let icon = valor[1]
                            let url = valor[2]
                            ClinicContactButton(title: text, image: icon, UIState: $UIState) {
                                openArchive(myUrl: url)
                            }
                            .frame(width: 75)
                        }
                    }
                        ClinicContactButton(title: btnClose.textBtn, image: btnClose.iconBtn, UIState: $UIState) {
                            self.showPopup.toggle()
                        }
                        .frame(width: 75)
                }
            }
            .padding()
        }
        .frame(maxWidth: min(UIScreen.main.bounds.size.width * 0.9, 500), minHeight: 400)
        .onChange(of: urlWebView, perform: { newValue in
            if newValue != ""{
                self.showWebView.toggle()
            }
        })
        .sheet(isPresented: $showWebView) {
            if let _ = urlWebView.getCleanedURL() {
                SafariWebView(url: urlWebView)
            }
        }
    }
    func openArchive(myUrl: String) {
        if self.urlWebView != "", self.urlWebView == myUrl{
            self.showWebView.toggle()
        }else{
            if myUrl != "" {
                if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
                    self.urlWebView = myUrl
                    print("URL a abrir:", urlWebView)
                }
            }
        }
    }
}

