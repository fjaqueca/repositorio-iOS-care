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
                }else{
                    EmptyView()
                        .blur(radius: 3)
                        .popup(item: .constant(
                            .init(
                                title: "Actualizacion importante pendiente",
                                message: "",
                                actionTitle: "Actualizar",
                                action: {
                                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(idAppStore)") {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                },
                                isCancellable: true, UIStateTitle: nil,
                                UIStateMessage: nil,
                                UIStateButton: nil,
                                UIStateCancelButton: nil,
                                cancelAction: {
                                    exit(0)
                                }
                            )
                        ))
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
                MainTabView()
                    .task {
                        await AppStatusManager.fetchData()
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
#if CareAssistance
    print("Using CareAssistance agreement")
    agreement = "a3yRN0000007kkTYAQ"
            //agreement = "a3yRN000000MMBZYA4" pre login de testing 
            self.iOSVersionApp = 24
            self.idAppStore = "6449431471"
#elseif Wellbeing
    print("Using Wellbeing agreement")
    agreement = "a3yRN0000007S7dYAE"
            self.iOSVersionApp = 24
            self.idAppStore = "6477316325"
#elseif BCI
    print("Using BCI agreement") //DISFRUTA MAS SALUD
    agreement = "a3yRN000000YiWTYA0"
            self.iOSVersionApp = 24
            self.idAppStore = "6479409551"
#elseif PharmaBenefits
    print("Using Pharma Benefits agreement")
    agreement = "a3yRN000000AxwTYAS"
            self.iOSVersionApp = 24
            self.idAppStore = "6479473964"
#elseif VCContigo
    print("Using Pharma Benefits agreement")
    agreement = "a3yRN000000Ch7dYAC"
            self.iOSVersionApp = 24
            self.idAppStore = "6479615108"
#elseif CareAssistanceMX
    print("Using CareAssistanceMX agreement")
    agreement = "a3yRN000000gzQTYAY"
            self.iOSVersionApp = 24
            self.idAppStore = "6479615108"
#elseif Premedic
    print("Using Premedic agreement")
    agreement = "a3yRN0000018NJpYAM"
            self.iOSVersionApp = 24
            self.idAppStore = "6743768129"
#elseif ContigoSalud
    print("Using Premedic agreement")
    agreement = "a3yRN0000017n8HYAQ"
            self.iOSVersionApp = 24
            self.idAppStore = "6744413095"
#endif
            
            let result = await Network.shared.getBrandAccount(agreementId: agreement)
            switch result {
                case let .success(response):
                let realm = try! Realm(queue: nil)
                try! realm.write {
                    let oldItems = realm.objects(BrandAccounts.self)
                    // Delete stored items
                    realm.delete(oldItems)
                    realm.add(response, update: .all)
                    for ba in response.records{
                        if ba.Name == "PreLogin"{
                            self.iOSVersionBA = Int(ba.valor123C ?? "1") ?? 1
                            print(ba.valor121C)
                            UserDefaults.standard.set(ba.valor121C, forKey: "campanaC")
                        }
                    }
                    print(iOSVersionBA)
                }
                case let .failure(error):
                    // 📊 Log del error de Brand Account en Crashlytics
                    Crashlytics.crashlytics().log("❌ Error al cargar Brand Account: \(agreement)")
                    Crashlytics.crashlytics().setCustomValue(agreement, forKey: "agreement_id")
                    
                    AppStatusManager.error(error)
            }
            self.isLoadingBrandAccount = false
        }
    }
    func getCurrentCountry() -> String? {
        let locale = Locale.current
        return locale.regionCode
    }
}
