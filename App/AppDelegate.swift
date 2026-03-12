import UIKit
import UserNotifications
import Firebase
import FirebaseCrashlytics
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
        let pushConfig = PushConfigBuilder(appId: "b904dc0c-5956-4e29-a65a-5f5f6837ad51")
            .setAccessToken("hJ5KtZU8CbXDsvRLWz6dfpfa")
            .setMarketingCloudServerUrl(
                URL(string: "https://mcmjn-1pfbl2yn2rlf5886l2-651.device.marketingcloudapis.com")!
            )
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
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in

            print("🔔 Push permission granted:", granted)

            if let error = error {
                print("❌ Push permission error:", error)
            }

            // 🧪 VER ESTADO REAL DEL SISTEMA
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("🧪 Notification authorization status:", settings.authorizationStatus.rawValue)
                // 0 = notDetermined
                // 1 = denied
                // 2 = authorized  ✅
            }

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    print("📲 registerForRemoteNotifications() called")
                }
            }
        }

        return true
    }

    // MARK: - APNs Token (ESTO ES LO QUE CAMBIA A OPTED IN)
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("📲 APNs device token received")
        print("🧪 Device token length:", deviceToken.count)
        
        // 📝 Log a Firebase (temporalmente comentado)
        // FirebaseLogger.shared.log("📲 APNs device token registered successfully")

        // 🔥 CRÍTICO PARA PASAR A OPTED IN
        SFMCSdk.mp.setDeviceToken(deviceToken)
        print("✅ Device token sent to SFMC → SHOULD BE OPTED IN")
        // FirebaseLogger.shared.log("✅ Device token sent to SFMC")

        // Firebase (opcional)
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
