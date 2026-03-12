//
//  AppStatusManager+Firebase.swift
//  CareAssistance
//
//  Created by AI Assistant on 25/02/2026.
//

import Foundation

/// Extensión de AppStatusManager para integrar logging automático con Firebase
extension AppStatusManager {
    
    /// Maneja errores y los registra automáticamente en Firebase Crashlytics
    /// - Parameter error: Error a manejar
    static func errorWithLogging(_ error: Error) {
        // Primero registramos en Firebase
        recordErrorInFirebase(error)
        
        // Luego llamamos al método original de error
        self.error(error)
    }
    
    /// Registra un error en Firebase con contexto adicional
    /// - Parameters:
    ///   - error: Error a registrar
    ///   - context: Contexto adicional (pantalla, acción, etc)
    static func errorWithContext(_ error: Error, context: String) {
        // Registrar con contexto en Firebase
        FirebaseLogger.shared.log("❌ Error in \(context): \(error.localizedDescription)")
        FirebaseLogger.shared.setCustomValue(context, forKey: "error_context")
        FirebaseLogger.shared.recordError(error, userInfo: ["context": context])
        
        // Llamar al método original
        self.error(error)
    }
    
    /// Método interno para registrar errores en Firebase
    private static func recordErrorInFirebase(_ error: Error) {
        // Intentar extraer información adicional del error usando reflexión
        let mirror = Mirror(reflecting: error)
        var userInfo: [String: Any] = [:]
        
        for child in mirror.children {
            if let label = child.label {
                if label == "httpCode", let httpCode = child.value as? Int {
                    userInfo["http_code"] = httpCode
                    FirebaseLogger.shared.setCustomValue(httpCode, forKey: "last_error_http_code")
                } else if label == "message", let message = child.value as? String {
                    userInfo["error_message"] = message
                } else if label == "endpoint", let endpoint = child.value as? String {
                    userInfo["endpoint"] = endpoint
                    FirebaseLogger.shared.setCustomValue(endpoint, forKey: "last_error_endpoint")
                }
            }
        }
        
        // Registrar en Firebase
        FirebaseLogger.shared.recordError(error, userInfo: userInfo.isEmpty ? nil : userInfo)
    }
    
    /// Registra un evento de autenticación exitosa
    /// - Parameters:
    ///   - userID: ID del usuario
    ///   - userName: Nombre del usuario (opcional)
    ///   - userEmail: Email del usuario (opcional)
    static func logSuccessfulAuth(userID: String, userName: String? = nil, userEmail: String? = nil) {
        FirebaseLogger.shared.setUserID(userID)
        FirebaseLogger.shared.setUserInfo(name: userName, email: userEmail)
        FirebaseLogger.shared.logAuthEvent(action: "login", success: true)
    }
    
    /// Registra un cierre de sesión
    static func logLogout() {
        FirebaseLogger.shared.logAuthEvent(action: "logout", success: true)
        FirebaseLogger.shared.setUserID(nil)
    }
}
