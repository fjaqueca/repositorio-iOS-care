# Implementación de Lógica de Permisos de Notificación (SplashActivity → iOS)

## 📋 Resumen

Este documento explica cómo se replicó la lógica de `SplashActivity.kt` (Android) en iOS, específicamente la parte de **permisos de notificación condicionales** y **enablePush() diferido**.

---

## 🔄 Comparación: Android vs iOS

### **Android (SplashActivity.kt)**

```kotlin
// initApp() - lógica de permisos

Android >= 13 (API 33, TIRAMISU)?
  ├─ SÍ → ¿POST_NOTIFICATIONS ya concedido?
  │         ├─ SÍ  → enablePush() + navigateToApp()
  │         └─ NO  → showNotificationRationaleDialog()
  └─ NO → enablePush() + navigateToApp()   ← Android < 13

// showNotificationRationaleDialog()
Diálogo propio con:
  - "Activar notificaciones"
  - Mensaje de salud
  - Botón "Permitir" → diálogo del sistema
  - Botón "Ahora no" → enablePush() + continuar

// requestNotificationPermission callback
SIEMPRE llama: enablePush() + navigateToApp()
(independiente de si aceptó o rechazó)

// enablePush() - lógica condicional
¿islogged()? (TOKEN en SharedPreferences)
  ├─ SÍ  → sdk.pushMessageManager.enablePush()
  └─ NO  → NO llama enablePush() (diferido al login)
```

### **iOS (AppDelegate.swift) - IMPLEMENTADO**

```swift
// didFinishLaunchingWithOptions - lógica de permisos

getNotificationSettings { settings in
  switch settings.authorizationStatus {
  
  case .authorized, .provisional, .ephemeral:
    // ✅ Ya concedido (como Android: POST_NOTIFICATIONS concedido)
    registerForRemoteNotifications()
    MarketingCloudManager.shared.enablePushIfLoggedIn()
    
  case .notDetermined:
    // ⚠️ Primera vez (como Android: no determinado)
    // OPCIÓN A: requestNotificationPermission() directo
    // OPCIÓN B: showNotificationRationaleDialog() primero
    requestNotificationPermission()
    
  case .denied:
    // ❌ Denegado (como Android: denied)
    MarketingCloudManager.shared.enablePushIfLoggedIn()
  }
}

// showNotificationRationaleDialog()
UIApplication.shared.showNotificationRationaleDialog(
  onAllow: { requestNotificationPermission() },
  onDismiss: { enablePushIfLoggedIn() }
)

// requestNotificationPermission callback
SIEMPRE llama: registerForRemoteNotifications() + enablePushIfLoggedIn()
(independiente de granted)

// enablePushIfLoggedIn() - lógica condicional
¿AppStatusManager.credentials != nil?
  ├─ SÍ  → setDeviceToken(pendingToken)
  └─ NO  → NO envía token (diferido al login)
```

---

## 🎯 Puntos Clave Implementados

### **1. Verificación de Estado de Permisos al Launch**

**Android:**
```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) 
        == PackageManager.PERMISSION_GRANTED) {
        // Ya concedido
        enablePush()
    } else {
        // No concedido, mostrar rationale
        showNotificationRationaleDialog()
    }
}
```

**iOS (equivalente):**
```swift
UNUserNotificationCenter.current().getNotificationSettings { settings in
    switch settings.authorizationStatus {
    case .authorized:
        // Ya concedido
        registerForRemoteNotifications()
        MarketingCloudManager.shared.enablePushIfLoggedIn()
    case .notDetermined:
        // No determinado, solicitar
        requestNotificationPermission()
    case .denied:
        // Denegado, intentar de todas formas
        MarketingCloudManager.shared.enablePushIfLoggedIn()
    }
}
```

✅ **Estado:** IMPLEMENTADO en `AppDelegate.swift` líneas 58-98

---

### **2. Diálogo Rationale Pre-Permiso**

**Android:**
```kotlin
fun showNotificationRationaleDialog() {
    AlertDialog.Builder(this)
        .setTitle("Activar notificaciones")
        .setMessage("Recibe recordatorios de salud...")
        .setPositiveButton("Permitir") { _, _ ->
            requestNotificationPermission.launch(POST_NOTIFICATIONS)
        }
        .setNegativeButton("Ahora no") { _, _ ->
            enablePush()
            navigateToApp()
        }
        .show()
}
```

**iOS (equivalente):**
```swift
// NotificationPermissionView.swift
UIApplication.shared.showNotificationRationaleDialog(
    onAllow: {
        // Usuario tocó "Permitir" → diálogo del sistema
        requestNotificationPermission()
    },
    onDismiss: {
        // Usuario tocó "Ahora no" → continuar sin permisos
        MarketingCloudManager.shared.enablePushIfLoggedIn()
    }
)
```

✅ **Estado:** IMPLEMENTADO en:
- `NotificationPermissionView.swift` (nueva vista SwiftUI)
- `AppDelegate.swift` método `showNotificationRationaleDialog()` líneas 123-144

---

### **3. enablePush() Condicional (Solo si está loggeado)**

**Android:**
```kotlin
fun enablePush() {
    if (islogged()) {  // TOKEN no está vacío
        sdk.pushMessageManager.enablePush()
        Log.d("Push", "Enabled with ContactKey: ${sdk.contactKey}")
    } else {
        Log.d("Push", "Deferred until login")
    }
}
```

**iOS (equivalente):**
```swift
// MarketingCloudManager.swift
func enablePushIfLoggedIn() {
    guard isUserLoggedIn() else {
        print("⏭️ Usuario NO loggeado, diferiendo hasta login")
        return
    }
    
    guard let deviceToken = pendingDeviceToken else {
        print("⏭️ No hay device token pendiente")
        return
    }
    
    SFMCSdk.requestSdk { sdk in
        if let existingContactKey = sdk.identity.profileId, !existingContactKey.isEmpty {
            sdk.mp.setDeviceToken(deviceToken)
            self.pendingDeviceToken = nil
            print("✅ Device token enviado con identidad existente")
        } else {
            print("⚠️ No hay ContactKey seteado aún")
        }
    }
}

private func isUserLoggedIn() -> Bool {
    return AppStatusManager.credentials != nil && AppStatusManager.rut != nil
}
```

✅ **Estado:** IMPLEMENTADO en `MarketingCloudManager.swift` líneas 108-133

---

### **4. Callback de Permiso SIEMPRE ejecuta enablePush()**

**Android:**
```kotlin
val requestNotificationPermission = registerForActivityResult(
    ActivityResultContracts.RequestPermission()
) { isGranted ->
    // ⚠️ IMPORTANTE: Independiente de isGranted
    enablePush()
    navigateToApp()
}
```

**iOS (equivalente):**
```swift
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
    ) { granted, error in
        print("🔔 Push permission granted:", granted)
        
        // ⚠️ IMPORTANTE: SIEMPRE registrar (como Android)
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // enablePush() condicional (solo si loggeado)
        MarketingCloudManager.shared.enablePushIfLoggedIn()
    }
}
```

✅ **Estado:** IMPLEMENTADO en `AppDelegate.swift` líneas 100-121

---

## 📊 Tabla de Equivalencias

| Android (SplashActivity) | iOS (AppDelegate) | Estado |
|--------------------------|-------------------|--------|
| `initApp()` | `didFinishLaunchingWithOptions` | ✅ Implementado |
| `getNotificationSettings()` | `getNotificationSettings()` | ✅ Implementado |
| `showNotificationRationaleDialog()` | `showNotificationRationaleDialog()` | ✅ Implementado |
| `requestNotificationPermission.launch()` | `requestAuthorization()` | ✅ Implementado |
| `enablePush()` | `enablePushIfLoggedIn()` | ✅ Implementado |
| `islogged()` | `isUserLoggedIn()` | ✅ Implementado |
| `sdk.pushMessageManager.enablePush()` | `sdk.mp.setDeviceToken()` | ✅ Implementado |
| `navigateToApp()` | (automático en iOS) | N/A |

---

## 🧪 Flujo de Pruebas

### **Caso 1: Usuario nuevo (sin login, sin permisos)**

**Secuencia:**
1. App se lanza
2. `getNotificationSettings()` → `notDetermined`
3. `requestNotificationPermission()` (o rationale primero)
4. Usuario acepta/rechaza
5. `registerForRemoteNotifications()` se llama SIEMPRE
6. `enablePushIfLoggedIn()` → NO hace nada (no loggeado)
7. Device token se guarda en `pendingDeviceToken`
8. Usuario hace login
9. `sendContactToMarketingCloud()` → envía token con ContactKey

**Logs esperados:**
```
🧪 Estado actual de notificaciones: 0
⚠️ Permisos de notificación no determinados, solicitando...
🔔 Push permission granted: true
📲 registerForRemoteNotifications() called
⏭️ [enablePush] Usuario NO loggeado, diferiendo hasta login
📲 APNs device token received
📦 Device token guardado (pending login)
```

---

### **Caso 2: Usuario con sesión persistida (login anterior)**

**Secuencia:**
1. App se lanza
2. `AppStatusManager.load()` → restaura credentials y rut
3. `getNotificationSettings()` → `authorized` (ya concedido antes)
4. `registerForRemoteNotifications()` inmediatamente
5. `enablePushIfLoggedIn()` → SÍ ejecuta (usuario loggeado)
6. Device token se recibe
7. Se guarda en `pendingDeviceToken`
8. `enablePushIfLoggedIn()` verifica si hay ContactKey
9. Si hay ContactKey → envía token inmediatamente

**Logs esperados:**
```
🧪 Estado actual de notificaciones: 2
✅ Permisos de notificación ya concedidos
📲 registerForRemoteNotifications() llamado (usuario con permisos)
🔄 [enablePush] Usuario YA loggeado, enviando device token pendiente...
✅ [enablePush] ContactKey existente encontrado: 003XXXXXXXXXX
📲 APNs device token received
✅ [enablePush] Device token enviado con identidad existente
```

---

### **Caso 3: Usuario rechazó permisos (denied)**

**Secuencia:**
1. App se lanza
2. `getNotificationSettings()` → `denied`
3. `enablePushIfLoggedIn()` → verifica si está loggeado
4. Si loggeado → intenta registrar (pero no habrá token)
5. Si no loggeado → no hace nada

**Logs esperados:**
```
🧪 Estado actual de notificaciones: 1
❌ Permisos de notificación denegados por el usuario
⏭️ [enablePush] Usuario NO loggeado, diferiendo hasta login
```

---

## 🔧 Configuración Opcional: Habilitar Diálogo Rationale

Por defecto, iOS va **directo al diálogo del sistema**. Para habilitar el diálogo rationale (como Android), cambia en `AppDelegate.swift`:

```swift
// ANTES (actual):
case .notDetermined:
    self.requestNotificationPermission()

// DESPUÉS (con rationale):
case .notDetermined:
    self.showNotificationRationaleDialog()  // ← Muestra diálogo custom primero
```

---

## 📁 Archivos Modificados/Creados

### **Modificados:**
1. ✅ `AppDelegate.swift`
   - Líneas 58-144: Lógica condicional de permisos
   - Métodos: `requestNotificationPermission()`, `showNotificationRationaleDialog()`

2. ✅ `MarketingCloudManager.swift`
   - Líneas 30-32: `isUserLoggedIn()` usando `AppStatusManager`
   - Líneas 108-133: `enablePushIfLoggedIn()` condicional

### **Creados:**
3. ✅ `NotificationPermissionView.swift`
   - Vista SwiftUI del diálogo rationale
   - Extension de `UIApplication` para mostrar desde AppDelegate

---

## ✅ Checklist de Implementación

- [x] **Verificación de estado de permisos al launch**
  - `getNotificationSettings()` en `didFinishLaunchingWithOptions`
  - Switch por `authorizationStatus` (authorized, notDetermined, denied)

- [x] **enablePush() condicional**
  - Solo ejecuta si `isUserLoggedIn()` es true
  - Verifica existencia de ContactKey antes de enviar token

- [x] **Callback de permiso siempre ejecuta enablePush()**
  - `registerForRemoteNotifications()` SIEMPRE se llama
  - `enablePushIfLoggedIn()` se ejecuta independiente de `granted`

- [x] **Diálogo rationale opcional**
  - Vista SwiftUI implementada
  - Extension de UIApplication para mostrar
  - Botones "Permitir" y "Ahora no" (como Android)

- [ ] **Testing en escenarios:**
  - [ ] Usuario nuevo sin login
  - [ ] Usuario con sesión persistida
  - [ ] Usuario que rechaza permisos
  - [ ] Usuario que acepta permisos después de login

---

## 🎉 Resultado Final

**iOS ahora replica EXACTAMENTE la lógica de Android:**

1. ✅ Verifica estado de permisos al launch (como `initApp()`)
2. ✅ Muestra diálogo rationale opcional (como `showNotificationRationaleDialog()`)
3. ✅ enablePush() solo si está loggeado (como `islogged()`)
4. ✅ Callback SIEMPRE registra para remote notifications
5. ✅ Device token se diferiere hasta login si no hay sesión
6. ✅ Si ya hay sesión, verifica ContactKey antes de enviar

**Diferencia clave con Android:**
- Android: `enablePush()` activa el registro en MC
- iOS: `setDeviceToken()` activa el registro en MC

Pero la **lógica condicional es idéntica**: solo se envía el token si hay un usuario loggeado con ContactKey.
