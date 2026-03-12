# 🚀 GUÍA RÁPIDA: Compilar y Verificar Firebase Logging

## ⚡ PASO 1: COMPILAR EL PROYECTO

### **En Xcode:**

1. **Abrir el proyecto**
   ```
   - Abre CareAssistance.xcodeproj o .xcworkspace
   ```

2. **Limpiar build (opcional pero recomendado)**
   ```
   ⌘ + Shift + K (Product → Clean Build Folder)
   ```

3. **Compilar**
   ```
   ⌘ + B (Product → Build)
   ```

4. **Verificar que compile sin errores** ✅
   ```
   Build Succeeded ✅
   ```

### **Posibles errores y soluciones:**

#### ❌ Error: "Cannot find 'FirebaseLogger' in scope"
**Causa:** El archivo `FirebaseLogger.swift` no está en el target de compilación.

**Solución:**
1. Selecciona `FirebaseLogger.swift` en el Project Navigator
2. Abre File Inspector (⌘+⌥+1)
3. Marca `✅ CareAssistance` en **Target Membership**

---

#### ❌ Error: "Module 'FirebaseCrashlytics' not found"
**Causa:** Firebase no está instalado o no está en las dependencias.

**Solución:**

**Si usas CocoaPods:**
```bash
cd /path/to/CareAssistance
pod install
```

**Si usas Swift Package Manager:**
1. Ve a **File → Add Package Dependencies**
2. Busca: `https://github.com/firebase/firebase-ios-sdk`
3. Agrega `FirebaseCrashlytics`

---

## ⚡ PASO 2: EJECUTAR EN SIMULADOR/DISPOSITIVO

### **Ejecutar:**
```
⌘ + R (Product → Run)
```

### **Verificar logs en consola:**

Deberías ver logs como:
```
🔄 Cargando profesionales para clínica: Clínica Central
✅ Profesionales cargados: 5
📅 Iniciando creación de cita
✅ Cita creada exitosamente
```

---

## ⚡ PASO 3: TESTEAR FLUJOS CRÍTICOS

### **Test 1: Error de Red** 🌐

1. **Desconecta WiFi/datos** en el simulador/dispositivo
2. **Intenta crear una cita** o cargar datos
3. **Verifica que aparezca el popup de error**

**Resultado esperado:**
- ✅ Popup de error visible
- ✅ En consola: `❌ Error al cargar profesionales: Network timeout`
- ✅ Log enviado a Firebase con endpoint y método

---

### **Test 2: Validación de Cita Duplicada** 📅

1. **Agenda una cita**
2. **Intenta agendar otra cita en la misma clínica** (sin cancelar la primera)
3. **Verifica el popup de "Ya tiene una cita en esta clínica"**

**Resultado esperado:**
- ✅ Popup visible
- ✅ En consola: `⚠️ Validación fallida: Cita duplicada en clínica - [Nombre]`
- ✅ Log enviado a Firebase con contexto

---

### **Test 3: Subir Examen** 📄

1. **Ve a la sección de exámenes**
2. **Sube uno o varios archivos**
3. **Envía el examen**

**Resultado esperado:**
- ✅ En consola: `🔄 Iniciando subida de X archivo(s) a S3`
- ✅ En consola: `✅ Archivo 1 subido a S3`
- ✅ En consola: `📊 Subida completada - Éxito: X, Fallos: Y`
- ✅ Logs enviados a Firebase

---

### **Test 4: Login/Logout** 🔑

1. **Cierra sesión** (si estás logueado)
2. **Intenta login con credenciales incorrectas**
3. **Verifica el mensaje de error**
4. **Login con credenciales correctas**

**Resultado esperado:**
- ✅ En consola login fallido: `❌ Login fallido: Invalid credentials`
- ✅ En consola login exitoso: `✅ Login exitoso`
- ✅ Logs enviados a Firebase

---

## ⚡ PASO 4: VERIFICAR EN FIREBASE CONSOLE

### **1. Acceder a Firebase Console:**
```
https://console.firebase.google.com
```

### **2. Seleccionar proyecto:**
```
CareAssistance
```

### **3. Ir a Crashlytics:**
```
Menú lateral → Crashlytics
```

### **4. Ver errores:**
```
Crashlytics → Issues
```

**Deberías ver:**
- ✅ Lista de errores recientes
- ✅ Cantidad de usuarios afectados
- ✅ Contexto de cada error

---

### **5. Ver detalles de un error:**

Click en cualquier error para ver:

```
📊 Error Details:

Error Type: UIErrorPopup / NetworkError / etc
Users Affected: X usuarios
Occurrences: Y veces

Custom Keys:
- user_id: 12345678-9
- empresa: Clínica Vida
- clinic_id: clinic_001
- clinic_name: Clínica Central
- endpoint: /api/appointments
- http_code: 500
- error_context: create_appointment

Breadcrumbs (últimos logs antes del error):
[10:25] Selected professional: Dr. Juan Pérez
[10:28] Selected date: 2026-03-01
[10:30] ❌ Error: Internal Server Error
```

---

## ⚡ PASO 5: FORZAR ERRORES PARA TESTING

### **Opción 1: Modo Avión**
```
1. Activa Modo Avión
2. Intenta cualquier operación de red
3. Verifica error en Firebase
```

### **Opción 2: Código de prueba temporal**
```swift
// En cualquier vista, añade temporalmente:
Button("Test Firebase Error") {
    let error = NSError(
        domain: "TestError",
        code: 999,
        userInfo: [NSLocalizedDescriptionKey: "Error de prueba"]
    )
    
    FirebaseLogger.shared.recordNetworkError(
        error,
        endpoint: "/test/endpoint",
        httpCode: 500,
        method: "POST"
    )
    
    FirebaseLogger.shared.logErrorPopup(
        title: "Error de Prueba",
        message: "Este es un mensaje de prueba",
        source: "TestView"
    )
}
```

### **Opción 3: Crash de prueba**
```swift
// ⚠️ SOLO PARA TESTING - NO DEJAR EN PRODUCCIÓN
Button("Test Crash") {
    fatalError("Test crash para Firebase")
}
```

---

## 📊 CHECKLIST DE VERIFICACIÓN

Marca cada item cuando lo hayas verificado:

### **Compilación:**
- [ ] ✅ Proyecto compila sin errores (`⌘+B`)
- [ ] ✅ No hay warnings relacionados con Firebase
- [ ] ✅ App se ejecuta en simulador/dispositivo

### **Logs en Consola:**
- [ ] ✅ Veo logs con emojis (🔄, ✅, ❌)
- [ ] ✅ Logs de inicio de operaciones
- [ ] ✅ Logs de errores con contexto
- [ ] ✅ Logs de éxito

### **Flujos Críticos:**
- [ ] ✅ Error de red muestra popup Y registra en Firebase
- [ ] ✅ Validación de cita duplicada registrada
- [ ] ✅ Subida de examen con logs detallados
- [ ] ✅ Login/Logout registrados

### **Firebase Console:**
- [ ] ✅ Puedo acceder a Firebase Console
- [ ] ✅ Veo errores en Crashlytics
- [ ] ✅ Errores tienen contexto (custom keys)
- [ ] ✅ Veo User ID en los errores
- [ ] ✅ Veo endpoint en errores de red

---

## 🐛 TROUBLESHOOTING

### **No veo logs en Firebase Console**

**Posibles causas:**

1. **Firebase no está configurado**
   ```swift
   // Verifica en tu @main App:
   import FirebaseCore
   
   init() {
       FirebaseApp.configure() // ← Debe estar aquí
   }
   ```

2. **Crashlytics no está habilitado**
   ```
   - Ve a Firebase Console → Crashlytics
   - Verifica que esté habilitado
   - Puede tardar hasta 5 minutos en aparecer el primer log
   ```

3. **App en modo debug**
   ```
   - Firebase Crashlytics puede no enviar logs inmediatamente en debug
   - Para testing inmediato, compila en Release o espera unos minutos
   ```

4. **GoogleService-Info.plist no está en el proyecto**
   ```
   - Descarga desde Firebase Console → Project Settings
   - Arrastra al proyecto Xcode
   - Asegúrate de que esté en el target
   ```

---

### **Veo muchos errores "Unknown endpoint"**

**Causa:** Algunos errores llegan a `AppStatusManager.error()` sin pasar por el logging de red específico.

**Solución (opcional):**
```swift
// En los archivos de Network, antes de devolver error:
FirebaseLogger.shared.recordNetworkError(
    error,
    endpoint: "/ruta/especifica",
    httpCode: responseCode,
    method: "GET"
)
```

---

### **Crashes no aparecen en Firebase**

**Causa:** Los crashes en debug no siempre se envían inmediatamente.

**Solución:**
1. Compila en **Release mode**
2. Fuerza un crash
3. Reinicia la app
4. Espera 5-10 minutos
5. Revisa Firebase Console

---

## 🎯 MÉTRICAS A MONITOREAR

Una vez en producción, revisa diariamente:

### **Dashboard de Crashlytics:**
```
📊 Métricas clave:

1. Crash-free rate (objetivo: >99%)
2. Errores más frecuentes (top 5)
3. Usuarios afectados por errores
4. Errores nuevos (últimas 24h)
```

### **Errores críticos a monitorear:**
```
🔴 Alta prioridad:
- Login fallidos (>5% tasa de fallo)
- Errores de creación de citas (>2% tasa de fallo)
- Errores de subida de exámenes (>3% tasa de fallo)
- Network errors 500 (errores de servidor)

🟡 Media prioridad:
- Validaciones fallidas (informativas)
- Timeouts ocasionales
- Errores de carga de datos

🟢 Baja prioridad:
- Network errors 404 (no encontrado)
- Errores de UI menores
```

---

## 📈 NEXT STEPS

Una vez verificado que todo funciona:

1. **Despliega a TestFlight** para testing interno
2. **Monitorea Firebase** durante 1-2 semanas
3. **Identifica errores recurrentes**
4. **Prioriza fixes** basándote en usuarios afectados
5. **Despliega a producción** con confianza

---

## 🎉 ¡LISTO!

Si has completado todos los checks, tu implementación de Firebase Logging está lista. 

**Ahora tienes:**
- ✅ Visibilidad completa de errores
- ✅ Contexto para reproducir bugs
- ✅ Dashboard de monitoreo en tiempo real
- ✅ Herramientas para mejorar la calidad de la app

**Firebase Crashlytics es ahora tu copiloto para debugging en producción.** 🚀

---

## 📞 ¿NECESITAS AYUDA?

Si tienes problemas o dudas:
1. Revisa el archivo `RESUMEN_IMPLEMENTACION_FIREBASE.md`
2. Revisa el archivo `GUIA_MEJORAS_FIREBASE_LOGGING.md`
3. Pregúntame directamente 😊
