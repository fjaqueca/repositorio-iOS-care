//
//  TileObjetcView.swift
//  CareAssistance
//
//  Created by The App Master on 10/01/2024.
//

import SwiftUI
import CachedAsyncImage

struct TileObjetcView: View {
    @Environment(\.dismiss) var dismiss
    @State var brand: BrandAccount
    @Binding var UIState: HomeUIState
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @Binding var totalSubHomes: [String]
    @Binding var currentSubHome: [String]
    @Binding var tipeSubHome: [Int]
    @State var clinicDetail: ClinicDetail = ClinicDetail()
    @State var idProgram: String?
    @State var PuntosActivos: Bool = false
    @State var showClinicDetail: Bool = false
    @State var showProgramView: Bool = false
    @State private var showWebView = false
    @State var showLoadingCustomPopup = false
    @State var showFailureCustomPopup = false
    @State var urlWebView: String = ""
    @State var itemSelected: Int = 0
    @State private var popup: Popup?
    var isGrid: Bool = false
    @Binding var selectedTab: Tab
    let agreementName: String = AppStatusManager.selectedEnterprise?.campaAC ?? ""
    let gridItemLayout = [GridItem(.flexible()),
                          GridItem(.flexible()),
                          GridItem(.flexible()),]
    var body: some View {
        
        ZStack{
            if tipeSubHome.last == 1 || isGrid{
                BrandGridView(
                    buttons: buildBrandButtons(from: brand),
                    onTap: { button in
                        handleButtonAction(button)
                    }
                )
            }else{
                BrandScrollView(
                    buttons: buildBrandButtons(from: brand),
                    onTap: { button in
                        handleButtonAction(button)
                    }
                )
            }
            if showLoadingCustomPopup {
                LoadingCustomPopup(showCustomPopup: $showLoadingCustomPopup, popupData: UIState.customPopupLoadingProgram)
                    .padding(.trailing)
            }
            if showFailureCustomPopup {
                FailureCustomPopup(showCustomPopup: $showFailureCustomPopup, popupData: UIState.customPopupFailureProgram)
                    .padding(.trailing)
            }
        }
        .onChange(of: totalSubHomes){ newValue in
            configView()
        }
        .onChange(of: idProgram){ newValue in
            if newValue != nil{
                self.showProgramView.toggle()
                
            }
        }
        .navigationLink(isActive: $showClinicDetail) {
            ClinicDetailView(clinicDetail: $clinicDetail, selectedTab: $selectedTab, UIStateAppoint: $UIStateAppoint)
        }
        .navigationLink(isActive: $showProgramView) {
            StagesView(programId: idProgram ?? "",
                       puntosActivos: false,
                       puntosObtener: 999999.9,
                       puntosAcumulados: 8888888.8,
                       startWithOverlay: true
            )
        }
        .sheet(isPresented: $showWebView) {
            if let _ = urlWebView.getCleanedURL() {
                SafariWebView(url: urlWebView)
            }
        }
    }
    func configView(){
        self.currentSubHome = []
        let currentStringSubHome = self.totalSubHomes.last ?? ""
        if currentStringSubHome.contains(";") {
            self.currentSubHome = self.totalSubHomes.last?.components(separatedBy: ";") ?? []
        } else {
            self.currentSubHome.append(currentStringSubHome)
        }
    }
    func newSubHomeNavigation(subHome: String){
        self.totalSubHomes.append(subHome)
        configView()
    }
    func openArchive(myUrl: String){
        if myUrl != "" {
            if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
                self.urlWebView = myUrl
                print("URL a abrir:", urlWebView)
                self.showWebView.toggle()
            }
        }
    }
    func getProgramByName(programName: String, flowName: String, whosCreated: Bool = false) {
        if !whosCreated {
            AppStatusManager.setLoading(true)
        }
        
        self.idProgram = nil
        let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
        Task{
            let result = await Network.shared.getPrograms(accountId: accountId)
            switch result {
            case let .success(listPrograms):
                for prog in listPrograms.records{
                    if prog.Name == programName{
                        self.idProgram = prog.Id
                        AppStatusManager.setLoading(false)
                        self.showLoadingCustomPopup = false
                        break
                    }
                }
                if self.idProgram == nil {
                    if whosCreated == false{
                        AppStatusManager.setLoading(false)
                        creatProgram(programName: programName, flowName: flowName, accountId: accountId)
                        withAnimation {
                            self.showLoadingCustomPopup = true
                        }
                    }else{
                        withAnimation {
                            self.showLoadingCustomPopup = false
                            self.showFailureCustomPopup = true
                        }
                        break
                    }
                }
            case let .failure(error):
                withAnimation {
                    self.showLoadingCustomPopup = false
                }
                AppStatusManager.error(error)
            }
        }
    }
    func creatProgram(programName: String, flowName: String, accountId: String){
        Task{
            let result = await Network.shared.createProgram(flowName: flowName, accountId: accountId, programName: programName)
            switch result {
            case .success:
                getProgramByName(programName: programName, flowName: flowName, whosCreated: true)
            case .failure:
                withAnimation {
                    self.showLoadingCustomPopup = false
                    self.showFailureCustomPopup = true
                }
            }
        }
    }
    struct FailureCustomPopup: View {
        @Binding var showCustomPopup: Bool
        let popupData: CustomPopupSelectedProgram
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 10)
                VStack(spacing: 5){
                    Text(popupData.popupMessage != "" ? popupData.popupMessage.htmlToString() : "Vaya! algo salió mal..\nTenemos algunos problemas técnicos, por favor intente más tarde.")
                        .font(Font.custom(popupData.popupAtr.font, size: CGFloat(Int(popupData.popupAtr.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.popupAtr.colorText))
                        .multilineTextAlignment(popupData.popupAtr.alignment == "center" ? .center : .leading)
                        .padding(.bottom)
                    Button {
                        self.showCustomPopup = false
                    } label: {
                        Text(popupData.btnPopup.textBtn == "" ? "Acepter" : popupData.btnPopup.textBtn)
                            .font(Font.custom(popupData.btnPopup.font, size: CGFloat(Int(popupData.btnPopup.size) ?? 18)))
                            .foregroundColor(Color(hex: popupData.btnPopup.colorTextBtn))
                    }
                }
                .padding()
            }
            .frame(maxWidth: min(UIScreen.main.bounds.size.width * 0.9, 500), minHeight: 250)
        }
    }
    struct LoadingCustomPopup: View {
        @Binding var showCustomPopup: Bool
        let popupData: CustomPopupSelectedProgram
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 10)
                VStack(spacing: 5){
                    Text(popupData.popupMessage != "" ? popupData.popupMessage.htmlToString() : "Espere un momento por favor mientras configuramos este programa para ti")
                        .font(Font.custom(popupData.popupAtr.font, size: CGFloat(Int(popupData.popupAtr.sizeText) ?? 18)))
                        .foregroundColor(Color(hex: popupData.popupAtr.colorText))
                        .multilineTextAlignment(popupData.popupAtr.alignment == "center" ? .center : .leading)
                        .padding(.bottom)
                    ProgressView()
                        .padding()
                        .tint(Color(hex: popupData.loadingColor))
                }
                .padding()
            }
            .frame(maxWidth: min(UIScreen.main.bounds.size.width * 0.9, 500), minHeight: 250)
        }
    }
    private func buildBrandButtons(from brand: BrandAccount) -> [BrandButton] {
        var buttons: [BrandButton] = []

        for index in 1...13 {
            let valorKey = "valor\(index)1C"
            if let imageUrl = brand.getBrandValue(section: index, field: 1), !imageUrl.isEmpty {
                if isWTW() {
                    let isBeneficioYappActive = UserDefaults.standard.bool(forKey: "beneficYapp")
                    let typeId = brand.getBrandValue(section: index, field: 3) ?? ""

                    if (typeId == "0VSRN00000003sL4AQ" && !isBeneficioYappActive) ||
                       (typeId == "0VS8c000000obNZGAY" && isBeneficioYappActive) {
                        print("🔸 Se omitió el botón con ID: \(typeId)")
                        continue // 👉 salta al próximo índice
                    }
                }
                if isComprehensiveSupport() {
                    let isComprehensiveSupportActive = UserDefaults.standard.bool(forKey: "comprehensiveSupport")
                    let typeId = brand.getBrandValue(section: index, field: 3) ?? ""

                    if !isComprehensiveSupportActive && typeId != "0VSRN00000000sr4AA" {
                        print("🔸 Se omitió el botón con ID: \(typeId)")
                        continue // 👉 salta al próximo índice
                    }
                }
                
                let tipoElementoRaw = brand.value(forKey: "tipoElemento\(index)C") as? String ?? ""
                let tipoElemento = TipoElemento(rawValue: tipoElementoRaw)
                
                let clinic = ClinicDetail()
                clinic.id = brand.getBrandValue(section: index, field: 3) ?? ""
                clinic.name = brand.value(forKey: "nombreElemento\(index)C") as? String ?? ""
                clinic.icon = brand.getBrandValue(section: index, field: 13) ?? brand.getBrandValue(section: index, field: 1)
                clinic.brandBanner = brand.getBrandValue(section: index, field: 4)
                clinic.descShort = brand.getBrandValue(section: index, field: 5)
                clinic.descLong = brand.getBrandValue(section: index, field: 6)
                clinic.whatsapp = brand.getBrandValue(section: index, field: 7)
                clinic.phoneNumber = brand.getBrandValue(section: index, field: 8)
                clinic.twilioFlexId = brand.getBrandValue(section: index, field: 9)
                clinic.videocallAvalible = brand.getBrandValue(section: index, field: 10)
                clinic.appointmentAvalible = brand.getBrandValue(section: index, field: 11)
                clinic.fondoOndemand = brand.getBrandValue(section: index, field: 12)
                clinic.dinamicButton = brand.getBrandValue(section: index, field: 14)
                clinic.textPopup = brand.getBrandValue(section: index, field: 15)
                clinic.atrTextPopup = brand.getBrandValue(section: index, field: 16)
                
                buttons.append(
                    BrandButton(
                        imageUrl: imageUrl,
                        tipoElemento: tipoElemento,
                        subHomeId: brand.getBrandValue(section: index, field: 4) ?? "",
                        name: brand.value(forKey: "nombreElemento\(index)C") as? String ?? "",
                        typeId: brand.getBrandValue(section: index, field: 3) ?? "",
                        logo: brand.getBrandValue(section: index, field: 5) ?? "",
                        customName: brand.getBrandValue(section: index, field: 6) ?? "",
                        clinicProperties: clinic,
                        programName: brand.getBrandValue(section: index, field: 4) ?? "",
                        programFlow: brand.getBrandValue(section: index, field: 5) ?? "",
                        archiveUrl: brand.getBrandValue(section: index, field: 3) ?? "",
                        itemSelected: index
                    )
                )
            }
        }

        return buttons
    }
    private func handleButtonAction(_ button: BrandButton) {
        switch button.tipoElemento {
        case .subHome:
            newSubHomeNavigation(subHome: button.subHomeId)
            UIState.nameSubHomeText.append(button.name)
            tipeSubHome.append(Int(button.typeId) ?? 0)
            UIState.imageLogo = button.logo
            UIState.customSubHomeName.append(button.customName)
            if isGrid {
                dismiss()
            }
        case .clinic:
            self.clinicDetail = button.clinicProperties
            self.showClinicDetail.toggle()
        case .program:
            getProgramByName(programName: button.programName, flowName: button.programFlow)
        case .archive:
            openArchive(myUrl: button.archiveUrl)
            self.itemSelected = button.itemSelected
        case .unknown:
            break
        }
    }
    private func isWTW() -> Bool {
        return self.agreementName.contains("Willis Tower Watson")
    }
    private func isComprehensiveSupport() -> Bool {
        return self.agreementName.contains("Acompañamiento Integral")
    }
}
