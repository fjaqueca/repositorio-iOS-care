# Guía de Estandarización de Loading States

## 📋 Resumen

Todos los indicadores de carga (loading spinners) en la aplicación deben usar el componente `CenteredLoadingView` para garantizar consistencia visual y UX uniforme.

## ✅ Componente Estándar

### CenteredLoadingView

Componente centralizado que muestra un `ProgressView` perfectamente centrado vertical y horizontalmente con padding adecuado.

```swift
import SwiftUI

// Uso básico
if isLoading {
    CenteredLoadingView()
}
```

## 🎯 Implementación en Diferentes Escenarios

### Escenario 1: Loading con Blur de Contenido

**Patrón recomendado para vistas principales:**

```swift
ZStack {
    VStack(spacing: 0) {
        // Tu contenido aquí
        ScrollView {
            // ...
        }
    }
    .blur(radius: isLoading ? 3 : 0.000001)
    
    if isLoading {
        CenteredLoadingView()
    }
}
```

**Vistas que usan este patrón:**
- ✅ `ProgramsView.swift`
- ✅ `TasksView.swift`
- ✅ `ElementsView.swift`

---

### Escenario 2: Loading de Pantalla Completa (Overlay)

**Patrón para transiciones entre vistas:**

```swift
ZStack {
    VStack(spacing: 0) {
        // Tu contenido aquí
    }
    
    if isLoading || showOverlay {
        CenteredLoadingView()
    }
}
```

**Vistas que usan este patrón:**
- ✅ `StagesView.swift`
- ✅ `ElementDetailsView.swift`

---

### Escenario 3: Loading Dentro de ScrollView

**❌ EVITAR este patrón:**

```swift
ScrollView {
    if isLoading {
        ProgressView()  // ❌ Se alinea arriba, no centrado
            .padding()
    } else {
        // contenido
    }
}
```

**✅ USAR en su lugar:**

```swift
ZStack {
    ScrollView {
        if isLoading {
            // Placeholder para mantener el ScrollView activo
            Color.clear
                .frame(height: 100)
        } else {
            // contenido real
        }
    }
    
    if isLoading {
        CenteredLoadingView()  // ✅ Centrado sobre todo
    }
}
```

---

## 🚫 Antipatrones a Evitar

### ❌ Antipatrón 1: ProgressView sin componente wrapper

```swift
if isLoading {
    ProgressView()  // ❌ NO USAR directamente
        .padding()
}
```

**Problema:** Inconsistencia en padding y posicionamiento.

---

### ❌ Antipatrón 2: Loading dentro de VStack/HStack

```swift
VStack {
    if isLoading {
        ProgressView()  // ❌ NO USAR
    }
    // contenido
}
```

**Problema:** No queda centrado verticalmente.

---

### ❌ Antipatrón 3: ZStack manual con fondo

```swift
ZStack {
    Color(.systemBackground)
    ProgressView()  // ❌ NO USAR
        .padding()
}
```

**Problema:** Duplicación de código. Usar `CenteredLoadingView()` en su lugar.

---

## 📱 Vistas Actualizadas

Todas las vistas del flujo de Programas han sido actualizadas:

| Vista | Estado | Patrón Usado |
|-------|--------|--------------|
| `ProgramsView.swift` | ✅ Actualizado | Loading con Blur |
| `StagesView.swift` | ✅ Actualizado | Loading Overlay |
| `TasksView.swift` | ✅ Actualizado | Loading con Blur (múltiples estados) |
| `ElementsView.swift` | ✅ Actualizado | Loading con Blur |
| `ElementDetailsView.swift` | ✅ Actualizado | Loading Overlay con zIndex |

---

## 🔍 Checklist para Nuevas Vistas

Al crear una nueva vista con estado de carga:

- [ ] Importar el componente (ya disponible en el proyecto)
- [ ] Decidir qué patrón usar (con blur, overlay, etc.)
- [ ] Usar `CenteredLoadingView()` en lugar de `ProgressView()` directo
- [ ] Verificar en dispositivo que el loading aparezca centrado vertical y horizontalmente
- [ ] Si hay blur, verificar que el contenido se vea correctamente difuminado

---

## 💡 Ventajas de este Approach

1. **Consistencia Visual**: Todos los loadings se ven igual
2. **UX Mejorada**: Siempre centrados, nunca pegados arriba
3. **Mantenibilidad**: Un solo componente para actualizar si cambia el diseño
4. **Reusabilidad**: Fácil de usar en cualquier vista nueva
5. **Testeable**: Un solo componente para probar comportamiento de loading

---

## 🛠 Debugging

Si un loading no aparece correctamente centrado:

1. Verificar que `CenteredLoadingView()` esté en un **ZStack**, no en VStack/HStack
2. Verificar que el ZStack tenga `.frame(maxWidth: .infinity, maxHeight: .infinity)`
3. Verificar que no haya otros modificadores `.frame()` limitando el tamaño
4. En Preview, probar con diferentes tamaños de pantalla

---

## 📝 Notas

- `CustomAnimatedProgressView`: Este es diferente, es una **barra de progreso** animada, no un loading spinner
- `CircularProgressView`: También diferente, es un indicador circular de porcentaje de completitud
- Estos NO deben reemplazarse con `CenteredLoadingView`

---

**Fecha de última actualización:** 16/02/2026  
**Responsable:** Estandarización de UI/UX
