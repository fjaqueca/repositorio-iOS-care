//
//  CompanySelectionView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 21/09/2022.
//

import SwiftUI
import CachedAsyncImage
import RealmSwift

extension CompanySelectionView {
    enum Style {
        case initial
        case profile
    }

    enum Status {
        case loading
        case empty
        case allAgreementsInFalse
        case selector(agreements: [CompanyAgreementR])
    }
}

struct CompanySelectionView: View {
    @ObservedResults(User.self) var user
    let style: Style
    @Environment(\.presentationMode) private var presentation
    @State private var agreements: [CompanyAgreementR]?
    @State private var selectedAgreement: CompanyAgreementR?
    @ObservedResults(BrandAccounts.self) var items
    @State var UIState: PreLoginUIState = PreLoginUIState()
    @State var defaultAgreementId = ""
    @State var popupData = PopupAllAgreementFalse()

    var buttonText: String {
        switch style {
            case .initial:
                return "Ingresar"
            case .profile:
                return "Seleccionar"

        }
    }

    var state: Status {
        if let agreements {
            if agreements.isEmpty {
                return .empty
            } else {
                if agreements.count == 1 {
                    if !(agreements.first?.appMobileC ?? false){
                        return .allAgreementsInFalse
                    }
                }
                return .selector(agreements: agreements)
            }
        } else {
            return .loading
        }
    }

    var body: some View {
        contentView
            .task {
                await AppStatusManager.loadUser()
                getDefaultCompany()
                
                
            }
            .onChange(of: items){ newValue in
                if style == .initial{
                    loadInitialUIState()
                }
            }
            
            .configureNavigation()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Perfil")
                        .font(.appTabTitleBold)
                        .foregroundColor(.primaryText)
                }
            }
    }

    @ViewBuilder
    var contentView: some View {
        switch state {
            case .loading:
                ProgressView()
                    .frame(height: 200.0)
            case .empty:
                noEnterpriseView
            case .allAgreementsInFalse:
                allAgreementsInFalsePopupView
            case let .selector(agreements):
                enterpriseSelectorView(agreements: agreements)
                .background(
                    Group {
                            if UIState.selectAgreementUIState.imageBackground != "" {
                                CachedAsyncImage(
                                    url: URL(string: UIState.selectAgreementUIState.imageBackground ),
                                    content: { image in
                                        image
                                            .resizable()
                                            .edgesIgnoringSafeArea(.all)
                                            .aspectRatio(contentMode: .fill)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    }
                                )
                                .eraseToAnyView()
                            }
                        }
                )
        }
    }

    @ViewBuilder
    var noEnterpriseView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Su usuario se encuentra pendiente de validación, por consultas por favor contactarse con Atención al Cliente")
                .foregroundColor(.primaryText)
                .font(.appSubheadRegular)
                .multilineTextAlignment(.center)
                .padding(.vertical, .margin)
            
            Spacer()
            
            PrimaryButton(title: "Aceptar") {
                asyncTask(AppStatusManager.logoutUser)
            }
        }
        .padding(.margin)
    }
    
    @ViewBuilder
    var allAgreementsInFalsePopupView: some View {
        
            ZStack {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    CachedAsyncImage(
                            url: URL(string: popupData.logo),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 60)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )

                    Text(popupData.title.text)
                        .font(Font.custom(popupData.title.font?.font ?? "", size: CGFloat(Int(popupData.title.size) ?? 16)))
                        .foregroundColor(Color(hex: popupData.title.color))
                        .multilineTextAlignment(popupData.title.alignment)
                        .padding(.horizontal)

                    
                        
                    Text(.init(popupData.onlyWeb.text))
                        .font(Font.custom(popupData.onlyWeb.font?.font ?? "", size: CGFloat(Int(popupData.onlyWeb.size) ?? 16)))
                        .foregroundColor(Color(hex: popupData.onlyWeb.color))
                        .multilineTextAlignment(popupData.onlyWeb.alignment)
                        .padding(.horizontal)

                
                    Button {
                        asyncTask(AppStatusManager.logoutUser)
                    } label: {
                        Text(popupData.btnAcept.textBtn)
                            .foregroundColor(Color(hex: popupData.btnAcept.colorTextBtn))
                            .font(Font.custom(popupData.btnAcept.font?.font ?? "", size: CGFloat(Int(popupData.btnAcept.size) ?? 16)))
                            .padding(10)
                            .cornerRadius(8)
                    }
                    
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                .frame(maxWidth: 350)
                .frame(minHeight: 100, maxHeight: UIScreen.main.bounds.height * 0.7)
            }
        }
    @ViewBuilder
    func enterpriseSelectorView(agreements: [CompanyAgreementR]) -> some View {
        VStack(spacing: 0.0) {
            if style == .initial {
                Text(UIState.selectAgreementUIState.title.text != "" ? UIState.selectAgreementUIState.title.text : "Selecciona tu convenio")
                    .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.selectAgreementUIState.title.sizeText) ?? 18)))
                    .foregroundColor(UIState.selectAgreementUIState.title.colorText != "" ? Color(hex: UIState.selectAgreementUIState.title.colorText) : .primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.margin)
            } else {
                Divider()
                Text("Selecciona tu convenio")
                    .font(.appBodyBold)
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.margin)
            }
            
            List {
                ForEach(agreements, id: \.self) { agreement in
                    CompanySelectorRow(agreement: agreement, isSelected: selectedAgreement == agreement, UIState: $UIState) { selectedAgreement = $0 }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            
            PrimaryButton(title: buttonText, UIStateBtn: UIState.selectAgreementUIState.btnGetInto) {
                selectEnterprise()
            }
            .disabled(AppStatusManager.selectedEnterprise == selectedAgreement)
            
            if style == .initial {
                Text(UIState.selectAgreementUIState.footer.text)
                    .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.selectAgreementUIState.footer.sizeText) ?? 14)))
                    .foregroundColor(UIState.selectAgreementUIState.footer.colorText != "" ? Color(hex: UIState.selectAgreementUIState.footer.colorText) : .primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, .margin)
            }
        }
        .padding(.margin)
    }
    
    func getAgreements() {
        Task {
            guard let rut = AppStatusManager.rut else {
                return
            }
            let profileResponse = await Network.shared.profile(rut: rut)
            switch profileResponse {
            case let .success(user):
                print(user)
                // Equivalente a ACCOUNT_SETTINGS_RESPONSE en Android:
                // Llamar a MC sync después de obtener EmpresaContactoConvenios__r
                if let userRecord = user.records.first,
                   userRecord.empresacontactoconveniosR?.records != nil {
                    let rut = AppStatusManager.rut ?? ""
                    let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
                    sendUserDataToMarketingCloud(
                        rut: rut,
                        nombre: userRecord.FirstName ?? "",
                        apellido: userRecord.LastName ?? "",
                        email: userRecord.PersonEmail ?? "",
                        telefono: userRecord.Phone ?? "",
                        accountId: accountId,
                        personContactId: userRecord.PersonContactId ?? ""
                    )
                }
                if let recordsAgreement = user.records.first?.empresacontactoconveniosR?.records{
                    var agreementsSuccess:[CompanyAgreementR] = []
                    var agreementsInFalseCount = 0
                    for enterpriseAgreement in recordsAgreement{
                        if enterpriseAgreement.appMobileC ?? false{
                            agreementsSuccess.append(enterpriseAgreement)
                        }else{
                            agreementsInFalseCount += 1
                        }
                    }
                    if let campanaC = UserDefaults.standard.string(forKey: "campanaC")?.components(separatedBy: ";"){
                        var filterAgreements:[CompanyAgreementR] = []
                        for c in campanaC{
                            for agre in agreementsSuccess {
                                if agre.campaAC == c{
                                    filterAgreements.append(agre)
                                }
                            }
                        }
                        if filterAgreements.isEmpty && agreementsInFalseCount == 0{
                            self.agreements = []
                        }else if filterAgreements.isEmpty && agreementsInFalseCount > 0{
                            self.agreements = [recordsAgreement.first!]
                            break
                        }else{
                            if style == .initial {
                                if self.defaultAgreementId != "" {
                                    for agreement in filterAgreements{
                                        if agreement.Id == self.defaultAgreementId {
                                            print(agreement.empresaC)
                                            self.selectedAgreement = agreement
                                            selectEnterprise()
                                            break
                                        }
                                    }
                                }
                            }
                            self.agreements = filterAgreements
                        }
                    }else{
                        if agreementsSuccess.isEmpty && agreementsInFalseCount > 0{
                            agreementsSuccess.append(recordsAgreement.first!)
                            self.agreements = agreementsSuccess
                            break
                        }
                        if style == .initial {
                            if self.defaultAgreementId != "" {
                                for agreement in agreementsSuccess{
                                    if agreement.Id == self.defaultAgreementId {
                                        print(agreement.empresaC)
                                        self.selectedAgreement = agreement
                                        selectEnterprise()
                                        break
                                    }
                                }
                            }
                        }
                        self.agreements = agreementsSuccess
                    }
                    
                    
                }else{
                    self.agreements = []
                }
                    return
                case let .failure(error):
                    print(error)
                    // TODO: Handle Error
                    return
            }
            
            
        }
    }
    
    func getDefaultCompany () {
        Task{
            guard let rut = AppStatusManager.rut else {
                return
            }
            let agreementDefault = await Network.shared.getDefaultAgreement(rut: rut)
            
            print("agreementDefault:", agreementDefault)
            
            switch agreementDefault {
            case .success(let response):
                self.defaultAgreementId = response.data.first?.Account.first??.empresaactualC ?? ""
                UserDefaults.standard.set(response.data.first?.Account.first??.beneficioYappActivoC, forKey: "beneficYapp")
                UserDefaults.standard.set(response.data.first?.Account.first??.acompanamientoIntegralC, forKey: "comprehensiveSupport")
                print("Success")
                getAgreements()
            case .failure(let error):
                print(error)
                getAgreements()
            }
        }
    }
    
    func selectEnterprise() {
        AppStatusManager.selectedEnterprise = selectedAgreement
        let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
        guard let agreementId = AppStatusManager.selectedEnterprise?.Id else { return }
        Task{
            let result = await Network.shared.sendCompanyToSalesforce(accountId: accountId, agreementId: agreementId)
            switch result {
            case .success:
                print("Success")
                self.presentation.wrappedValue.dismiss()
            case .failure:
                print("error")
                self.presentation.wrappedValue.dismiss()
            }
        }
    }

    // MARK: - Marketing Cloud Integration
    // Equivalente a sendUserDataToMarketingCloud() en LoginFragment
    private func sendUserDataToMarketingCloud(
        rut: String,
        nombre: String,
        apellido: String,
        email: String,
        telefono: String,
        accountId: String,
        personContactId: String
    ) {
        let empresaId = AppStatusManager.selectedEnterprise?.empresaC
        let convenioId = AppStatusManager.selectedEnterprise?.Id

        let contactData = MarketingCloudManager.ContactData(
            rut: rut,
            nombre: nombre,
            apellido: apellido,
            email: email,
            telefono: telefono,
            accountId: accountId,
            personContactId: personContactId,
            empresaId: empresaId,
            convenioId: convenioId
        )

        MarketingCloudManager.sendContactToMarketingCloud(
            contactData: contactData,
            onSuccess: {
                print("CompanySelectionView: Usuario sincronizado con Marketing Cloud: \(rut)")
            },
            onError: { error in
                print("CompanySelectionView: Error al sincronizar con Marketing Cloud: \(error)")
            }
        )
    }
    
    func loadInitialUIState(){
        if let record = self.items.first?.records{
            for brandAccount in record{
                if brandAccount.Name == "PreLogin"{
                    //MARK: - SelectedAgreementUIState
                    self.UIState.selectAgreementUIState.imageBackground = brandAccount.valor81C ?? ""
                    
                    self.UIState.selectAgreementUIState.title.text = brandAccount.valor82C ?? ""
                    if let valor83 = brandAccount.valor83C?.components(separatedBy: ";"), valor83.count >= 2{
                        self.UIState.selectAgreementUIState.title.colorText = valor83[0]
                        self.UIState.selectAgreementUIState.title.sizeText = valor83[1]
                    }
                    
                    self.UIState.selectAgreementUIState.btnGetInto.textBtn = brandAccount.valor84C ?? ""
                    if let valor85 = brandAccount.valor85C?.components(separatedBy: ";"), valor85.count >= 3{
                        self.UIState.selectAgreementUIState.btnGetInto.colorTextBtn = valor85[0]
                        self.UIState.selectAgreementUIState.btnGetInto.backgroundBtn = valor85[1]
                        self.UIState.selectAgreementUIState.btnGetInto.backgroundPressBtn = valor85[2]
                    }
                    
                    self.UIState.selectAgreementUIState.footer.text = brandAccount.valor86C ?? ""
                    if let valor87 = brandAccount.valor87C?.components(separatedBy: ";"), valor87.count >= 2{
                        self.UIState.selectAgreementUIState.footer.colorText = valor87[0]
                        self.UIState.selectAgreementUIState.footer.sizeText = valor87[1]
                    }
                    
                    if let valor88 = brandAccount.valor88C?.components(separatedBy: ";"), valor88.count >= 2{
                        self.UIState.selectAgreementUIState.defaultAgreementColor = valor88[0]
                        self.UIState.selectAgreementUIState.seleccionAgreementColor = valor88[1]
                    }
                    //MARK: - Popup All Agreement In False
                    self.popupData.logo = brandAccount.valor89C ?? ""
                    self.popupData.title.text = brandAccount.valor810C ?? ""
                    
                    if let valor = brandAccount.valor811C?.components(separatedBy: ";"), valor.count >= 4{
                        self.popupData.title.color = valor[0]
                        self.popupData.title.size = valor[1]
                        self.popupData.title.font = fontTextWithInit(from: valor[2])
                        self.popupData.title.alignment = TextAlignmentFromString(from: valor[3]).alignment
                    }
                    
                    self.popupData.onlyWeb.text = brandAccount.valor812C?.htmlToString() ?? ""
                    
                    if let valor = brandAccount.valor813C?.components(separatedBy: ";"), valor.count >= 4{
                        self.popupData.onlyWeb.color = valor[0]
                        self.popupData.onlyWeb.size = valor[1]
                        self.popupData.onlyWeb.font = fontTextWithInit(from: valor[2])
                        self.popupData.onlyWeb.alignment = TextAlignmentFromString(from: valor[3]).alignment
                    }
                    
                    self.popupData.btnAcept.textBtn = brandAccount.valor814C ?? ""
                    
                    if let valor = brandAccount.valor815C?.components(separatedBy: ";"), valor.count >= 3{
                        self.popupData.btnAcept.colorTextBtn = valor[0]
                        self.popupData.btnAcept.size = valor[1]
                        self.popupData.btnAcept.font = fontTextWithInit(from: valor[2])
                    }
                    
                    
                }
            }
        }
    }
    
    struct CompanySelectorRow: View {
        let agreement: CompanyAgreementR
        let isSelected: Bool
        @Binding var  UIState: PreLoginUIState
        let action: (CompanyAgreementR) -> Void
        var body: some View {
            HStack {
                Circle()
                    .frame(width: 65.0, height: 65.0)
                    .foregroundColor(.white)
                    .shadow(color: .shadowLight, radius: 4, x: 1,y: 1)
                    .overlay {
                        CachedAsyncImage(
                            url: URL(string: agreement.disenoDeIconoC ?? ""),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40.0, height: 40.0)
                                    .saturation(isSelected ? 1.0 : 0.0)
                            },
                            placeholder: {
                                ProgressView()
                            })
                    }
                
                Text(agreement.identificadorC ?? "")
                    .font(.appBodyBold)
                    .foregroundColor(isSelected ? (UIState.selectAgreementUIState.seleccionAgreementColor != "" ? Color(hex: UIState.selectAgreementUIState.seleccionAgreementColor) : Color.secondaryText) : (UIState.selectAgreementUIState.defaultAgreementColor != "" ? Color(hex: UIState.selectAgreementUIState.defaultAgreementColor) : Color.textSecondary))
                    .padding(.horizontal, .margin)
                
                Spacer()
                
                Image(systemName: isSelected ? "smallcircle.filled.circle.fill" : "circle")
                    .frame(width: 25, height: 25)
                    .foregroundColor(isSelected ? (UIState.selectAgreementUIState.seleccionAgreementColor != "" ? Color(hex: UIState.selectAgreementUIState.seleccionAgreementColor) : Color.secondaryText) : (UIState.selectAgreementUIState.defaultAgreementColor != "" ? Color(hex: UIState.selectAgreementUIState.defaultAgreementColor) : Color.textSecondary))
            }
            .onTapGesture {
                action(agreement)
            }
        }
    }
    
    private func asyncTask<T>(_ action: @escaping () async -> Result<T, AppError>) {
        Task {
            let result = await action()
            if case let .failure(error) = result {
                print("There was an \(error)")
            }
        }
    }
}
