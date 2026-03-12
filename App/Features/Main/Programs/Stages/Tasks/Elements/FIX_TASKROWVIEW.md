# 🔧 Cómo Arreglar el Error en TaskRowView

## Problema
El crash ocurre en `ElementsView` línea 128 porque `TaskRowView` tiene un `NavigationLink` que navega a `ElementsView`, pero no está pasando el `navigationState`.

## Solución

Necesitas encontrar el archivo donde está definido `TaskRowView` y hacer estos cambios:

### 1. Agregar `@EnvironmentObject` en TaskRowView

```swift
struct TaskRowView: View {
    // ... tus propiedades existentes ...
    
    // ✅ AGREGAR ESTA LÍNEA:
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        // ... tu código existente ...
    }
}
```

### 2. Verificar que el NavigationLink en TaskRowView pase el navigationState

Si `TaskRowView` tiene un `NavigationLink` a `ElementsView`, debe verse así:

```swift
NavigationLink(destination: 
    ElementsView(
        totalActivities: ...,
        taskTitle: ...,
        // ... otros parámetros ...
    )
    .environmentObject(navigationState)  // ✅ AGREGAR ESTA LÍNEA
) {
    // Contenido del link
}
```

O si usas `.navigationLink(isActive:)`:

```swift
.navigationLink(isActive: $showElementsView) {
    ElementsView(
        totalActivities: ...,
        taskTitle: ...,
        // ... otros parámetros ...
    )
    .environmentObject(navigationState)  // ✅ AGREGAR ESTA LÍNEA
}
```

## Cómo encontrar TaskRowView

1. Busca en tu proyecto un archivo llamado algo como:
   - `TaskRowView.swift`
   - `TaskRow.swift`
   - O busca dentro de otros archivos por `struct TaskRowView`

2. Una vez que lo encuentres, aplica los cambios de arriba.

## Lo mismo aplica para StageRowView y ElementRowView

Si también tienen `NavigationLink` internos, necesitan el mismo tratamiento:

- `StageRowView` debe tener `@EnvironmentObject var navigationState: NavigationState`
- `ElementRowView` debe tener `@EnvironmentObject var navigationState: NavigationState`
- Ambos deben pasar `.environmentObject(navigationState)` en sus NavigationLinks

## Verificación

Después de hacer estos cambios, la jerarquía completa debería verse así:

```
TileObjectView (CREA navigationState)
    ↓ .environmentObject
StagesView (RECIBE + DECLARA @EnvironmentObject)
    ├─→ StageRowView (RECIBE + DECLARA @EnvironmentObject)
    │       └─→ Si navega a TasksView: .environmentObject(navigationState)
    └─→ TasksView (RECIBE + DECLARA @EnvironmentObject)
            ├─→ TaskRowView (RECIBE + DECLARA @EnvironmentObject) ⚠️ FALTA ESTO
            │       └─→ Si navega a ElementsView: .environmentObject(navigationState)
            └─→ ElementsView (RECIBE + DECLARA @EnvironmentObject)
                    ├─→ ElementRowView (RECIBE + DECLARA @EnvironmentObject)
                    └─→ ElementDetailsView (RECIBE + DECLARA @EnvironmentObject)
```

## Logs para confirmar

Deberías ver en los logs:

```
🔍 [TaskRowView] Navegando a ElementsView
📍 [NavigationState] Tarea actual: [taskId]
🔍 [ElementsView] Verificando camino de auto-navegación
```

Si no ves el primer log, significa que TaskRowView aún no tiene acceso al navigationState.
