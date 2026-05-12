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
    @State var PuntosActivos: Bool?
    @State var PuntosObtener: Float?
    @State var PuntosAcumulados: Float?
    @State var showClinicDetail: Bool = false
    @State var showProgramView: Bool = false
    @State private var showWebView = false
    @State var urlWebView: String = ""
    @State var itemSelected: Int = 0
    @State private var popup: Popup?
    var isGrid: Bool = false
    @Binding var selectedTab: Tab
    let agreementName: String = AppStatusManager.selectedEnterprise?.campaAC ?? ""
    let gridItemLayout = [GridItem(.flexible()),
                          GridItem(.flexible()),
                          GridItem(.flexible()),]
    
    // MARK: - NUEVAS VARIABLES DE ESTADO
    @State private var showCreationLoading: Bool = false
    @State private var creationLoadingMessage: String = ""
    @State private var showCreationError: Bool = false
    @State private var showActionLoading: Bool = false
    
    // ✅ NUEVO: Estado de navegación para este programa
    @StateObject private var navigationState = NavigationState()
    
    
    
    var body: some View {
        
        ZStack{
            // 1. Tu contenido principal
            mainContent
            
            // 1.5. Loading general de acciones (mismo estilo que StagesView)
            if showActionLoading {
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()
                    ProgressView()
                        .padding()
                }
                .zIndex(998)
            }
            
            // 2. EL NUEVO POPUP SUPERPUESTO
            if showCreationLoading {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        ProgramCreationLoadingView(
                            message: creationLoadingMessage,
                            popupData: UIState.customPopupLoadingProgram
                        )
                    )
                    .ignoresSafeArea()
                    .zIndex(999)
            }
            
            // 3. EL NUEVO POPUP DE ERROR (Actualizado)
            if showCreationError {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        ProgramErrorView(
                            popupData: UIState.customPopupFailureProgram,
                            onDismiss: {
                                withAnimation {
                                    showCreationError = false
                                    showActionLoading = false
                                }
                            }
                        )
                    )
                    .ignoresSafeArea()
                    .zIndex(1000)
            }
            
        }
        .onChange(of: totalSubHomes){ newValue in
            configView()
        }
        .onChange(of: idProgram) { newValue in
            if let _ = newValue {
                // Cerramos solo el popup de creación si estaba activo
                withAnimation {
                    self.showCreationLoading = false
                    // NO desactivamos showActionLoading aquí
                }
                
                // Pequeño delay para asegurar transición suave
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.showProgramView = true
                }
            }
        }
        .onChange(of: showProgramView) { isNavigating in
            if !isNavigating {
                // Si volvemos atrás desde StagesView, desactivamos el loading
                withAnimation {
                    self.showActionLoading = false
                }
            }
        }
        .onDisappear {
            // Cuando esta vista desaparece (por navegación), desactivamos el loading
            // Esto asegura que al volver atrás, el estado esté limpio
            if showProgramView {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        self.showActionLoading = false
                    }
                }
            }
        }
        .navigationLink(isActive: $showClinicDetail) {
            ClinicDetailView(clinicDetail: $clinicDetail, selectedTab: $selectedTab, UIStateAppoint: $UIStateAppoint)
        }
        .navigationLink(isActive: $showProgramView) {
            StagesView(programId: idProgram ?? "",
                       puntosActivos: PuntosActivos ?? false,
                       puntosObtener: PuntosObtener ?? 0.0,
                       puntosAcumulados: PuntosAcumulados ?? 0.0,
                       startWithOverlay: true)
                .environmentObject(navigationState)  // ✅ PASAR ESTADO
        }
        .sheet(isPresented: $showWebView) {
            if let _ = urlWebView.getCleanedURL() {
                SafariWebView(url: urlWebView)
            }
        }
    }
    
    var mainContent: some View {
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
    
    // MARK: - Popup de Carga Adaptado a HomeUIState
        struct ProgramCreationLoadingView: View {
            var message: String
            let popupData: CustomPopupSelectedProgram // El modelo que viene de UIState
            
            
            var body: some View {
                ZStack {
                    // Bloqueo de pantalla - CUBRIR TODO
                    /*Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)*/
                    
                    ZStack {
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
                    .padding(.trailing) // Mantenemos el padding que usabas antes
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    
    // MARK: - Componente Visual de Error (Estilo FailureCustomPopup)
        struct ProgramErrorView: View {
            let popupData: CustomPopupSelectedProgram // Data de Salesforce
            var onDismiss: () -> Void
            
            var body: some View {
                ZStack {
                    // Fondo oscuro para bloquear interacción - CUBRIR TODO
                    /*Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)*/
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: .gray, radius: 10)
                        
                        VStack(spacing: 12) {

                            Text(
                                popupData.popupMessage != ""
                                ? popupData.popupMessage.htmlToString()
                                : "¡Vaya! Algo salió mal.\nTenemos algunos problemas técnicos, por favor intente más tarde."
                            )
                            .font(Font.custom(popupData.popupAtr.font,
                                  size: CGFloat(Int(popupData.popupAtr.sizeText) ?? 18)))
                            .foregroundColor(Color(hex: popupData.popupAtr.colorText))
                            .multilineTextAlignment(
                                popupData.popupAtr.alignment == "center" ? .center : .leading
                            )
                            .padding(.bottom, 8)

                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    onDismiss()
                                }
                            } label: {
                                Text(popupData.btnPopup.textBtn.isEmpty ? "Aceptar" : popupData.btnPopup.textBtn)
                                    .font(
                                        Font.custom(
                                            popupData.btnPopup.font,
                                            size: CGFloat(Int(popupData.btnPopup.size) ?? 16)
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color(hex: popupData.btnPopup.colorTextBtn))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)

                        .padding()
                    }
                    .frame(maxWidth: min(UIScreen.main.bounds.size.width * 0.9, 500), minHeight: 250)
                    .padding(.trailing) // Mantenemos el padding lateral de tu versión antigua
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    
    func getProgramByName(programName: String, flowName: String, whosCreated: Bool = false) {

            self.idProgram = nil
            self.PuntosActivos = nil
            self.PuntosObtener = nil
            self.PuntosAcumulados = nil
            let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
              
            Task {
                let result = await Network.shared.getPrograms(accountId: accountId)
                  
                await MainActor.run {
                    switch result {
                    case let .success(listPrograms):
                        if let prog = listPrograms.records.first(where: { $0.Name == programName }) {
                            print("✅ Programa encontrado:", prog)
                            // 2. Si se encuentra, asignamos el ID.
                            // El .onChange(of: idProgram) se encargará de la navegación.
                            // El popup NUNCA se mostró, así que la transición es directa.
                            self.idProgram = prog.Id
                            self.PuntosActivos = prog.puntosactivosC
                            self.PuntosObtener = prog.puntosAObtenerC
                            self.PuntosAcumulados = prog.puntosAcumuladosC
                            
                        } else {
                            // 3. NO SE ENCONTRÓ: Aquí es donde debemos levantar el popup
                            if !whosCreated {
                                print("⚠️ No existe, intentando crear...")
                                
                                // Desactivar loading general y activar el popup de creación
                                withAnimation {
                                    self.showActionLoading = false
                                    self.creationLoadingMessage = "Creando tu programa personalizado..."
                                    self.showCreationLoading = true
                                }
                                
                                self.creatProgram(programName: programName, flowName: flowName, accountId: accountId)
                            } else {
                                print("❌ Falló incluso después de crearlo")
                                // Si falló la segunda vuelta, cerramos lo que haya
                                withAnimation { 
                                    self.showCreationLoading = false
                                    self.showActionLoading = false
                                }
                            }
                        }
                          
                    case let .failure(error):
                        // Si hubo error de red en la búsqueda, nos aseguramos que no quede cargando
                        withAnimation { 
                            self.showCreationLoading = false
                            self.showActionLoading = false
                        }
                        AppStatusManager.error(error)
                    }
                }
            }
        }
    
    func creatProgram(programName: String, flowName: String, accountId: String) {
            print("🚀 Iniciando proceso de creación de programa")
              
            // Mantenemos esto para asegurar que el mensaje sea el correcto y el popup esté visible
            withAnimation {
                self.creationLoadingMessage = "Creando tu programa personalizado...\nEsto tomará unos segundos."
                self.showCreationLoading = true
            }
              
            Task {
                let result = await Network.shared.createProgram(flowName: flowName, accountId: accountId, programName: programName)
                  
                await MainActor.run {
                    switch result {
                    case .success:
                        print("✅ Creación exitosa, re-intentando búsqueda...")
                        // Volvemos a buscar. Como 'whosCreated' será true, no volverá a intentar crear si falla.
                        self.getProgramByName(programName: programName, flowName: flowName, whosCreated: true)
                          
                    case .failure:
                        print("❌ Error en la creación")
                          
                        // Ocultamos el Loading
                        withAnimation { self.showCreationLoading = false }
                          
                        // Mostramos el Error
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                self.showCreationError = true
                            }
                        }
                    }
                }
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
                
                let tipoElementoRaw = brand.safeValue(forKey: "tipoElemento\(index)C") as? String ?? ""
                let tipoElemento = TipoElemento(rawValue: tipoElementoRaw)
                
                let clinic = ClinicDetail()
                clinic.id = brand.getBrandValue(section: index, field: 3) ?? ""
                clinic.name = brand.safeValue(forKey: "nombreElemento\(index)C") as? String ?? ""
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
                        name: brand.safeValue(forKey: "nombreElemento\(index)C") as? String ?? "",
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
        // Activar el loading al inicio de cualquier acción
        withAnimation {
            showActionLoading = true
        }
        
        switch button.tipoElemento {
        case .subHome:
            newSubHomeNavigation(subHome: button.subHomeId)
            UIState.nameSubHomeText.append(button.name)
            tipeSubHome.append(Int(button.typeId) ?? 0)
            UIState.imageLogo = button.logo
            UIState.customSubHomeName.append(button.customName)
            
            // Desactivar loading después de la navegación
            withAnimation {
                showActionLoading = false
            }
            
            if isGrid {
                dismiss()
            }
            
        case .clinic:
            self.clinicDetail = button.clinicProperties
            self.showClinicDetail.toggle()
            
            // Desactivar loading después de mostrar la clínica
            withAnimation {
                showActionLoading = false
            }
            
        case .program:
            // Para programas, el loading se mantiene hasta que:
            // 1. Se muestre el popup de creación (se desactiva automáticamente)
            // 2. Se navegue a StagesView (se desactiva en onChange)
            // 3. Se muestre el popup de error (se desactiva en onDismiss)
            getProgramByName(programName: button.programName, flowName: button.programFlow)
            
        case .archive:
            openArchive(myUrl: button.archiveUrl)
            self.itemSelected = button.itemSelected
            
            // Desactivar loading después de abrir el archivo
            withAnimation {
                showActionLoading = false
            }
            
        case .unknown:
            // Desactivar loading si la acción es desconocida
            withAnimation {
                showActionLoading = false
            }
        }
    }
    private func isWTW() -> Bool {
        return self.agreementName.contains("Willis Tower Watson")
    }
    private func isComprehensiveSupport() -> Bool {
        return self.agreementName.contains("Acompañamiento Integral")
    }
}
