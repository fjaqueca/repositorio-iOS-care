//
//  AppStatusManager.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/09/2022.
//

import UIKit
import Combine
import RealmSwift
import Alamofire
import FirebaseCrashlytics

enum AppStatus {
    case loading
    case selectingEnterprise
    case signedIn
    case onboarding
}

class AppStatusManager {
    static var credentials: Credentials?
    static var rut: String?

    static var selectedEnterprise: CompanyAgreementR? {
        get {
            guard let rut = rut else {
                return nil
            }
            let defaults = UserDefaults.standard
            guard
                let data = defaults.data(forKey: "enterprise_\(rut)"),
                let item = try? JSONDecoder().decode(CompanyAgreementR.self, from: data)
            else {
                return nil
            }
            return item
        }
        set {
            guard let rut = rut else {
                return
            }
            let oldValue = selectedEnterprise
            if oldValue != newValue {
                let defaults = UserDefaults.standard
                let data = try! JSONEncoder().encode(newValue)
                defaults.set(data, forKey: "enterprise_\(rut)")

                selectedEnterprisePublisher.send(newValue)
                changeEnterprise()
                updateStatus()
            }
        }
    }

    fileprivate static func updateStatus() {
        if self.credentials != nil, self.rut != nil {
            if self.selectedEnterprise == nil {
                status.send(.selectingEnterprise)
            } else {
                status.send(.signedIn)
            }
        } else {
///         If no credentials or rut we go to onboarding
            status.send(.onboarding)
        }
    }

    fileprivate static let status: CurrentValueSubject<AppStatus, Never> = .init(.loading)
    fileprivate static let isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    fileprivate static let error: CurrentValueSubject<AppError?, Never> = .init(nil)
    fileprivate static let selectedEnterprisePublisher: CurrentValueSubject<CompanyAgreementR?, Never> = .init(nil)

    private enum DefaultKeys: String {
        case credentials
        case rut
    }

    /// Initial load that reads from local storage and sends the signedIn state in case a user is found.
    static func load() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [AppStatusManager] Decisión de navegación")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard
        guard
            let rut = defaults.string(forKey: DefaultKeys.rut.rawValue),
            let encodedCredentials = defaults.object(forKey: DefaultKeys.credentials.rawValue) as? Data,
            let credentials = try? decoder.decode(Credentials.self, from: encodedCredentials)
        else {
            print("   isLogged: false (credenciales no encontradas)")
            print("   ➜ Destino: Onboarding (sin sesión)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return cleanup()
        }
        self.credentials = credentials
        self.rut = rut

        let tokenPrefix = String(credentials.AccessToken.prefix(60))
        print("   isLogged: true (token length=\(credentials.AccessToken.count))")
        print("   Token:    '\(tokenPrefix)...'")
        print("   RUT:      '\(rut)'")
        print("   ➜ Destino: \(self.selectedEnterprise != nil ? "MainTabView (sesión activa)" : "CompanySelection (sin empresa)")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        updateStatus()
    }

    /// Signs in a user with rut and password, and stores it.
    public static func signIn(rut: String, password: String) async -> Result<Void, AppError> {
        // 🔒 SEGURIDAD: Verificar que no haya un login en progreso
        guard !isLoading.value else {
            print("⚠️ [SECURITY] Login ya en progreso, ignorando solicitud duplicada")
            FirebaseLogger.shared.log("⚠️ [SECURITY] Intento de login duplicado detectado")
            return .failure(AppError(
                id: "login_in_progress",
                name: "Login en progreso",
                message: "Por favor espera a que termine la operación actual",
                httpCode: nil
            ))
        }
        
        isLoading.send(true)
        
        // 🔥 FIREBASE LOGGING: Inicio de login
        FirebaseLogger.shared.log("🔄 Intentando login para RUT: \(rut)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔐 INICIO DE LOGIN")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👤 RUT: \(rut)")
        print("⏰ Timestamp: \(Date())")
        
        let signinResponse = await Network.shared.signIn(rut: rut, password: password)
        isLoading.send(false)
        
        switch signinResponse {
            case let .success(credentials):
                print("✅ Credenciales recibidas correctamente del servidor")
                print("🔑 Access Token length: \(credentials.AccessToken.count)")
                print("🔑 Refresh Token length: \(credentials.RefreshToken.count)")
                
                if save(rut: rut, credentials: credentials) {
                    print("✅ Credenciales guardadas en UserDefaults")
                    
                    // 🔥 FIREBASE LOGGING: Login exitoso
                    FirebaseLogger.shared.log("✅ Login exitoso")
                    FirebaseLogger.shared.logAuthEvent(
                        action: "login",
                        success: true
                    )
                    FirebaseLogger.shared.setUserID(rut)
                    
                    updateStatus()
                    
                    // 📲 NUEVO: Cargar datos del usuario y enviar a Marketing Cloud
                    // Esto replica el flujo de Android: signin → account_settings → sendUserDataToMarketingCloud
                    Task {
                        await sendUserDataToMarketingCloudAfterLogin(rut: rut)
                    }
                    
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("✅ LOGIN EXITOSO")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    
                    return .success(())
                } else {
                    print("❌ Error al guardar credenciales en UserDefaults")
                    
                    // 🔥 FIREBASE LOGGING: Error al guardar credenciales
                    FirebaseLogger.shared.log("❌ Error al guardar credenciales")
                    FirebaseLogger.shared.logAuthEvent(
                        action: "login",
                        success: false,
                        error: AppError.parsingError
                    )
                    
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("❌ LOGIN FALLIDO (Error guardando)")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    
                    return .failure(.parsingError)
                }
                
            case let .failure(error):
                print("❌ Error en la llamada de login al servidor")
                print("❌ Error: \(error.localizedDescription)")
                print("❌ HTTP Code: \(error.httpCode ?? -1)")
                
                // 🔥 FIREBASE LOGGING: Login fallido
                FirebaseLogger.shared.log("❌ Login fallido: \(error.localizedDescription)")
                FirebaseLogger.shared.logAuthEvent(
                    action: "login",
                    success: false,
                    error: error
                )
                FirebaseLogger.shared.recordNetworkError(
                    error,
                    endpoint: "/api/auth/login",
                    httpCode: (error as? AppError)?.httpCode,
                    method: "POST"
                )
                
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("❌ LOGIN FALLIDO (Error de red/servidor)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                cleanup()
                return .failure(error)
        }
    }
    
    /// Envía los datos del usuario a Marketing Cloud después del login exitoso
    /// Replica el flujo de Android: accountSettingsService() → sendUserDataToMarketingCloud()
    private static func sendUserDataToMarketingCloudAfterLogin(rut: String) async {
        print("📲 [MC] Iniciando envío de datos a Marketing Cloud post-login...")
        
        // 1. Obtener datos del usuario (equivalente a account_settings en Android)
        let profileResult = await Network.shared.profile(rut: rut)
        
        switch profileResult {
        case .success(let user):
            guard let userRecord = user.records.first else {
                print("❌ [MC] No se encontró registro de usuario")
                FirebaseLogger.shared.log("❌ [MC] No se encontró registro de usuario para envío a Marketing Cloud")
                return
            }
            
            // 2. Extraer datos del usuario (igual que Android extrae de account_settings)
            let firstName = userRecord.FirstName ?? ""
            let lastName = userRecord.LastName ?? ""
            let email = userRecord.PersonEmail ?? ""
            let phone = userRecord.Phone ?? ""
            let accountId = userRecord.Id ?? ""  // Account Id (001xxx)
            let personContactId = userRecord.PersonContactId ?? ""  // Contact Id (003xxx) - PREFERIDO
            
            // 3. Obtener empresaId y convenioId de SharedPreferences (igual que Android)
            let empresaId = selectedEnterprise?.empresaC  // empresaC contiene el ID de la empresa
            let convenioId = selectedEnterprise?.Id
            
            print("📲 [MC] Datos extraídos del usuario:")
            print("   - RUT: \(rut)")
            print("   - FirstName: \(firstName)")
            print("   - LastName: \(lastName)")
            print("   - Email: \(email)")
            print("   - Phone: \(phone)")
            print("   - AccountId: \(accountId)")
            print("   - PersonContactId: \(personContactId)")
            print("   - EmpresaId: \(empresaId ?? "N/A")")
            print("   - ConvenioId: \(convenioId ?? "N/A")")
            
            // 4. Enviar a Marketing Cloud (equivalente a sendUserDataToMarketingCloud() en Android)
            MarketingCloudManager.shared.sendContactToMarketingCloud(
                rut: rut,
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone,
                accountId: accountId,
                personContactId: personContactId,
                empresaId: empresaId,
                convenioId: convenioId
            ) { result in
                switch result {
                case .success:
                    print("✅ [MC] Datos enviados exitosamente a Marketing Cloud")
                    FirebaseLogger.shared.log("✅ [MC] Usuario registrado en Marketing Cloud con ContactKey: \(personContactId.isEmpty ? accountId : personContactId)")
                    
                    // Guardar datos en UserDefaults para uso futuro
                    UserDefaults.standard.set(accountId, forKey: "account_id")
                    UserDefaults.standard.set(personContactId, forKey: "person_contact_id")
                    
                case .failure(let error):
                    print("❌ [MC] Error al enviar datos a Marketing Cloud: \(error.localizedDescription)")
                    FirebaseLogger.shared.recordError(error, userInfo: [
                        "context": "marketing_cloud_registration",
                        "rut": rut
                    ])
                }
            }
            
        case .failure(let error):
            print("❌ [MC] Error al obtener perfil de usuario: \(error.localizedDescription)")
            FirebaseLogger.shared.recordError(error, userInfo: [
                "context": "marketing_cloud_profile_fetch",
                "rut": rut
            ])
        }
    }

    /// Save credentials and rut (username) locally.
    static func save(rut: String, credentials: Credentials) -> Bool {
        let encoder = JSONEncoder()
        let defaults = UserDefaults.standard
        defaults.set(rut, forKey: DefaultKeys.rut.rawValue)
        guard let encodedCredentials = try? encoder.encode(credentials) else {
            return false
        }
        defaults.set(encodedCredentials, forKey: DefaultKeys.credentials.rawValue)
        self.rut = rut
        self.credentials = credentials
        return true
    }

    /// Logout the user.
    public static func logoutUser() async -> Result<Alamofire.Empty, AppError> {
        // 🔥 FIREBASE LOGGING: Inicio de logout
        FirebaseLogger.shared.log("🔄 Cerrando sesión de usuario")
        
        guard let token = credentials?.RefreshToken else {
            FirebaseLogger.shared.log("❌ Logout fallido: Token no encontrado")
            return .failure(.generic)
        }
        
        let result = await closeUserSession { rut in
            await Network.shared.logout(token: token)
        }
        
        // 🔥 FIREBASE LOGGING: Resultado de logout
        switch result {
        case .success:
            FirebaseLogger.shared.log("✅ Logout exitoso")
            FirebaseLogger.shared.logAuthEvent(action: "logout", success: true)
            
        case .failure(let error):
            FirebaseLogger.shared.log("❌ Logout fallido: \(error.localizedDescription)")
            FirebaseLogger.shared.logAuthEvent(action: "logout", success: false, error: error)
        }
        
        return result
    }

    /// Deletes user account.
    public static func deleteUser() async -> Result<Alamofire.Empty, AppError> {
        // 🔥 FIREBASE LOGGING: Inicio de eliminación de cuenta
        FirebaseLogger.shared.log("🔄 Eliminando cuenta de usuario")
        
        let result = await closeUserSession(action: Network.shared.deleteAccount)
        
        // 🔥 FIREBASE LOGGING: Resultado de eliminación
        switch result {
        case .success:
            FirebaseLogger.shared.log("✅ Cuenta eliminada exitosamente")
            FirebaseLogger.shared.logAuthEvent(action: "delete_account", success: true)
            
        case .failure(let error):
            FirebaseLogger.shared.log("❌ Error al eliminar cuenta: \(error.localizedDescription)")
            FirebaseLogger.shared.logAuthEvent(action: "delete_account", success: false, error: error)
        }
        
        return result
    }

    /// Close the user section after successfully performing an action
    private static func closeUserSession(action: (String) async -> Result<Alamofire.Empty, AppError>) async -> Result<Alamofire.Empty, AppError> {
        guard let rut = self.rut else {
            return .failure(.generic)
        }
        isLoading.send(true)
        let result = await action(rut)
        isLoading.send(false)
        if case .success = result {
            DispatchQueue.main.async {
                AppStatusManager.cleanup()
            }
        }
        return result
    }

    /// Cleans the local storage and sends the `.onboarding` state.
    static func cleanup() {
        if let rut = self.rut {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "enterprise_\(rut)")
        }
        self.rut = nil
        credentials = nil
        selectedEnterprise = nil

        UserDefaults.standard.removeObject(forKey: DefaultKeys.rut.rawValue)
        UserDefaults.standard.removeObject(forKey: DefaultKeys.credentials.rawValue)
        
        // 🔄 NUEVO: Resetear flag de ficha clínica (como Android)
        UserDefaults.standard.removeObject(forKey: "ficha_clinica_completada")
        UserDefaults.standard.removeObject(forKey: "account_id")
        UserDefaults.standard.removeObject(forKey: "person_contact_id")
        print("🧹 [Cleanup] Flags de ficha clínica reseteados")
        
        // 📲 NUEVO: Limpiar identidad en Marketing Cloud (como Android)
        MarketingCloudManager.shared.logout { result in
            switch result {
            case .success:
                print("✅ [MC] Logout exitoso de Marketing Cloud")
                FirebaseLogger.shared.log("✅ [MC] Usuario deslogueado de Marketing Cloud")
            case .failure(let error):
                print("❌ [MC] Error al hacer logout de Marketing Cloud: \(error.localizedDescription)")
                FirebaseLogger.shared.recordError(error, userInfo: [
                    "context": "marketing_cloud_logout"
                ])
            }
        }

        cleanRealm()
        updateStatus()
    }

    static func cleanRealm() {
        if let realm = try? Realm() {
            try? realm.write {
                realm.deleteAll()
            }
        }
    }

    /// A publisher that keeps track of the status of the app.
    public static var onStatus: Publishers.Share<CurrentValueSubject<AppStatus, Never>> {
        status.share()
    }

    /// A publisher that keeps track of the loading status of the app.
    public static var onLoading: Publishers.Share<CurrentValueSubject<Bool, Never>> {
        isLoading.share()
    }

    /// A publisher that keeps track of the loading status of the app.
    public static var onSelectedEnterprise: Publishers.Share<CurrentValueSubject<CompanyAgreementR?, Never>> {
        selectedEnterprisePublisher.share()
    }

    public static func setLoading(_ value: Bool) {
        isLoading.send(value)
    }

    static func changeEnterprise() {
        cleanRealm()
        Task {
            await fetchData()
        }
    }

    static func fetchData() async {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📦 [fetchData] INICIO - Cargando datos post-login")
        print("   RUT: '\(self.rut ?? "(nil)")'")
        print("   Empresa: '\(self.selectedEnterprise?.empresaC ?? "(nil)")'")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        await AppStatusManager.loadUser()
        print("   ✅ loadUser completado")
        await AppStatusManager.loadBrandAccount()
        print("   ✅ loadBrandAccount completado")
        await AppStatusManager.loadAppointments()
        print("   ✅ loadAppointments completado")
        await AppStatusManager.loadFavoriteTask()
        print("   ✅ loadFavoriteTask completado")

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📦 [fetchData] FIN - Todos los datos cargados")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

extension AppStatusManager {
    /// A publisher that keeps track of the loading status of the app.
    public static var onError: Publishers.Share<CurrentValueSubject<AppError?, Never>> {
        error.share()
    }

    public static func error(_ value: AppError) {
        // 📊 Registrar error en Firebase usando FirebaseLogger
        logErrorToFirebase(value)
        
        error.send(value)
    }

    public static func dismissError() {
        error.send(nil)
    }
    
    // MARK: - Firebase Logging
    
    /// Registra un error en Firebase usando FirebaseLogger centralizado
    private static func logErrorToFirebase(_ appError: AppError) {
        // Establecer contexto de usuario
        if let rut = self.rut {
            FirebaseLogger.shared.setUserID(rut)
        }
        
        if let enterprise = selectedEnterprise {
            FirebaseLogger.shared.setUserInfo(
                name: nil,
                email: nil,
                enterprise: enterprise.empresaR?.nombreDeEmpresaC
            )
            FirebaseLogger.shared.setCustomValue(enterprise.Id ?? "N/A", forKey: "empresa_id")
        }
        
        // Registrar el error como popup (ya que el usuario lo verá)
        FirebaseLogger.shared.logErrorPopup(
            title: appError.name,
            message: appError.message,
            source: "AppStatusManager"
        )
        
        // Si tiene código HTTP, registrar como error de servicio
        if let httpCode = appError.httpCode {
            let nsError = NSError(
                domain: "CareAssistance.AppError",
                code: httpCode,
                userInfo: [
                    NSLocalizedDescriptionKey: appError.name,
                    NSLocalizedFailureReasonErrorKey: appError.message,
                    "error_id": appError.id
                ]
            )
            
            FirebaseLogger.shared.recordNetworkError(
                nsError,
                endpoint: "unknown",
                httpCode: httpCode
            )
        }
        
        // Log adicional para debugging
        print("📊 Error logged to Firebase: [\(appError.id)] \(appError.name)")
    }
}
