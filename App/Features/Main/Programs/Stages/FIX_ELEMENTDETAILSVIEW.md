# 🔧 Cómo Arreglar el Error en ElementDetailsView

## Problema
El crash ocurre cuando presionas "Cerrar" en el modo revisión (tarea completada). El log muestra:
```
➡️ [UI] Tap en Cerrar
🔄 [onChange] navigateToStages=true
👁️ [StagesView] onAppear
SwiftUICore/EnvironmentObject.swift:93: Fatal error: No ObservableObject of type NavigationState found
```

Esto indica que `ElementDetailsView` está navegando a `StagesView` sin pasar el `navigationState`.

## Solución

### 1. Buscar el archivo `ElementDetailsView.swift`

Probablemente está en:
- Carpeta `Elements/` o `Activities/`
- Busca por "ElementDetailsView" en Xcode (Cmd + Shift + F)

### 2. Verificar que tenga la declaración de `@EnvironmentObject`

```swift
struct ElementDetailsView: View {
    // ... tus propiedades existentes ...
    
    // ✅ AGREGAR ESTA LÍNEA SI NO EXISTE:
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        // ...
    }
}
```

### 3. Buscar el `NavigationLink` o navegación a `StagesView`

Busca en el código algo como:

```swift
// Opción 1: NavigationLink directo
NavigationLink(destination: StagesView(...)) {
    Text("Cerrar")
}

// Opción 2: navigationLink con binding
.navigationLink(isActive: $navigateToStages) {
    StagesView(...)
}

// Opción 3: Presentación programática
if navigateToStages {
    StagesView(...)
}
```

### 4. Agregar `.environmentObject(navigationState)` a StagesView

Cambia la navegación para que pase el `navigationState`:

```swift
// ANTES:
StagesView(
    programId: programId,
    puntosActivos: puntosActivos,
    puntosObtener: puntosObtener,
    puntosAcumulados: puntosAcumulados,
    startWithOverlay: true
)

// DESPUÉS:
StagesView(
    programId: programId,
    puntosActivos: puntosActivos,
    puntosObtener: puntosObtener,
    puntosAcumulados: puntosAcumulados,
    startWithOverlay: true
)
.environmentObject(navigationState)  // ✅ AGREGAR ESTA LÍNEA
```

## Alternativa: Buscar el botón "Cerrar"

El log dice `➡️ [UI] Tap en Cerrar`, así que busca en `ElementDetailsView`:

```swift
// Busca algo como:
Button("Cerrar") {
    // Aquí hay lógica que activa navegateToStages
}
```

O:

```swift
Button(action: closeAndNavigate) {
    Text("Cerrar")
}
```

Sigue el flujo desde ese botón hasta encontrar dónde se navega a `StagesView`.

## Patrón General para TODAS las vistas

**Regla de oro**: Si una vista `A` navega a una vista `B`, y `B` usa `@EnvironmentObject var navigationState`:

1. `A` debe declarar: `@EnvironmentObject var navigationState: NavigationState`
2. `A` debe pasar al navegar: `.environmentObject(navigationState)`

## Vistas que probablemente necesitan este cambio:

- ✅ `TaskRowView` - ARREGLADO
- ⚠️ `ElementDetailsView` - NECESITA ARREGLO (este es tu problema actual)
- ❓ `StageRowView` - Verificar si navega directamente
- ❓ `ElementRowView` - Verificar si navega directamente

## Logs esperados después del arreglo

```
➡️ [UI] Tap en Cerrar
🔙 [Complete] Tarea en modo revisión. Cerrando sin POST ni alert.
🔄 [onChange] navigateToStages=true
👁️ [StagesView] onAppear
🔍 [StagesView] backEtapas: false  ← YA NO CRASH
🔍 [StagesView] isFirstLoad: false
📋 [StagesView] Mostrando lista...
```

## ¿Cómo encuentro todos los lugares que navegan a StagesView?

En Xcode:
1. Cmd + Shift + F (Find in Project)
2. Busca: `StagesView(`
3. Verifica cada resultado para asegurar que tiene `.environmentObject(navigationState)`

Los lugares ya arreglados:
- ✅ `TileObjectView.swift` línea ~140
- ✅ `TileObjectSecondView.swift` línea ~72
- ⚠️ Falta: `ElementDetailsView` (o donde esté el botón "Cerrar")
