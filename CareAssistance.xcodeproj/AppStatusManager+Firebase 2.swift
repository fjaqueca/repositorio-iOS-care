//
//  AppStatusManager+Firebase.swift
//  CareAssistance
//
//  Created by AI Assistant on 25/02/2026.
//

import Foundation

extension AppStatusManager {
    /// Maneja errores y los registra en Firebase Crashlytics antes de mostrarlos al usuario
    /// - Parameter error: Error a manejar y registrar
    static func error(_ error: Error) {
        // Registrar el error en Firebase Crashlytics
        FirebaseLogger.shared.recordError(error)
        
        // Extraer información del error para logging adicional
        let errorDescription = error.localizedDescription
        
        // Intentar obtener información adicional del error si es de tipo AFError (Alamofire)
        var additionalInfo: [String: Any] = [:]
        
        if let afError = error as? NSError {
            additionalInfo["domain"] = afError.domain
            additionalInfo["code"] = afError.code
            
            if let userInfo = afError.userInfo as? [String: Any] {
                additionalInfo["user_info"] = userInfo
            }
        }
        
        // Log adicional con el contexto
        FirebaseLogger.shared.log("⚠️ AppStatusManager.error called: \(errorDescription)")
        
        if !additionalInfo.isEmpty {
            FirebaseLogger.shared.setCustomValues(additionalInfo)
        }
        
        // Continuar con el manejo normal de errores de la app
        // (aquí iría tu lógica existente para mostrar popups, alerts, etc)
        handleErrorDisplay(error)
    }
    
    /// Maneja la presentación del error al usuario
    /// - Parameter error: Error a mostrar
    private static func handleErrorDisplay(_ error: Error) {
        // Aquí va tu lógica existente para mostrar el error al usuario
        // Por ejemplo, mostrar un popup, alert, toast, etc.
        
        // Ejemplo básico (ajusta según tu implementación actual):
        DispatchQueue.main.async {
            // Aquí podrías mostrar un popup o notificación al usuario
            print("❌ Error: \(error.localizedDescription)")
            
            // Si tienes un popup manager o similar, úsalo aquí
            // PopupManager.show(error: error)
        }
    }
}

// MARK: - Network Error Handling

extension AppStatusManager {
    /// Maneja errores de red específicamente
    /// - Parameters:
    ///   - error: Error de red
    ///   - endpoint: Endpoint que falló
    ///   - statusCode: Código HTTP si está disponible
    static func networkError(_ error: Error, endpoint: String, statusCode: Int? = nil) {
        // Registrar el error de red en Firebase
        FirebaseLogger.shared.recordNetworkError(error, endpoint: endpoint, httpCode: statusCode)
        
        // Log adicional
        if let statusCode = statusCode {
            FirebaseLogger.shared.log("🌐 Network error on \(endpoint) - HTTP \(statusCode)")
        } else {
            FirebaseLogger.shared.log("🌐 Network error on \(endpoint)")
        }
        
        // Mostrar el error al usuario
        handleErrorDisplay(error)
    }
}
