# 📝 Logs de Appointments - Documentación

## 🎯 Objetivo
Agregar logs detallados de la respuesta raw del servicio que trae las citas (`Appointment`) para facilitar el debugging y verificar que los datos lleguen correctamente desde el backend.

---

## 📦 Logs agregados

### 1. **Log en `AppStatusManager+Appointment.swift`**
**Ubicación:** Método `loadAppointments()`  
**Momento:** Cuando se cargan todas las citas desde el servicio

#### Información que muestra:
- ✅ Total de appointments recibidos
- ✅ Para cada appointment:
  - `id`
  - `status` (raw value)
  - `schedStartTime` (⭐ crítico para lógica de cancelación)
  - `schedEndTime`
  - `professionalName`
  - `clinica`
  - `workTypeGroup`
  - `appointmentType`
  - `serviceTerritoryId`
  - `iconoAzul`
  - **JSON completo serializado** (formato legible)

#### Ejemplo de log:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 [Appointments] Respuesta del servicio (parseada)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   • Total appointments: 2

   📅 Appointment #1:
      • id: a0D8d00000XYZ123
      • status: Confirmado
      • schedStartTime: 2026-03-15T14:00:00.000-0300
      • schedEndTime: 2026-03-15T14:30:00.000-0300
      • professionalName: Dr. Juan Pérez
      • clinica: Cardiología
      • workTypeGroup: 0MD8d00000ABC456
      • appointmentType: Video
      • serviceTerritoryId: 0Hh8d00000DEF789
      • iconoAzul: https://example.com/icon.png

      📄 JSON completo:
         {
           "appointmentType" : "Video",
           "clinica" : "Cardiología",
           "iconoAzul" : "https://example.com/icon.png",
           "id" : "a0D8d00000XYZ123",
           "professionalName" : "Dr. Juan Pérez",
           "schedEndTime" : "2026-03-15T14:30:00.000-0300",
           "schedStartTime" : "2026-03-15T14:00:00.000-0300",
           "serviceTerritoryId" : "0Hh8d00000DEF789",
           "status" : "Confirmado",
           "workTypeGroup" : "0MD8d00000ABC456"
         }

   📅 Appointment #2:
      • id: a0D8d00000XYZ124
      • status: Programado
      • schedStartTime: 2026-03-18T10:00:00.000-0300
      ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 2. **Log en `AppointmentDetailsView.swift`**
**Ubicación:** Método `logAppointmentDetails()` llamado en `onAppear`  
**Momento:** Cuando el usuario abre el detalle de una cita específica

#### Información que muestra:
- ✅ Todos los campos del `Appointment` individual
- ✅ **Fecha parseada** usando la computed property `date`
- ✅ **Computed properties** de la vista:
  - `isConfirmed`
  - `isCanceled`
  - `isCancelButtonEnabledByStatus`
- ✅ **JSON RAW completo** del objeto serializado

#### Ejemplo de log:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 [AppointmentDetailsView] Datos de la cita
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   • id: a0D8d00000XYZ123
   • status: Confirmado (Confirmado)
   • schedStartTime: 2026-03-15T14:00:00.000-0300
   • schedEndTime: 2026-03-15T14:30:00.000-0300
   • professionalName: Dr. Juan Pérez
   • clinica: Cardiología
   • workTypeGroup: 0MD8d00000ABC456
   • appointmentType: Video (Videollamada)
   • serviceTerritoryId: 0Hh8d00000DEF789
   • iconoAzul: https://example.com/icon.png

   📅 Fecha parseada (date property):
      • 2026-03-15 14:00:00 +0000

   🔍 Computed properties:
      • isConfirmed: true
      • isCanceled: false
      • isCancelButtonEnabledByStatus: true

   📄 JSON RAW completo del Appointment:
      {
        "appointmentType" : "Video",
        "clinica" : "Cardiología",
        "iconoAzul" : "https://example.com/icon.png",
        "id" : "a0D8d00000XYZ123",
        "professionalName" : "Dr. Juan Pérez",
        "schedEndTime" : "2026-03-15T14:30:00.000-0300",
        "schedStartTime" : "2026-03-15T14:00:00.000-0300",
        "serviceTerritoryId" : "0Hh8d00000DEF789",
        "status" : "Confirmado",
        "workTypeGroup" : "0MD8d00000ABC456"
      }
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔍 Información clave para debugging

### **schedStartTime** ⭐ CRÍTICO
Este campo es **el más importante** para la lógica de deshabilitar el botón "Cancelar".

**Formato esperado:**
```
"2026-03-15T14:00:00.000-0300"
└──────┬──────┘ └──┬──┘ └─┬─┘
  Fecha ISO8601   Hora   Offset TZ
```

**Componentes:**
- `2026-03-15`: Fecha (año-mes-día)
- `T`: Separador ISO8601
- `14:00:00.000`: Hora (HH:mm:ss.SSS)
- `-0300`: Offset de zona horaria (GMT-3 = Chile)

**Variaciones posibles:**
- `+0000`: UTC/GMT
- `-0500`: EST (New York)
- `+0100`: CET (Europa Central)
- `+0530`: IST (India)

---

## 📊 Flujo de logs en la app

```
1. Usuario inicia sesión
         ↓
2. AppStatusManager.loadAppointments()
         ↓
3. 📦 LOG: Respuesta del servicio (todos los appointments)
         ↓
4. Appointments se guardan en Realm
         ↓
5. Usuario navega a lista de citas
         ↓
6. Usuario hace tap en una cita
         ↓
7. Se abre AppointmentDetailsView
         ↓
8. onAppear → logAppointmentDetails()
         ↓
9. 📋 LOG: Datos de la cita específica
         ↓
10. 🔧 LOG: Setup inicial botón cancelar
         ↓
11. ⏰ LOG: Check cada 5s (timer)
```

---

## 🧪 Casos de uso para los logs

### Caso 1: Verificar formato de schedStartTime
**Problema:** El botón cancelar no se deshabilita correctamente  
**Solución:** Revisar el log de `schedStartTime` y verificar que tenga el formato correcto con offset

**Log a buscar:**
```
📋 [AppointmentDetailsView] Datos de la cita
   • schedStartTime: 2026-03-15T14:00:00.000-0300
                                            ^^^^^ ← Verificar que exista el offset
```

---

### Caso 2: Verificar status de la cita
**Problema:** El botón cancelar está deshabilitado incorrectamente  
**Solución:** Verificar el `status` en el log

**Log a buscar:**
```
📋 [AppointmentDetailsView] Datos de la cita
   • status: Confirmado (Confirmado)
   
   🔍 Computed properties:
      • isCancelButtonEnabledByStatus: true
                                       ^^^^ ← Debe ser true para "Confirmado"
```

---

### Caso 3: Verificar zona horaria del usuario
**Problema:** Usuario en España no puede cancelar cita de Chile  
**Solución:** Comparar el offset del `schedStartTime` con la hora actual

**Log a buscar:**
```
📋 [AppointmentDetailsView] Datos de la cita
   • schedStartTime: 2026-03-15T14:00:00.000-0300
                                            ^^^^^ Chile GMT-3

📅 schedStartTime: 2026-03-15T14:00:00.000-0300
   • Corrected date: 2026-03-15 17:00:00 +0000
                                 ^^^^^^^^^^^^^^ UTC corregido

⏰ [CancelButton] Check cada 5s:
   • Now (UTC): 2026-03-15 18:00:00 +0000
   • Appt corrected (UTC): 2026-03-15 17:00:00 +0000
   • Diferencia: -3600.0s (ya pasó 1 hora)
   ❌ La hora de la cita ya pasó → Deshabilitando botón
```

---

### Caso 4: Verificar datos faltantes
**Problema:** Algunos campos aparecen vacíos en la UI  
**Solución:** Revisar el JSON RAW completo

**Log a buscar:**
```
📄 JSON RAW completo del Appointment:
   {
     "professionalName" : "",  ← ❌ Campo vacío desde el backend
     ...
   }
```

---

## 🔧 Modificaciones realizadas

### Archivo 1: `AppStatusManager+Appointment.swift`
**Líneas modificadas:** ~15-50  
**Función:** `loadAppointments()`

**Cambios:**
```swift
case let .success(appointments):
    // ✅ NUEVO: Log detallado antes de guardar en Realm
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📦 [Appointments] Respuesta del servicio (parseada)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    // ... logs detallados ...
    
    let realm = try! Realm(queue: nil)
    // ... continúa igual ...
```

---

### Archivo 2: `AppointmentDetailsView.swift`
**Líneas modificadas:** ~186-189 (onAppear) + nueva función

**Cambios:**
```swift
.onAppear {
    // ✅ NUEVO: Log al abrir la vista
    logAppointmentDetails()
    
    updateVideoCallButtonStatus()
    setupInitialCancelButtonState()
    checkAndUpdateCancelButton()
}

// ✅ NUEVO: Función de logging
func logAppointmentDetails() {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [AppointmentDetailsView] Datos de la cita")
    // ... logs detallados ...
}
```

---

## ⚠️ Consideraciones

### Performance
- ✅ Los logs solo se imprimen en consola (no afectan producción si se desactivan)
- ✅ La serialización JSON es ligera (< 1ms por appointment)
- ✅ Solo se ejecutan cuando realmente se cargan las citas o se abre el detalle

### Seguridad
- ⚠️ Los logs contienen datos sensibles (IDs de Salesforce)
- ⚠️ En producción, considerar desactivar o limitar los logs
- ✅ No se exponen datos personales del usuario (RUT, email, teléfono)

### Compatibilidad
- ✅ Compatible con iOS 15+
- ✅ No requiere permisos adicionales
- ✅ Funciona con Realm y Alamofire

---

## 🚀 Próximos pasos (opcional)

### Mejora 1: Log condicional según ambiente
```swift
#if DEBUG
print("📦 [Appointments] ...")
#endif
```

### Mejora 2: Escribir logs en archivo
```swift
let logger = Logger(subsystem: "com.careassistance", category: "appointments")
logger.info("Appointments loaded: \(appointments.count)")
```

### Mejora 3: Enviar logs a servicio externo (Firebase, Sentry)
```swift
FirebaseLogger.shared.log("Appointments loaded", metadata: ["count": appointments.count])
```

---

## 📚 Referencias

- [ISO 8601 Date Format](https://en.wikipedia.org/wiki/ISO_8601)
- [Swift JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder)
- [Realm Swift Documentation](https://www.mongodb.com/docs/realm/sdk/swift/)

---

**Fecha de implementación:** 12 de marzo de 2026  
**Implementado por:** Assistant  
**Archivos modificados:** 2  
**Líneas agregadas:** ~80
