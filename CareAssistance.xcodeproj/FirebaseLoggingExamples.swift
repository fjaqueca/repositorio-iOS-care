//
//  FirebaseLoggingExamples.swift
//  CareAssistance
//
//  Created by AI Assistant on 25/02/2026.
//  
//  📝 Este archivo contiene ejemplos de código para integrar Firebase Logging
//  NO COMPILAR - Solo para referencia
//

import Foundation
import FirebaseCrashlytics

// MARK: - 1. Login/Authentication Examples

/*
 Ejemplo: Login Flow Completo
 */
func loginExample() {
    FirebaseLogger.shared.log("🔑 User attempting login")
    
    Task {
        do {
            let user = try await authService.login(rut: rut, password: password)
            
            // ✅ Login exitoso - configurar usuario en Firebase
            FirebaseLogger.shared.setUserID(user.id)
            FirebaseLogger.shared.setUserInfo(
                name: user.firstName,
                email: user.email,
                enterprise: user.enterprise
            )
            FirebaseLogger.shared.logAuthEvent(action: "login", success: true)
            
        } catch {
            // ❌ Login falló
            FirebaseLogger.shared.logAuthEvent(
                action: "login",
                success: false,
                error: error
            )
            AppStatusManager.errorWithContext(error, context: "LoginView")
        }
    }
}

/*
 Ejemplo: Logout
 */
func logoutExample() {
    FirebaseLogger.shared.log("🚪 User logging out")
    FirebaseLogger.shared.logAuthEvent(action: "logout", success: true)
    
    // Limpiar usuario de Firebase
    FirebaseLogger.shared.setUserID(nil)
    
    // Tu código de logout...
}

// MARK: - 2. Network/API Call Examples

/*
 Ejemplo: GET Request con error handling
 */
func fetchAppointmentsExample() {
    Task {
        FirebaseLogger.shared.log("📅 Fetching appointments")
        
        let result = await Network.shared.getAppointments()
        switch result {
        case .success(let appointments):
            FirebaseLogger.shared.log("✅ Appointments loaded: \(appointments.count) items")
            
        case let .failure(error):
            FirebaseLogger.shared.recordNetworkError(
                error,
                endpoint: "/api/appointments",
                httpCode: error.httpCode,
                method: "GET"
            )
            AppStatusManager.errorWithContext(error, context: "AppointmentsListView")
        }
    }
}

/*
 Ejemplo: POST Request (crear cita)
 */
func createAppointmentExample(clinicId: String, date: Date) {
    Task {
        FirebaseLogger.shared.log("📝 Creating appointment")
        FirebaseLogger.shared.setCustomValues([
            "clinic_id": clinicId,
            "appointment_date": date.description
        ])
        
        let result = await Network.shared.createAppointment(clinicId: clinicId, date: date)
        switch result {
        case .success(let appointment):
            FirebaseLogger.shared.logEvent("appointment_created", attributes: [
                "appointment_id": appointment.id,
                "clinic_id": clinicId
            ])
            
        case let .failure(error):
            FirebaseLogger.shared.logAppointmentError(
                action: "create",
                appointmentId: nil,
                error: error
            )
            AppStatusManager.errorWithContext(error, context: "CreateAppointmentView")
        }
    }
}

// MARK: - 3. Video Call Examples

/*
 Ejemplo: Conectar a videollamada
 */
func connectToVideoCallExample(roomName: String, clinicId: String) {
    FirebaseLogger.shared.log("📹 Connecting to video call")
    FirebaseLogger.shared.setCustomValues([
        "room_name": roomName,
        "clinic_id": clinicId
    ])
    
    do {
        // Tu código de conexión...
        let room = try connectToRoom(name: roomName)
        FirebaseLogger.shared.log("✅ Connected to video room: \(roomName)")
        
    } catch {
        FirebaseLogger.shared.logVideoCallError(
            action: "connect",
            error: error,
            roomName: roomName,
            clinicId: clinicId
        )
        AppStatusManager.errorWithContext(error, context: "VideoCallView")
    }
}

/*
 Ejemplo: Error de cámara en videollamada
 */
func cameraErrorExample(error: Error) {
    FirebaseLogger.shared.logCameraError(
        action: "start_camera",
        error: error
    )
    
    // Mostrar mensaje al usuario
    showCameraError(error)
}

// MARK: - 4. Permissions Examples

/*
 Ejemplo: Solicitar permiso de cámara
 */
func requestCameraPermissionExample() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        let status = granted ? "granted" : "denied"
        
        FirebaseLogger.shared.logPermissionIssue(
            permission: "camera",
            status: status
        )
        
        if !granted {
            // Mostrar alerta al usuario
            DispatchQueue.main.async {
                self.showCameraPermissionAlert()
            }
        }
    }
}

/*
 Ejemplo: Solicitar permiso de micrófono
 */
func requestMicrophonePermissionExample() {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
        let status = granted ? "granted" : "denied"
        
        FirebaseLogger.shared.logPermissionIssue(
            permission: "microphone",
            status: status
        )
    }
}

/*
 Ejemplo: Solicitar permiso de notificaciones
 */
func requestNotificationPermissionExample() {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
    ) { granted, error in
        
        if let error = error {
            FirebaseLogger.shared.recordError(error, userInfo: [
                "permission_type": "notifications"
            ])
        }
        
        let status = granted ? "granted" : "denied"
        FirebaseLogger.shared.logPermissionIssue(
            permission: "notifications",
            status: status
        )
    }
}

// MARK: - 5. Error Popup/Alert Examples

/*
 Ejemplo: Mostrar popup de error
 */
func showErrorPopupExample() {
    let title = "Error de conexión"
    let message = "No se pudo conectar al servidor. Intenta nuevamente."
    
    // Registrar antes de mostrar
    FirebaseLogger.shared.logErrorPopup(
        title: title,
        message: message,
        source: "HomeView"
    )
    
    // Mostrar popup
    self.showErrorPopup = true
}

/*
 Ejemplo: Alert de SwiftUI
 */
func swiftUIAlertExample() -> some View {
    Text("Content")
        .alert("Error", isPresented: $showAlert) {
            Button("OK") {
                showAlert = false
            }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: showAlert) { newValue in
            if newValue {
                // Registrar cuando se muestra
                FirebaseLogger.shared.logAlert(
                    title: "Error",
                    message: errorMessage,
                    source: "ProfileView"
                )
            }
        }
}

// MARK: - 6. Navigation Examples

/*
 Ejemplo: Tracking de navegación en SwiftUI
 */
struct ExampleView: View {
    var body: some View {
        Text("Content")
            .onAppear {
                FirebaseLogger.shared.logNavigation(
                    from: "HomeView",
                    to: "ProfileView"
                )
                FirebaseLogger.shared.setCustomValue("ProfileView", forKey: "current_screen")
            }
            .onDisappear {
                FirebaseLogger.shared.log("📤 Leaving ProfileView")
            }
    }
}

// MARK: - 7. Generic Error Handling Examples

/*
 Ejemplo: Try-Catch básico
 */
func tryCatchExample() {
    do {
        try performSomeOperation()
        
    } catch {
        // Registrar error con contexto
        FirebaseLogger.shared.recordError(error, userInfo: [
            "operation": "performSomeOperation",
            "context": "ExampleView"
        ])
        
        // Mostrar al usuario
        showError(error)
    }
}

/*
 Ejemplo: Result type handling
 */
func resultHandlingExample() {
    Task {
        let result = await someAsyncOperation()
        
        switch result {
        case .success(let data):
            FirebaseLogger.shared.log("✅ Operation successful")
            handleSuccess(data)
            
        case .failure(let error):
            FirebaseLogger.shared.recordError(error, userInfo: [
                "operation": "someAsyncOperation"
            ])
            AppStatusManager.errorWithContext(error, context: "CurrentView")
        }
    }
}

// MARK: - 8. User Context Examples

/*
 Ejemplo: Configurar información de usuario después de login
 */
func setupUserContextExample(user: User) {
    // ID único del usuario
    FirebaseLogger.shared.setUserID(user.id)
    
    // Información adicional
    FirebaseLogger.shared.setUserInfo(
        name: "\(user.firstName) \(user.lastName)",
        email: user.email,
        enterprise: user.enterpriseName
    )
    
    // Custom values útiles
    FirebaseLogger.shared.setCustomValues([
        "user_type": user.type,
        "registration_date": user.createdAt.description,
        "has_active_appointments": user.hasActiveAppointments
    ])
    
    FirebaseLogger.shared.log("👤 User context configured")
}

/*
 Ejemplo: Limpiar contexto de usuario
 */
func clearUserContextExample() {
    FirebaseLogger.shared.setUserID(nil)
    FirebaseLogger.shared.log("👤 User context cleared")
}

// MARK: - 9. Custom Events Examples

/*
 Ejemplo: Evento de negocio (usuario completó onboarding)
 */
func trackOnboardingCompletedExample() {
    FirebaseLogger.shared.logEvent("onboarding_completed", attributes: [
        "steps_completed": 5,
        "time_spent_seconds": 120,
        "skipped_tutorial": false
    ])
}

/*
 Ejemplo: Evento de búsqueda
 */
func trackSearchExample(query: String, resultsCount: Int) {
    FirebaseLogger.shared.logEvent("search_performed", attributes: [
        "query": query,
        "results_count": resultsCount,
        "search_type": "clinics"
    ])
}

/*
 Ejemplo: Evento de pago/transacción
 */
func trackPaymentExample(amount: Double, method: String) {
    FirebaseLogger.shared.logEvent("payment_initiated", attributes: [
        "amount": amount,
        "payment_method": method,
        "currency": "CLP"
    ])
}

// MARK: - 10. App Lifecycle Examples

/*
 Ejemplo: En AppDelegate o SwiftUI App
 */
func appLifecycleExample() {
    // App entrando a background
    NotificationCenter.default.addObserver(
        forName: UIApplication.didEnterBackgroundNotification,
        object: nil,
        queue: .main
    ) { _ in
        FirebaseLogger.shared.logAppLifecycle("app_background")
    }
    
    // App volviendo a foreground
    NotificationCenter.default.addObserver(
        forName: UIApplication.willEnterForegroundNotification,
        object: nil,
        queue: .main
    ) { _ in
        FirebaseLogger.shared.logAppLifecycle("app_foreground")
    }
}

// MARK: - 11. Debugging Examples

/*
 Ejemplo: Breadcrumbs para debugging
 */
func debuggingBreadcrumbsExample() {
    FirebaseLogger.shared.log("🔍 Starting complex operation")
    
    FirebaseLogger.shared.log("Step 1: Validating input")
    // ... código
    
    FirebaseLogger.shared.log("Step 2: Fetching data")
    // ... código
    
    FirebaseLogger.shared.log("Step 3: Processing results")
    // ... código
    
    FirebaseLogger.shared.log("✅ Complex operation completed")
}

/*
 Ejemplo: Custom values para debugging
 */
func debuggingCustomValuesExample() {
    FirebaseLogger.shared.setCustomValues([
        "screen_orientation": UIDevice.current.orientation.isPortrait ? "portrait" : "landscape",
        "battery_level": UIDevice.current.batteryLevel,
        "free_storage_gb": getFreeStorageSpace(),
        "network_type": getNetworkType()
    ])
}

// MARK: - 12. Edge Cases Examples

/*
 Ejemplo: Timeout error
 */
func timeoutErrorExample() {
    Task {
        do {
            let result = try await performOperationWithTimeout(seconds: 30)
            
        } catch {
            if error.localizedDescription.contains("timeout") {
                FirebaseLogger.shared.log("⏱️ Operation timed out")
                FirebaseLogger.shared.recordError(error, userInfo: [
                    "error_type": "timeout",
                    "operation": "performOperation",
                    "timeout_seconds": 30
                ])
            }
        }
    }
}

/*
 Ejemplo: Offline error
 */
func offlineErrorExample() {
    if !isConnectedToNetwork() {
        FirebaseLogger.shared.log("📵 Device is offline")
        FirebaseLogger.shared.setCustomValue("offline", forKey: "network_status")
        
        showOfflineMessage()
    }
}

// MARK: - 13. Reemplazo Simple

/*
 ANTES: Código sin logging
 */
func oldCodeExample() {
    Task {
        let result = await someOperation()
        switch result {
        case .success(let data):
            handleSuccess(data)
        case .failure(let error):
            AppStatusManager.error(error)  // ❌ SIN LOGGING
        }
    }
}

/*
 DESPUÉS: Con logging básico
 */
func newCodeBasicExample() {
    Task {
        let result = await someOperation()
        switch result {
        case .success(let data):
            handleSuccess(data)
        case .failure(let error):
            AppStatusManager.errorWithLogging(error)  // ✅ CON LOGGING
        }
    }
}

/*
 MEJOR: Con logging y contexto
 */
func newCodeBestExample() {
    Task {
        FirebaseLogger.shared.log("🚀 Starting operation")
        
        let result = await someOperation()
        switch result {
        case .success(let data):
            FirebaseLogger.shared.log("✅ Operation completed successfully")
            handleSuccess(data)
            
        case .failure(let error):
            AppStatusManager.errorWithContext(error, context: "ExampleView")  // ✅ CON CONTEXTO
        }
    }
}

// MARK: - 14. ViewModel Pattern Example

/*
 Ejemplo: ViewModel con Firebase Logging
 */
class ExampleViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadData() {
        FirebaseLogger.shared.log("📊 Loading data in ExampleViewModel")
        isLoading = true
        
        Task {
            do {
                let data = try await fetchData()
                
                await MainActor.run {
                    self.isLoading = false
                    FirebaseLogger.shared.log("✅ Data loaded successfully")
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    
                    FirebaseLogger.shared.recordError(error, userInfo: [
                        "view_model": "ExampleViewModel",
                        "action": "loadData"
                    ])
                }
            }
        }
    }
}

// MARK: - 15. Migration Helpers

/*
 Encuentra todos los lugares donde necesitas agregar logging:
 
 1. Busca en Xcode: "AppStatusManager.error"
    - Reemplaza con: "AppStatusManager.errorWithLogging(error)"
 
 2. Busca: "case let .failure(error):"
    - Agrega antes de manejar: "FirebaseLogger.shared.recordError(error)"
 
 3. Busca: "catch {"
    - Agrega dentro: "FirebaseLogger.shared.recordError(error)"
 
 4. Busca: "showErrorPopup"
    - Agrega antes: "FirebaseLogger.shared.logErrorPopup(...)"
 
 5. Busca: "login" o "signIn"
    - Agrega: "FirebaseLogger.shared.logAuthEvent(...)"
 */
