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
        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard
        guard
            let rut = defaults.string(forKey: DefaultKeys.rut.rawValue),
            let encodedCredentials = defaults.object(forKey: DefaultKeys.credentials.rawValue) as? Data,
            let credentials = try? decoder.decode(Credentials.self, from: encodedCredentials)
        else {
            return cleanup()
        }
        self.credentials = credentials
        self.rut = rut

        updateStatus()
        #if CareAssistance
        print("*\n*\n*\n")
        print("Cargado, usuario salvado")
        print("Usuario: \(rut)")
        print("Access Token: \(credentials.AccessToken)")
        print("Refresh Token: \(credentials.RefreshToken)")
        print("*\n*\n*\n")
        #endif
    }

    /// Signs in a user with rut and password, and stores it.
    public static func signIn(rut: String, password: String) async -> Result<Void, AppError> {
        isLoading.send(true)
        
        // 🔥 FIREBASE LOGGING: Inicio de login
        FirebaseLogger.shared.log("🔄 Intentando login para RUT: \(rut)")
        
        let signinResponse = await Network.shared.signIn(rut: rut, password: password)
        isLoading.send(false)
        
        switch signinResponse {
            case let .success(credentials):
                if save(rut: rut, credentials: credentials) {
                    // 🔥 FIREBASE LOGGING: Login exitoso
                    FirebaseLogger.shared.log("✅ Login exitoso")
                    FirebaseLogger.shared.logAuthEvent(
                        action: "login",
                        success: true
                    )
                    FirebaseLogger.shared.setUserID(rut)
                    
                    updateStatus()
                    return .success(())
                } else {
                    // 🔥 FIREBASE LOGGING: Error al guardar credenciales
                    FirebaseLogger.shared.log("❌ Error al guardar credenciales")
                    FirebaseLogger.shared.logAuthEvent(
                        action: "login",
                        success: false,
                        error: AppError.parsingError
                    )
                    
                    return .failure(.parsingError)
                }
                
            case let .failure(error):
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
                
                cleanup()
                return .failure(error)
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
        print("🧹 [Cleanup] Flags de ficha clínica reseteados")

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
        await AppStatusManager.loadUser()
        await AppStatusManager.loadBrandAccount()
        await AppStatusManager.loadAppointments()
        await AppStatusManager.loadFavoriteTask()
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
