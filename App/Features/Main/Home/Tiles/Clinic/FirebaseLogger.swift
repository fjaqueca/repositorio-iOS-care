//
//  FirebaseLogger.swift
//  CareAssistance
//
//  Created by AI Assistant on 25/02/2026.
//

import Foundation
import FirebaseCrashlytics

/// Servicio centralizado para logging y tracking de errores en Firebase Crashlytics
class FirebaseLogger {
    static let shared = FirebaseLogger()
    private init() {}
    
    // MARK: - User Context
    
    /// Establece el ID del usuario para tracking en Crashlytics
    /// - Parameter userID: ID único del usuario (ej: RUT, email hash, etc)
    func setUserID(_ userID: String?) {
        guard let userID = userID, !userID.isEmpty else {
            Crashlytics.crashlytics().setUserID("")
            return
        }
        Crashlytics.crashlytics().setUserID(userID)
        log("👤 User ID set: \(userID)")
    }
    
    /// Establece información adicional del usuario
    /// - Parameters:
    ///   - name: Nombre del usuario
    ///   - email: Email del usuario
    ///   - enterprise: Empresa/organización del usuario
    func setUserInfo(name: String? = nil, email: String? = nil, enterprise: String? = nil) {
        if let name = name {
            Crashlytics.crashlytics().setCustomValue(name, forKey: "user_name")
        }
        if let email = email {
            Crashlytics.crashlytics().setCustomValue(email, forKey: "user_email")
        }
        if let enterprise = enterprise {
            Crashlytics.crashlytics().setCustomValue(enterprise, forKey: "user_enterprise")
        }
    }
    
    // MARK: - Error Recording
    
    /// Registra un error no fatal en Crashlytics
    /// - Parameters:
    ///   - error: Error a registrar
    ///   - userInfo: Información adicional contextual
    func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        log("❌ Recording error: \(error.localizedDescription)")
        
        if let userInfo = userInfo {
            Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
        } else {
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
    /// Registra un error con información de red
    /// - Parameters:
    ///   - error: Error a registrar
    ///   - endpoint: Endpoint que falló
    ///   - httpCode: Código HTTP de respuesta
    ///   - method: Método HTTP (GET, POST, etc)
    func recordNetworkError(_ error: Error, endpoint: String, httpCode: Int? = nil, method: String? = nil) {
        log("🌐 Network error on \(endpoint): \(error.localizedDescription)")
        
        var userInfo: [String: Any] = [
            "endpoint": endpoint,
            "error_type": "network_error"
        ]
        
        if let httpCode = httpCode {
            userInfo["http_code"] = httpCode
            Crashlytics.crashlytics().setCustomValue(httpCode, forKey: "last_http_code")
        }
        
        if let method = method {
            userInfo["http_method"] = method
        }
        
        Crashlytics.crashlytics().setCustomValue(endpoint, forKey: "last_failed_endpoint")
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }
    
    // MARK: - Event Logging
    
    /// Registra un log/breadcrumb en Crashlytics
    /// - Parameter message: Mensaje a registrar
    func log(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        Crashlytics.crashlytics().log("[\(timestamp)] \(message)")
    }
    
    /// Registra un evento importante con custom keys
    /// - Parameters:
    ///   - event: Nombre del evento
    ///   - attributes: Atributos adicionales del evento
    func logEvent(_ event: String, attributes: [String: Any]? = nil) {
        log("📊 Event: \(event)")
        
        if let attributes = attributes {
            for (key, value) in attributes {
                Crashlytics.crashlytics().setCustomValue(value, forKey: key)
            }
        }
    }
    
    // MARK: - Service Failures
    
    /// Registra un fallo en un servicio/API
    /// - Parameters:
    ///   - service: Nombre del servicio
    ///   - endpoint: Endpoint que falló
    ///   - error: Error ocurrido
    ///   - statusCode: Código HTTP de respuesta
    func logServiceFailure(service: String, endpoint: String, error: Error, statusCode: Int?) {
        log("⚠️ Service failure: \(service) - \(endpoint)")
        
        Crashlytics.crashlytics().setCustomValue(service, forKey: "failed_service")
        Crashlytics.crashlytics().setCustomValue(endpoint, forKey: "failed_endpoint")
        
        var userInfo: [String: Any] = [
            "service": service,
            "endpoint": endpoint,
            "error_type": "service_failure"
        ]
        
        if let statusCode = statusCode {
            Crashlytics.crashlytics().setCustomValue(statusCode, forKey: "http_status")
            userInfo["status_code"] = statusCode
        }
        
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }
    
    // MARK: - UI Error Tracking
    
    /// Registra cuando se muestra un popup de error al usuario
    /// - Parameters:
    ///   - title: Título del popup
    ///   - message: Mensaje del popup
    ///   - source: Vista/pantalla donde se mostró
    func logErrorPopup(title: String, message: String, source: String) {
        log("🚨 Error popup shown: '\(title)' in \(source)")
        
        Crashlytics.crashlytics().setCustomValue(title, forKey: "last_popup_title")
        Crashlytics.crashlytics().setCustomValue(message, forKey: "last_popup_message")
        Crashlytics.crashlytics().setCustomValue(source, forKey: "last_popup_source")
        
        // Crear un NSError para registrar el popup como evento
        let error = NSError(
            domain: "UIErrorPopup",
            code: 9001,
            userInfo: [
                NSLocalizedDescriptionKey: title,
                NSLocalizedFailureReasonErrorKey: message,
                "source": source
            ]
        )
        Crashlytics.crashlytics().record(error: error)
    }
    
    /// Registra cuando se muestra un alert al usuario
    /// - Parameters:
    ///   - title: Título del alert
    ///   - message: Mensaje del alert
    ///   - source: Vista/pantalla donde se mostró
    func logAlert(title: String, message: String, source: String) {
        log("⚠️ Alert shown: '\(title)' in \(source)")
        
        Crashlytics.crashlytics().setCustomValue(title, forKey: "last_alert_title")
        Crashlytics.crashlytics().setCustomValue(message, forKey: "last_alert_message")
        Crashlytics.crashlytics().setCustomValue(source, forKey: "last_alert_source")
    }
    
    // MARK: - Video Call Tracking
    
    /// Registra errores relacionados con videollamadas
    /// - Parameters:
    ///   - action: Acción que falló (connect, disconnect, enqueue, etc)
    ///   - error: Error ocurrido
    ///   - roomName: Nombre de la sala (opcional)
    ///   - clinicId: ID de la clínica (opcional)
    func logVideoCallError(action: String, error: Error, roomName: String? = nil, clinicId: String? = nil) {
        log("📹 Video call error (\(action)): \(error.localizedDescription)")
        
        var userInfo: [String: Any] = [
            "video_call_action": action,
            "error_type": "video_call_error"
        ]
        
        if let roomName = roomName {
            userInfo["room_name"] = roomName
            Crashlytics.crashlytics().setCustomValue(roomName, forKey: "last_video_room")
        }
        
        if let clinicId = clinicId {
            userInfo["clinic_id"] = clinicId
            Crashlytics.crashlytics().setCustomValue(clinicId, forKey: "last_video_clinic")
        }
        
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }
    
    // MARK: - Permission Tracking
    
    /// Registra problemas con permisos
    /// - Parameters:
    ///   - permission: Tipo de permiso (camera, microphone, notifications, etc)
    ///   - status: Estado del permiso
    func logPermissionIssue(permission: String, status: String) {
        log("🔐 Permission issue: \(permission) - \(status)")
        
        Crashlytics.crashlytics().setCustomValue(status, forKey: "permission_\(permission)")
        
        let error = NSError(
            domain: "PermissionError",
            code: 9002,
            userInfo: [
                NSLocalizedDescriptionKey: "Permission denied: \(permission)",
                "permission_type": permission,
                "permission_status": status
            ]
        )
        Crashlytics.crashlytics().record(error: error)
    }
    
    // MARK: - Navigation Tracking
    
    /// Registra navegación entre pantallas
    /// - Parameters:
    ///   - from: Pantalla de origen
    ///   - to: Pantalla de destino
    func logNavigation(from: String, to: String) {
        log("🧭 Navigation: \(from) → \(to)")
        Crashlytics.crashlytics().setCustomValue(to, forKey: "current_screen")
    }
    
    // MARK: - Custom Context
    
    /// Establece un valor personalizado para contexto
    /// - Parameters:
    ///   - value: Valor a establecer
    ///   - key: Clave del valor
    func setCustomValue(_ value: Any, forKey key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    /// Establece múltiples valores personalizados
    /// - Parameter values: Diccionario de valores
    func setCustomValues(_ values: [String: Any]) {
        for (key, value) in values {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }
    
    // MARK: - App Lifecycle
    
    /// Registra eventos del ciclo de vida de la app
    /// - Parameter event: Evento (launch, background, foreground, etc)
    func logAppLifecycle(_ event: String) {
        log("🔄 App lifecycle: \(event)")
        Crashlytics.crashlytics().setCustomValue(event, forKey: "last_lifecycle_event")
    }
    
    // MARK: - Authentication Tracking
    
    /// Registra eventos de autenticación
    /// - Parameters:
    ///   - action: Acción (login, logout, token_refresh, etc)
    ///   - success: Si fue exitoso
    ///   - error: Error si falló
    func logAuthEvent(action: String, success: Bool, error: Error? = nil) {
        log("🔑 Auth event: \(action) - \(success ? "success" : "failed")")
        
        Crashlytics.crashlytics().setCustomValue(action, forKey: "last_auth_action")
        Crashlytics.crashlytics().setCustomValue(success, forKey: "last_auth_success")
        
        if let error = error {
            let userInfo: [String: Any] = [
                "auth_action": action,
                "error_type": "authentication_error"
            ]
            Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
        }
    }
    
    // MARK: - Appointment Tracking
    
    /// Registra errores relacionados con citas
    /// - Parameters:
    ///   - action: Acción (create, cancel, reschedule, etc)
    ///   - appointmentId: ID de la cita
    ///   - error: Error ocurrido
    func logAppointmentError(action: String, appointmentId: String?, error: Error) {
        log("📅 Appointment error (\(action)): \(error.localizedDescription)")
        
        var userInfo: [String: Any] = [
            "appointment_action": action,
            "error_type": "appointment_error"
        ]
        
        if let appointmentId = appointmentId {
            userInfo["appointment_id"] = appointmentId
            Crashlytics.crashlytics().setCustomValue(appointmentId, forKey: "last_appointment_id")
        }
        
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }
    
    // MARK: - Camera Tracking
    
    /// Registra errores de cámara
    /// - Parameters:
    ///   - action: Acción que falló
    ///   - error: Error ocurrido
    func logCameraError(action: String, error: Error) {
        log("📷 Camera error (\(action)): \(error.localizedDescription)")
        
        let userInfo: [String: Any] = [
            "camera_action": action,
            "error_type": "camera_error"
        ]
        
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }
}

// MARK: - Convenience Extensions

extension FirebaseLogger {
    /// Registra un error de red desde un NetworkError (si existe en tu proyecto)
    func recordNetworkError<T: Error>(_ error: T, endpoint: String) {
        // Intentar extraer información HTTP si el error tiene esas propiedades
        var httpCode: Int?
        var method: String?
        
        // Usar reflexión para intentar obtener propiedades
        let mirror = Mirror(reflecting: error)
        for child in mirror.children {
            if child.label == "httpCode" {
                httpCode = child.value as? Int
            } else if child.label == "method" {
                method = child.value as? String
            }
        }
        
        recordNetworkError(error, endpoint: endpoint, httpCode: httpCode, method: method)
    }
}
