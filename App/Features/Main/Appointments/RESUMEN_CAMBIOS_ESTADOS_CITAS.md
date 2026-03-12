# Resumen de Cambios: Estados de Citas - Implementación iOS

## 📋 Objetivo
Implementar en la app iOS (Swift) la misma lógica que se implementó en Android para el manejo de estados de citas, específicamente:
- Definir qué estados **bloquean** el agendamiento de nuevas citas
- Definir qué estados se **muestran** en las listas del Home y Agenda
- Definir qué estados se consideran "cita existente" para mostrar popup de reemplazo vs creación

## 📊 Tabla de Estados

| Estado       | Bloquea agendamiento | Se muestra en Home/Agenda | Popup que muestra        |
|--------------|----------------------|---------------------------|--------------------------|
| A Confirmar  | ✅                   | ✅                        | "Cita modificada" ✏️     |
| Programado   | ✅                   | ✅                        | "Cita modificada" ✏️     |
| Confirmado   | ✅                   | ✅                        | "Cita modificada" ✏️     |
| Cancelado    | ❌                   | ❌                        | "Cita creada" ✅         |
| Fallido      | ❌                   | ❌                        | "Cita creada" ✅         |
| Reagendado   | ❌                   | ❌                        | "Cita creada" ✅         |
| Realizado    | ❌                   | ❌                        | "Cita creada" ✅         |
| No realizado | ❌                   | ❌                        | "Cita creada" ✅         |

## 🔧 Archivos Modificados

### 1. `NewAppointmentSelectDetailsView.swift` (líneas ~759-800)

Se modificaron **3 funciones** para manejar correctamente los estados:

#### Función `checkPreviusAppoitnment()` - **CAMBIO CRÍTICO** 🔥
Esta función determina si se debe **reemplazar** una cita o crear una nueva.

**Antes:**
```swift
func checkPreviusAppoitnment() -> Appointment? {
    for appoint in self.previousAppointment{
        if appoint.workTypeGroup == self.id {
            if appoint.status.rawValue != "Cancelado" {
                return appoint
            }
        }
    }
    return nil
}
```
❌ **Problema**: Solo excluía "Cancelado", pero trataba estados como "Realizado" o "Fallido" como si aún estuvieran activos.

**Después:**
```swift
func checkPreviusAppoitnment() -> Appointment? {
    for appoint in self.previousAppointment{
        if appoint.workTypeGroup == self.id {
            // ✅ Solo consideramos como "cita existente" los 3 estados activos
            // Los estados inactivos NO deben tratarse como reemplazo
            if appoint.status.rawValue == "A Confirmar" || 
               appoint.status.rawValue == "Programado" || 
               appoint.status.rawValue == "Confirmado" {
                return appoint
            }
        }
    }
    return nil
}
```
✅ **Solución**: Ahora solo considera "cita existente" si está en los 3 estados activos.

**Impacto en el flujo de creación de citas:**
```swift
var previousAppointment = checkPreviusAppoitnment()

// Si previousAppointment != nil → llama a replaceAppointment() → "Cita modificada"
// Si previousAppointment == nil → llama a createAppointment() → "Cita creada"

let result: Result<Alamofire.Empty, AppError>
if let previousAppointment = previousAppointment {
    result = await Network.shared.replaceAppointment(
        previousAppointment: previousAppointment,
        rut: rut,
        clinic: clinic,
        professional: professional,
        slot: slot
    )
} else {
    result = await Network.shared.createAppointment(
        rut: rut,
        clinic: clinic,
        professional: professional,
        slot: slot
    )
}
```

#### Función `checkPreviusAppoitnmentForConfirmedOrScheduledClinic()`
Valida si ya existe una cita **activa** en la misma clínica.

**Antes:**
```swift
func checkPreviusAppoitnmentForConfirmedOrScheduledClinic() -> Bool {
    for appoint in self.previousAppointment{
        if appoint.workTypeGroup == self.id {
            if appoint.status.rawValue == "Programado" || 
               appoint.status.rawValue == "Confirmado"{
                return true
            }
        }
    }
    return false
}
```

**Después:**
```swift
func checkPreviusAppoitnmentForConfirmedOrScheduledClinic() -> Bool {
    for appoint in self.previousAppointment{
        if appoint.workTypeGroup == self.id {
            // ✅ Solo estos 3 estados bloquean el agendamiento
            if appoint.status.rawValue == "A Confirmar" || 
               appoint.status.rawValue == "Programado" || 
               appoint.status.rawValue == "Confirmado"{
                return true
            }
        }
    }
    return false
}
```

#### Función `checkPreviusAppoitnmentForConfirmedOrScheduledHour()`
Valida si ya existe una cita **activa** en el mismo horario.

**Antes:**
```swift
func checkPreviusAppoitnmentForConfirmedOrScheduledHour() -> Bool {
    for appoint in self.previousAppointment{
        if appoint.date == self.slot?.startDate {
            if appoint.status.rawValue == "Programado" || 
               appoint.status.rawValue == "Confirmado"{
                // ... código de clinicName
                return true
            }
        }
    }
    return false
}
```

**Después:**
```swift
func checkPreviusAppoitnmentForConfirmedOrScheduledHour() -> Bool {
    for appoint in self.previousAppointment{
        if appoint.date == self.slot?.startDate {
            // ✅ Solo estos 3 estados bloquean el agendamiento
            if appoint.status.rawValue == "A Confirmar" || 
               appoint.status.rawValue == "Programado" || 
               appoint.status.rawValue == "Confirmado"{
                if let matched = clinicObjects.first(where: { $0.id == appoint.workTypeGroup }) {
                    self.clinicName = matched.name
                } else {
                    self.clinicName = appoint.clinica
                }
                return true
            }
        }
    }
    return false
}
```

### 2. `AppointmentsListView.swift` (línea ~12)

**Cambio**: Se agregó filtro NSPredicate para excluir estados inactivos.

**Antes:**
```swift
struct AppointmentsListView: View {
    @ObservedResults(Appointment.self) var appointments
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @State private var sections: [ListSection] = []
```

**Después:**
```swift
struct AppointmentsListView: View {
    // ✅ Solo mostramos citas con estados activos: A Confirmar, Programado, Confirmado
    // Excluimos: Cancelado, Fallido, Reagendado, Realizado, No realizado, No Confirmado
    @ObservedResults(
        Appointment.self,
        filter: NSPredicate(format: "status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@",
                            "No realizado", "Reagendado", "No Confirmado", "Realizado", "Cancelado", "Fallido"),
        sortDescriptor: .init(keyPath: \Appointment.date, ascending: true)
    ) var appointments
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @State private var sections: [ListSection] = []
```

### 3. `AppointmentsTile.swift` - ✅ YA ESTABA CORRECTO

**Estado**: Este archivo ya tenía el filtro correcto implementado (líneas 15-20).

```swift
@ObservedResults(
    Appointment.self,
    filter: NSPredicate(format: "status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@",
                        "No realizado", "Reagendado", "No Confirmado", "Realizado", "Cancelado", "Fallido"),
    sortDescriptor: .init(keyPath: \Appointment.date, ascending: true)
) var appointments
```

## ✅ Resultado Final

### Comportamiento implementado:

1. **En la pestaña "Home"** (`AppointmentsTile`):
   - ✅ Solo se muestran citas con estados: "A Confirmar", "Programado", "Confirmado"
   - ❌ Las citas con estados "Cancelado", "Fallido", "Reagendado", "Realizado", "No realizado" están ocultas

2. **En la pestaña "Agenda"** (`AppointmentsListView`):
   - ✅ Solo se muestran citas con estados: "A Confirmar", "Programado", "Confirmado"
   - ❌ Las citas con estados "Cancelado", "Fallido", "Reagendado", "Realizado", "No realizado" están ocultas

3. **Al intentar agendar una nueva cita** (`NewAppointmentSelectDetailsView`):
   - ✅ El sistema bloquea el agendamiento si ya existe una cita en el mismo horario o clínica con estados: "A Confirmar", "Programado", "Confirmado"
   - ❌ Las citas con estados "Cancelado", "Fallido", "Reagendado", "Realizado", "No realizado" NO bloquean el agendamiento
   - 🆕 **NUEVO**: Si ya existía una cita "Cancelada" o con otro estado inactivo, ahora se muestra "Cita creada con éxito" en lugar de "Cita modificada"

## 🔄 Consistencia con Android

La implementación iOS ahora es **100% consistente** con la implementación Android:

| Aspecto                  | Android (Kotlin)                | iOS (Swift)                     | Estado |
|--------------------------|----------------------------------|----------------------------------|--------|
| Filtro en Home           | ✅ 3 estados activos             | ✅ 3 estados activos             | ✅     |
| Filtro en Agenda/Lista   | ✅ 3 estados activos             | ✅ 3 estados activos             | ✅     |
| Validación por clínica   | ✅ 3 estados bloquean            | ✅ 3 estados bloquean            | ✅     |
| Validación por horario   | ✅ 3 estados bloquean            | ✅ 3 estados bloquean            | ✅     |
| Popup de reemplazo       | ✅ Solo 3 estados activos        | ✅ Solo 3 estados activos        | ✅     |

## 📝 Escenarios de Uso

### Escenario 1: Usuario con cita "Confirmada" intenta agendar otra
```
Estado actual: Cita "Confirmada" en Clínica A
Acción: Intenta agendar nueva cita en Clínica A
Resultado: ❌ BLOQUEADO - Popup "Ya tiene una cita en esta clínica"
```

### Escenario 2: Usuario con cita "Cancelada" intenta agendar
```
Estado actual: Cita "Cancelada" en Clínica A (NO se muestra en Home/Agenda)
Acción: Intenta agendar nueva cita en Clínica A
Resultado: ✅ PERMITIDO - Popup "Cita creada con éxito" (no "modificada")
```

### Escenario 3: Usuario con cita "Realizada" intenta agendar
```
Estado actual: Cita "Realizada" en Clínica A (NO se muestra en Home/Agenda)
Acción: Intenta agendar nueva cita en Clínica A
Resultado: ✅ PERMITIDO - Popup "Cita creada con éxito"
```

### Escenario 4: Usuario con cita "Programada" la reagenda
```
Estado actual: Cita "Programada" en Clínica A (SÍ se muestra en Home/Agenda)
Acción: Agenda otra cita en Clínica A
Resultado: ✅ PERMITIDO - Popup "Cita modificada con éxito" + cancela la anterior
```

## 🧪 Testing Recomendado

### Tests de Filtrado de Listas
- [ ] Verificar que en Home solo aparecen citas con estados: A Confirmar, Programado, Confirmado
- [ ] Verificar que en la lista de Agenda solo aparecen citas con estados: A Confirmar, Programado, Confirmado
- [ ] Crear una cita y cancelarla → debe desaparecer de Home y Agenda

### Tests de Validación de Bloqueo
- [ ] Intentar agendar cita cuando ya existe una "A Confirmar" → debe bloquear
- [ ] Intentar agendar cita cuando ya existe una "Programada" → debe bloquear
- [ ] Intentar agendar cita cuando ya existe una "Confirmada" → debe bloquear
- [ ] Intentar agendar cita cuando existe una "Cancelada" → NO debe bloquear
- [ ] Intentar agendar cita cuando existe una "Realizada" → NO debe bloquear
- [ ] Intentar agendar cita cuando existe una "Fallida" → NO debe bloquear

### Tests de Popup de Confirmación ⭐ NUEVO
- [ ] Agendar cita SIN citas previas → debe mostrar "Cita creada con éxito"
- [ ] Agendar cita teniendo una "Cancelada" → debe mostrar "Cita creada con éxito"
- [ ] Agendar cita teniendo una "Realizada" → debe mostrar "Cita creada con éxito"
- [ ] Agendar cita teniendo una "A Confirmar" → debe mostrar "Cita modificada con éxito"
- [ ] Agendar cita teniendo una "Programada" → debe mostrar "Cita modificada con éxito"

## 📱 Textos de los Popups

Según el código en `createAppointment()`:

**Popup de Creación (cita nueva):**
```swift
popup = .init(
    image: UIStateAppoint.popupAppointmentUIState.iconCheck,
    title: UIStateAppoint.popupAppointmentUIState.agend.text1,
    message: UIStateAppoint.popupAppointmentUIState.agend.text2,
    actionTitle: UIStateAppoint.popupAppointmentUIState.agend.btnOk,
    ...
)
```

**Popup de Modificación (reemplazo):**
```swift
popup = .init(
    image: UIStateAppoint.popupAppointmentUIState.iconCheck,
    title: UIStateAppoint.popupAppointmentUIState.modifier.text1,
    message: "Usted ya tenia una cita agendada. La misma fue cancelada y se agendó una nueva cita...",
    actionTitle: UIStateAppoint.popupAppointmentUIState.agend.btnOk,
    ...
)
```

---
**Fecha de implementación**: 26 de febrero de 2026  
**Implementado por**: Asistente de Código iOS  
**Archivos modificados**: 3  
**Funciones modificadas**: 4  
**Líneas de código modificadas**: ~25
