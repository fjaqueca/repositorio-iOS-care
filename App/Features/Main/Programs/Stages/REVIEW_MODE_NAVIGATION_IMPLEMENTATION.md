# 📋 Implementación del Modo Revisión - Botón "Cerrar"

## 🎯 Objetivo

Implementar la lógica de navegación del botón "Cerrar" en modo revisión (última pregunta de concatenación con actividad 100% contestada) siguiendo exactamente el comportamiento de Android.

## 📱 Contexto

**Modo Revisión:** El usuario está en una tarea/actividad que ya fue respondida al 100% previamente y ahora está revisando o editando las respuestas.

**Condiciones para Modo Revisión:**
- `isReviewMode = true` (implícito por `isActivityFullyAnsweredPreviously`)
- Estás en la **última actividad** de la cadena de concatenación (`determineNextActivity() == nil`)
- El botón muestra "Cerrar" en lugar de "Siguiente" o "Terminar"

## 🔀 Flujo Completo

### Al presionar "Cerrar" → `handleComplete()`

```
btnActividadSiguiente click
  └→ handleComplete()
        │
        ├─ isActivityFullyAnsweredPreviously == true ✓
        ├─ determineNextActivity() == null ✓
        │
        └─ ¿hasChanges()?  ← compara respuestas actuales vs baseline original
```

---

## 📊 Caso A: SIN CAMBIOS

**Condición:** `hasChanges() == false` (solo revisó, no editó nada)

### Flujo de Navegación

```
hasChanges() == false
  └→ navigateReviewModeByConcat()
        │
        ├─ nextId = siguienteActividadConcatenadaId → null/vacío
        ├─ nextId = actividad.Id_Actividad_Concatenada_Enrolamiento__c → null/vacío
        │
        └─ ES ÚLTIMA ACTIVIDAD (nextId vacío)
           │
           └→ updateFragment(ProgramasMainActivity.TAREAS)  ← VA A TAREAS
              │
              ❌ NO ejecuta ningún servicio en ElementDetailsView
              ❌ NO hace POST
              │
              └→ TareasListaFragment (TasksView) se carga
                    └→ tareasService()  ← GET /programa-tareas
                          └→ serviceResponse2() → loadData()
                                └→ ¿Auto-skip? (1 tarea + condiciones)
                                      ├─ SÍ → navega a ACTIVIDADES (ElementsView)
                                      └─ NO → muestra lista de tareas
```

### Servicios Ejecutados
- **Total: 1**
  - `GET /programa-tareas` (al cargar TasksView)

### Implementación en Swift

```swift
// En ElementDetailsView.swift - handleComplete()

if !hasChanges {
    // ========== CASO A: SIN CAMBIOS ==========
    print("📋 [Caso A] Sin cambios - Navegando a TAREAS sin POST")
    
    await MainActor.run {
        // Activar overlay durante navegación
        self.isCheckingProgress = true
        
        // Marcar que debe recargar datos
        navigationState.markForReload()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Navegar haciendo pop hasta ElementsView (lista de actividades/tareas)
            self.publisher.send() // Hace dismiss hasta ElementsView
            self.isLoadingTasks = true // Activa recarga en TasksView
            self.isCheckingProgress = false
        }
    }
    return
}
```

---

## 📊 Caso B: CON CAMBIOS

**Condición:** `hasChanges() == true` (editó alguna respuesta)

### Flujo de Navegación

```
hasChanges() == true
  │
  ├─ reviewNavigationDirection = 1 (hacia adelante)
  ├─ showCustomProgress(true)  ← muestra loading
  │
  └→ enviarTareaService()  ← POST /task-completions  (servicio 1)
        │
        │  ... espera respuesta ...
        │
        └→ serviceResponse() → éxito
              │
              └→ reloadTareaData()  ← GET /programa-tareas  (servicio 2)
                    │
                    │  ... espera respuesta ...
                    │
                    └→ serviceResponse2() (RETURN_RELOAD_TAREA)
                          │
                          ├─ Actualiza cumplimiento del servidor
                          ├─ Actualiza datos frescos
                          ├─ shouldReloadTareaFragment = true
                          ├─ shouldReloadTareas = true
                          ├─ shouldReloadEtapas = true
                          ├─ shouldReloadProgramas = true
                          │
                          └─ isReviewMode == true ✓  (línea 3268)
                               │
                               ├─ showCustomProgress(false)
                               │
                               └→ navigateReviewModeByConcat()
                                    │
                                    ├─ nextId = null/vacío (última actividad)
                                    │
                                    └─ ES ÚLTIMA ACTIVIDAD
                                       │
                                       └→ updateFragment(ProgramasMainActivity.TAREAS)
                                          │
                                          └→ TareasListaFragment se carga
                                                └→ tareasService()  ← GET /programa-tareas  (servicio 3)
                                                      └→ serviceResponse2() → loadData()
                                                            └→ ¿Auto-skip?
                                                                  ├─ SÍ → ACTIVIDADES
                                                                  └─ NO → muestra lista
```

### Servicios Ejecutados
- **Total: 3**
  1. `POST /task-completions` (enviar cambios)
  2. `GET /programa-tareas` (reload data)
  3. `GET /programa-tareas` (al cargar TareasListaFragment/TasksView)

### Implementación en Swift

```swift
// En ElementDetailsView.swift - handleComplete()

if hasChanges {
    // ========== CASO B: CON CAMBIOS ==========
    print("✏️ [Caso B] Con cambios - POST + Navegando a TAREAS")
    
    await MainActor.run {
        self.isCheckingProgress = true
    }
    
    // POST: Enviar solo lo modificado
    await uploadImagesToS3(onlyFor: Set(updates.map { $0.Id ?? "" }))
    
    let unionTemplates = creates + updates
    let filteredResponse = unionTemplates.reduce(into: [String: String]()) { dict, template in
        if let id = template.Id, let value = completionResponse[id] {
            dict[id] = value
        }
    }
    
    let result = await Network.shared.postTask(
        activityData: unionTemplates,
        response: filteredResponse,
        existingCompletionIds: existingCompletionIds
    )
    
    switch result {
    case .success:
        print("✅ [Caso B] POST exitoso - Marcando recargas")
        
        // Marcar que se deben recargar todos los niveles
        await MainActor.run {
            navigationState.shouldReloadTareaFragment = true
            navigationState.shouldReloadTareas = true
            navigationState.shouldReloadEtapas = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Navegar haciendo pop hasta ElementsView
                self.publisher.send()
                self.isLoadingTasks = true
                self.isCheckingProgress = false
                
                print("🧭 [Caso B] Navegando a TAREAS con recargas activadas")
            }
        }
        
    case .failure(let error):
        await MainActor.run {
            AppStatusManager.error(error)
            self.alertAuthEvent = .FailSendData
            self.showAlert = true
            self.isCheckingProgress = false
        }
    }
    return
}
```

---

## 🔑 Puntos Clave de la Implementación

### 1. **Detección de Cambios**

La función `computeChanges()` compara las respuestas actuales con el baseline original:

```swift
func computeChanges() -> (creates: [Template], updates: [Template], filtered: [String:String], changedIds: Set<String>) {
    var creates: [Template] = []
    var updates: [Template] = []
    var filteredResponse: [String: String] = [:]
    var changedIds = Set<String>()
    
    for template in completion.records {
        let id = template.Id
        let hasExisting = existingCompletionIds[id] != nil
        let current = completionResponse[id] ?? ""
        let original = originalCompletionResponse[id] ?? ""
        
        if !hasExisting {
            // CREATE si hay respuesta presente
            if !current.isEmpty {
                creates.append(template)
                filteredResponse[id] = current
                changedIds.insert(id)
            }
        } else {
            // UPDATE si cambió vs baseline
            if current != original {
                updates.append(template)
                filteredResponse[id] = current
                changedIds.insert(id)
            }
        }
    }
    
    return (creates, updates, filteredResponse, changedIds)
}
```

### 2. **Navegación al Nivel Correcto**

**❌ INCORRECTO (anterior):** Navegar a `StagesView`
```swift
self.navigateToStages = true  // ❌ NO
```

**✅ CORRECTO (nuevo):** Navegar a `TasksView` (equivalente a TareasListaFragment)
```swift
self.publisher.send()  // ✅ SÍ - Hace dismiss hasta ElementsView/TasksView
self.isLoadingTasks = true  // Activa recarga
```

### 3. **Flags de Recarga en NavigationState**

```swift
// NavigationState.swift

/// Marca recarga básica (usada en flujo normal)
func markForReload() {
    shouldReloadTareaFragment = true
    shouldReloadTareas = true
    shouldReloadEtapas = true
}

/// Marca recarga completa (usada en modo revisión con cambios)
func markForFullReload() {
    shouldReloadTareaFragment = true
    shouldReloadTareas = true
    shouldReloadEtapas = true
    shouldReloadProgramas = true
}
```

### 4. **Respuesta a Recargas en TasksView**

```swift
// TasksView.swift - onAppear

.onAppear {
    print("👁️ [TasksView] onAppear")
    print("🔍 [TasksView] shouldReloadTareas: \(navigationState.shouldReloadTareas)")
    
    // ✅ SI VIENE DE MODO REVISIÓN CON CAMBIOS, RECARGAR DATOS
    if navigationState.shouldReloadTareas {
        print("🔄 [TasksView] Recarga solicitada desde modo revisión")
        navigationState.shouldReloadTareas = false // Resetear flag
        hasCheckedAutoNavigation = false // Permitir nueva verificación de auto-skip
    }
    
    Task {
        await refreshData()
    }
}
```

### 5. **Respuesta a Recargas en ElementsView**

```swift
// ElementsView.swift - onAppear

.onAppear {
    print("👁️ [ElementsView] onAppear")
    print("🔍 [ElementsView] shouldReloadTareaFragment: \(navigationState.shouldReloadTareaFragment)")
    
    // ✅ SI VIENE DE MODO REVISIÓN CON CAMBIOS, RECARGAR DATOS
    if navigationState.shouldReloadTareaFragment {
        print("🔄 [ElementsView] Recarga solicitada desde modo revisión")
        navigationState.shouldReloadTareaFragment = false // Resetear flag
        
        Task {
            await refreshData()
        }
        return
    }
    
    checkAutoNavigationPath()
}

private func refreshData() async {
    print("🔄 [ElementsView] Refrescando datos de actividades...")
    isLoading = true
    
    let result = await Network.shared.getActivities(taskId: taskId)
    
    switch result {
    case .success(let updatedActivities):
        await MainActor.run {
            self.allActivities = updatedActivities
            // Recalcular progreso
            self.progress = calculateProgress(from: updatedActivities)
            self.isLoading = false
            
            // ✅ IMPORTANTE: Después de recargar, NO auto-navegar
            // Según Android: "NO navegar automáticamente tras reload"
            print("🛑 [ElementsView] Datos recargados - NO auto-navegación tras reload")
            self.isLoadingTasks = false
        }
    case .failure(let error):
        print("❌ [ElementsView] Error al refrescar: \(error)")
        await MainActor.run {
            self.isLoading = false
            self.isLoadingTasks = false
        }
    }
}

// ✅ PROTECCIÓN: No auto-navegar si tarea está completa al 100%
func checkAutoNavigationPath() {
    print("🔍 [ElementsView] Verificando camino de auto-navegación")
    print("🔍 [ElementsView] progress (cumplimiento): \(progress)%")
    
    // ✅ Si la tarea está completa al 100%, NO auto-navegar
    // Esto permite que el usuario entre manualmente en modo revisión
    if progress >= 100 {
        print("🛑 [ElementsView] Tarea completa al 100% - esperando selección manual")
        self.isLoadingTasks = false
        return
    }
    
    // Resto de la lógica de auto-navegación...
}
```

### 6. **Respuesta a Recargas en StagesView**

```swift
// StagesView.swift - onAppear

.onAppear {
    print("👁️ [StagesView] onAppear")
    print("🔍 [StagesView] shouldReloadEtapas: \(navigationState.shouldReloadEtapas)")
    
    // ✅ SI VIENE DE MODO REVISIÓN CON CAMBIOS, RECARGAR DATOS
    if navigationState.shouldReloadEtapas {
        print("🔄 [StagesView] Recarga solicitada desde modo revisión")
        navigationState.shouldReloadEtapas = false // Resetear flag
        isFirstLoad = false // Evitar auto-skip después de revisión
    }
    
    refreshData()
}
```

---

## 📋 Resumen Comparativo

| Escenario | Servicios Ejecutados | Destino Final |
|-----------|---------------------|---------------|
| **Sin cambios** | 1: GET /programa-tareas (al cargar TasksView) | TAREAS (con posible auto-skip) |
| **Con cambios** | 3: POST /task-completions → GET (reload implícito) → GET /programa-tareas (TasksView) | TAREAS (con posible auto-skip) |

---

## 🔄 Flujo de Re-entrada a Tarea Completa (Modo Revisión)

### Escenario: Usuario presiona "Cerrar" y vuelve a entrar a la misma tarea

Este es un flujo crítico que debe manejarse correctamente para evitar loops infinitos de navegación.

### Paso 1: "Cerrar" en Modo Revisión
```
ElementDetailsView (última pregunta, 100% completa)
  ├─ Usuario presiona "Cerrar"
  ├─ hasChanges? 
  │   ├─ NO → publisher.send() sin POST
  │   └─ SÍ → POST + publisher.send()
  │
  └→ Dismiss hasta ElementsView (lista de actividades/tareas)
        └→ TasksView recarga automáticamente
```

### Paso 2: TasksView se Carga
```
TasksView.onAppear
  ├─ shouldReloadTareas? 
  │   └─ SÍ → resetear flag + recargar
  │
  └→ GET /programa-tareas (SIEMPRE)
        └→ Auto-skip?
              ├─ ¿Solo 1 tarea?
              ├─ ¿Estado != "Completo"?  ← ❌ ES "Completo" → NO auto-skip
              ├─ ¿Mostrar_Si_Es_Un_Solo_Registro__c = false?
              └─ ¿backTareas = false?
              
              Resultado: NO cumple condiciones → Muestra lista
```

**✅ PROTECCIÓN #1:** El auto-skip de TasksView excluye tareas con `Estado = "Completo"`

### Paso 3: Usuario Toca la Tarea en la Lista
```
TaskRowView → Click
  └→ Navega a ElementsView (lista de actividades)
        └→ ElementsView.onAppear
```

### Paso 4: ElementsView se Carga
```
ElementsView.onAppear
  │
  ├─ shouldReloadTareaFragment?
  │   └─ SÍ → refreshData() → NO auto-navega
  │
  └─ checkAutoNavigationPath()
        │
        ├─ progress >= 100%?  ← ✅ SÍ
        │   └→ 🛑 NO AUTO-NAVEGAR
        │       └→ Muestra lista, espera selección manual
        │
        └─ progress < 100%?
            └→ Evaluar auto-skip normal
```

**✅ PROTECCIÓN #2:** ElementsView NO auto-navega si `progress >= 100%`

**✅ PROTECCIÓN #3:** Después de `refreshData()`, NO se ejecuta `checkAutoNavigationPath()`

### Paso 5: Usuario Selecciona Actividad Manualmente
```
ElementRowView → Click
  └→ Navega a ElementDetailsView
        └→ ElementDetailsView.onAppear
              └→ resumeToFirstUnansweredInChain()
                    │
                    ├─ Consulta servidor por CADA actividad concatenada
                    ├─ isActivityFullyAnswered()? → SÍ en todas
                    │
                    └→ ✅ ACTIVA MODO REVISIÓN
                          ├─ isReviewMode = true
                          ├─ Carga primera actividad con datos guardados
                          ├─ Muestra botones "Anterior/Siguiente/Cerrar"
                          └─ Usuario puede revisar/editar respuestas
```

### Resumen Visual del Flujo de Re-entrada

```
"Cerrar" (modo revisión)
   │
   └→ TasksView
        ├─ GET /programa-tareas
        ├─ Estado = "Completo" → NO auto-skip ✅
        └─ Muestra lista de tareas
             │
             └→ [Usuario toca la tarea]
                  │
                  └→ ElementsView
                       ├─ shouldReloadTareaFragment? 
                       │   └→ SÍ → refreshData() (NO auto-navega) ✅
                       │
                       ├─ progress >= 100%? 
                       │   └→ SÍ → NO auto-navegar ✅
                       │
                       └─ Muestra lista de actividades
                            │
                            └→ [Usuario selecciona actividad]
                                 │
                                 └→ ElementDetailsView
                                      └─ resumeToFirstUnansweredInChain()
                                           └─ Activa modo revisión ✅
```

### Protecciones Anti-Loop

| Protección | Dónde | Qué Previene |
|-----------|-------|--------------|
| **#1: Estado "Completo"** | `TasksView.checkAutoNavigationToSingleActivity()` | Auto-skip infinito en lista de tareas |
| **#2: Progress >= 100%** | `ElementsView.checkAutoNavigationPath()` | Auto-skip infinito en lista de actividades |
| **#3: No auto-navegar tras reload** | `ElementsView.refreshData()` | Auto-skip después de recarga desde modo revisión |

### Diferencias Clave con Flujo Normal

| Aspecto | Primera Vez (Normal) | Re-entrada (Revisión) |
|---------|---------------------|---------------------|
| **TasksView auto-skip** | ✅ Puede auto-navegar | ❌ NO (Estado = "Completo") |
| **ElementsView auto-skip** | ✅ Puede auto-navegar | ❌ NO (progress >= 100%) |
| **Carga de datos** | Primera carga | Reload desde servidor |
| **Navegación** | Automática si aplica | **Manual** por usuario |
| **Modo revisión** | NO (primera vez) | ✅ SÍ (detecta 100%) |

---

## 🧪 Casos de Prueba

### ✅ Caso A - Sin Cambios

**Pasos:**
1. Completar una tarea al 100%
2. Volver a entrar (modo revisión)
3. Navegar por las preguntas SIN modificar ninguna respuesta
4. En la última pregunta, presionar "Cerrar"

**Resultado esperado:**
- ✅ NO se ejecuta POST
- ✅ Navega a TasksView
- ✅ TasksView recarga datos (GET /programa-tareas)
- ✅ Si hay 1 sola tarea y cumple condiciones, hace auto-skip a ElementsView
- ✅ Si hay múltiples tareas, muestra lista

**Log esperado:**
```
🔙 [Complete] Modo revisión - última actividad de concatenación
🔍 [Complete] ¿Hay cambios? false (creates: 0, updates: 0)
📋 [Caso A] Sin cambios - Navegando a TAREAS sin POST
👁️ [TasksView] onAppear
🔍 [TasksView] shouldReloadTareas: true
🔄 [TasksView] Recarga solicitada desde modo revisión
🔍 [TasksView] Fetching tareas...
✅ [TasksView] Tareas cargadas
```

### ✅ Caso B - Con Cambios

**Pasos:**
1. Completar una tarea al 100%
2. Volver a entrar (modo revisión)
3. Modificar al menos una respuesta
4. En la última pregunta, presionar "Cerrar"

**Resultado esperado:**
- ✅ SÍ se ejecuta POST con solo los campos modificados
- ✅ Muestra loading durante el POST
- ✅ Marca flags de recarga (shouldReloadTareas, shouldReloadEtapas, etc.)
- ✅ Navega a TasksView
- ✅ TasksView recarga datos frescos del servidor
- ✅ Barras de progreso se actualizan con nuevos valores

**Log esperado:**
```
🔙 [Complete] Modo revisión - última actividad de concatenación
🔍 [Complete] ¿Hay cambios? true (creates: 0, updates: 2)
✏️ [Caso B] Con cambios - POST + Navegando a TAREAS
📦 [Send] POST con 2 templates modificados
✅ [Caso B] POST exitoso - Marcando recargas
🧭 [Caso B] Navegando a TAREAS con recargas activadas
👁️ [TasksView] onAppear
🔍 [TasksView] shouldReloadTareas: true
🔄 [TasksView] Recarga solicitada desde modo revisión
🔍 [TasksView] Fetching tareas...
✅ [TasksView] Tareas cargadas
```

### ✅ Caso C - Re-entrada a Tarea Completa

**Pasos:**
1. Completar tarea al 100%
2. Presionar "Cerrar" en modo revisión
3. Llegar a TasksView con la tarea completada
4. **Volver a tocar la misma tarea**

**Resultado esperado:**
- ✅ TasksView NO hace auto-skip (tarea completa)
- ✅ Al tocar la tarea, navega a ElementsView
- ✅ ElementsView detecta `progress >= 100%`
- ✅ NO auto-navega a ninguna actividad
- ✅ Muestra lista de actividades normalmente
- ✅ Loading se desactiva correctamente
- ✅ Usuario puede seleccionar actividad manualmente

**Log esperado:**
```
👁️ [TasksView] onAppear
🔍 [TasksView] shouldReloadTareas: true
🔄 [TasksView] Recarga solicitada desde modo revisión
🔍 [TasksView] Fetching tareas...
✅ [TasksView] Tareas cargadas
📋 [TasksView] Mostrando lista (1 tarea pero estado = Completo)

[Usuario toca la tarea]

👁️ [ElementsView] onAppear
🔍 [ElementsView] shouldReloadTareaFragment: true
🔄 [ElementsView] Recarga solicitada desde modo revisión
🔄 [ElementsView] Refrescando datos de actividades...
✅ [ElementsView] Datos actualizados - Progreso: 100%
🛑 [ElementsView] Datos recargados - NO auto-navegación tras reload

[O si no viene de reload, checkAutoNavigationPath se ejecuta:]

🔍 [ElementsView] Verificando camino de auto-navegación
🔍 [ElementsView] progress (cumplimiento): 100%
🛑 [ElementsView] Tarea completa al 100% - esperando selección manual
✅ [ElementsView] Loading desactivado
```

**❌ Error si NO está implementado correctamente:**
- Loading infinito
- Auto-navegación en loop
- Crash por estado inconsistente

---

## 🚨 Errores Comunes a Evitar

### ❌ Error 1: Navegar a StagesView en lugar de TasksView
```swift
// ❌ INCORRECTO
self.navigateToStages = true
```

**Solución:**
```swift
// ✅ CORRECTO
self.publisher.send()  // Dismiss hasta ElementsView
self.isLoadingTasks = true  // TasksView recargará
```

### ❌ Error 2: No Detectar Cambios Correctamente
```swift
// ❌ INCORRECTO - Comparar solo si hay respuestas
let hasChanges = !completionResponse.isEmpty
```

**Solución:**
```swift
// ✅ CORRECTO - Comparar vs baseline original
let (creates, updates, _, _) = computeChanges()
let hasChanges = !creates.isEmpty || !updates.isEmpty
```

### ❌ Error 3: Auto-Navegar en Tarea Completa al 100%
```swift
// ❌ INCORRECTO - No verifica progreso antes de auto-navegar
func checkAutoNavigationPath() {
    if taskData.saltarListaDeActividadesC == true {
        self.navigateToQuestions = true  // ❌ Siempre navega
    }
}
```

**Solución:**
```swift
// ✅ CORRECTO - Verifica progreso primero
func checkAutoNavigationPath() {
    if progress >= 100 {
        print("🛑 Tarea completa - NO auto-navegar")
        self.isLoadingTasks = false
        return  // ✅ Sale temprano
    }
    
    if taskData.saltarListaDeActividadesC == true {
        // Solo navega si NO está completa
        self.navigateToQuestions = true
    }
}
```

### ❌ Error 4: Auto-Navegar Después de Reload
```swift
// ❌ INCORRECTO - Auto-navega después de recargar
private func refreshData() async {
    // ... recarga datos ...
    self.isLoading = false
    checkAutoNavigationPath()  // ❌ No debe auto-navegar tras reload
}
```

**Solución:**
```swift
// ✅ CORRECTO - NO auto-navega después de reload
private func refreshData() async {
    // ... recarga datos ...
    self.isLoading = false
    self.isLoadingTasks = false  // ✅ Solo desactiva loading
    // NO llama a checkAutoNavigationPath()
}
```

### ❌ Error 5: No Resetear Flags de Recarga
```swift
// ❌ INCORRECTO - Flag nunca se resetea
if navigationState.shouldReloadTareas {
    refreshData()
    // Falta resetear el flag
}
```

**Solución:**
```swift
// ✅ CORRECTO
if navigationState.shouldReloadTareas {
    navigationState.shouldReloadTareas = false  // Resetear
    hasCheckedAutoNavigation = false  // Permitir nueva verificación
    refreshData()
}
```

### ❌ Error 4: Mostrar Alert en Modo Revisión Sin Cambios
```swift
// ❌ INCORRECTO
self.alertAuthEvent = .SuccesSendData
self.showAlert = true
```

**Solución:**
```swift
// ✅ CORRECTO - NO mostrar alert, navegar directamente
self.publisher.send()
self.isLoadingTasks = true
```

---

## 📚 Referencias

- **Archivo Principal:** `ElementDetailsView.swift` - Función `handleComplete()`
- **Estado Global:** `NavigationState.swift` - Flags de recarga
- **Vista de Tareas:** `TasksView.swift` - Recarga con `shouldReloadTareas`
- **Vista de Actividades:** `ElementsView.swift` - Recarga con `shouldReloadTareaFragment`
- **Vista de Etapas:** `StagesView.swift` - Recarga con `shouldReloadEtapas`

---

## ✅ Checklist de Implementación

- [✅] Detectar cambios correctamente con `computeChanges()`
- [✅] Caso A (Sin cambios): Navegar sin POST
- [✅] Caso B (Con cambios): POST + marcar recargas
- [✅] Navegar a TasksView (NO a StagesView)
- [✅] Implementar flags de recarga en NavigationState
- [✅] Responder a recargas en TasksView
- [✅] Responder a recargas en ElementsView
- [✅] Responder a recargas en StagesView
- [✅] Mantener overlay durante navegación
- [✅] NO mostrar alert en caso sin cambios
- [✅] Permitir auto-skip después de recarga
- [✅] Logs detallados para debugging

---

## 🎉 Resultado Final

Con esta implementación, el flujo del botón "Cerrar" en modo revisión funciona **exactamente igual que en Android**:

1. **Detecta correctamente** si hubo cambios en las respuestas
2. **Caso A (Sin cambios):** Navega directamente sin POST
3. **Caso B (Con cambios):** Ejecuta POST + marca recargas en cascada
4. **Siempre navega a TAREAS** (TasksView), nunca a Etapas
5. **Permite auto-skip** si solo hay 1 tarea después de recargar
6. **Actualiza todas las barras de progreso** con datos frescos del servidor
7. **Mantiene UX fluida** con overlays durante transiciones

