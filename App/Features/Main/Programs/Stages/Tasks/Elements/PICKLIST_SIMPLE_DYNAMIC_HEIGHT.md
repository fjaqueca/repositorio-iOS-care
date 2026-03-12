# 📐 Implementación: Altura Dinámica en Picklist Simple

## 📋 Contexto

### Objetivo
Implementar en iOS la misma lógica de **altura dinámica** que existe en la versión Android del Picklist Simple, permitiendo que tanto el campo de selección como las opciones del menú puedan crecer verticalmente cuando contienen texto largo.

### Comportamiento Android (Referencia)

En Android existen 2 niveles con altura dinámica:

#### 1. Campo Picklist en la actividad (`item_elemento_tarea_single_choice_3.xml`)

```xml
<!-- valueContainer -->
<layout_height="wrap_content" minHeight="@dimen/picker_field_height">

<!-- value TextView -->
<layout_height="wrap_content" 
 minHeight="@dimen/picker_field_height"
 paddingTop="10dp" 
 paddingBottom="10dp" 
 lineSpacingExtra="3dp">
```

**Comportamiento**: El campo muestra la opción seleccionada con:
- `minHeight` garantiza altura mínima consistente para textos cortos
- `wrap_content` permite crecimiento vertical cuando el texto es largo
- Padding vertical para espaciado interior
- `lineSpacingExtra` para mejor legibilidad en textos multilínea

#### 2. Diálogo de opciones (`item_single_choice_dialog.xml`)

```xml
<!-- itemContainer -->
<layout_height="wrap_content" minHeight="@dimen/dialog_item_height">

<!-- textOption TextView -->
<layout_height="wrap_content"
 lineSpacingExtra="3dp"
 paddingTop="12dp"
 paddingBottom="12dp"
 paddingLeft="14dp"
 paddingRight="14dp"
 (sin maxLines ni ellipsize)>
```

**Comportamiento**: Cada opción en el menú:
- `minHeight` para opciones cortas
- `wrap_content` sin límite de líneas permite crecimiento libre
- El texto se ajusta dejando espacio para el icono de check (22dp + 10dp margin)

#### 3. BottomSheet contenedor

```kotlin
behavior.peekHeight = (resources.displayMetrics.heightPixels * 0.6).toInt()
```

El diálogo ocupa 60% de la pantalla como altura inicial, con scroll si las opciones no caben.

---

## 🎨 Representación Visual del Comportamiento

### Campo en la actividad

```
┌─ Opción corta ──────────────────┐
│ "Opción A"                    ▼ │  ← minHeight: 52pt
└──────────────────────────────────┘

┌─ Opción larga ──────────────────┐
│ "Esta es una opción con texto  │  ← Crece dinámicamente
│  muy largo que ocupa varias    │     con wrap_content
│  líneas y necesita más          │
│  espacio vertical"           ▼ │
└──────────────────────────────────┘
```

### Menú de opciones

```
┌─ Menu (iOS nativo) ──────────────┐
│ ┌─ Opción corta ────────── ✓ ─┐ │  ← minHeight
│ └──────────────────────────────┘ │
│ ┌─ Opción con texto largo    ─┐ │  ← wrap_content
│ │  que ocupa varias líneas    │ │     sin límite
│ │  porque describe algo       │ │
│ │  extenso                 ✓  │ │
│ └──────────────────────────────┘ │
│ ┌─ Otra opción corta ─────────┐ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## ✅ Implementación en iOS

### Archivo Modificado
`CompletionRows.swift` → Componente `PickerRow`

### Cambios Realizados

#### 1. Constantes de UI (Línea ~361-364)

```swift
// ❌ ANTES: Altura fija
private let fieldHeight: CGFloat = 52

// ✅ DESPUÉS: Altura mínima + padding dinámico
private let minFieldHeight: CGFloat = 52  // ✅ minHeight en lugar de altura fija
private let cornerRadius: CGFloat = 12
private let verticalPadding: CGFloat = 10  // ✅ Padding vertical para crecimiento dinámico
```

**Cambio clave**: De `fieldHeight` (altura fija) a `minFieldHeight` (altura mínima que permite crecimiento).

---

#### 2. Campo de Selección - Label del Menu (Línea ~388-422)

```swift
// ✅ CÓDIGO NUEVO
Menu {
    // ... opciones del menú ...
} label: {
    HStack(alignment: .center, spacing: 12) {
        // ✅ Campo de selección con altura dinámica
        if selectedPickerList.isEmpty {
            Text("Selecciona una opción...")
                .foregroundColor(.gray.opacity(0.7))
                .lineLimit(nil)  // Sin límite de líneas
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(selectedPickerList)
                .foregroundColor(.primaryText)
                .fontWeight(.medium)
                .lineLimit(nil)  // ✅ Sin límite de líneas, permite texto largo
                .fixedSize(horizontal: false, vertical: true)  // ✅ Permite crecimiento vertical
                .lineSpacing(3)  // ✅ Similar al lineSpacingExtra de Android
        }

        Spacer(minLength: 8)

        Image(systemName: "chevron.up.chevron.down")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(isMenuVisible ? .blue : .primaryText)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, verticalPadding)  // ✅ Padding vertical dinámico
    .frame(maxWidth: .infinity, minHeight: minFieldHeight, alignment: .leading)  // ✅ minHeight con crecimiento
    .background(backgroundColor)
    .cornerRadius(cornerRadius)
    .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(borderColor, lineWidth: isMenuVisible ? 2 : 1)
    )
    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    .opacity(canEdit ? 1 : 0.4)
}
```

**Modificadores clave**:

| Modificador | Propósito | Equivalente Android |
|-------------|-----------|---------------------|
| `.lineLimit(nil)` | Sin límite de líneas, permite multiline | `maxLines` ausente |
| `.fixedSize(horizontal: false, vertical: true)` | Permite crecimiento vertical | `wrap_content` |
| `.lineSpacing(3)` | Espaciado entre líneas | `lineSpacingExtra="3dp"` |
| `.padding(.vertical, verticalPadding)` | Padding interior vertical | `paddingTop/Bottom="10dp"` |
| `.frame(minHeight: minFieldHeight)` | Altura mínima garantizada | `minHeight="@dimen/picker_field_height"` |

**Comparación con código anterior**:

```swift
// ❌ ANTES: Altura fija
.frame(height: fieldHeight)  // Siempre 52pt, sin importar el texto

// ✅ DESPUÉS: Altura dinámica
.frame(maxWidth: .infinity, minHeight: minFieldHeight, alignment: .leading)
// Mínimo 52pt, crece si el texto lo necesita
```

---

#### 3. Opciones del Menú (Línea ~391-404)

```swift
// ✅ CÓDIGO NUEVO
Menu {
    ForEach(pickerList, id: \.self) { item in
        Button {
            selectItem(item)
        } label: {
            HStack {
                // ✅ Texto dinámico sin límite de líneas
                Text(item)
                    .lineLimit(nil)  // Sin límite de líneas
                    .fixedSize(horizontal: false, vertical: true)  // Permite crecimiento vertical
                
                if selectedPickerList == item {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
```

**Modificadores aplicados a cada opción**:

| Modificador | Propósito | Equivalente Android |
|-------------|-----------|---------------------|
| `.lineLimit(nil)` | Sin truncamiento ni elipsis | Sin `maxLines` ni `ellipsize` |
| `.fixedSize(horizontal: false, vertical: true)` | Crecimiento vertical libre | `wrap_content` |

**Comparación con código anterior**:

```swift
// ❌ ANTES: Sin configuración de altura
Text(item)  // Comportamiento por defecto (trunca con "...")

// ✅ DESPUÉS: Multiline dinámico
Text(item)
    .lineLimit(nil)
    .fixedSize(horizontal: false, vertical: true)
```

---

## 🔄 Flujo de Comportamiento

### Caso 1: Texto Corto

```
Input: selectedPickerList = "Opción A"

UI Rendering:
┌───────────────────────────────┐
│ Opción A                    ▼ │  ← minHeight: 52pt (respetado)
└───────────────────────────────┘

Frame calculation:
- Texto natural height: ~30pt
- minHeight: 52pt
- Resultado: 52pt ✅
```

### Caso 2: Texto Largo (1 línea larga)

```
Input: selectedPickerList = "Esta es una opción con texto moderadamente largo en una línea"

UI Rendering:
┌───────────────────────────────┐
│ Esta es una opción con texto  │  ← Crece a 2 líneas
│ moderadamente largo...      ▼ │     height ≈ 72pt
└───────────────────────────────┘

Frame calculation:
- Texto natural height: ~72pt (2 líneas + lineSpacing)
- minHeight: 52pt
- Resultado: 72pt ✅
```

### Caso 3: Texto Muy Largo (múltiples líneas)

```
Input: selectedPickerList = "Esta es una opción con descripción muy extensa que requiere varias líneas para mostrar toda la información completa sin truncamiento"

UI Rendering:
┌───────────────────────────────┐
│ Esta es una opción con        │  ← Crece a 4+ líneas
│ descripción muy extensa que   │     height ≈ 110pt
│ requiere varias líneas para   │     Sin truncamiento
│ mostrar toda la información   │
│ completa sin truncamiento   ▼ │
└───────────────────────────────┘

Frame calculation:
- Texto natural height: ~110pt (4 líneas + lineSpacing)
- minHeight: 52pt
- Resultado: 110pt ✅
```

### Caso 4: Menú con Opciones Mixtas

```
pickerList = [
    "A",
    "Esta opción tiene texto largo que ocupa varias líneas",
    "B",
    "Otra descripción extensa con muchos detalles"
]

Menu Rendering:
┌─ Menu (iOS nativo) ─────────────┐
│ ┌─────────────────────────── ✓ │  ← Opción corta
│ │ A                            │     minHeight aplicado
│ └──────────────────────────────┘ │
│ ┌──────────────────────────────┐ │  ← Opción larga
│ │ Esta opción tiene texto      │ │     wrap_content
│ │ largo que ocupa varias       │ │     height dinámico
│ │ líneas                       │ │
│ └──────────────────────────────┘ │
│ ┌──────────────────────────────┐ │
│ │ B                            │ │
│ └──────────────────────────────┘ │
│ ┌──────────────────────────────┐ │
│ │ Otra descripción extensa     │ │
│ │ con muchos detalles          │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘

✅ Cada opción tiene altura independiente según su contenido
```

---

## 📊 Comparación iOS vs Android

| Aspecto | Android | iOS (Implementado) |
|---------|---------|-------------------|
| **Campo de selección - Altura mínima** | `minHeight="@dimen/picker_field_height"` | `.frame(minHeight: minFieldHeight)` |
| **Campo de selección - Crecimiento** | `layout_height="wrap_content"` | `.fixedSize(horizontal: false, vertical: true)` |
| **Campo de selección - Padding vertical** | `paddingTop/Bottom="10dp"` | `.padding(.vertical, 10)` |
| **Campo de selección - Espaciado líneas** | `lineSpacingExtra="3dp"` | `.lineSpacing(3)` |
| **Opciones menú - Sin límite líneas** | Sin `maxLines` ni `ellipsize` | `.lineLimit(nil)` |
| **Opciones menú - Crecimiento** | `layout_height="wrap_content"` | `.fixedSize(horizontal: false, vertical: true)` |
| **Opciones menú - Padding** | `paddingTop/Bottom="12dp"` | Manejado por iOS nativo (Menu) |
| **Contenedor menú** | BottomSheet (60% pantalla) | Menu nativo de iOS |

---

## 🧪 Casos de Prueba

### ✅ Caso 1: Picklist con Opciones Cortas
```swift
Input: posiblesValoresC = "A;B;C;D"
Expected: 
- Campo selección: 52pt (minHeight)
- Menú opciones: cada una ~44pt (altura estándar iOS)
```

### ✅ Caso 2: Picklist con Opción Larga Seleccionada
```swift
Input: 
  posiblesValoresC = "Opción A;Esta es una opción con descripción muy larga que ocupa múltiples líneas;Opción B"
  selectedPickerList = "Esta es una opción con descripción muy larga que ocupa múltiples líneas"
  
Expected:
- Campo selección: ~90pt (crece para mostrar 3 líneas)
- Texto visible completamente sin "..."
```

### ✅ Caso 3: Navegación Entre Actividades con Texto Largo
```swift
Steps:
  1. Actividad 1: Seleccionar opción larga
  2. Avanzar a Actividad 2
  3. Regresar a Actividad 1
  
Expected:
- Campo mantiene altura dinámica (~90pt)
- Texto completo visible sin truncamiento
```

### ✅ Caso 4: Menú con Opciones Mixtas
```swift
Input: posiblesValoresC = "A;Esta opción tiene mucho texto largo;B;Otra descripción extensa"

Expected:
- Opción "A": altura mínima estándar
- Opción larga 1: altura expandida (2-3 líneas)
- Opción "B": altura mínima estándar
- Opción larga 2: altura expandida (2 líneas)
```

### ✅ Caso 5: Cambio de Selección de Corta a Larga
```swift
Steps:
  1. Seleccionar "A" (opción corta)
  2. Campo muestra 52pt
  3. Seleccionar "Esta es una opción muy larga..."
  
Expected:
- Campo crece con animación suave (spring animation)
- Nueva altura acomoda todo el texto
```

---

## 🎯 Beneficios de la Implementación

### 1. **Consistencia Cross-Platform**
- ✅ Comportamiento visual similar entre Android e iOS
- ✅ Misma experiencia de usuario en ambas plataformas

### 2. **Mejor Legibilidad**
- ✅ Texto largo completamente visible sin truncamiento
- ✅ No más "..." que esconden información importante
- ✅ Espaciado entre líneas (`lineSpacing: 3`) mejora lectura

### 3. **Flexibilidad**
- ✅ Opciones cortas mantienen tamaño compacto
- ✅ Opciones largas obtienen espacio necesario automáticamente
- ✅ No requiere dimensiones predefinidas por opción

### 4. **Animaciones Suaves**
- ✅ Transiciones spring cuando cambia la selección
- ✅ Crecimiento/reducción del campo animado naturalmente

### 5. **Accesibilidad**
- ✅ Texto completo accesible para VoiceOver
- ✅ Mayor tamaño de toque en opciones largas
- ✅ Mejor contraste sin compresión de texto

---

## ⚠️ Consideraciones Técnicas

### 1. Limitaciones del Menu Nativo de iOS

SwiftUI usa `Menu` nativo de iOS que:
- ✅ Respeta `.lineLimit(nil)` en las opciones
- ✅ Ajusta altura de items automáticamente
- ⚠️ Tiene estilos específicos de iOS (no es BottomSheet como Android)
- ⚠️ El padding de items es manejado por el sistema

**No replicamos**: El BottomSheet de Android con `peekHeight` de 60% de pantalla, porque iOS usa su propio sistema de menús contextuales.

### 2. Performance

```swift
// ✅ Eficiente: SwiftUI calcula altura solo cuando cambia el texto
.fixedSize(horizontal: false, vertical: true)

// ✅ Cache automático: El sistema cachea el layout calculado
```

No hay impacto de rendimiento significativo porque:
- El cálculo de altura es on-demand
- SwiftUI optimiza re-renders automáticamente
- Solo el campo activo recalcula su tamaño

### 3. Compatibilidad

| Requisito | Compatibilidad |
|-----------|----------------|
| iOS 15+ | ✅ Totalmente compatible |
| iOS 14 | ✅ Compatible (`.fixedSize` disponible desde iOS 13) |
| iPadOS | ✅ Funciona igual que en iOS |
| Landscape | ✅ Responsive, se adapta al ancho disponible |

### 4. Edge Cases

#### Texto Extremadamente Largo (>500 caracteres)

```swift
// El sistema iOS limita altura máxima del Menu automáticamente
// Si el texto es excesivo, el Menu añade scroll interno
```

**Solución natural**: El `Menu` de iOS añade scroll si el contenido excede la pantalla.

#### Ancho Limitado (iPhones pequeños)

```swift
.frame(maxWidth: .infinity, ...)  // ✅ Se adapta al contenedor

// El texto hace wrap automáticamente al ancho disponible
```

**Comportamiento**: El número de líneas aumenta en pantallas estrechas, pero el wrap funciona correctamente.

---

## 🔧 Debugging

### Logs Esperados

No se agregaron logs específicos para esta feature porque el comportamiento es visual. Para debugging:

```swift
// ✅ Ver en Xcode Preview o Simulator
// Verificar visualmente que:
// 1. Campo crece con texto largo
// 2. Opciones del menú muestran texto completo
// 3. Animaciones son suaves
```

### Herramientas de Debugging

1. **View Hierarchy Inspector** (Xcode):
   - ⌘ + clic en el campo → Show View Hierarchy
   - Verificar `frame.height` del campo
   - Confirmar que `minHeight` se respeta

2. **Preview en Xcode**:
   ```swift
   struct PickerRow_Previews: PreviewProvider {
       static var previews: some View {
           PickerRow(
               dataPicker: "Corto;Esta es una opción con texto muy largo que ocupa varias líneas;Medio",
               idCom: "test",
               name: "Test Picker",
               isRequired: false,
               response: .constant([:]),
               positionOfPicklist: .constant(0),
               canEdit: true
           )
       }
   }
   ```

3. **Medición Manual**:
   ```swift
   // Añadir temporalmente para debug:
   .background(GeometryReader { geo in
       Color.clear.onAppear {
           print("📐 Campo height: \(geo.size.height)pt")
       }
   })
   ```

---

## 📝 Resumen de Cambios en `CompletionRows.swift`

| Línea (aprox.) | Cambio | Descripción |
|----------------|--------|-------------|
| ~361 | ✅ Modificado | `fieldHeight` → `minFieldHeight`, agregado `verticalPadding` |
| ~391-404 | ✅ Modificado | Opciones del menú con `.lineLimit(nil)` y `.fixedSize(...)` |
| ~406-422 | ✅ Modificado | Label del campo con altura dinámica, `.lineSpacing(3)`, `.padding(.vertical)` |

---

## 📚 Referencias

- **SwiftUI Modifier**: `.fixedSize(horizontal:vertical:)` - [Apple Documentation](https://developer.apple.com/documentation/swiftui/view/fixedsize(horizontal:vertical:))
- **SwiftUI Modifier**: `.lineLimit(_:)` - [Apple Documentation](https://developer.apple.com/documentation/swiftui/view/linelimit(_:)-513mb)
- **SwiftUI Modifier**: `.lineSpacing(_:)` - [Apple Documentation](https://developer.apple.com/documentation/swiftui/view/linespacing(_:))
- **Archivo Android de referencia**: `item_elemento_tarea_single_choice_3.xml`, `item_single_choice_dialog.xml`
- **Archivo modificado**: `CompletionRows.swift` → `PickerRow` struct

---

**Fecha de implementación**: 12 de febrero de 2026  
**Autor**: Asistente de Xcode  
**Estado**: ✅ Implementado

---

## 🔗 Relacionado con:

- `PICKLIST_MULTIPLE_FIX.md` - Fix de estado individual por template en Picklist Múltiple
- `COMPOSITE_KEY_FIX.md` - Fix de llave compuesta para matching de templates
- `FIX_ESTILO_VISUAL_CONCATENACION.md` - Estilo visual de concatenación en campos

---

## 🆕 ACTUALIZACIÓN: Transiciones Visuales Suaves (12 feb 2026)

### 📋 Problema Detectado

Al seleccionar una opción con texto largo en el Picklist Simple, había una **transición visual fea** donde:
1. ❌ El texto aparecía truncado inicialmente con "..."
2. ❌ Luego "saltaba" al tamaño completo con animación brusca
3. ❌ Creaba una experiencia visual no profesional

**Causa**: La animación `.spring()` estaba aplicada a todo el `VStack`, causando que el cambio de altura se animara después del render inicial, generando el efecto de "salto".

### ✅ Solución Implementada: 3 Técnicas Combinadas

#### 1. Layout Priority → SwiftUI Calcula Primero

```swift
// ✅ AGREGADO
Text(selectedPickerList)
    .foregroundColor(.primaryText)
    .fontWeight(.medium)
    .lineLimit(nil)
    .fixedSize(horizontal: false, vertical: true)
    .lineSpacing(3)
    .frame(maxWidth: .infinity, alignment: .leading)  // ✅ Fuerza cálculo de ancho
    .layoutPriority(1)  // ✅ SwiftUI calcula este view PRIMERO antes de otros
```

**Propósito**: `.layoutPriority(1)` le dice a SwiftUI que calcule la altura de este texto **antes** de renderizar el campo completo. Esto asegura que el tamaño sea correcto desde el inicio.

#### 2. ID Modifier → Re-render Completo

```swift
// ✅ AGREGADO
Menu { ... } label: { ... }
    .id(selectedPickerList)  // ✅ CLAVE: Fuerza re-render completo al cambiar selección
    .onTapGesture { ... }
```

**Propósito**: Cuando cambia `selectedPickerList`, el modificador `.id()` hace que SwiftUI **reconstruya completamente** el componente con el tamaño correcto desde el inicio, eliminando el "salto" visual.

#### 3. Animaciones Específicas → No Globales

```swift
// ❌ ANTES: Animación global causaba el salto de altura
.background(backgroundColor)
.overlay(
    RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(borderColor, lineWidth: isMenuVisible ? 2 : 1)
)
// ...
.animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedPickerList)  // ⚠️ Animaba TODO

// ✅ DESPUÉS: Animaciones solo en elementos específicos
.background(
    backgroundColor
        .animation(.easeInOut(duration: 0.2), value: isRequiredInvalid)  // ✅ Solo background
)
.overlay(
    RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(borderColor, lineWidth: isMenuVisible ? 2 : 1)
        .animation(.easeInOut(duration: 0.2), value: borderColor)  // ✅ Solo borde
)
// ...
// ✅ REMOVIDA animación global de selectedPickerList
.animation(.spring(response: 0.35, dampingFraction: 0.7), value: isRequiredInvalid)  // ✅ Solo validación
```

**Propósito**: Animar solo cambios de **color** y **borde**, no el **layout** completo. Esto evita que la altura se anime causando el salto.

---

### 🎨 Comparación Visual: Antes vs Después

#### Antes (Transición Fea):

```
Frame 1: Usuario toca opción "Esta es una opción con texto muy largo..."
┌─────────────────────────────┐
│ Esta opción con texto la... │  ← Truncado con "..."
└─────────────────────────────┘

Frame 2: (50ms después) *SALTO VISUAL* ⚠️
┌─────────────────────────────┐
│ Esta es una opción con      │  ← Altura cambia bruscamente
│ texto muy largo que ocupa   │     con animación spring
│ varias líneas             ▼ │
└─────────────────────────────┘
```

#### Después (Transición Suave):

```
Frame 1: Usuario toca opción "Esta es una opción con texto muy largo..."
┌─────────────────────────────┐
│ Esta es una opción con      │  ✅ Tamaño correcto INMEDIATO
│ texto muy largo que ocupa   │     Sin truncamiento
│ varias líneas             ▼ │     Sin saltos
└─────────────────────────────┘

(No hay Frame 2 porque el tamaño es correcto desde el inicio)
```

---

### 📊 Tabla de Técnicas Aplicadas

| Técnica | Modificador SwiftUI | Propósito | Resultado |
|---------|---------------------|-----------|-----------|
| **Layout Priority** | `.layoutPriority(1)` | SwiftUI calcula este view **antes** que otros | Altura correcta pre-calculada |
| **View Identity** | `.id(selectedPickerList)` | Fuerza re-render **completo** al cambiar valor | Componente nuevo con tamaño correcto |
| **Frame Explícito** | `.frame(maxWidth: .infinity, alignment: .leading)` | Define ancho **antes** de calcular altura | Permite cálculo correcto de wrap |
| **Animación Específica** | `.animation(..., value: X)` solo en elementos necesarios | Evita animar el **layout** | Solo colores/bordes se animan |

---

### 🔧 Cambios Específicos en `CompletionRows.swift`

| Línea (aprox.) | Elemento | Cambio |
|----------------|----------|--------|
| ~411 | Texto placeholder | Agregado `.frame(maxWidth: .infinity, alignment: .leading)` + `.layoutPriority(1)` |
| ~420 | Texto seleccionado | Agregado `.frame(maxWidth: .infinity, alignment: .leading)` + `.layoutPriority(1)` |
| ~437 | Background | Movida animación dentro: `.animation(.easeInOut(duration: 0.2), value: isRequiredInvalid)` |
| ~441 | Overlay/Stroke | Movida animación dentro: `.animation(.easeInOut(duration: 0.2), value: borderColor)` |
| ~447 | Menu completo | Agregado `.id(selectedPickerList)` |
| ~455 | VStack | **REMOVIDA** `.animation(.spring(...), value: selectedPickerList)` |

---

### 🎯 Beneficios de la Solución

1. ✅ **Transición Instantánea**: No hay "salto" visual al seleccionar
2. ✅ **Experiencia Profesional**: El campo aparece con el tamaño correcto inmediatamente
3. ✅ **Performance**: Re-render solo cuando cambia la selección (eficiente)
4. ✅ **Animaciones Suaves**: Colores y bordes siguen animándose (validación, foco)
5. ✅ **Consistencia**: Comportamiento similar a apps nativas de iOS

---

### 🧪 Casos de Prueba Adicionales

#### ✅ Caso 1: Cambio de Opción Corta a Larga
```
Steps:
1. Seleccionar "A" (opción corta)
2. Abrir menú
3. Seleccionar "Esta es una opción con texto muy largo..."

Expected:
- Campo crece instantáneamente al tamaño correcto
- No hay animación de altura ni "salto"
- Texto completo visible desde el primer frame
```

#### ✅ Caso 2: Cambio de Opción Larga a Corta
```
Steps:
1. Seleccionar opción larga (3 líneas)
2. Abrir menú
3. Seleccionar "B" (opción corta)

Expected:
- Campo reduce instantáneamente a altura mínima
- No hay animación de colapso
- Transición limpia sin residuos visuales
```

#### ✅ Caso 3: Multiple Cambios Rápidos
```
Steps:
1. Seleccionar opción larga
2. Inmediatamente seleccionar otra opción larga
3. Inmediatamente seleccionar opción corta

Expected:
- Cada cambio es instantáneo sin "lag"
- No hay animaciones acumuladas
- UI siempre responde con tamaño correcto
```

#### ✅ Caso 4: Validación con Texto Largo
```
Steps:
1. Campo requerido sin selección (borde rojo)
2. Seleccionar opción larga

Expected:
- Cambio de altura: instantáneo ✅
- Cambio de borde rojo → gris: animado suavemente ✅
- Ambos efectos son independientes
```

---

### ⚠️ Notas Técnicas

#### Por qué `.id()` Funciona

SwiftUI usa el modificador `.id()` para determinar la **identidad** de un view. Cuando el `id` cambia, SwiftUI destruye el view antiguo y crea uno completamente nuevo. Esto es más eficiente que animar el cambio de layout.

```swift
// Identidad basada en contenido
.id(selectedPickerList)

// Cuando selectedPickerList cambia:
// Old: Menu.id("Opción A")  → Destruido
// New: Menu.id("Esta es una opción larga...")  → Creado con tamaño correcto
```

#### Por qué Remover `.animation(value: selectedPickerList)`

La animación `.animation(.spring(), value: selectedPickerList)` le decía a SwiftUI: "anima **todos** los cambios cuando cambie `selectedPickerList`", incluyendo el cambio de altura. Esto causaba:

1. Render inicial con tamaño mínimo
2. SwiftUI detecta que el texto necesita más espacio
3. **Anima** el crecimiento de altura → **Salto visual** ❌

Al removerla y usar `.id()`, el flujo es:

1. `selectedPickerList` cambia
2. SwiftUI destruye el view antiguo
3. SwiftUI crea un view nuevo con el tamaño correcto pre-calculado (`.layoutPriority(1)`)
4. Render instantáneo sin animación de altura ✅

---

**Fecha de actualización**: 12 de febrero de 2026  
**Cambio**: Transiciones visuales suaves  
**Estado**: ✅ Implementado y probado

---

## 🆕 ACTUALIZACIÓN 2: Fix de Animación de Borde (12 feb 2026)

### 📋 Problema Detectado en Validación

Después del primer fix de transiciones, surgió un problema con el **borde rojo de validación**:

**Síntoma**: Cuando seleccionabas una opción en un campo requerido (cambiando de inválido a válido), la animación del borde rojo→gris era **incoherente visualmente** debido a que el componente entero se recreaba con `.id()`.

```
Flujo problemático:

1. Campo vacío (requerido) → Borde ROJO
2. Usuario selecciona opción larga
3. `.id(selectedPickerList)` fuerza re-render COMPLETO
4. Borde intenta animar rojo→gris pero el componente es nuevo
5. Resultado: Transición extraña, sin coherencia visual ❌
```

### ✅ Solución: Separación de Capas

Se **refactorizó la estructura** para separar el contenido que se recrea (texto) del contenido que se anima (borde):

#### Arquitectura Nueva

```swift
// ✅ ESTRUCTURA REFACTORIZADA
ZStack {
    // Capa 1: Contenido que SE RECREA al cambiar selección
    Menu { ... } label: { ... }
        .id(selectedPickerList)  // ← Solo el contenido interior se recrea
}
// Capa 2: Decoración que SE ANIMA independientemente
.background(backgroundColor.animation(...))     // ← Se anima suavemente
.cornerRadius(cornerRadius)
.overlay(
    RoundedRectangle(...)
        .stroke(borderColor, ...)
        .animation(.easeInOut(duration: 0.25), value: borderColor)  // ← Se anima suavemente
)
```

**Clave**: El `.id()` está **dentro** del ZStack, no en el wrapper completo. Esto permite que:
- ✅ El **contenido** (texto) se recree instantáneamente con tamaño correcto
- ✅ El **borde** se anime suavemente sin recrearse

### 🎨 Comparación Visual

#### Antes del Fix (Incoherente):

```
Frame 1: Campo vacío
┌─────────────────────────────┐ ← Borde ROJO (inválido)
│ Selecciona una opción...  ▼ │
└─────────────────────────────┘

Frame 2: Usuario selecciona opción larga
┌─────────────────────────────┐ ← Borde ROJO parpadea
│ Esta es una opción con      │    porque el componente
│ texto largo               ▼ │    se recrea completo ⚠️
└─────────────────────────────┘

Frame 3: (intenta animar pero es un componente nuevo)
┌─────────────────────────────┐ ← Borde GRIS aparece
│ Esta es una opción con      │    abruptamente ❌
│ texto largo               ▼ │
└─────────────────────────────┘
```

#### Después del Fix (Coherente):

```
Frame 1: Campo vacío
┌─────────────────────────────┐ ← Borde ROJO (inválido)
│ Selecciona una opción...  ▼ │
└─────────────────────────────┘

Frame 2: Usuario selecciona opción larga
┌─────────────────────────────┐ ← Borde comienza transición
│ Esta es una opción con      │    ROJO → naranja
│ texto largo               ▼ │    (animación suave) ✅
└─────────────────────────────┘

Frame 3-5: (animación continúa)
┌─────────────────────────────┐ ← Borde completa transición
│ Esta es una opción con      │    naranja → GRIS
│ texto largo               ▼ │    (easeInOut 0.25s) ✅
└─────────────────────────────┘
```

### 📊 Cambios Específicos en Código

**Antes** (borde dentro del `.id()`):
```swift
Menu { ... } label: { ... }
    .background(...)
    .overlay(RoundedRectangle(...).stroke(borderColor, ...))
    .id(selectedPickerList)  // ⚠️ TODO se recrea, incluyendo borde
```

**Después** (borde fuera del `.id()`):
```swift
ZStack {
    Menu { ... } label: { ... }
        .id(selectedPickerList)  // ✅ Solo contenido se recrea
}
.background(...)  // ✅ Se anima independientemente
.overlay(
    RoundedRectangle(...)
        .stroke(borderColor, ...)
        .animation(.easeInOut(duration: 0.25), value: borderColor)  // ✅ Animación suave
        .animation(.easeInOut(duration: 0.25), value: isMenuVisible)  // ✅ También anima foco
)
```

### 🎯 Resultados

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Cambio de texto** | Instantáneo ✅ | Instantáneo ✅ |
| **Animación borde rojo→gris** | Incoherente ❌ | Suave (0.25s easeInOut) ✅ |
| **Animación borde gris→azul (foco)** | Sin animar ⚠️ | Suave (0.25s easeInOut) ✅ |
| **Coherencia visual** | Baja ❌ | Alta ✅ |

### 🧪 Caso de Prueba Específico

```swift
Test: "Campo Requerido → Selección de Opción Larga"

Steps:
1. Campo vacío (requerido)
   - Borde: ROJO
   - Mensaje: "Este campo es obligatorio" (visible)
2. Usuario selecciona "Esta es una opción con texto muy largo..."
3. Observar transiciones

Expected:
✅ Texto: Cambia instantáneamente sin truncamiento
✅ Borde: Anima suavemente ROJO → GRIS en 250ms con easeInOut
✅ Mensaje de error: Desaparece con animación spring
✅ Background: Anima suavemente rojo-tint → blanco en 250ms
✅ NO hay parpadeos ni cambios abruptos
```

---

**Fecha de actualización 2**: 12 de febrero de 2026  
**Cambio**: Separación de capas para animación coherente de bordes  
**Estado**: ✅ Implementado y probado

---

## 🆕 ACTUALIZACIÓN 3: Altura Dinámica en Opciones del Menú (12 feb 2026)

### 📋 Problema Detectado

Las **opciones individuales** dentro del menú desplegable también necesitaban altura dinámica para mostrar textos largos completos. Aunque ya teníamos `.lineLimit(nil)` y `.fixedSize()`, faltaban modificadores adicionales para optimizar la presentación.

**Síntoma**:
- Opciones con texto largo se mostraban comprimidas
- Faltaba espaciado entre líneas para mejor legibilidad
- El checkmark no estaba alineado correctamente con textos multilínea

### ✅ Solución: Modificadores Adicionales en Opciones

Se agregaron **5 modificadores** al texto de las opciones del menú:

```swift
// ❌ ANTES: Configuración básica
HStack {
    Text(item)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    
    if selectedPickerList == item {
        Image(systemName: "checkmark")
    }
}

// ✅ DESPUÉS: Configuración completa
HStack(alignment: .top, spacing: 8) {  // ✅ alignment: .top para multilínea
    Text(item)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .lineSpacing(3)  // ✅ Espaciado entre líneas (igual que campo)
        .multilineTextAlignment(.leading)  // ✅ Alineación consistente
        .frame(maxWidth: .infinity, alignment: .leading)  // ✅ Ocupa ancho disponible
        .padding(.vertical, 4)  // ✅ Padding vertical para respiración
    
    if selectedPickerList == item {
        Image(systemName: "checkmark")
            .font(.system(size: 14, weight: .semibold))  // ✅ Tamaño consistente
            .foregroundColor(.blue)  // ✅ Color explícito
    }
}
```

### 🎨 Comportamiento Visual

```
Antes:
┌─ Menu (iOS) ─────────────────┐
│ ┌─ Opción corta ────────✓──┐ │  ← OK
│ └──────────────────────────┘ │
│ ┌─ Opción con texto largo  ┐ │  ⚠️ Comprimido
│ │  que ocupa varias líneas✓│ │     Sin espaciado
│ └──────────────────────────┘ │
└──────────────────────────────┘

Después:
┌─ Menu (iOS) ─────────────────┐
│ ┌─ Opción corta ────────✓──┐ │  ← OK
│ └──────────────────────────┘ │
│ ┌─ Opción con texto largo  ┐ │  ✅ Bien espaciado
│ │                          ✓│ │     Checkmark arriba
│ │  Esta es una opción con  │ │     Texto legible
│ │  texto muy largo que     │ │     Padding vertical
│ │  ocupa varias líneas     │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

### 📊 Modificadores Aplicados

| Modificador | Propósito | Equivalente Android |
|-------------|-----------|---------------------|
| `HStack(alignment: .top)` | Checkmark alineado arriba con texto multilínea | `layout_gravity="top"` |
| `.lineSpacing(3)` | Espaciado entre líneas para legibilidad | `lineSpacingExtra="3dp"` |
| `.multilineTextAlignment(.leading)` | Alineación consistente de texto | `textAlign="start"` |
| `.frame(maxWidth: .infinity, alignment: .leading)` | Texto ocupa ancho disponible | `match_parent` |
| `.padding(.vertical, 4)` | Respiración vertical dentro del item | `paddingTop/Bottom="4dp"` |

### 🎯 Mejoras Logradas

1. ✅ **Mejor Legibilidad**: Espaciado entre líneas igual que en el campo de selección
2. ✅ **Alineación Correcta**: Checkmark alineado arriba para textos multilínea
3. ✅ **Respiración Visual**: Padding vertical evita opciones apretadas
4. ✅ **Ancho Completo**: Texto utiliza todo el ancho disponible del menú
5. ✅ **Consistencia**: Mismo estilo visual que el campo de selección

### 🧪 Casos de Prueba

#### ✅ Caso 1: Menú con Opciones Mixtas
```
Input: 
  pickerList = [
    "A",
    "Esta es una opción con texto muy largo que ocupa varias líneas",
    "B",
    "Otra descripción extensa con múltiples líneas de texto"
  ]

Expected:
- Opción "A": altura mínima (~44pt estándar iOS)
- Opción larga 1: altura expandida (~80pt con 3 líneas)
- Opción "B": altura mínima (~44pt)
- Opción larga 2: altura expandida (~80pt con 3 líneas)
- Checkmarks alineados arriba en todas las opciones ✅
- Espaciado consistente entre líneas ✅
```

#### ✅ Caso 2: Opción Muy Larga (>200 caracteres)
```
Input: 
  "Esta es una opción con una descripción extremadamente larga que contiene más de 200 caracteres y necesita muchas líneas para mostrar todo el contenido completo sin truncamiento alguno..."

Expected:
- Opción crece a ~120-140pt (5-6 líneas)
- Texto completamente visible sin "..."
- Checkmark permanece alineado arriba
- Padding vertical mantiene separación de otras opciones
```

#### ✅ Caso 3: Selección de Opción Larga desde Menú
```
Steps:
1. Abrir menú
2. Opción larga es visible completa con espaciado ✅
3. Tocar opción larga
4. Menú se cierra
5. Campo muestra opción completa con mismo espaciado ✅

Expected:
- Consistencia visual entre menú y campo seleccionado
- Mismo lineSpacing (3pt) en ambos lugares
- Sin cambios abruptos en el texto
```

### 🔧 Cambios en Código

**Archivo**: `CompletionRows.swift` → `struct PickerRow`

**Línea ~397**: Cambiado `HStack` → `HStack(alignment: .top, spacing: 8)`

**Línea ~403-406**: Agregados 4 modificadores:
- `.lineSpacing(3)`
- `.multilineTextAlignment(.leading)`
- `.frame(maxWidth: .infinity, alignment: .leading)`
- `.padding(.vertical, 4)`

**Línea ~408-410**: Mejorado estilo del checkmark:
- `.font(.system(size: 14, weight: .semibold))`
- `.foregroundColor(.blue)`

---

**Fecha de actualización 3**: 12 de febrero de 2026  
**Cambio**: Altura dinámica y espaciado en opciones del menú  
**Estado**: ✅ Implementado y probado

---
