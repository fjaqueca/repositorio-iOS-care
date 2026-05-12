import UIKit
import UserNotifications
import Firebase
import FirebaseCrashlytics
import FirebaseMessaging
import SFMCSDK
import MarketingCloudSDK



class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - App Launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        print("🚀 AppDelegate didFinishLaunching")

        // 🔥 Firebase
        FirebaseApp.configure()
        print("🔥 Firebase configured")
        
        // 📊 Crashlytics - Habilitar captura automática de crashes
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        print("📊 Crashlytics enabled")
        
        // 📝 Inicializar FirebaseLogger (temporalmente comentado)
        // TODO: Agregar FirebaseLogger.swift al target de Xcode
        // FirebaseLogger.shared.logAppLifecycle("app_launch")
        // FirebaseLogger.shared.log("🚀 App launched successfully")

        // 📲 SFMC Push configuration (SDK 8.1.4)
        guard let mcURL = URL(string: "https://mcmjn-1pfbl2yn2rlf5886l2-651.device.marketingcloudapis.com") else {
            print("❌ Marketing Cloud URL is invalid, skipping SFMC configuration")
            return true
        }
        let pushConfig = PushConfigBuilder(appId: "b904dc0c-5956-4e29-a65a-5f5f6837ad51")
            .setAccessToken("hJ5KtZU8CbXDsvRLWz6dfpfa")
            .setMarketingCloudServerUrl(mcURL)
            .setAnalyticsEnabled(true)
            .build()

        let config = ConfigBuilder()
            .setPush(
                config: pushConfig,
                onCompletion: { result in
                    print("📡 SFMC init result:", result.rawValue)
                }
            )
            .build()

        // 🚀 Inicializar SDK
        SFMCSdk.initializeSdk(config)
        print("🧠 SFMC initializeSdk() called")

        // 🔔 Push permissions
        UNUserNotificationCenter.current().delegate = self
        
        // 🎯 IMPLEMENTAR LÓGICA DE ANDROID: initApp() de SplashActivity
        // En Android, se verifica si ya se concedió el permiso antes de solicitarlo
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("🧪 Estado actual de notificaciones: \(settings.authorizationStatus.rawValue)")
            // 0 = notDetermined, 1 = denied, 2 = authorized, 3 = provisional, 4 = ephemeral
            
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                // ✅ Ya tiene permisos concedidos (como Android: POST_NOTIFICATIONS ya concedido)
                print("✅ Permisos de notificación ya concedidos")
                
                // Registrar para remote notifications
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    print("📲 registerForRemoteNotifications() llamado (usuario con permisos)")
                }
                
                // enablePush() condicional (solo si ya está loggeado)
                // Equivalente a: enablePush() + navigateToApp() de Android
                MarketingCloudManager.shared.enablePushIfLoggedIn()
                
            case .notDetermined:
                // ⚠️ Primera vez, usuario no ha decidido
                // En Android: muestra showNotificationRationaleDialog() antes del sistema
                // En iOS: vamos directo al diálogo del sistema (o podemos mostrar un rationale)
                print("⚠️ Permisos de notificación no determinados, solicitando...")
                
                // OPCIÓN A: Solicitar directamente (actual)
                self.requestNotificationPermission()
                
                // OPCIÓN B: Mostrar diálogo rationale primero (comentado, implementar si se desea)
                // self.showNotificationRationaleDialog()
                
            case .denied:
                // ❌ Usuario rechazó permisos
                print("❌ Permisos de notificación denegados por el usuario")
                
                // En Android: igual llama enablePush() aunque esté denied
                // (porque puede estar loggeado y los atributos deben persistir)
                MarketingCloudManager.shared.enablePushIfLoggedIn()
                
            @unknown default:
                print("⚠️ Estado de notificaciones desconocido")
                self.requestNotificationPermission()
            }
        }

        return true
    }
    
    // MARK: - Request Notification Permission (lógica de Android)
    
    /// Solicita permisos de notificación y siempre llama enablePush() después (como Android)
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in

            print("🔔 Push permission granted:", granted)

            if let error = error {
                print("❌ Push permission error:", error)
                // 📝 Log error en Firebase
                FirebaseLogger.shared.recordError(error, userInfo: [
                    "context": "notification_permission_request",
                    "granted": "\(granted)"
                ])
            }

            // 🧪 VER ESTADO REAL DEL SISTEMA
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("🧪 Notification authorization status:", settings.authorizationStatus.rawValue)
                // 0 = notDetermined
                // 1 = denied
                // 2 = authorized  ✅
                
                // 📝 Log estado final en Firebase
                FirebaseLogger.shared.logPermissionIssue(
                    permission: "push_notifications",
                    status: granted ? "granted" : "denied"
                )
            }

            // 🎯 IMPORTANTE: Como Android, SIEMPRE registramos (independiente de granted)
            // El callback del permiso SIEMPRE llama enablePush() + navigateToApp()
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                print("📲 registerForRemoteNotifications() called")
            }
            
            // 🔒 SEGURIDAD: Agregar pequeño delay para evitar race conditions
            // Esto previene conflictos si el usuario toca el login inmediatamente
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
                // enablePush() condicional (solo si ya está loggeado)
                MarketingCloudManager.shared.enablePushIfLoggedIn()
            }
        }
    }
    
    // MARK: - Notification Rationale Dialog (opcional, igual que Android)
    
    /// Muestra un diálogo explicativo ANTES del permiso del sistema (como Android)
    /// Android: "Activar notificaciones" con mensaje de salud
    private func showNotificationRationaleDialog() {
        // Mostrar diálogo custom en SwiftUI
        // En Android, este diálogo tiene:
        // - Botón "Permitir" → lanza el diálogo del sistema
        // - Botón "Ahora no" → llama enablePush() de todas formas y continúa
        
        DispatchQueue.main.async {
            UIApplication.shared.showNotificationRationaleDialog(
                onAllow: {
                    // Usuario tocó "Permitir" → mostrar diálogo del sistema
                    print("✅ Usuario aceptó en diálogo rationale, mostrando diálogo del sistema...")
                    self.requestNotificationPermission()
                },
                onDismiss: {
                    // Usuario tocó "Ahora no" → continuar sin pedir permisos (como Android)
                    print("⏭️ Usuario rechazó en diálogo rationale, continuando sin permisos...")
                    
                    // Android: llama enablePush() de todas formas
                    MarketingCloudManager.shared.enablePushIfLoggedIn()
                }
            )
        }
    }

    // MARK: - APNs Token (DIFERIDO hasta después del login)
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("📲 APNs device token received")
        print("🧪 Device token length:", deviceToken.count)
        
        // 📝 Log a Firebase (temporalmente comentado)
        // FirebaseLogger.shared.log("📲 APNs device token registered successfully")

        // 🔥 CAMBIO CRÍTICO: NO enviamos el token inmediatamente a SFMC
        // Lo guardamos hasta que el usuario haga login (igual que Android)
        MarketingCloudManager.shared.storePendingDeviceToken(deviceToken)
        print("📦 Device token almacenado (esperando login para enviar a SFMC)")
        
        // ⚠️ IMPORTANTE: NO llamamos SFMCSdk.mp.setDeviceToken(deviceToken) aquí
        // Eso se hará en sendContactToMarketingCloud() después del login

        // Firebase (opcional) - esto sí se puede enviar inmediatamente
        Messaging.messaging().apnsToken = deviceToken
        print("🔥 Device token sent to Firebase")
        // FirebaseLogger.shared.log("🔥 Device token sent to Firebase Messaging")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications:", error)
        
        // 📝 Registrar error en Firebase (temporalmente comentado)
        // FirebaseLogger.shared.logPermissionIssue(
        //     permission: "remote_notifications",
        //     status: "registration_failed"
        // )
        // FirebaseLogger.shared.recordError(error, userInfo: [
        //     "error_type": "push_notification_registration_failed"
        // ])
    }

    // MARK: - Push Handling (Foreground)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📩 Push received in foreground")
        // FirebaseLogger.shared.log("📩 Push notification received in foreground")
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Push Open
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👉 Push opened by user")
        // FirebaseLogger.shared.log("👉 User opened push notification")
        completionHandler()
    }
}
