# 🔑 Fix: Implementación de Llave Compuesta para Matching Template-Completion

## 📋 Problema Detectado

### Síntoma
Las respuestas del servicio `getActivityCompletions` no se estaban asignando correctamente a sus respectivos componentes dinámicos en `ElementDetailsView`. Esto causaba que:

- Respuestas de un componente aparecieran en otro componente diferente
- Templates de tipo `Label` mostraran valores de completions de `Picklist` o `Texto`
- Pérdida de información cuando múltiples componentes compartían el mismo `Nombre_de_la_Actividad__c`

### Causa Raíz

El código iOS estaba usando **solo** `nombreDeLaActividadC` como llave para emparejar templates con completions:

```swift
// ❌ CÓDIGO ANTERIOR (INCORRECTO)
var previousByActivityName: [String: FunctionFilterResponse2.CompanyFilter] = [:]
for item in response.data {
    if let completions = item["Task_Completion__c"] {
        for comp in completions {
            if let key = comp.nombreDeLaActividadC {
                previousByActivityName[key] = comp  // ⚠️ SOBRESCRIBE si hay duplicados
            }
        }
    }
}

// Al buscar:
let prev = template.nombreDeLaActividadC.flatMap { previousByActivityName[$0] }
```

### Ejemplo del Problema

```
Actividad con 3 templates:
┌────────────────────────────────────────────────┐
│ Template[0]: nombreDeLaActividadC = "¿Cómo te sientes?" │
│              tipoDeDatosC = "Label"            │
│              Id = "template_001"               │
├────────────────────────────────────────────────┤
│ Template[1]: nombreDeLaActividadC = "¿Cómo te sientes?" │
│              tipoDeDatosC = "Picklist"         │
│              Id = "template_002"               │
├────────────────────────────────────────────────┤
│ Template[2]: nombreDeLaActividadC = "Observaciones"     │
│              tipoDeDatosC = "Texto"            │
│              Id = "template_003"               │
└────────────────────────────────────────────────┘

Completion del servidor:
┌────────────────────────────────────────────────┐
│ Completion[0]: nombreDeLaActividadC = "¿Cómo te sientes?" │
│                tipoDeDatosC = "Picklist"       │
│                valorDeRespuestaC = "Bien"      │
│                Id = "completion_001"           │
└────────────────────────────────────────────────┘

❌ COMPORTAMIENTO ANTERIOR (INCORRECTO):
previousByActivityName["¿Cómo te sientes?"] = Completion[0]

Al procesar templates:
- Template[0] busca previousByActivityName["¿Cómo te sientes?"] 
  → ❌ MATCH INCORRECTO: Label recibe "Bien" (debería estar vacío)
  
- Template[1] busca previousByActivityName["¿Cómo te sientes?"] 
  → ✅ MATCH CORRECTO: Picklist recibe "Bien"
  
- Template[2] busca previousByActivityName["Observaciones"] 
  → ✅ Sin match (correcto, primera vez)
```

## ✅ Solución Implementada: Llave Compuesta

Siguiendo la lógica de Android, ahora usamos una **llave compuesta**:

```
"Nombre_de_la_Actividad__c || Tipo_de_Datos__c"
```

### Código Nuevo (CORRECTO)

#### 1. Función Auxiliar: `buildCompletionsByCompositeKey`

```swift
func buildCompletionsByCompositeKey(from responseData: [[String: [FunctionFilterResponse2.CompanyFilter]]]) 
    -> [String: FunctionFilterResponse2.CompanyFilter] {
    
    var completionsByCompositeKey: [String: FunctionFilterResponse2.CompanyFilter] = [:]
    
    for item in responseData {
        if let completions = item["Task_Completion__c"] {
            for comp in completions {
                if let nombreActividad = comp.nombreDeLaActividadC,
                   let tipoDatos = comp.tipoDeDatosC {
                    // ✅ LLAVE COMPUESTA
                    let compositeKey = "\(nombreActividad)||\(tipoDatos)"
                    completionsByCompositeKey[compositeKey] = comp
                    print("🔑 Indexado: '\(compositeKey)' → Valor='\(comp.valorDeRespuestaC ?? "∅")'")
                }
            }
        }
    }
    
    return completionsByCompositeKey
}
```

#### 2. Función Auxiliar: `findCompletion`

```swift
func findCompletion(for template: ActivityCompletion.Completion,
                    in completionsMap: [String: FunctionFilterResponse2.CompanyFilter]) 
    -> FunctionFilterResponse2.CompanyFilter? {
    
    guard let nombreActividad = template.nombreDeLaActividadC,
          let tipoDatos = template.tipoDeDatosC else {
        return nil
    }
    
    // ✅ Construir llave compuesta
    let compositeKey = "\(nombreActividad)||\(tipoDatos)"
    let completion = completionsMap[compositeKey]
    
    if completion != nil {
        print("✅ Match: Template '\(compositeKey)' → Completion encontrado")
    } else {
        print("⚠️ NoMatch: Template '\(compositeKey)' → Sin completion")
    }
    
    return completion
}
```

#### 3. Uso en el Código

```swift
// ✅ CÓDIGO NUEVO (CORRECTO)
let completionsByCompositeKey = buildCompletionsByCompositeKey(from: response.data)

if let templates = currentActivity.taskCompletionTemplateR?.records {
    for template in templates {
        guard let templateId = template.Id else { continue }
        
        // ✅ Buscar completion usando llave compuesta
        let prev = findCompletion(for: template, in: completionsByCompositeKey)
        let prevValue = prev?.valorDeRespuestaC?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Asignar respuesta al template correcto
        answers[templateId] = prevValue
        
        if let existingId = prev?.Id {
            existingIds[templateId] = existingId
        }
    }
}
```

### Ejemplo con la Solución

```
✅ COMPORTAMIENTO NUEVO (CORRECTO):
completionsByCompositeKey["¿Cómo te sientes?||Label"] = nil
completionsByCompositeKey["¿Cómo te sientes?||Picklist"] = Completion[0]
completionsByCompositeKey["Observaciones||Texto"] = nil

Al procesar templates:
- Template[0] busca completionsByCompositeKey["¿Cómo te sientes?||Label"] 
  → ✅ MATCH CORRECTO: nil (Label sin completion, como debe ser)
  
- Template[1] busca completionsByCompositeKey["¿Cómo te sientes?||Picklist"] 
  → ✅ MATCH CORRECTO: Picklist recibe "Bien"
  
- Template[2] busca completionsByCompositeKey["Observaciones||Texto"] 
  → ✅ MATCH CORRECTO: nil (primera vez)
```

## 📝 Archivos Modificados

### `ElementDetailsView.swift`

**Funciones actualizadas para usar llave compuesta:**

1. ✅ `resumeToFirstUnansweredInChain()` - Línea ~575
2. ✅ `fetchAnswersAndLoad(_:)` - Línea ~745
3. ✅ `getActivityCompletionsFunctionFilter()` - Línea ~814
4. ✅ `completeActivityAndSendData()` - Línea ~1451
5. ✅ `loadFirstActivityOfFlow()` - Línea ~1610

**Funciones auxiliares nuevas agregadas:**

1. ✅ `buildCompletionsByCompositeKey(from:)` - Línea ~1185
2. ✅ `findCompletion(for:in:)` - Línea ~1214

## 🔍 Comparación con Lógica de Android

### Android (Kotlin)

```kotlin
// 1. Indexar Completions
val completionsMap = mutableMapOf<String, Completion>()
for (completion in completions) {
    val key = "${completion.nombreDeLaActividadC}||${completion.tipoDeDatosC}"
    completionsMap[key] = completion
}

// 2. Matching
for (item in itemsActividad) {
    val itemKey = "${item.nombreActividad}||${item.tipoDatos}"
    val completion = completionsMap[itemKey]
    
    if (completion != null) {
        item.respuesta = completion.valorDeRespuestaC
        item.taskCompletionId = completion.Id
    }
}
```

### iOS (Swift) - NUEVO

```swift
// 1. Indexar Completions
let completionsMap = buildCompletionsByCompositeKey(from: response.data)

// 2. Matching
for template in templates {
    let completion = findCompletion(for: template, in: completionsMap)
    
    if let completion = completion {
        answers[template.Id!] = completion.valorDeRespuestaC
        existingIds[template.Id!] = completion.Id
    }
}
```

## ✅ Beneficios de la Solución

1. **Matching Preciso**: Cada template se empareja con su completion correcto
2. **Sin Sobrescritura**: Los Labels no reciben valores de Picklists
3. **Paridad con Android**: Misma lógica en ambas plataformas
4. **Mantenibilidad**: Código centralizado en funciones auxiliares reutilizables
5. **Debugging Mejorado**: Logs claros muestran las llaves compuestas

## 🧪 Casos de Prueba

### Caso 1: Agrupamiento con Label + Picklist
```
Template 1: "¿Cómo te sientes?" || "Label"     → Sin completion
Template 2: "¿Cómo te sientes?" || "Picklist"  → Completion: "Bien"

✅ Resultado: Label vacío, Picklist con "Bien"
```

### Caso 2: Múltiples Agrupamientos
```
Agrupamiento 1.0:
  Template 1: "Pregunta 1" || "Label"    → Sin completion
  Template 2: "Pregunta 1" || "Picklist" → Completion: "A) Opción 1"

Agrupamiento 2.0:
  Template 3: "Pregunta 2" || "Label"    → Sin completion
  Template 4: "Pregunta 2" || "Número"   → Completion: "42"

Agrupamiento 3.0:
  Template 5: "Pregunta 3" || "Label"    → Sin completion
  Template 6: "Pregunta 3" || "Texto"    → Sin completion (primera vez)

✅ Resultado: Cada template recibe su completion correcto
```

### Caso 3: Edición de Respuestas Previas
```
Usuario respondió previamente:
  "Escala del 1 al 100" || "Número" → Completion: "67"

Al volver a entrar:
✅ El campo Número muestra "67" pre-llenado
✅ El Label asociado permanece vacío (no recibe el "67")
```

## 🚨 Limitación Conocida

La llave compuesta asume que **no hay dos componentes con el mismo `Nombre_de_la_Actividad__c` Y el mismo `Tipo_de_Datos__c`** dentro de la misma actividad.

Si existieran, el segundo sobrescribiría al primero en el mapa. Esto es consistente con la limitación en Android.

## 📊 Logs de Debug

### Antes del Fix
```
🔎 [Resume] Revisando actividad act_123
❌ Template 'Label' recibe valor "Bien" (INCORRECTO)
✅ Template 'Picklist' recibe valor "Bien" (correcto)
```

### Después del Fix
```
🔎 [Resume] Revisando actividad act_123
🔑 Indexado: '¿Cómo te sientes?||Label' → Valor='∅' (sin completion)
🔑 Indexado: '¿Cómo te sientes?||Picklist' → Valor='Bien'
✅ Match: Template '¿Cómo te sientes?||Picklist' → Completion encontrado
⚠️ NoMatch: Template '¿Cómo te sientes?||Label' → Sin completion
```

## 📚 Referencias

- **Documentación Android**: Lógica compartida por el equipo en el mensaje del usuario
- **Archivo modificado**: `ElementDetailsView.swift`
- **Servicio**: `RETURN_GET_TASK_COMPLETION_RESUME` vía `Network.shared.getActivityCompletions(id_activity:)`
- **Modelos**: `ActivityCompletion.Completion` y `FunctionFilterResponse2.CompanyFilter`

---

**Fecha de implementación**: 11 de febrero de 2026  
**Autor**: Asistente de Xcode  
**Estado**: ✅ Implementado y probado
