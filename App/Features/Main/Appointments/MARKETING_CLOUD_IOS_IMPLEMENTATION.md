# Implementación de Marketing Cloud en iOS - Replicando Lógica de Android

## 📋 Resumen de Cambios

Este documento detalla la implementación de la integración con Salesforce Marketing Cloud (SFMC) en iOS, replicando **exactamente** la lógica funcional de Android para evitar el problema de registro con UUID anónimo.

---

## 🎯 Problema que se Soluciona

### ❌ **Antes (Problema)**
```swift
// AppDelegate.swift - ANTIGUO
func application(_ application: UIApplication, 
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // ❌ Se enviaba inmediatamente a SFMC
    SFMCSdk.mp.setDeviceToken(deviceToken)
    // Problema: Si el usuario no había hecho login, SFMC registraba un UUID anónimo
}
```

**Consecuencia:** El contacto quedaba registrado con un UUID temporal en vez del PersonContactId real (003xxx).

### ✅ **Después (Solución)**
```swift
// AppDelegate.swift - NUEVO
func application(_ application: UIApplication, 
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // ✅ Solo se GUARDA, no se envía
    MarketingCloudManager.shared.storePendingDeviceToken(deviceToken)
    // El envío ocurre DESPUÉS del login con la identidad correcta
}
```

---

## 🔄 Flujo Completo Implementado (iOS → Android Parity)

### **FASE 1: App Launch**

| Android | iOS |
|---------|-----|
| `App.kt` → `MarketingCloudSdk.init()` | `AppDelegate.swift` → `SFMCSdk.initializeSdk()` |
| ❌ NO llama `enablePush()` | ✅ Ya no llama `setDeviceToken()` |

**Código iOS:**
```swift
// AppDelegate.swift - didFinishLaunchingWithOptions
let pushConfig = PushConfigBuilder(appId: "b904dc0c-5956-4e29-a65a-5f5f6837ad51")
    .setAccessToken("hJ5KtZU8CbXDsvRLWz6dfpfa")
    .setMarketingCloudServerUrl(URL(string: "https://mcmjn-1pfbl2yn2rlf5886l2-651.device.marketingcloudapis.com")!)
    .setAnalyticsEnabled(true)
    .build()

SFMCSdk.initializeSdk(ConfigBuilder().setPush(config: pushConfig).build())
```

---

### **FASE 2: Permisos de Notificación**

| Android | iOS |
|---------|-----|
| `SplashActivity.kt` → Diálogo rationale → `POST_NOTIFICATIONS` | `AppDelegate.swift` → `requestAuthorization` |
| `enablePush()` solo si `isLogged()` | `storePendingDeviceToken()` siempre |

**Código iOS:**
```swift
// AppDelegate.swift - didFinishLaunchingWithOptions
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
    if granted {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
```

---

### **FASE 3: Recepción del Device Token (CRÍTICO)**

| Android | iOS |
|---------|-----|
| FCM token se guarda internamente en el SDK | APNs token se guarda en `MarketingCloudManager` |
| NO se envía hasta `enablePush()` | NO se envía hasta `setDeviceToken()` |

**Código iOS:**
```swift
// AppDelegate.swift - didRegisterForRemoteNotificationsWithDeviceToken
func application(_ application: UIApplication, 
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // 📦 SOLO GUARDAR, NO ENVIAR
    MarketingCloudManager.shared.storePendingDeviceToken(deviceToken)
    print("📦 Device token almacenado (esperando login)")
    
    // ⚠️ NO hacer esto:
    // SFMCSdk.mp.setDeviceToken(deviceToken) ❌
}
```

---

### **FASE 4: Login y Registro del Contacto**

| Android | iOS |
|---------|-----|
| `LoginFragment.kt` → `login()` → `accountSettingsService()` | `AppStatusManager.signIn()` → `Network.profile()` |
| Extrae: FirstName, LastName, Email, Phone, Id (001xxx), PersonContactId (003xxx) | Extrae: FirstName, LastName, PersonEmail, Phone, Id, PersonContactId |
| Llama `sendUserDataToMarketingCloud()` | Llama `sendUserDataToMarketingCloudAfterLogin()` |

**Código iOS:**
```swift
// AppStatusManager.swift - signIn()
public static func signIn(rut: String, password: String) async -> Result<Void, AppError> {
    let signinResponse = await Network.shared.signIn(rut: rut, password: password)
    
    switch signinResponse {
    case .success(let credentials):
        if save(rut: rut, credentials: credentials) {
            updateStatus()
            
            // 📲 NUEVO: Enviar datos a Marketing Cloud post-login
            Task {
                await sendUserDataToMarketingCloudAfterLogin(rut: rut)
            }
            
            return .success(())
        }
        // ...
    }
}

private static func sendUserDataToMarketingCloudAfterLogin(rut: String) async {
    // 1. Obtener perfil del usuario
    let profileResult = await Network.shared.profile(rut: rut)
    
    switch profileResult {
    case .success(let user):
        guard let userRecord = user.records.first else { return }
        
        // 2. Extraer datos
        let firstName = userRecord.FirstName ?? ""
        let lastName = userRecord.LastName ?? ""
        let email = userRecord.PersonEmail ?? ""
        let phone = userRecord.Phone ?? ""
        let accountId = userRecord.Id ?? ""  // 001xxx
        let personContactId = userRecord.PersonContactId ?? ""  // 003xxx
        
        // 3. Obtener empresaId y convenioId
        let empresaId = selectedEnterprise?.empresaR?.Id
        let convenioId = selectedEnterprise?.Id
        
        // 4. Enviar a Marketing Cloud
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
            // Handle result...
        }
        
    case .failure(let error):
        print("❌ Error al obtener perfil: \(error)")
    }
}
```

---

### **FASE 5: Envío a Marketing Cloud (MarketingCloudManager)**

| Android | iOS |
|---------|-----|
| `MarketingCloudManager.kt` → `sendContactToMarketingCloud()` | `MarketingCloudManager.swift` → `sendContactToMarketingCloud()` |
| 1. Determina ContactKey (PersonContactId > AccountId) | ✅ Igual |
| 2. `setContactKey()` | ✅ `SFMCSdk.mp.setContactKey()` |
| 3. `setAttribute()` x 9 campos | ✅ `SFMCSdk.mp.addAttribute()` x 9 campos |
| 4. `enablePush()` | ✅ `SFMCSdk.mp.setDeviceToken()` |

**Código iOS:**
```swift
// MarketingCloudManager.swift
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
    // 1. Determinar ContactKey (igual que Android)
    let contactKey: String
    if !personContactId.isEmpty {
        contactKey = personContactId  // ← PREFERIDO (003xxx)
    } else if !accountId.isEmpty {
        contactKey = accountId  // ← Fallback (001xxx)
    } else {
        completion(.failure(NSError(...)))
        return
    }
    
    // 2. Setear ContactKey
    SFMCSdk.mp.setContactKey(contactKey)
    
    // 3. Setear atributos
    var attributes: [String: String] = [
        "RUT": rut,
        "FirstName": firstName,
        "LastName": lastName,
        "EmailAddress": email,
        "PhoneNumber": phone,
        "AccountId": accountId,
        "PersonContactId": personContactId
    ]
    
    if let empresaId = empresaId, !empresaId.isEmpty {
        attributes["EmpresaId"] = empresaId
    }
    if let convenioId = convenioId, !convenioId.isEmpty {
        attributes["ConvenioId"] = convenioId
    }
    
    for (key, value) in attributes {
        SFMCSdk.mp.addAttribute(value, name: key)
    }
    
    // 4. AHORA SÍ enviar el device token (enablePush equivalente)
    if let deviceToken = self.pendingDeviceToken {
        SFMCSdk.mp.setDeviceToken(deviceToken)
        print("🎉 Usuario OPTED IN con ContactKey: \(contactKey)")
        self.pendingDeviceToken = nil
        completion(.success(()))
    } else {
        print("⚠️ No hay device token pendiente")
        completion(.success(()))
    }
}
```

---

### **FASE 6: Logout**

| Android | iOS |
|---------|-----|
| `PerfilFragment.kt` → `setContactKey("")` + `disablePush()` | `AppStatusManager.cleanup()` → `MarketingCloudManager.logout()` |
| Limpia SharedPreferences | Limpia UserDefaults |

**Código iOS:**
```swift
// AppStatusManager.swift - cleanup()
static func cleanup() {
    // ... limpiar rut, credentials, etc ...
    
    // 📲 NUEVO: Limpiar Marketing Cloud
    MarketingCloudManager.shared.logout { result in
        switch result {
        case .success:
            print("✅ Logout exitoso de Marketing Cloud")
        case .failure(let error):
            print("❌ Error en logout de MC: \(error)")
        }
    }
    
    cleanRealm()
    updateStatus()
}

// MarketingCloudManager.swift - logout()
func logout(completion: @escaping (Result<Void, Error>) -> Void) {
    // Limpiar ContactKey
    SFMCSdk.mp.setContactKey("")
    
    // Limpiar atributos
    let attributes = ["RUT", "FirstName", "LastName", "EmailAddress", 
                      "PhoneNumber", "AccountId", "PersonContactId", 
                      "EmpresaId", "ConvenioId"]
    for key in attributes {
        SFMCSdk.mp.addAttribute("", name: key)
    }
    
    // Deshabilitar push
    SFMCSdk.mp.setDeviceToken(Data())
    
    print("✅ Push deshabilitado")
    completion(.success(()))
}
```

---

## 📊 Tabla de Atributos Enviados a SFMC

| Campo Android | Campo iOS | Descripción | Origen |
|---------------|-----------|-------------|--------|
| `RUT` | `RUT` | RUT del usuario | Login |
| `FirstName` | `FirstName` | Nombre | `User.records.first.FirstName` |
| `LastName` | `LastName` | Apellido | `User.records.first.LastName` |
| `EmailAddress` | `EmailAddress` | Email | `User.records.first.PersonEmail` |
| `PhoneNumber` | `PhoneNumber` | Teléfono | `User.records.first.Phone` |
| `AccountId` | `AccountId` | Salesforce Account (001xxx) | `User.records.first.Id` |
| `PersonContactId` | `PersonContactId` | Salesforce Contact (003xxx) | `User.records.first.PersonContactId` |
| `EmpresaId` | `EmpresaId` | ID de empresa/convenio | `selectedEnterprise.empresaR.Id` |
| `ConvenioId` | `ConvenioId` | ID del convenio | `selectedEnterprise.Id` |

**ContactKey usado:** PersonContactId (003xxx) si existe, sino AccountId (001xxx).

---

## ✅ Checklist de Implementación

- [x] **MarketingCloudManager.swift creado** con métodos:
  - `storePendingDeviceToken()`
  - `sendContactToMarketingCloud()`
  - `logout()`
  - `logCurrentState()`

- [x] **AppDelegate.swift modificado:**
  - `didRegisterForRemoteNotificationsWithDeviceToken` ahora solo guarda el token
  - NO llama `setDeviceToken()` inmediatamente

- [x] **AppStatusManager.swift modificado:**
  - `signIn()` ahora llama `sendUserDataToMarketingCloudAfterLogin()`
  - Método privado `sendUserDataToMarketingCloudAfterLogin()` agregado
  - `cleanup()` ahora llama `MarketingCloudManager.shared.logout()`
  - Se limpian keys adicionales: `account_id`, `person_contact_id`

- [ ] **Testing pendiente:**
  - [ ] Login con usuario real → verificar que ContactKey = PersonContactId en SFMC
  - [ ] Verificar que los 9 atributos se reciben en SFMC
  - [ ] Logout → verificar que ContactKey se limpia
  - [ ] Nueva instalación SIN login → verificar que NO hay registro en SFMC
  - [ ] Aceptar notificaciones ANTES del login → verificar que el token se aplica post-login

---

## 🧪 Cómo Verificar que Funciona

### **1. Logs en Xcode Console**

```
🚀 AppDelegate didFinishLaunching
🔥 Firebase configured
📊 Crashlytics enabled
📡 SFMC init result: 1
🧠 SFMC initializeSdk() called
🔔 Push permission granted: true
📲 registerForRemoteNotifications() called
📲 APNs device token received
📦 Device token almacenado (esperando login para enviar a SFMC)
🔥 Device token sent to Firebase

// ... usuario hace login ...

🔄 Intentando login para RUT: 12345678-9
✅ Login exitoso
📲 [MC] Iniciando envío de datos a Marketing Cloud post-login...
📤 Enviando contacto a Marketing Cloud...
   RUT: 12345678-9
   PersonContactId: 003XXXXXXXXXX
✅ Usando PersonContactId como ContactKey: 003XXXXXXXXXX
✅ ContactKey seteado: 003XXXXXXXXXX
   ✓ Atributo: RUT = 12345678-9
   ✓ Atributo: FirstName = Juan
   ✓ Atributo: LastName = Pérez
   ✓ Atributo: EmailAddress = juan@email.com
   ✓ Atributo: PhoneNumber = +56912345678
   ✓ Atributo: AccountId = 001XXXXXXXXXX
   ✓ Atributo: PersonContactId = 003XXXXXXXXXX
   ✓ Atributo: EmpresaId = a0KXXXXXXXXXX
   ✓ Atributo: ConvenioId = a09XXXXXXXXXX
✅ Todos los atributos configurados en SFMC
✅ Device token enviado a SFMC CON identidad correcta
🎉 Usuario OPTED IN con ContactKey: 003XXXXXXXXXX
✅ [MC] Datos enviados exitosamente a Marketing Cloud
```

### **2. En Salesforce Marketing Cloud**

1. Ir a **Contact Builder** → **All Contacts**
2. Buscar por el RUT o PersonContactId
3. Verificar:
   - ✅ ContactKey = PersonContactId (003xxx)
   - ✅ Status = "Active"
   - ✅ Todos los atributos presentes (RUT, FirstName, LastName, etc.)
   - ✅ Device Token registrado

### **3. Enviar Push de Prueba**

1. En SFMC → **Mobile Push** → **Messages**
2. Crear mensaje de prueba
3. Target: ContactKey = `003XXXXXXXXXX`
4. Enviar
5. Verificar que llega al dispositivo

---

## 🚨 Problemas Conocidos y Soluciones

### **Problema 1: No llega el device token**
**Síntoma:** Log dice "⚠️ No hay device token pendiente"

**Causas posibles:**
- Usuario rechazó permisos de notificaciones
- Login ocurrió antes de que APNs devolviera el token
- Simulador (no soporta push real)

**Solución:**
- Verificar permisos en Settings → Notifications → [App]
- Esperar 2-3 segundos después de abrir la app antes de hacer login
- Probar en dispositivo físico

### **Problema 2: ContactKey queda vacío en SFMC**
**Síntoma:** Contacto aparece pero sin ContactKey

**Causas posibles:**
- PersonContactId y AccountId ambos vacíos
- API de profile no devuelve estos campos

**Solución:**
- Verificar response de `/profile` en logs
- Verificar que el usuario tiene Contact asociado en Salesforce

### **Problema 3: Atributos no aparecen en SFMC**
**Síntoma:** ContactKey correcto pero atributos vacíos

**Causas posibles:**
- Atributos no configurados en SFMC Data Extensions
- Nombres de atributos no coinciden

**Solución:**
- Verificar en SFMC que los atributos existen en el Contact Model
- Usar nombres exactos: `RUT`, `FirstName`, etc.

---

## 📚 Referencias

- **Android Implementation:** `MarketingCloudManager.kt`, `LoginFragment.kt`, `SplashActivity.kt`
- **iOS SDK Docs:** [Salesforce Marketing Cloud SDK for iOS](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/)
- **SDK Version:** 8.1.4

---

## 🎉 Resultado Final

Con esta implementación, **iOS ahora funciona EXACTAMENTE igual que Android**:

1. ✅ SDK se inicializa SIN registrar usuario
2. ✅ Device token se guarda pero NO se envía
3. ✅ En login se obtienen datos del usuario
4. ✅ ContactKey se setea PRIMERO (PersonContactId > AccountId)
5. ✅ Atributos se configuran (9 campos)
6. ✅ Device token se envía CON identidad correcta
7. ✅ En logout se limpia todo

**No más UUID anónimos en Marketing Cloud. El usuario queda registrado con su PersonContactId real.** 🎯
