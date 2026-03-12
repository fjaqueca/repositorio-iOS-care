# 🚀 Implementación de Auto-Navegación a Tarea Única

## 📋 Resumen del Requerimiento

Cuando el usuario entra **por primera vez** a `TasksView` y **solo hay 1 tarea**, el sistema debe:
1. Navegar automáticamente a `ElementsView`
2. Mantener el **loading activo** mientras se decide el camino
3. Desactivar el loading solo cuando se muestre la vista correspondiente:
   - **Camino A**: Lista de actividades (ElementsView normal)
   - **Camino B**: Cuestionario de concatenación (navegación automática)

---

## ✅ Cambios Implementados

### 1️⃣ **TasksView.swift** - Control de Auto-Navegación

#### Variables de Estado Nuevas:
```swift
// Control de navegación automática
@State private var hasCheckedAutoNavigation: Bool = false
@State private var shouldAutoNavigate: Bool = false
```

#### Modificación del Body:
```swift
// MOSTRAR LOADING MIENTRAS SE CARGA O MIENTRAS SE DECIDE AUTO-NAVEGACIÓN
if isLoadingTasks || shouldAutoNavigate {
    ProgressView()
        .padding()
} else {
    // ... lista de tareas
}
```

#### Nueva Función: `checkAutoNavigationToSingleActivity()`
```swift
@MainActor
private func checkAutoNavigationToSingleActivity() async {
    // Solo verificar la primera vez
    guard !hasCheckedAutoNavigation else {
        self.isLoadingTasks = false
        return
    }
    
    hasCheckedAutoNavigation = true
    
    // Contar tareas
    var totalTasks = 0
    var singleTask: Goals.Goal?
    
    for taskGroup in goals {
        for task in taskGroup.records {
            for goal in task.goalsR.records {
                totalTasks += 1
                if totalTasks == 1 {
                    singleTask = goal
                }
            }
        }
    }
    
    // Si solo hay 1 tarea, activar navegación automática
    if totalTasks == 1, let task = singleTask {
        self.shouldAutoNavigate = true
        self.onlyOneTask = task
        self.isFavorite = task.favoritoAppC ?? false
        
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        // Activar navegación
        self.navigateToElementsView = true
        
        // El loading permanece activo hasta que ElementsView decida el camino
    } else {
        // Múltiples tareas - mostrar lista normal
        self.shouldAutoNavigate = false
        self.isLoadingTasks = false
    }
}
```

#### Modificación en `getTasks()`:
```swift
case let .success(listTask):
    self.goals = listTask
    
    // ✅ VERIFICAR AUTO-NAVEGACIÓN SOLO LA PRIMERA VEZ
    await checkAutoNavigationToSingleActivity()
```

#### Modificación en `.onAppear`:
```swift
.onAppear {
    // Si volvemos de navegación automática, permitir recarga
    if shouldAutoNavigate {
        shouldAutoNavigate = false
        // NO resetear hasCheckedAutoNavigation para evitar loop
    }
    
    Task {
        await refreshData()
    }
}
```

---

### 2️⃣ **ElementsView.swift** - Decisión de Camino (A o B)

#### Modificación en `.onAppear`:
```swift
.onAppear {
    isFavorite = taskData.favoritoAppC ?? false
    
    // ✅ VERIFICAR SI DEBE AUTO-NAVEGAR (CAMINO A o B)
    checkAutoNavigationPath()
}
```

#### Nueva Función: `checkAutoNavigationPath()`
```swift
func checkAutoNavigationPath() {
    print("🔍 ElementsView - Verificando camino de auto-navegación")
    
    // CAMINO B: Si debe saltar directo a la concatenación (cuestionario)
    if let _ = taskData.idInicioDeConcatenacionEnrolamientoC,
       taskData.saltarListaDeActividadesC == true {
        
        // Verificar si hay actividades pendientes
        if let activities = allActivities.records {
            for activity in activities {
                if (Int(activity.cantTaskCompletionC ?? 0) < 
                   (Int((activity.totalTaskCompletion2C ?? 0) / 
                   (activity.totalTaskComTemplateC ?? 1)))) {
                    
                    print("🎯 CAMINO B: Navegando directamente al cuestionario")
                    
                    // Navegar al cuestionario
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.navigateToQuestions = true
                        self.isQuestionnaire = true
                        
                        // ✅ DESACTIVAR LOADING de TasksView
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.isLoadingTasks = false
                            print("✅ Loading desactivado - Camino B completado")
                        }
                    }
                    return
                }
            }
        }
    }
    
    // CAMINO A: Mostrar lista normal de actividades
    print("📋 CAMINO A: Mostrando lista de actividades normal")
    
    // ✅ DESACTIVAR LOADING inmediatamente
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.isLoadingTasks = false
        print("✅ Loading desactivado - Camino A completado")
    }
}
```

---

## 🎯 Flujo Completo

```
1. Usuario entra a TasksView (primera vez)
   ↓
2. Loading visible ⏳
   ↓
3. Se cargan las tareas desde la API
   ↓
4. checkAutoNavigationToSingleActivity()
   ├─ ¿Solo 1 tarea?
   │  ├─ SÍ → shouldAutoNavigate = true
   │  │        navigateToElementsView = true
   │  │        Loading SIGUE ACTIVO ⏳
   │  │        ↓
   │  │        ElementsView.onAppear()
   │  │        ↓
   │  │        checkAutoNavigationPath()
   │  │        ├─ ¿Camino B? (cuestionario)
   │  │        │  ├─ SÍ → Navegar a cuestionario
   │  │        │  │       Loading OFF ✅ (0.5s después)
   │  │        │  └─ NO → Mostrar lista de actividades
   │  │        │          Loading OFF ✅ (0.2s después)
   │  │
   │  └─ NO → Mostrar lista de tareas
   │          Loading OFF ✅
```

---

## 🔍 Logs de Debug

Los siguientes mensajes ayudan a rastrear el flujo:

```
📱 TasksView - Carga inicial
📊 Total de tareas encontradas: 1
✅ Solo hay 1 tarea - Navegando automáticamente a: [Nombre]
🔄 Loading mantenido activo hasta que ElementsView decida el camino
🔍 ElementsView - Verificando camino de auto-navegación
🎯 CAMINO B: Navegando directamente al cuestionario
✅ Loading desactivado - Camino B completado
```

o

```
📋 CAMINO A: Mostrando lista de actividades normal
✅ Loading desactivado - Camino A completado
```

---

## ⚠️ Consideraciones Importantes

1. **Primera vez únicamente**: `hasCheckedAutoNavigation` evita loops infinitos
2. **Loading continuo**: El loading permanece activo durante toda la decisión
3. **Delays calculados**: Los delays aseguran transiciones UI suaves
4. **Reseteo al volver**: `shouldAutoNavigate` se resetea en `.onAppear` para permitir navegación manual

---

## 🧪 Casos de Prueba

| Escenario | Comportamiento Esperado |
|-----------|------------------------|
| 1 tarea + Camino A | Auto-navega → Muestra lista → Loading OFF |
| 1 tarea + Camino B | Auto-navega → Muestra cuestionario → Loading OFF |
| 2+ tareas | Muestra lista de tareas → Loading OFF |
| 0 tareas | Muestra lista vacía → Loading OFF |
| Volver con Back | No auto-navega de nuevo (flag preservado) |

---

## ✨ Beneficios

- ✅ **UX mejorada**: Usuario llega directamente donde debe estar
- ✅ **Loading inteligente**: Solo visible mientras se toma la decisión
- ✅ **Sin loops**: Navegación automática solo en primera visita
- ✅ **Debug fácil**: Logs claros para seguimiento
- ✅ **Flexible**: Funciona con ambos caminos (A y B)

