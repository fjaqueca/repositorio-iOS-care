# 🔧 Fix: Picklist Múltiple - Estado Individual por Template

## 📋 Problema Detectado

### Síntoma
Los valores de **Picklist Múltiple** no se estaban mostrando correctamente en el formulario dinámico cuando:

1. El servicio `getActivityCompletions` retornaba respuestas previas con formato `"Negro;Blanco;Morado"`
2. Existían múltiples componentes de tipo "Picklist Múltiple" en la misma actividad
3. Se navegaba entre actividades con historial (botón Anterior/Siguiente)

**Ejemplo del problema:**
```
Servicio retorna:
  Template 1: "Selecciona todos los colores que te gusten:"
              Tipo='Picklist Múltiple'
              Respuesta='Negro;Blanco;Morado'
  
  Template 2: "¿Qué mascotas tienes?"
              Tipo='Picklist Múltiple'
              Respuesta='Perro;Gato'

❌ COMPORTAMIENTO ANTERIOR (INCORRECTO):
- Al entrar a la actividad, ambos Picklist Múltiple aparecían VACÍOS
- Solo el último procesado (Template 2) mostraba sus valores
- Template 1 perdía su información
```

### Causa Raíz

El código iOS estaba usando **una sola variable global `@State`** para todos los Picklist Múltiple:

```swift
// ❌ CÓDIGO ANTERIOR (INCORRECTO)
@State private var selectedItems: [ChipItem] = []

// En el UI, TODOS los Picklist Múltiple compartían la misma variable:
if com.tipoDeDatosC == "Picklist Múltiple" {
    MultiSelectField(
        selectedItems: $selectedItems,  // ⚠️ Mismo binding para todos
        ...
    )
}

// Al cargar respuestas previas:
case "Picklist Múltiple":
    self.completionResponse[templateId] = prevValue
    self.selectedItems = ChipItem.parse(prevValue)  // ⚠️ Se sobreescribe cada vez
```

### Problema de Estado Compartido

```
Flujo del bug:

1️⃣ Servicio retorna 2 Picklist Múltiple con valores:
   - Template_A: "Negro;Blanco;Morado"
   - Template_B: "Perro;Gato"

2️⃣ Al procesar respuestas:
   selectedItems = ChipItem.parse("Negro;Blanco;Morado")  // Template_A
   selectedItems = ChipItem.parse("Perro;Gato")           // ⚠️ SOBRESCRIBE Template_A

3️⃣ En la UI:
   - MultiSelectField de Template_A usa selectedItems → "Perro;Gato" ❌
   - MultiSelectField de Template_B usa selectedItems → "Perro;Gato" ✅
```

### Problema Adicional: `loadActivityUI` no inicializaba

La función `loadActivityUI()` recibía el diccionario `answers` con todas las respuestas, pero **nunca inicializaba los chips seleccionados** para Picklist Múltiple:

```swift
// ❌ ANTERIOR: Solo asignaba respuestas de texto
func loadActivityUI(..., with answers: [String:String], ...) {
    self.completionResponse = answers  // ✅ Esto guarda el string
    // ❌ FALTABA: Parsear los valores de Picklist Múltiple a ChipItem
}
```

Esto causaba que cuando se navegaba entre actividades usando el historial (botón Anterior), los Picklist Múltiple aparecían vacíos a pesar de que `completionResponse` tenía los valores correctos.

---

## ✅ Solución Implementada: Estado Individual por Template

### 1. Cambio de Variable: De Global a Diccionario

```swift
// ✅ CÓDIGO NUEVO (CORRECTO)
// En lugar de un solo array, usamos un diccionario por templateId
@State private var selectedItemsByTemplate: [String: [ChipItem]] = [:]
```

### 2. Binding Individual en MultiSelectField

```swift
// ✅ Cada Picklist Múltiple tiene su propio binding
if com.tipoDeDatosC == "Picklist Múltiple" {
    let templateId = com.Id ?? ""
    
    VStack(alignment: .leading, spacing: 4) {
        MultiSelectField(
            label: com.nombrePersonalizadoC ?? "Sin Nombre",
            placeholder: "Selecciona una o más opciones",
            selectedItems: Binding(
                get: { selectedItemsByTemplate[templateId] ?? [] },
                set: { selectedItemsByTemplate[templateId] = $0 }
            ),
            allOptions: com.posiblesValoresC ?? "",
            isRequired: com.requeridoC ?? false,
            isValid: !(completionResponse[templateId]?.isEmpty ?? true),
            canEdit: isEditable(for: com)
        )
    }
    .onAppear {
        // ✅ Inicializar el diccionario de items seleccionados si no existe
        if selectedItemsByTemplate[templateId] == nil {
            // Parsear valor previo si existe
            let prevValue = completionResponse[templateId] ?? ""
            selectedItemsByTemplate[templateId] = ChipItem.parse(prevValue)
            print("🔵 [Picklist Múltiple onAppear] TemplateId=\(templateId) Parseado='\(prevValue)' → Items=\(selectedItemsByTemplate[templateId]?.count ?? 0)")
        }
        
        // Si no hay respuesta previa, inicializamos vacío
        if completionResponse[templateId] == nil {
            completionResponse[templateId] = ""
        }
    }
    .onChange(of: selectedItemsByTemplate[templateId]) { newValue in
        let stringValue = ChipItem.toString(newValue ?? [])
        completionResponse[templateId] = stringValue
        print("🧩 [Picklist Múltiple] Selección actualizada TemplateId=\(templateId) Valor='\(stringValue)'")
    }
    .disabled(!isEditable(for: com))
}
```

### 3. Actualización en `getActivityCompletionsFunctionFilter()`

```swift
// Al procesar respuestas del servicio:
case "Picklist Múltiple":
    self.completionResponse[templateId] = prevValue
    // ✅ Parsear y asignar al diccionario específico del template
    self.selectedItemsByTemplate[templateId] = ChipItem.parse(prevValue)
    print("🟢 [Picklist Múltiple Parse] TemplateId=\(templateId) Valor='\(prevValue)' → Items=\(self.selectedItemsByTemplate[templateId]?.count ?? 0)")
```

### 4. Inicialización en `loadActivityUI()` (✨ CLAVE)

Esta es la adición más importante para solucionar el problema de navegación:

```swift
@MainActor
func loadActivityUI(_ act: Activities.Activity,
                    with answers: [String:String],
                    existingIds: [String:String],
                    positionIndex: Int = 0) {
    print("🖼️ [UI] loadActivityUI ActivityId=\(act.Id ?? "-") ...")
    
    // ... código existente ...
    
    self.completionResponse = answers
    self.originalCompletionResponse = answers
    self.existingCompletionIds = existingIds
    self.positionOfPicklist = positionIndex
    
    // ✅ NUEVO: Inicializar selectedItemsByTemplate para Picklist Múltiple
    if let templates = act.taskCompletionTemplateR?.records {
        for template in templates {
            guard let templateId = template.Id,
                  template.tipoDeDatosC == "Picklist Múltiple" else { continue }
            
            let prevValue = answers[templateId] ?? ""
            if !prevValue.isEmpty {
                self.selectedItemsByTemplate[templateId] = ChipItem.parse(prevValue)
                print("🟣 [UI LoadActivity] Picklist Múltiple inicializado TemplateId=\(templateId) Valor='\(prevValue)' → Items=\(self.selectedItemsByTemplate[templateId]?.count ?? 0)")
            } else {
                self.selectedItemsByTemplate[templateId] = []
                print("🟣 [UI LoadActivity] Picklist Múltiple vacío TemplateId=\(templateId)")
            }
        }
    }
    
    // ... código existente ...
}
```

---

## 🔄 Flujo Completo con la Solución

### Caso 1: Carga Inicial desde Servicio

```
1️⃣ Servicio retorna:
   Template_A (id="tpl_001"): "Selecciona colores" → "Negro;Blanco;Morado"
   Template_B (id="tpl_002"): "Selecciona mascotas" → "Perro;Gato"

2️⃣ getActivityCompletionsFunctionFilter() procesa:
   completionResponse["tpl_001"] = "Negro;Blanco;Morado"
   selectedItemsByTemplate["tpl_001"] = [ChipItem("Negro"), ChipItem("Blanco"), ChipItem("Morado")]
   
   completionResponse["tpl_002"] = "Perro;Gato"
   selectedItemsByTemplate["tpl_002"] = [ChipItem("Perro"), ChipItem("Gato")]

3️⃣ En la UI:
   MultiSelectField(tpl_001) → binding a selectedItemsByTemplate["tpl_001"] ✅
   MultiSelectField(tpl_002) → binding a selectedItemsByTemplate["tpl_002"] ✅
   
✅ RESULTADO: Cada Picklist Múltiple muestra sus valores correctos
```

### Caso 2: Navegación con Historial (Botón Anterior)

```
1️⃣ Usuario responde en Actividad 1 con Picklist Múltiple
   answersCache["act_001"]["tpl_001"] = "Azul;Verde;Rojo"

2️⃣ Usuario avanza a Actividad 2, luego presiona "Anterior"

3️⃣ fetchAnswersAndLoad() recupera caché:
   cached = answersCache["act_001"]  // contiene tpl_001 = "Azul;Verde;Rojo"

4️⃣ loadActivityUI(act_001, with: cached) ejecuta:
   self.completionResponse = cached  // ✅
   
   // ✅ NUEVO: Parsea Picklist Múltiple
   for template in templates where tipo == "Picklist Múltiple" {
       selectedItemsByTemplate["tpl_001"] = ChipItem.parse("Azul;Verde;Rojo")
   }

5️⃣ En la UI:
   MultiSelectField(tpl_001) → binding a selectedItemsByTemplate["tpl_001"]
   
✅ RESULTADO: Los chips aparecen correctamente al regresar
```

### Caso 3: Múltiples Picklist Múltiple en Una Actividad

```
Actividad con 3 Picklist Múltiple:

Template_A (id="tpl_A"): "Colores" → "Rojo;Azul"
Template_B (id="tpl_B"): "Frutas" → "Manzana;Pera;Uva"
Template_C (id="tpl_C"): "Deportes" → "Fútbol"

✅ Estado Final:
selectedItemsByTemplate = {
    "tpl_A": [ChipItem("Rojo"), ChipItem("Azul")],
    "tpl_B": [ChipItem("Manzana"), ChipItem("Pera"), ChipItem("Uva")],
    "tpl_C": [ChipItem("Fútbol")]
}

✅ UI: Cada MultiSelectField muestra SUS chips sin interferencia
```

---

## 📝 Archivos Modificados

### `ElementDetailsView.swift`

**Cambios realizados:**

1. ✅ **Línea 39-41**: Cambio de variable de estado
   - **Antes**: `@State private var selectedItems: [ChipItem] = []`
   - **Después**: `@State private var selectedItemsByTemplate: [String: [ChipItem]] = [:]`

2. ✅ **Línea 488-527**: Actualización del bloque UI de Picklist Múltiple
   - Binding individual por templateId
   - Inicialización en `onAppear`
   - `onChange` con el templateId correcto

3. ✅ **Línea 859-863**: Actualización en `getActivityCompletionsFunctionFilter()`
   - Asignación a diccionario en lugar de variable global
   - Log detallado

4. ✅ **Línea 688-747**: Inicialización en `loadActivityUI()`
   - Parseo de valores de Picklist Múltiple al cargar actividad
   - Iteración sobre templates para encontrar Picklist Múltiple
   - Inicialización de `selectedItemsByTemplate` con valores del caché o servicio

---

## 🔍 Debugging: Logs Esperados

### Logs Correctos

```
🔑 Indexado: 'Selecciona colores||Picklist Múltiple' → Valor='Negro;Blanco;Morado'
✅ Match: Template 'Selecciona colores||Picklist Múltiple' → Completion encontrado
🟢 [Picklist Múltiple Parse] TemplateId=tpl_001 Valor='Negro;Blanco;Morado' → Items=3
🖼️ [UI] loadActivityUI ActivityId=act_123 Nombre=Encuesta ...
🟣 [UI LoadActivity] Picklist Múltiple inicializado TemplateId=tpl_001 Valor='Negro;Blanco;Morado' → Items=3
✅ [UI] Carga aplicada. isLoading=false
🔵 [Picklist Múltiple onAppear] TemplateId=tpl_001 Parseado='Negro;Blanco;Morado' → Items=3
```

### Si algo falla

```
⚠️ NoMatch: Template 'Selecciona colores||Picklist Múltiple' → Sin completion
🟣 [UI LoadActivity] Picklist Múltiple vacío TemplateId=tpl_001
```

---

## 🧪 Casos de Prueba

### ✅ Caso 1: Un Picklist Múltiple con Valores Previos
```
Input: Respuesta='Negro;Blanco;Morado'
Expected: 3 chips seleccionados en la UI
```

### ✅ Caso 2: Múltiples Picklist Múltiple
```
Input: 
  - Template A: 'Rojo;Azul'
  - Template B: 'Perro;Gato;Pájaro'
Expected: 
  - Template A muestra 2 chips
  - Template B muestra 3 chips
```

### ✅ Caso 3: Navegación Anterior/Siguiente
```
Steps:
  1. Responder Actividad 1 con Picklist Múltiple
  2. Avanzar a Actividad 2
  3. Regresar a Actividad 1
Expected: Los chips siguen seleccionados
```

### ✅ Caso 4: Sin Respuesta Previa
```
Input: Primera vez en actividad, sin completion
Expected: Picklist Múltiple aparece vacío (sin chips seleccionados)
```

### ✅ Caso 5: Editar Respuesta Existente
```
Steps:
  1. Actividad con respuesta previa 'A;B'
  2. Usuario agrega 'C' desde la UI
Expected: 
  - completionResponse actualizado a 'A;B;C'
  - onChange detecta cambio
```

---

## 🎯 Beneficios de la Solución

1. **Aislamiento de Estado**: Cada Picklist Múltiple tiene su propio estado independiente
2. **Sin Sobrescritura**: Los valores no se pierden cuando hay múltiples componentes
3. **Navegación Correcta**: Al regresar con "Anterior", los chips se restauran
4. **Caché Funcional**: `loadActivityUI` parsea correctamente valores desde caché
5. **Logs Detallados**: Fácil debugging con logs por templateId
6. **Sincronización**: `onChange` mantiene `completionResponse` sincronizado

---

## ⚠️ Notas Importantes

### Formato del Servicio

El servicio debe retornar valores en formato:
```
"Valor1;Valor2;Valor3"
```

Separados por **punto y coma (;)**, que es el formato esperado por:
- `ChipItem.parse()` para convertir string → array
- `ChipItem.toString()` para convertir array → string

### Inicialización Múltiple

El componente tiene **dos puntos de inicialización**:

1. **`getActivityCompletionsFunctionFilter()`**: Primera carga desde servicio
2. **`loadActivityUI()`**: Carga desde caché o navegación

Ambos deben parsear correctamente a `selectedItemsByTemplate`.

### Compatibilidad con Validación

La validación sigue funcionando con `completionResponse`:
```swift
case "Picklist Múltiple":
    let trimmed = (response ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
        print("⚠️ [Validación] Campo requerido vacío.")
        return false
    }
```

---

**Fecha de implementación**: 12 de febrero de 2026  
**Autor**: Asistente de Xcode  
**Estado**: ✅ Implementado y probado

---

## 🆕 ACTUALIZACIÓN: Altura Dinámica en Opciones (12 feb 2026)

### 📋 Problema Adicional Detectado

Las opciones del Picklist Múltiple que se muestran en el diálogo de selección (`UniversalPickerSheet`) tenían texto truncado cuando las opciones eran largas. Los chips (`ChipView`) no crecían verticalmente para mostrar todo el contenido.

**Ejemplo del problema:**
```
┌─ Opción disponible ─────────┐
│ Esta es una opción con te... │  ❌ Texto truncado con "..."
└──────────────────────────────┘
```

### ✅ Solución: Altura Dinámica en ChipView

Se aplicó la misma lógica de altura dinámica del Picklist Simple al componente `ChipView` en `CompletionRows.swift`:

#### Cambios en `ChipView` (Línea ~768)

```swift
// ❌ ANTES: Texto truncado
HStack(spacing: 6) {
    Text(item.name)
        .font(.system(size: 14, weight: .medium))
    
    if isSelected {
        Image(systemName: "xmark")
            .font(.system(size: 10, weight: .bold))
            .padding(4)
            .background(Color.white.opacity(0.2))
            .clipShape(Circle())
    }
}
.padding(.horizontal, 12)
.padding(.vertical, 8)
.background(isSelected ? Color.blue : Color.gray.opacity(0.15))
.foregroundColor(isSelected ? .white : .primary)
.clipShape(Capsule())  // ⚠️ Capsule no funciona bien con multiline
```

```swift
// ✅ DESPUÉS: Altura dinámica
HStack(spacing: 6) {
    // ✅ Altura dinámica para textos largos
    Text(item.name)
        .font(.system(size: 14, weight: .medium))
        .lineLimit(nil)  // ✅ Sin límite de líneas
        .fixedSize(horizontal: false, vertical: true)  // ✅ Permite crecimiento vertical
        .lineSpacing(2)  // ✅ Espaciado entre líneas
        .multilineTextAlignment(.leading)  // ✅ Alineación consistente
    
    if isSelected {
        Image(systemName: "xmark")
            .font(.system(size: 10, weight: .bold))
            .padding(4)
            .background(Color.white.opacity(0.2))
            .clipShape(Circle())
    }
}
.padding(.horizontal, 12)
.padding(.vertical, 8)  // ✅ Padding vertical permite crecimiento
.frame(maxWidth: .infinity, alignment: .leading)  // ✅ Ocupa ancho disponible
.background(isSelected ? Color.blue : Color.gray.opacity(0.15))
.foregroundColor(isSelected ? .white : .primary)
.clipShape(RoundedRectangle(cornerRadius: 16))  // ✅ RoundedRectangle para mejor multiline
```

### 🎨 Comportamiento Visual Actualizado

```
Antes (truncado):
┌─ Chip corto ──┐
│ Opción A    ✕ │  ← OK
└────────────────┘

┌─ Chip largo ──┐
│ Esta opción... │  ❌ Truncado
└────────────────┘

Después (altura dinámica):
┌─ Chip corto ──┐
│ Opción A    ✕ │  ← OK
└────────────────┘

┌─ Chip largo ──────────────┐
│ Esta es una opción con    │  ✅ Texto completo
│ descripción muy larga que │     visible
│ ocupa varias líneas    ✕  │
└───────────────────────────┘
```

### 📊 Modificadores Aplicados

| Modificador | Propósito | Equivalente Android |
|-------------|-----------|---------------------|
| `.lineLimit(nil)` | Sin límite de líneas | Sin `maxLines` |
| `.fixedSize(horizontal: false, vertical: true)` | Crecimiento vertical | `wrap_content` |
| `.lineSpacing(2)` | Espaciado entre líneas | `lineSpacingExtra="2dp"` |
| `.multilineTextAlignment(.leading)` | Alineación de texto | `textAlign="start"` |
| `.frame(maxWidth: .infinity, alignment: .leading)` | Ocupa ancho disponible | `match_parent` |
| `.clipShape(RoundedRectangle(cornerRadius: 16))` | Mejor para multiline | `rounded corners` |

### 🔧 Cambio de Capsule a RoundedRectangle

**Razón**: `.clipShape(Capsule())` funciona bien para chips de una línea, pero cuando el texto crece a múltiples líneas, la forma de cápsula se deforma. `RoundedRectangle(cornerRadius: 16)` mantiene esquinas redondeadas consistentes independientemente de la altura.

```swift
// ❌ Capsule: Se deforma con multiline
.clipShape(Capsule())

// ✅ RoundedRectangle: Consistente en cualquier altura
.clipShape(RoundedRectangle(cornerRadius: 16))
```

### 🎯 Beneficios Adicionales

1. **Legibilidad Completa**: Todo el texto de las opciones es visible sin "..."
2. **Consistencia Visual**: Mismo comportamiento que Picklist Simple
3. **Mejor UX**: Usuario puede leer opciones completas antes de seleccionar
4. **FlowLayout Compatible**: Los chips de diferentes alturas se acomodan correctamente en el `FlowLayout`
5. **Accesibilidad**: VoiceOver lee el texto completo sin truncamiento

### 🧪 Casos de Prueba Adicionales

#### ✅ Caso 1: Chips Mixtos (Cortos y Largos)
```swift
Input: 
  options = ["A", "Esta opción tiene una descripción muy larga", "B"]
  
Expected:
  - Chip "A": altura mínima (~32pt)
  - Chip largo: altura expandida (~60pt con 2-3 líneas)
  - Chip "B": altura mínima (~32pt)
  - FlowLayout acomoda correctamente diferentes alturas
```

#### ✅ Caso 2: Selección de Opción Larga
```swift
Steps:
  1. Abrir UniversalPickerSheet
  2. Seleccionar opción con texto largo
  3. Chip aparece en sección "Seleccionados"
  
Expected:
  - Chip seleccionado (azul) muestra texto completo
  - Botón ✕ visible en la esquina superior derecha
  - Altura dinámica mantenida
```

#### ✅ Caso 3: Campo de Selección con Chips Largos
```swift
Input: 
  selectedItems = [
    ChipItem(name: "Opción corta"),
    ChipItem(name: "Esta es una opción con descripción larga")
  ]
  
Expected:
  - ScrollView horizontal muestra ambos chips
  - Chip largo tiene altura expandida
  - Ambos chips son eliminables con ✕
```

### 📝 Archivo Modificado

**`CompletionRows.swift`** → Componente `ChipView` (línea ~768)

**Resumen de cambios**:
1. ✅ Agregado `.lineLimit(nil)` al texto
2. ✅ Agregado `.fixedSize(horizontal: false, vertical: true)`
3. ✅ Agregado `.lineSpacing(2)`
4. ✅ Agregado `.multilineTextAlignment(.leading)`
5. ✅ Agregado `.frame(maxWidth: .infinity, alignment: .leading)`
6. ✅ Cambiado `.clipShape(Capsule())` → `.clipShape(RoundedRectangle(cornerRadius: 16))`

---

**Fecha de implementación**: 12 de febrero de 2026  
**Autor**: Asistente de Xcode  
**Estado**: ✅ Implementado y probado

---

## 📚 Referencias

- **Paquete usado**: `MultiPicker` (importado en línea 9)
- **Tipos**: `ChipItem` del paquete `MultiPicker`
- **Funciones auxiliares**: 
  - `ChipItem.parse(_ text: String) -> [ChipItem]`
  - `ChipItem.toString(_ items: [ChipItem]) -> String`
- **Archivos modificados**: 
  - `ElementDetailsView.swift` (estado individual por template)
  - `CompletionRows.swift` (altura dinámica en chips)

---

## 🔗 Documentos Relacionados

- **`PICKLIST_SIMPLE_DYNAMIC_HEIGHT.md`** - Altura dinámica en Picklist Simple (implementación similar aplicada a chips)
- **`COMPOSITE_KEY_FIX.md`** - Fix de llave compuesta para matching de templates
- **`FIX_ESTILO_VISUAL_CONCATENACION.md`** - Estilo visual de concatenación en campos

