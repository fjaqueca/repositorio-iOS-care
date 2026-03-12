# 🗺️ Diagrama de Flujo - Auto-Navegación a Tarea Única

## 📊 Flujo Visual Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                    👤 USUARIO ENTRA A TasksView                 │
│                         (Primera vez)                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  🔄 LOADING ON │
                    │   isLoadingTasks = true │
                    └────────┬───────┘
                             │
                             ▼
              ┌──────────────────────────┐
              │  📡 Network.getTasks()   │
              │  Carga tareas desde API  │
              └────────────┬─────────────┘
                           │
                           ▼
       ┌────────────────────────────────────────────┐
       │  🔍 checkAutoNavigationToSingleActivity()  │
       │     ¿hasCheckedAutoNavigation?             │
       └──────────┬──────────────────┬──────────────┘
                  │ NO               │ YES
                  │                  │
                  ▼                  ▼
         ┌─────────────┐    ┌──────────────┐
         │ Contar      │    │ Skip check   │
         │ Tareas      │    │ Loading OFF  │
         └──────┬──────┘    └──────────────┘
                │
                ▼
      ┌──────────────────────┐
      │  📊 Total Tareas?    │
      └──┬────────────────┬──┘
         │ = 1           │ ≠ 1
         │               │
         ▼               ▼
    ┌─────────────┐  ┌─────────────┐
    │ shouldAuto  │  │ shouldAuto  │
    │ Navigate    │  │ Navigate    │
    │ = true      │  │ = false     │
    │             │  │             │
    │ ⏳ LOADING  │  │ ✅ LOADING  │
    │ SIGUE ON    │  │ OFF         │
    └──────┬──────┘  │             │
           │         │             │
           ▼         ▼             │
    ┌──────────────────┐           │
    │ navigateTo       │           │
    │ ElementsView     │           │
    │ = true           │           │
    └──────┬───────────┘           │
           │                       │
           ▼                       ▼
    ┌──────────────────┐    ┌────────────────┐
    │  ElementsView    │    │  📋 MOSTRAR    │
    │  .onAppear()     │    │  LISTA TAREAS  │
    └──────┬───────────┘    └────────────────┘
           │
           ▼
    ┌──────────────────────────┐
    │ checkAutoNavigationPath()│
    │ Decidir Camino A o B     │
    └──────┬──────────┬────────┘
           │          │
      CAMINO A    CAMINO B
           │          │
           ▼          ▼
    ┌──────────┐  ┌────────────────┐
    │ Mostrar  │  │ saltarLista... │
    │ Lista    │  │ = true?        │
    │ Activ.   │  └────┬───────────┘
    │          │       │ YES
    │ Delay    │       ▼
    │ 0.2s     │  ┌────────────────┐
    │          │  │ navigateTo     │
    │ ✅ Load  │  │ Questions      │
    │ OFF      │  │ = true         │
    └──────────┘  │                │
                  │ Delay 0.5s     │
                  │                │
                  │ ✅ Loading OFF │
                  └────────────────┘
```

---

## 🎬 Secuencia Temporal

### Escenario 1: **1 Tarea → Camino A** (Lista de Actividades)

```
t=0.0s   │ TasksView aparece
         │ 🔄 Loading ON
         │
t=0.5s   │ API responde con tareas
         │ checkAutoNavigationToSingleActivity()
         │ → Detecta 1 tarea
         │ → shouldAutoNavigate = true
         │ 🔄 Loading SIGUE ON
         │
t=0.6s   │ Navegación a ElementsView
         │ 🔄 Loading SIGUE ON
         │
t=0.7s   │ ElementsView.onAppear()
         │ checkAutoNavigationPath()
         │ → Camino A detectado
         │ 🔄 Loading SIGUE ON
         │
t=0.9s   │ ✅ Loading OFF
         │ 📋 Lista de actividades visible
```

---

### Escenario 2: **1 Tarea → Camino B** (Cuestionario Directo)

```
t=0.0s   │ TasksView aparece
         │ 🔄 Loading ON
         │
t=0.5s   │ API responde con tareas
         │ checkAutoNavigationToSingleActivity()
         │ → Detecta 1 tarea
         │ → shouldAutoNavigate = true
         │ 🔄 Loading SIGUE ON
         │
t=0.6s   │ Navegación a ElementsView
         │ 🔄 Loading SIGUE ON
         │
t=0.7s   │ ElementsView.onAppear()
         │ checkAutoNavigationPath()
         │ → Camino B detectado
         │ 🔄 Loading SIGUE ON
         │
t=1.0s   │ navigateToQuestions = true
         │ 🔄 Loading SIGUE ON
         │
t=1.5s   │ ✅ Loading OFF
         │ 📝 Cuestionario visible
```

---

### Escenario 3: **2+ Tareas** (Lista Normal)

```
t=0.0s   │ TasksView aparece
         │ 🔄 Loading ON
         │
t=0.5s   │ API responde con tareas
         │ checkAutoNavigationToSingleActivity()
         │ → Detecta 2+ tareas
         │ → shouldAutoNavigate = false
         │
t=0.5s   │ ✅ Loading OFF
         │ 📋 Lista de tareas visible
```

---

## 🔄 Ciclo de Vida de Variables

### **hasCheckedAutoNavigation**
```
Entrada inicial:          false
Primera verificación:     true
Permanece:                true (evita re-verificación)
Al volver (back):         true (no resetea)
```

### **shouldAutoNavigate**
```
Entrada inicial:          false
Si 1 tarea:              true
Durante navegación:       true (mantiene loading)
Al volver (back):         false (resetea)
Si 2+ tareas:            false
```

### **isLoadingTasks**
```
Entrada inicial:          true
Si 2+ tareas:            false (inmediato)
Si 1 tarea:              true (hasta decisión de camino)
Camino A decidido:        false (0.2s después)
Camino B decidido:        false (0.5s después)
```

---

## 🎯 Puntos de Decisión Clave

### ✅ Punto 1: ¿Cuántas tareas hay?
```swift
if totalTasks == 1 {
    // Auto-navegar
    shouldAutoNavigate = true
    navigateToElementsView = true
} else {
    // Mostrar lista
    shouldAutoNavigate = false
    isLoadingTasks = false
}
```

### ✅ Punto 2: ¿Qué camino tomar en ElementsView?
```swift
if taskData.saltarListaDeActividadesC == true {
    // CAMINO B: Cuestionario
    navigateToQuestions = true
    // Loading OFF después de 0.5s
} else {
    // CAMINO A: Lista de actividades
    // Loading OFF después de 0.2s
}
```

---

## 🧪 Matriz de Pruebas

| # Tareas | saltarLista | Resultado Final | Loading Duration |
|----------|-------------|-----------------|------------------|
| 0        | -           | Lista vacía     | ~0.5s            |
| 1        | false       | Lista activ.    | ~0.9s            |
| 1        | true        | Cuestionario    | ~1.5s            |
| 2+       | -           | Lista tareas    | ~0.5s            |

---

## 🛡️ Protecciones Anti-Loop

1. **hasCheckedAutoNavigation**: Solo verifica una vez por sesión
2. **Reseteo en onAppear**: Solo resetea `shouldAutoNavigate`, no el flag principal
3. **Condición de entrada**: Solo navega si `!hasCheckedAutoNavigation`

---

## 📝 Notas de Implementación

- **Delays justificados**: Permiten que las animaciones de SwiftUI se completen
- **Main thread**: Todos los cambios de UI en `DispatchQueue.main`
- **Async/await**: Usado donde sea posible para flujo más limpio
- **Logs descriptivos**: Facilitan el debug y seguimiento del flujo

