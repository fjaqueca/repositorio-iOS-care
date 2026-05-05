//
//  AppView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/08/2022.
//

import SwiftUI
import RealmSwift
import FirebaseCrashlytics

struct AppView: View {
    @State private var status: AppStatus = .loading
    @State private var isLoading: Bool = false
    @State var isLoadingBrandAccount: Bool = false
    @State private var error: AppError?
    @State private var popup: Popup?
    @State var iOSVersionApp: Int = 1
    @State var iOSVersionBA: Int = 1
    @State var idAppStore: String = ""
    @State private var showPostLoginLoading: Bool = false
    @State private var postLoginLoadingComplete: Bool = false
    @State private var forceUpdateIconScale: CGFloat = 0.0
    @State private var forceUpdateIconRotation: Double = 0.0
    var body: some View {
        ZStack{
            if isLoadingBrandAccount{
                ProgressView()
                    .frame(height: 200.0)
                    .task {
                        print("🔵 [AppView] Loading #1: Cargando BrandAccount pre-login...")
                        preLoginBrandAccount()
                    }
                    .onAppear {
                        print("🔵 [AppView] Loading #1 VISIBLE (isLoadingBrandAccount=true)")
                    }
                    .onDisappear {
                        print("🔵 [AppView] Loading #1 OCULTO (isLoadingBrandAccount=false)")
                    }
            }else{
                if iOSVersionApp >= iOSVersionBA {
                    mainView
                        .onAppear {
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("✅ [ForceUpdate] VERSIÓN OK — No se requiere actualización")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("   iOSVersionApp (hardcoded): \(iOSVersionApp)")
                            print("   iOSVersionBA (Salesforce Valor_12_3__c): \(iOSVersionBA)")
                            print("   Condición: \(iOSVersionApp) >= \(iOSVersionBA) → true")
                            print("   idAppStore: \(idAppStore)")
                            print("   CFBundleShortVersionString: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A")")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        }
                        .overlayView(isLoading)
                        .transition(.opacity)
                        .animation(.default, value: status)
                        .animation(.default, value: isLoading)
                        .onReceive(AppStatusManager.onStatus) { newValue in
                            status = newValue
                            
                        }
                        .onReceive(AppStatusManager.onLoading) { newValue in
                            isLoading = newValue
                        }
                        .onReceive(AppStatusManager.onError) { newValue in
                            error = newValue
                        }
                        .onChange(of: error) { newValue in
                            if newValue == nil {
                                AppStatusManager.dismissError()
                            }
                        }
                        .popup(item: $popup)

            //          TODO: Enable this feature
            //            .task {
            //                checkAPIVersion()
            //            }
                        .errorAlert(error: $error)
                        .onAppear{
                            let locale = getCurrentCountry()
                            print(locale)
                        #if CareAssistance
                            if locale == "MX"{
                                popup = regionPopup
                            }
                        #endif
                        #if CareAssistanceMX
                            if locale == "CL"{
                                popup = regionPopup
                            }
                        #endif
                        }
                } else {
                    forceUpdateDialog
                }
                
            }
        }
        .onAppear {
            if status == .onboarding || status == .loading {
                preLoginBrandAccount()
            }
            }
        .onChange(of: status) { newValue in
                    if newValue == .onboarding {
                        preLoginBrandAccount()
                    }
                }
    }
    
    @ViewBuilder
    var mainView: some View {
        switch status {
            case .signedIn:
                ZStack {
                    MainTabView()

                    if showPostLoginLoading {
                        ConvenioLoadingDialog(
                            isPresented: $showPostLoginLoading,
                            shouldComplete: $postLoginLoadingComplete
                        )
                        .zIndex(100)
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: showPostLoginLoading)
                .task {
                    // Mostrar dialog del engranaje durante la carga post-login
                    // (paridad Android: ProgressBarDialog tras login/registro)
                    postLoginLoadingComplete = false
                    showPostLoginLoading = true

                    await AppStatusManager.fetchData()

                    postLoginLoadingComplete = true
                }
            case .onboarding:
                OnboardingView()
            case .selectingEnterprise:
                CompanySelectionView(style: .initial)
            case .loading:
                Color.white
                    .edgesIgnoringSafeArea(.all)
        }
    }
    
    func checkAPIVersion() {
        Task {
            let result = await Network.shared.checkAPIVersion()
            switch result {
                case let .success(response):
                    let production = response.production[0]
                    if appVersion == production.version {
                        print(appVersion)
                    } else if production.version > appVersion {
                        popup = updatePopup
                    }
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
    
    var appVersion: Int {
        // TODO: Update with country code upon confirmation
        return Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0") ?? 0
    }
    
    var updatePopup: Popup {
        .init(
            image: "exclamationmark.triangle",
            title: "Hay una actualización disponible!",
            actionTitle: "Actualizar",
            action: {
                let appStoreLink = "https://apps.apple.com/app/{app-name}/{app-id}"
                guard let url = URL(string: appStoreLink) else { return }
                UIApplication.shared.open(url)
            },
            isCancellable: false,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
    var regionPopup: Popup {
        .init(
            title: "Tenemos una app especifica para su pais!",
            actionTitle: "Ir",
            action: {
            #if CareAssistance
//                if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(idAppStore)") {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
            #endif
            #if CareAssistanceMX
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id6449431471") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            #endif
            },
            isCancellable: true,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
    func preLoginBrandAccount() {
        self.isLoadingBrandAccount = true
        Task {
            var agreement = ""
            var schemeName = ""
#if CareAssistance
    // ─── CONVENIO PRE-LOGIN ───────────────────────────────────────
    // PROD REAL (Onboarding_Care PROD REAL) — descomentar para producción/App Store
    agreement = "a3yRN0000007kkTYAQ"
    // TESTING (Onboarding_Care TEST / PRUEBATESTINGCA) — descomentar SOLO para QA
    // agreement = "a3yRN000000MMBZYA4"
    // ──────────────────────────────────────────────────────────────
            self.iOSVersionApp = 47
            self.idAppStore = "6449431471"
            schemeName = "CareAssistance"
#elseif Wellbeing
    agreement = "a3yRN0000007S7dYAE"
            self.iOSVersionApp = 47
            self.idAppStore = "6477316325"
            schemeName = "Wellbeing"
#elseif BCI
    agreement = "a3yRN000000YiWTYA0"
            self.iOSVersionApp = 47
            self.idAppStore = "6479409551"
            schemeName = "BCI"
#elseif PharmaBenefits
    agreement = "a3yRN000000AxwTYAS"
            self.iOSVersionApp = 47
            self.idAppStore = "6479473964"
            schemeName = "PharmaBenefits"
#elseif VCContigo
    agreement = "a3yRN000000Ch7dYAC"
            self.iOSVersionApp = 47
            self.idAppStore = "6479615108"
            schemeName = "VCContigo"
#elseif CareAssistanceMX
    agreement = "a3yRN000000gzQTYAY"
            self.iOSVersionApp = 47
            self.idAppStore = "6479615108"
            schemeName = "CareAssistanceMX"
#elseif Premedic
    agreement = "a3yRN0000018NJpYAM"
            self.iOSVersionApp = 47
            self.idAppStore = "6743768129"
            schemeName = "Premedic"
#elseif ContigoSalud
    agreement = "a3yRN0000017n8HYAQ"
            self.iOSVersionApp = 47
            self.idAppStore = "6744413095"
            schemeName = "ContigoSalud"
#endif
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [ForceUpdate] PASO 1 — Configuración hardcodeada del scheme")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("   Scheme: \(schemeName)")
            print("   Agreement ID: \(agreement)")
            print("   iOSVersionApp (hardcoded): \(iOSVersionApp)")
            print("   idAppStore: \(idAppStore)")
            print("   CFBundleShortVersionString: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A")")
            print("   CFBundleVersion: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A")")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            print("📋 [ForceUpdate] PASO 2 — Consultando BrandAccount desde Salesforce (agreement: \(agreement))...")
            let result = await Network.shared.getBrandAccount(agreementId: agreement)
            switch result {
                case let .success(response):
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [ForceUpdate] PASO 2 — BrandAccount recibido OK")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("   Total records: \(response.records.count)")
                let realm = try! Realm(queue: nil)
                try! realm.write {
                    let oldItems = realm.objects(BrandAccounts.self)
                    // Delete stored items
                    realm.delete(oldItems)
                    realm.add(response, update: .all)
                    for ba in response.records{
                        if ba.Name == "PreLogin"{
                            let rawValor123C = ba.valor123C ?? "nil"
                            self.iOSVersionBA = Int(ba.valor123C ?? "1") ?? 1
                            UserDefaults.standard.set(ba.valor121C, forKey: "campanaC")

                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("📋 [ForceUpdate] PASO 3 — Registro PreLogin encontrado")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("   valor123C (Valor_12_3__c) raw: \"\(rawValor123C)\"")
                            print("   iOSVersionBA (parseado): \(self.iOSVersionBA)")
                            print("   valor121C (campaña): \(ba.valor121C ?? "nil")")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("📋 [ForceUpdate] RESULTADO — Comparación de versiones")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("   iOSVersionApp (hardcoded): \(self.iOSVersionApp)")
                            print("   iOSVersionBA (Salesforce):  \(self.iOSVersionBA)")
                            if self.iOSVersionApp >= self.iOSVersionBA {
                                print("   ✅ \(self.iOSVersionApp) >= \(self.iOSVersionBA) → Versión OK, flujo normal")
                            } else {
                                print("   🚨 \(self.iOSVersionApp) < \(self.iOSVersionBA) → FORCE UPDATE ACTIVADO")
                                print("   📱 Se mostrará popup de actualización forzada")
                                print("   🔗 URL: itms-apps://itunes.apple.com/app/id\(self.idAppStore)")
                            }
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        }
                    }
                }
                case let .failure(error):
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("❌ [ForceUpdate] ERROR — Falló la carga de BrandAccount")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("   Agreement: \(agreement)")
                    print("   Error: \(error)")
                    print("   ⚠️ No se pudo verificar versión mínima, iOSVersionBA queda en: \(self.iOSVersionBA)")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    // 📊 Log del error de Brand Account en Crashlytics
                    Crashlytics.crashlytics().log("❌ Error al cargar Brand Account: \(agreement)")
                    Crashlytics.crashlytics().setCustomValue(agreement, forKey: "agreement_id")

                    AppStatusManager.error(error)
            }
            self.isLoadingBrandAccount = false
        }
    }
    // MARK: - Force Update Dialog

    private var forceUpdateDialog: some View {
        ZStack {
            Color.black.opacity(0.30)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Ícono animado: giro + bounce en bucle
                ZStack {
                    Circle()
                        .fill(Color(hex: "#E3F2FD"))
                        .frame(width: 64, height: 64)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Color(hex: "#00BBDC"))
                }
                .scaleEffect(forceUpdateIconScale)
                .rotationEffect(.degrees(forceUpdateIconRotation))
                .padding(.top, 24)
                .onAppear {
                    forceUpdateIconScale = 0.0
                    forceUpdateIconRotation = 0.0
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                        forceUpdateIconScale = 1.0
                    }
                    startForceUpdateIconLoop()

                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("🚨 [ForceUpdate] ACTUALIZACIÓN FORZADA — Mostrando popup")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("   iOSVersionApp (hardcoded): \(iOSVersionApp)")
                    print("   iOSVersionBA (Salesforce Valor_12_3__c): \(iOSVersionBA)")
                    print("   Condición: \(iOSVersionApp) >= \(iOSVersionBA) → false")
                    print("   idAppStore: \(idAppStore)")
                    print("   URL App Store: itms-apps://itunes.apple.com/app/id\(idAppStore)")
                    print("   CFBundleShortVersionString: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A")")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }

                // Título
                Text("Actualización importante pendiente")
                    .font(Font.custom("FiraSans-Bold", size: 17))
                    .foregroundColor(Color(hex: "#333333"))
                    .multilineTextAlignment(.center)

                // Mensaje
                Text("Hay una nueva versión disponible. Por favor actualiza la app para continuar.")
                    .font(Font.custom("FiraSans-Regular", size: 13))
                    .foregroundColor(Color(hex: "#777777"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                // Botones
                HStack(spacing: 12) {
                    // Actualizar
                    Button {
                        print("🚨 [ForceUpdate] Usuario presionó ACTUALIZAR → Abriendo App Store: itms-apps://itunes.apple.com/app/id\(idAppStore)")
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(idAppStore)") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    } label: {
                        Text("Actualizar")
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: "#00BBDC")))
                    }
                    .buttonStyle(.plain)

                    // Cerrar
                    Button {
                        print("🚨 [ForceUpdate] Usuario presionó CERRAR → Cerrando app con exit(0)")
                        exit(0)
                    } label: {
                        Text("Cerrar")
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(Color(hex: "#555555"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(hex: "#CCCCCC"), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
                .padding(.bottom, 18)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 380)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
        }
    }

    private func startForceUpdateIconLoop() {
        // Paso 1: Giro 360°
        withAnimation(.easeInOut(duration: 1.2).delay(0.8)) {
            forceUpdateIconRotation = 360
        }
        // Paso 2: Bounce (escala baja y sube)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                forceUpdateIconScale = 0.75
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                    forceUpdateIconScale = 1.0
                }
            }
        }
        // Repetir el ciclo
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            forceUpdateIconRotation = 0
            startForceUpdateIconLoop()
        }
    }

    func getCurrentCountry() -> String? {
        let locale = Locale.current
        return locale.regionCode
    }
}
