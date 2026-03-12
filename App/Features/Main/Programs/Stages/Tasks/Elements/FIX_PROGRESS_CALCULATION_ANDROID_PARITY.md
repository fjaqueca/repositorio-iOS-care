# 🔧 FIX: Cálculo de Progreso - Paridad con Android

## 🐛 Problema Original

### Crash en Línea 438
```
Thread 1: Fatal error: Float value cannot be converted to Int because it is either infinite or NaN
```

**Código problemático:**
```swift
let total = Int((activity.totalTaskCompletion2C ?? 0) / (activity.totalTaskComTemplateC ?? 1))
```

### Causa Raíz
1. **División de Floats seguida de conversión a Int**: Puede producir NaN o infinito
2. **Arquitectura diferente a Android**: iOS calculaba localmente el progreso, mientras Android lo lee del servidor

---

## 📊 Diferencias Arquitecturales: iOS vs Android

### Progreso de la Barra (Nivel Tarea)

| Aspecto | iOS (ANTES ❌) | Android ✅ | iOS (AHORA ✅) |
|---------|---------------|-----------|---------------|
| **Fuente de datos** | Calculado localmente | Leído del servidor | Leído del servidor |
| **Campo usado** | N/A (cálculo manual) | `Cumplimiento_de_la_Tarea__c` | `cumplimientoDeLaTareaC` |
| **Lógica** | `completedCount / total * 100` | Directo desde Salesforce | Directo desde taskData |

**Android (TareaFragment.kt:2186-2193):**
```kotlin
val cumplimientoServidor = tareaJson.optDouble("Cumplimiento_de_la_Tarea__c").toInt()
mainActivityProgramas.porcentajeCumplimiento = cumplimientoServidor
```

**iOS (ElementsView.swift - NUEVO):**
```swift
let cumplimientoServidor = taskData.cumplimientoDeLaTareaC ?? 0.0
progress = Int(cumplimientoServidor)
```

---

### Completitud por Actividad (Para UI de Lista)

**Android (TareaFragment.kt:741-796 - showActividades()):**
```kotlin
var repeticiones = if (actividad.CantItems > 1)
    actividad.Cant_Task_Completion__c / actividad.Total_Task_Com_Template__c
else
    actividad.Cant_Task_Completion__c

var totalRepeticiones = actividad.Total_Task_Completion2__c / actividad.Total_Task_Com_Template__c

val completa = repeticiones >= totalRepeticiones
```

**iOS (ElementsView.swift - NUEVO):**
```swift
func isActivityCompleted(_ activity: Activities.Activity) -> Bool {
    let totalTaskComTemplate = activity.totalTaskComTemplateC ?? 1.0
    
    guard totalTaskComTemplate > 0 else { return false }
    
    let cantItems = Int(totalTaskComTemplate)
    let repeticiones: Float
    
    if cantItems > 1 {
        repeticiones = (activity.cantTaskCompletionC ?? 0) / totalTaskComTemplate
    } else {
        repeticiones = activity.cantTaskCompletionC ?? 0
    }
    
    let totalRepeticiones = (activity.totalTaskCompletion2C ?? 0) / totalTaskComTemplate
    
    guard repeticiones.isFinite && totalRepeticiones.isFinite else { return false }
    
    return repeticiones >= totalRepeticiones
}
```

---

## ✅ Solución Implementada

### 1. Nueva función `calculateProgress()`

**ANTES ❌:**
```swift
private func calculateProgress() {
    guard let activities = allActivities.records else {
        progress = 0
        return
    }
    
    let completedActivities = activities.filter { activity in
        let completed = Int(activity.cantTaskCompletionC ?? 0)
        let total = Int((activity.totalTaskCompletion2C ?? 0) / (activity.totalTaskComTemplateC ?? 1)) // ⚠️ CRASH AQUÍ
        return completed >= total
    }
    
    progress = Int((Double(completedActivities.count) / Double(activities.count)) * 100)
}
```

**AHORA ✅:**
```swift
private func calculateProgress() {
    // 🔄 PARIDAD ANDROID: Leer progreso directamente del servidor
    let cumplimientoServidor = taskData.cumplimientoDeLaTareaC ?? 0.0
    
    // Validar que el valor sea válido antes de convertir
    guard cumplimientoServidor.isFinite else {
        print("⚠️ Valor de cumplimiento inválido (NaN o infinito), usando 0")
        progress = 0
        return
    }
    
    progress = Int(cumplimientoServidor)
    
    print("📊 [ElementsView] Progreso leído del servidor (como Android):")
    print("   - cumplimientoDeLaTareaC: \(cumplimientoServidor)")
    print("   - Porcentaje: \(progress)%")
}
```

### 2. Nueva función `isActivityCompleted(_ activity:)`

Replica exactamente la lógica de Android en `showActividades()`:

```swift
private func isActivityCompleted(_ activity: Activities.Activity) -> Bool {
    let totalTaskComTemplate = activity.totalTaskComTemplateC ?? 1.0
    
    // Evitar división por cero
    guard totalTaskComTemplate > 0 else {
        print("⚠️ totalTaskComTemplateC es 0 para actividad \(activity.Id ?? "desconocida")")
        return false
    }
    
    // Calcular repeticiones (equivalente a Android)
    let cantItems = Int(totalTaskComTemplate)
    let repeticiones: Float
    
    if cantItems > 1 {
        repeticiones = (activity.cantTaskCompletionC ?? 0) / totalTaskComTemplate
    } else {
        repeticiones = activity.cantTaskCompletionC ?? 0
    }
    
    // Calcular total de repeticiones esperadas
    let totalRepeticiones = (activity.totalTaskCompletion2C ?? 0) / totalTaskComTemplate
    
    // Validar que los valores sean finitos
    guard repeticiones.isFinite && totalRepeticiones.isFinite else {
        print("⚠️ Valores NaN/infinito detectados")
        return false
    }
    
    return repeticiones >= totalRepeticiones
}
```

### 3. Actualizaciones en funciones existentes

Todas las funciones que hacían cálculo manual ahora usan `isActivityCompleted()`:

- ✅ `refreshDataInBackground()`
- ✅ `refreshData()`
- ✅ `checkAutoNavigationPath()`
- ✅ `checkIsQuestionnaire()`

---

## 🔍 Validaciones de Seguridad Añadidas

### 1. Validación de valores finitos
```swift
guard cumplimientoServidor.isFinite else {
    print("⚠️ Valor de cumplimiento inválido (NaN o infinito), usando 0")
    progress = 0
    return
}
```

### 2. Protección contra división por cero
```swift
guard totalTaskComTemplate > 0 else {
    print("⚠️ totalTaskComTemplateC es 0")
    return false
}
```

### 3. Validación de operaciones matemáticas
```swift
guard repeticiones.isFinite && totalRepeticiones.isFinite else {
    print("⚠️ Valores NaN/infinito detectados")
    return false
}
```

---

## 📋 Tabla de Mapeo de Campos

| Concepto | Android | iOS |
|----------|---------|-----|
| Progreso de tarea | `Cumplimiento_de_la_Tarea__c` | `cumplimientoDeLaTareaC` |
| Completados actuales | `Cant_Task_Completion__c` | `cantTaskCompletionC` |
| Total esperado | `Total_Task_Completion2__c` | `totalTaskCompletion2C` |
| Templates por actividad | `Total_Task_Com_Template__c` | `totalTaskComTemplateC` |

---

## 🧪 Testing

### Casos de prueba:

1. **Tarea al 0%**: 
   - `cumplimientoDeLaTareaC = 0.0` → `progress = 0`

2. **Tarea al 75%** (del log):
   - `cumplimientoDeLaTareaC = 75.0` → `progress = 75`

3. **Tarea completa**:
   - `cumplimientoDeLaTareaC = 100.0` → `progress = 100`

4. **Valor NaN/Infinito**:
   - `cumplimientoDeLaTareaC = NaN` → `progress = 0` (con warning)

5. **División por cero en actividad**:
   - `totalTaskComTemplateC = 0` → `isActivityCompleted() = false` (con warning)

---

## 📝 Logs Mejorados

### Antes:
```
activity.totalTaskCompletion2C ?? 0 = 1.0
activity.totalTaskComTemplateC ?? 1 = 1.0
[CRASH]
```

### Ahora:
```
📊 [ElementsView] Progreso leído del servidor (como Android):
   - cumplimientoDeLaTareaC: 75.0
   - Porcentaje: 75%
   ℹ️ Android equivalente: Cumplimiento_de_la_Tarea__c

📋 [ElementsView] Estado de actividades:
   📌 Actividad 1:
      - cantTaskCompletionC: 1.0
      - totalTaskCompletion2C: 1.0
      - totalTaskComTemplateC: 1.0
      - repeticiones: 1.0
      - totalRepeticiones: 1.0
      - completa: true
   ✓ Completa: true - Invisible: false
```

---

## ✨ Beneficios de este cambio

1. **🐛 Elimina el crash**: No más conversiones inseguras de Float a Int
2. **🔄 Paridad con Android**: Comportamiento idéntico en ambas plataformas
3. **📡 Fuente única de verdad**: El servidor calcula el progreso, no el cliente
4. **🛡️ Mayor robustez**: Validaciones múltiples contra NaN/Infinito/División por cero
5. **🔍 Mejor debugging**: Logs detallados mostrando cada paso del cálculo
6. **♻️ Código reutilizable**: `isActivityCompleted()` puede usarse en toda la app

---

## 🚀 Próximos Pasos

Si el servidor NO está enviando `cumplimientoDeLaTareaC` correctamente:

1. Verificar el endpoint de API que devuelve `Goals.Goal`
2. Asegurar que Salesforce está calculando `Cumplimiento_de_la_Tarea__c`
3. Si no existe, solicitar al backend que agregue este campo calculado

---

## 📚 Referencias

- **Android**: `TareaFragment.kt`
  - Líneas 2186-2193: Lectura de progreso del servidor
  - Líneas 741-796: Lógica de `showActividades()` con cálculo de completitud

- **iOS**: `ElementsView.swift`
  - `calculateProgress()`: Lectura de progreso del servidor
  - `isActivityCompleted()`: Cálculo de completitud individual

- **Modelos**: `Task.swift`
  - `Goals.Goal.cumplimientoDeLaTareaC: Float?`
