//
//  MarketingCloudManager.swift
//  CareAssistance
//
//  Created on 16/03/2026.
//
 
import Foundation
import SFMCSDK
import MarketingCloudSDK
 
/// Manager centralizado para interacciones con Salesforce Marketing Cloud
/// Replica la lógica de MarketingCloudManager.kt en Android
/// Compatible con SFMCSDK 1.1.4 + MarketingCloudSDK 8.1.4
class MarketingCloudManager {
    
    static let shared = MarketingCloudManager()
    
    private init() {}
    
    // MARK: - Almacenamiento temporal del device token
    /// Guardamos el device token hasta que el usuario haga login
    private var pendingDeviceToken: Data?
    
    /// Guarda el device token pero NO lo envía a SFMC hasta después del login
    func storePendingDeviceToken(_ deviceToken: Data) {
        self.pendingDeviceToken = deviceToken
        print("📦 Device token guardado (pending login)")
        
        // Logging detallado del device token (como Android)
        logDeviceToken(deviceToken)
    }
    
    /// Verifica si hay un usuario loggeado
    private func isUserLoggedIn() -> Bool {
        // Verificar si hay credenciales guardadas (igual que Android verifica TOKEN)
        return AppStatusManager.credentials != nil && AppStatusManager.rut != nil
    }
    
    // MARK: - Helper: verificar si el SDK está operacional
    
    private func isSdkOperational() -> Bool {
        return SFMCSdk.mp.getStatus() == .operational
    }
    
    // MARK: - Envío de contacto a Marketing Cloud (Post-Login)
    
    /// Envía los datos del usuario a Marketing Cloud y habilita push
    /// - Parameters:
    ///   - rut: RUT del usuario
    ///   - firstName: Nombre
    ///   - lastName: Apellido
    ///   - email: Email
    ///   - phone: Teléfono
    ///   - accountId: Salesforce Account Id (001xxx)
    ///   - personContactId: Salesforce Contact Id (003xxx) - PREFERIDO como ContactKey
    ///   - empresaId: ID de la empresa (convenio)
    ///   - convenioId: ID del convenio
    ///   - completion: Callback con resultado (success/error)
    func sendContactToMarketingCloud(
        rut: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        accountId: String,
        personContactId: String,
        empresaId: String? = nil,
        convenioId: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 ENVIANDO CONTACTO A MARKETING CLOUD")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👤 Datos del Usuario:")
        print("   RUT: \(rut)")
        print("   Nombre: \(firstName) \(lastName)")
        print("   Email: \(email)")
        print("   Teléfono: \(phone)")
        print("   AccountId: \(accountId)")
        print("   PersonContactId: \(personContactId)")
        if let empresaId = empresaId {
            print("   EmpresaId: \(empresaId)")
        }
        if let convenioId = convenioId {
            print("   ConvenioId: \(convenioId)")
        }
        print("")
        
        // 1. Determinar el ContactKey a usar (igual que Android)
        let contactKey: String
        if !personContactId.isEmpty {
            contactKey = personContactId  // ← PREFERIDO (003xxx)
            print("✅ Usando PersonContactId como ContactKey: \(contactKey)")
        } else if !accountId.isEmpty {
            contactKey = accountId  // ← Fallback (001xxx)
            print("⚠️ PersonContactId vacío, usando AccountId como ContactKey: \(contactKey)")
        } else {
            print("❌ ERROR: PersonContactId y AccountId están vacíos")
            completion(.failure(NSError(
                domain: "MarketingCloudManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "PersonContactId y AccountId están vacíos"]
            )))
            return
        }
        
        // 2. Verificar que el SDK esté operacional
        guard isSdkOperational() else {
            print("❌ MarketingCloudSDK no está operacional (status: \(SFMCSdk.mp.getStatus()))")
            completion(.failure(NSError(
                domain: "MarketingCloudManager",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "MarketingCloudSDK no está operacional"]
            )))
            return
        }
        
        // 3. Setear ContactKey usando SFMCSdk.identity (API 8.x)
        // Equivalente al viejo: MarketingCloudSDK.sharedInstance().sfmc_setContactKey(...)
        SFMCSdk.identity.setProfileId(contactKey)
        print("✅ ContactKey (ProfileId) seteado: \(contactKey)")
        
        // 4. Preparar atributos
        var attributes: [String: String] = [
            "RUT": rut,
            "FirstName": firstName,
            "LastName": lastName,
            "EmailAddress": email,
            "PhoneNumber": phone,
            "AccountId": accountId,
            "PersonContactId": personContactId
        ]
        
        // Agregar opcionales si existen
        if let empresaId = empresaId, !empresaId.isEmpty {
            attributes["EmpresaId"] = empresaId
        }
        if let convenioId = convenioId, !convenioId.isEmpty {
            attributes["ConvenioId"] = convenioId
        }
        
        // 5. Setear atributos usando SFMCSdk.identity (API 8.x)
        // Equivalente al viejo: MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed(key, value:)
        SFMCSdk.identity.setProfileAttributes(attributes)
        print("✅ Todos los atributos configurados en SFMC:")
        for (key, value) in attributes {
            print("   ✓ Atributo: \(key) = \(value)")
        }
        
        // 6. AHORA SÍ enviar el device token (enablePush equivalente)
        if let deviceToken = self.pendingDeviceToken {
            SFMCSdk.mp.setDeviceToken(deviceToken)
            print("✅ Device token enviado a SFMC CON identidad correcta")
            print("🎉 Usuario OPTED IN con ContactKey: \(contactKey)")
            self.pendingDeviceToken = nil  // Limpiar
            
            print("")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("✅ REGISTRO EN MARKETING CLOUD COMPLETADO")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("ContactKey: \(contactKey)")
            print("Atributos configurados: \(attributes.count)")
            print("Device Token: Registrado ✅")
            print("Estado: OPTED IN 🎉")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            completion(.success(()))
        } else {
            print("")
            print("⚠️ No hay device token pendiente")
            print("⚠️ Esto puede ocurrir si:")
            print("   - El usuario no aceptó permisos de notificaciones")
            print("   - APNs aún no ha devuelto el token")
            print("   - El login ocurrió antes de recibir el token")
            print("")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("⚠️ REGISTRO PARCIAL EN MARKETING CLOUD")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("ContactKey: \(contactKey)")
            print("Atributos configurados: \(attributes.count)")
            print("Device Token: ⚠️ No disponible")
            print("Estado: Sin push habilitado")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            // Aún así consideramos éxito porque los atributos se setearon
            completion(.success(()))
        }
    }
    
    // MARK: - Logout
    
    /// Limpia la identidad del usuario en Marketing Cloud y deshabilita push
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🚪 CERRANDO SESIÓN EN MARKETING CLOUD")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // Loguear estado ANTES del logout
        if let contactKey = SFMCSdk.mp.contactKey(), !contactKey.isEmpty {
            print("ContactKey actual: \(contactKey)")
        } else {
            print("ContactKey actual: N/A")
        }
        
        if let deviceToken = SFMCSdk.mp.deviceToken() {
            print("Device Token actual: Registrado ✅")
        } else {
            print("Device Token actual: No registrado")
        }
        
        print("")
        
        guard isSdkOperational() else {
            print("❌ MarketingCloudSDK no está operacional")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            completion(.failure(NSError(
                domain: "MarketingCloudManager",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "MarketingCloudSDK no está operacional"]
            )))
            return
        }
        
        // Limpiar ContactKey usando SFMCSdk.identity (API 8.x)
        SFMCSdk.identity.setProfileId("")
        print("✅ ContactKey (ProfileId) limpiado")
        
        // Limpiar atributos individualmente usando clearProfileAttribute (API 8.x)
        let attributeKeys = ["RUT", "FirstName", "LastName", "EmailAddress",
                             "PhoneNumber", "AccountId", "PersonContactId",
                             "EmpresaId", "ConvenioId"]
        for key in attributeKeys {
            SFMCSdk.identity.clearProfileAttribute(key: key)
        }
        print("✅ Atributos limpiados (\(attributeKeys.count) campos)")
        
        // Deshabilitar push limpiando el device token
        SFMCSdk.mp.setDeviceToken(Data())  // Token vacío = opted out
        print("✅ Push deshabilitado (device token limpiado)")
        
        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("✅ LOGOUT DE MARKETING CLOUD COMPLETADO")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("ContactKey: Limpiado ✅")
        print("Atributos: Limpiados ✅")
        print("Device Token: Desregistrado ✅")
        print("Estado: OPTED OUT")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        completion(.success(()))
    }
    
    // MARK: - Verificación de estado (opcional, para debugging)
    
    func logCurrentState() {
        print("🧪 ESTADO ACTUAL DE SFMC:")
        print("   SDK Status: \(SFMCSdk.mp.getStatus())")
        
        guard isSdkOperational() else {
            print("   ❌ MarketingCloudSDK no está operacional")
            return
        }
        
        // Obtener ContactKey actual (PushInterface method)
        if let contactKey = SFMCSdk.mp.contactKey(), !contactKey.isEmpty {
            print("   ContactKey: \(contactKey)")
        } else {
            print("   ContactKey: N/A")
        }
        
        print("   Device Token existe (pending): \(self.pendingDeviceToken != nil ? "Sí" : "No")")
        
        if let deviceToken = SFMCSdk.mp.deviceToken() {
            print("   Device Token registrado en SFMC: \(deviceToken)")
        } else {
            print("   Device Token registrado en SFMC: N/A")
        }
        
        // Mostrar atributos actuales
        if let attrs = SFMCSdk.mp.attributes() {
            print("   Atributos: \(attrs)")
        }
    }
    
    // MARK: - Logging de estado de permisos (para debugging como Android)
    
    /// Loguea el estado actual de los permisos de notificación
    /// Replica el logging detallado de Android en cada paso
    func logNotificationPermissionState() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔔 ESTADO DE PERMISOS DE NOTIFICACIÓN")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status = settings.authorizationStatus
            let statusText: String
            let statusEmoji: String
            
            switch status {
            case .notDetermined:
                statusText = "No determinado (usuario no ha decidido)"
                statusEmoji = "⚪️"
            case .denied:
                statusText = "Denegado por el usuario"
                statusEmoji = "🔴"
            case .authorized:
                statusText = "Autorizado"
                statusEmoji = "🟢"
            case .provisional:
                statusText = "Provisional (quiet notifications)"
                statusEmoji = "🟡"
            case .ephemeral:
                statusText = "Efímero (App Clip)"
                statusEmoji = "🟠"
            @unknown default:
                statusText = "Estado desconocido"
                statusEmoji = "⚫️"
            }
            
            print("\(statusEmoji) Authorization Status: \(statusText)")
            print("   Raw Value: \(status.rawValue)")
            print("")
            
            print("📋 Configuración Detallada:")
            print("   Alert Style: \(settings.alertStyle.rawValue)")
            print("   Alert Setting: \(settings.alertSetting.rawValue)")
            print("   Badge Setting: \(settings.badgeSetting.rawValue)")
            print("   Sound Setting: \(settings.soundSetting.rawValue)")
            print("   Notification Center: \(settings.notificationCenterSetting.rawValue)")
            print("   Lock Screen: \(settings.lockScreenSetting.rawValue)")
            print("   Car Play: \(settings.carPlaySetting.rawValue)")
            
            if #available(iOS 15.0, *) {
                print("   Scheduled Delivery: \(settings.scheduledDeliverySetting.rawValue)")
                print("   Time Sensitive: \(settings.timeSensitiveSetting.rawValue)")
            }
            
            print("")
            print("📊 Estado de Marketing Cloud:")
            print("   SDK Operacional: \(self.isSdkOperational() ? "✅ Sí" : "❌ No")")
            print("   Usuario Loggeado: \(self.isUserLoggedIn() ? "✅ Sí" : "❌ No")")
            print("   Device Token Pendiente: \(self.pendingDeviceToken != nil ? "✅ Sí" : "❌ No")")
            
            if let contactKey = SFMCSdk.mp.contactKey(), !contactKey.isEmpty {
                print("   ContactKey: \(contactKey)")
            } else {
                print("   ContactKey: ❌ No configurado")
            }
            
            // FIX: SFMCSdk.mp.deviceToken() retorna String, no Data.
            // Se usa directamente como String sin intentar mapear bytes.
            if let deviceToken = SFMCSdk.mp.deviceToken() {
                print("   Device Token en SFMC: \(deviceToken.prefix(16))...")
            } else {
                print("   Device Token en SFMC: ❌ No registrado")
            }
            
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }
    
    /// Loguea el device token en formato legible (como Android loguea el FCM token)
    func logDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02hhx", $0) }.joined(separator: "")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 DEVICE TOKEN RECIBIDO")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Token (hex): \(tokenString)")
        print("Token (length): \(deviceToken.count) bytes")
        print("Token (primeros 32 chars): \(tokenString.prefix(32))...")
        print("Estado del usuario: \(isUserLoggedIn() ? "✅ Loggeado" : "❌ No loggeado")")
        print("Acción: \(isUserLoggedIn() ? "Se enviará a SFMC con identidad" : "Se guardará hasta login")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    
    // MARK: - Habilitar Push si ya está loggeado (para lógica de Splash)
    
    /// Intenta habilitar push si el usuario ya está loggeado y hay un device token pendiente
    /// Replica la lógica de enablePush() condicional de Android
    func enablePushIfLoggedIn() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔄 VERIFICANDO SI DEBE HABILITAR PUSH")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        let loggedIn = isUserLoggedIn()
        let hasToken = pendingDeviceToken != nil
        let isOperational = isSdkOperational()
        
        print("Usuario loggeado: \(loggedIn ? "✅ Sí" : "❌ No")")
        print("Device token pendiente: \(hasToken ? "✅ Sí" : "❌ No")")
        print("SDK operacional: \(isOperational ? "✅ Sí" : "❌ No")")
        print("")
        
        guard loggedIn else {
            print("⏭️ [enablePush] Usuario NO loggeado, diferiendo hasta login")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return
        }
        
        guard let deviceToken = pendingDeviceToken else {
            print("⏭️ [enablePush] No hay device token pendiente")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return
        }
        
        guard isOperational else {
            print("❌ [enablePush] MarketingCloudSDK no está operacional")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return
        }
        
        // Si hay usuario loggeado Y device token, enviarlo
        print("🔄 [enablePush] Usuario YA loggeado, enviando device token pendiente...")
        
        // Verificar si ya hay un ContactKey seteado
        if let existingContactKey = SFMCSdk.mp.contactKey(), !existingContactKey.isEmpty {
            print("✅ [enablePush] ContactKey existente encontrado: \(existingContactKey)")
            SFMCSdk.mp.setDeviceToken(deviceToken)
            self.pendingDeviceToken = nil
            print("✅ [enablePush] Device token enviado con identidad existente")
            print("")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("✅ PUSH HABILITADO CON SESIÓN EXISTENTE")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("ContactKey: \(existingContactKey)")
            print("Device Token: Registrado ✅")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        } else {
            print("⚠️ [enablePush] No hay ContactKey seteado aún, esperando login completo")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }
}
