# 🔍 Guía de Búsqueda y Reemplazo - Firebase Logging

## 📋 Cambios a Realizar en el Proyecto

Para completar la integración de Firebase Logging, necesitas buscar y actualizar los siguientes patrones en todo el proyecto:

---

## 1️⃣ BUSCAR: `AppStatusManager.error(`

### **Ubicaciones probables:**
- Todas las vistas (Views)
- ViewModels
- Servicios de red
- Managers y coordinadores

### **Acción:**
Reemplazar por una de estas opciones:

#### **Opción A: Con contexto (Recomendado)**
```swift
// ANTES:
AppStatusManager.error(error)

// DESPUÉS:
AppStatusManager.errorWithContext(error, context: "NombreDeLaVista")
```

#### **Opción B: Sin contexto**
```swift
// ANTES:
AppStatusManager.error(error)

// DESPUÉS:
AppStatusManager.errorWithLogging(error)
```

### **Ejemplo completo:**
```swift
// ANTES:
case let .failure(error):
    AppStatusManager.error(error)

// DESPUÉS:
case let .failure(error):
    AppStatusManager.errorWithContext(error, context: "AppointmentsListView")
```

---

## 2️⃣ BUSCAR: Lugares con manejo de errores

### **Patrón a buscar:**
```swift
catch {
    // manejar error
}

catch let error {
    // manejar error
}

case let .failure(error):
    // manejar error
```

### **Acción:**
Agregar logging antes de mostrar el error al usuario:

```swift
catch let error {
    // ✅ AGREGAR ESTO:
    FirebaseLogger.shared.recordError(error, userInfo: ["context": "CurrentView"])
    
    // Tu código existente...
    showErrorAlert(error)
}
```

---

## 3️⃣ BUSCAR: Popups y Alerts de Error

### **Patrones a buscar:**
```swift
.alert(
.sheet(
showErrorPopup
showAlert
presentAlert
```

### **Acción:**
Agregar logging cuando se muestre el popup:

```swift
// ANTES:
self.showErrorPopup = true

// DESPUÉS:
FirebaseLogger.shared.logErrorPopup(
    title: "Título del popup",
    message: "Mensaje del error",
    source: "NombreDeLaVista"
)
self.showErrorPopup = true
```

---

## 4️⃣ BUSCAR: Autenticación y Login

### **Patrones a buscar:**
```swift
signIn
login
logout
authenticate
checkCredentials
```

### **En Login Exitoso:**
```swift
// Después de login exitoso:
FirebaseLogger.shared.setUserID(user.id)
FirebaseLogger.shared.setUserInfo(
    name: user.name,
    email: user.email,
    enterprise: user.enterprise
)
FirebaseLogger.shared.logAuthEvent(action: "login", success: true)
```

### **En Logout:**
```swift
// Al hacer logout:
FirebaseLogger.shared.logAuthEvent(action: "logout", success: true)
FirebaseLogger.shared.setUserID(nil)
```

### **En Error de Login:**
```swift
catch let error {
    FirebaseLogger.shared.logAuthEvent(action: "login", success: false, error: error)
    // Tu manejo de error...
}
```

---

## 5️⃣ BUSCAR: Creación/Modificación de Citas

### **Patrones a buscar:**
```swift
createAppointment
cancelAppointment
rescheduleAppointment
updateAppointment
```

### **Acción:**
```swift
// Al crear cita exitosamente:
FirebaseLogger.shared.logEvent("appointment_created", attributes: [
    "clinic_id": clinicId,
    "professional_id": professionalId
])

// Al fallar:
catch let error {
    FirebaseLogger.shared.logAppointmentError(
        action: "create",
        appointmentId: appointmentId,
        error: error
    )
}
```

---

## 6️⃣ BUSCAR: Permisos (Camera, Microphone, Notifications)

### **Patrones a buscar:**
```swift
AVCaptureDevice.requestAccess
UNUserNotificationCenter.requestAuthorization
requestPermission
checkPermission
```

### **Acción:**
```swift
// Cuando pides permiso de cámara:
AVCaptureDevice.requestAccess(for: .video) { granted in
    let status = granted ? "granted" : "denied"
    FirebaseLogger.shared.logPermissionIssue(
        permission: "camera",
        status: status
    )
}

// Cuando pides permiso de micrófono:
AVCaptureDevice.requestAccess(for: .audio) { granted in
    let status = granted ? "granted" : "denied"
    FirebaseLogger.shared.logPermissionIssue(
        permission: "microphone",
        status: status
    )
}
```

---

## 7️⃣ BUSCAR: Navegación entre vistas

### **Patrones a buscar:**
```swift
.onAppear
.task
navigationDestination
NavigationLink
```

### **Acción (Opcional pero útil):**
```swift
.onAppear {
    FirebaseLogger.shared.logNavigation(from: "PreviousView", to: "CurrentView")
    FirebaseLogger.shared.setCustomValue("CurrentView", forKey: "current_screen")
    
    // Tu código existente...
}
```

---

## 8️⃣ BUSCAR: Llamadas a servicios de red

### **Patrones a buscar:**
```swift
Network.shared
await Network
networkService
apiClient
```

### **En cada llamada importante:**
```swift
let result = await Network.shared.getAppointments()
switch result {
case .success(let data):
    FirebaseLogger.shared.log("✅ Appointments loaded successfully")
    
case let .failure(error):
    FirebaseLogger.shared.recordNetworkError(
        error,
        endpoint: "/api/appointments",
        httpCode: error.httpCode,
        method: "GET"
    )
}
```

---

## 9️⃣ BUSCAR: Errores de cámara y video

### **Ubicaciones:**
- CameraManager
- VideoCallViewModel
- Cualquier uso de AVFoundation

### **Acción:**
```swift
catch let error {
    FirebaseLogger.shared.logCameraError(
        action: "start_capture",
        error: error
    )
}
```

---

## 🔟 BUSCAR: Estados de la app

### **En AppDelegate o App:**
```swift
func applicationDidEnterBackground() {
    FirebaseLogger.shared.logAppLifecycle("app_background")
}

func applicationWillEnterForeground() {
    FirebaseLogger.shared.logAppLifecycle("app_foreground")
}

func applicationWillTerminate() {
    FirebaseLogger.shared.logAppLifecycle("app_terminate")
}
```

---

## ✅ Checklist de Búsqueda

Usa esta lista para ir marcando lo que ya revisaste:

### **Archivos Críticos (Alta prioridad):**
- [ ] Todos los archivos con `AppStatusManager.error`
- [ ] Archivos de autenticación (SignIn, Login, SignUp)
- [ ] Archivos de citas (Appointments)
- [ ] Archivos de videollamada (VideoCall, Clinic)
- [ ] Network service / API client
- [ ] AppDelegate / App

### **Archivos Importantes (Media prioridad):**
- [ ] ViewModels principales
- [ ] Managers (UserManager, SessionManager, etc)
- [ ] Servicios de negocio
- [ ] Vistas con formularios

### **Archivos Opcionales (Baja prioridad):**
- [ ] Vistas de detalle
- [ ] Componentes reutilizables
- [ ] Helpers y utilidades

---

## 🛠️ Herramientas de Búsqueda

### **En Xcode:**

1. **Find in Workspace:**
   - `Cmd + Shift + F`
   - Buscar: `AppStatusManager.error`
   - Find in: Workspace
   - Matching: Contains

2. **Find and Replace:**
   - `Cmd + Shift + F`
   - Find: `AppStatusManager.error(error)`
   - Replace: `AppStatusManager.errorWithLogging(error)`
   - Preview antes de reemplazar

3. **Buscar patrones:**
   ```
   AppStatusManager.error
   case let .failure(error):
   catch {
   catch let error {
   .alert(
   showError
   showPopup
   requestAccess
   ```

---

## 📊 Estadísticas Estimadas

Basado en una app típica de este tamaño, deberías encontrar aproximadamente:

- **AppStatusManager.error:** ~20-30 ocurrencias
- **Manejo de errores (catch, .failure):** ~50-100 ocurrencias
- **Popups/Alerts de error:** ~10-20 ocurrencias
- **Llamadas de autenticación:** ~5-10 ocurrencias
- **Permisos:** ~3-5 ocurrencias

**Tiempo estimado de actualización:** 2-4 horas

---

## 🎯 Estrategia Recomendada

### **Fase 1: Rápido y Efectivo (30 minutos)**
1. Buscar y reemplazar TODOS los `AppStatusManager.error(error)` por `AppStatusManager.errorWithLogging(error)`
2. Listo, ya tienes el 80% de cobertura

### **Fase 2: Mejorar Contexto (1-2 horas)**
1. Revisar cada `errorWithLogging` agregado
2. Cambiar a `errorWithContext(error, context: "ViewName")` donde sea relevante
3. Agregar contexto útil

### **Fase 3: Logging de Usuario (30 minutos)**
1. Agregar `setUserID()` después del login
2. Agregar `logAuthEvent()` en login/logout
3. Agregar `setUserInfo()` con nombre/email

### **Fase 4: Eventos Importantes (1 hora)**
1. Agregar logging en creación de citas
2. Agregar logging de permisos
3. Agregar popups importantes

### **Fase 5: Opcional (1-2 horas)**
1. Agregar navegación tracking
2. Agregar eventos de negocio
3. Agregar custom values útiles

---

## 🚀 Comando de Terminal (Opcional)

Si quieres ver un resumen rápido de dónde buscar:

```bash
# Buscar AppStatusManager.error en todo el proyecto
find . -name "*.swift" -exec grep -l "AppStatusManager.error" {} \;

# Contar ocurrencias
find . -name "*.swift" -exec grep -c "AppStatusManager.error" {} \; | grep -v ":0"

# Buscar patrones de manejo de errores
find . -name "*.swift" -exec grep -l "case let .failure" {} \;
```

---

## 💡 Tips Finales

1. **No te obsesiones con el 100%:** Empieza con los lugares críticos (videollamada, autenticación, citas)

2. **Usa contextos descriptivos:** En lugar de "View1", usa "VideoCallConnectionView"

3. **No logs información sensible:** Nunca passwords, tokens completos, o datos médicos

4. **Prueba en Firebase Console:** Después de cada cambio importante, verifica que los logs lleguen

5. **Usa commits pequeños:** Agrupa cambios por tipo (ej: "Add Firebase logging to video call flow")

---

## ❓ Preguntas Frecuentes

**P: ¿Debo reemplazar TODOS los AppStatusManager.error?**  
R: Idealmente sí, pero empieza con los más críticos (videollamada, login, citas).

**P: ¿Qué pasa si ya hay mucho código y no quiero cambiar todo?**  
R: Puedes modificar el método original `AppStatusManager.error()` para que llame a Firebase automáticamente.

**P: ¿Los logs consumen muchos datos?**  
R: No, Firebase optimiza el envío y agrupa los logs. Solo se envían cuando hay conexión.

**P: ¿Puedo ver los logs en tiempo real?**  
R: Sí, en Firebase Console > Crashlytics verás los eventos casi en tiempo real.

**P: ¿Qué pasa si un error no es crítico?**  
R: Igual regístralo. Firebase te permite filtrar por severidad después.

---

**Última actualización:** 25 de Febrero de 2026  
**Autor:** AI Assistant  
**Status:** ✅ Listo para usar
