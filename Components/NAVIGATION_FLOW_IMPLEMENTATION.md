# 🚀 Lógica de Navegación Automática - iOS Implementation

## 📋 Resumen

Este documento describe la implementación de la lógica de navegación automática en iOS, replicando el comportamiento de Android para el flujo:

**Programas → Etapas → Tareas → Actividades**

---

## 🎯 Principios Clave

### 1. **Los Servicios SIEMPRE se Ejecutan**
El auto-skip NO salta los servicios. La lógica decide QUÉ HACER con los datos DESPUÉS de recibirlos.

### 2. **Flags Anti-Loop**
Evitan navegación infinita al presionar "atrás":
- `backEtapas`: Evita auto-skip en StagesView al volver de TasksView
- `backTareas`: Evita auto-skip en TasksView al volver de ElementsView

### 3. **Loading Continuo**
El loading se mantiene activo durante toda la cadena de auto-navegación hasta llegar al destino final.

---

## 🔄 Flujo Completo

```
┌─────────────────┐
│  ProgramsView   │
└────────┬────────┘
         │ Usuario toca programa
         │ navigationState.resetForNewProgram()
         ↓
┌─────────────────┐
│  ProgramCard    │
└────────┬────────┘
         │ Crea NavigationState
         │ Navega a StagesView
         ↓
┌─────────────────────────────────────────────────────────┐
│  StagesView                                             │
│  ✅ SERVICIO: GET /programa-etapas (SIEMPRE)           │
└────────┬────────────────────────────────────────────────┘
         │
         ├─ Condiciones AUTO-SKIP:
         │  1. totalSize == 1
         │  2. mostrarSiEsUnSoloRegistroC == false
         │  3. backEtapas == false
         │  4. isFirstLoad == true
         │
         ├─ ✅ CUMPLE → Navegar a TasksView (mantener loading)
         └─ ❌ NO CUMPLE → Mostrar lista (desactivar loading)
         │
         ↓
┌─────────────────────────────────────────────────────────┐
│  TasksView                                              │
│  ✅ SERVICIO: GET /programa-tareas (SIEMPRE)           │
└────────┬────────────────────────────────────────────────┘
         │
         ├─ Condiciones AUTO-SKIP:
         │  1. totalTasks == 1
         │  2. estadoC != "Completo"
         │  3. mostrarSiEsUnSoloRegistroC == false
         │  4. backTareas == false
         │
         ├─ ✅ CUMPLE → Navegar a ElementsView (mantener loading)
         └─ ❌ NO CUMPLE → Mostrar lista (desactivar loading)
         │
         ↓
┌─────────────────────────────────────────────────────────┐
│  ElementsView                                           │
│  ⚠️ NO LLAMA SERVICIO (datos vienen de TasksView)      │
└────────┬────────────────────────────────────────────────┘
         │
         ├─ CAMINO B: saltarListaDeActividadesC == true
         │  → Navegar a cuestionario (desactivar loading)
         │
         └─ CAMINO A: Mostrar lista de actividades
            → Desactivar loading inmediatamente
```

---

## 📁 Archivos Modificados

### **1. NavigationState.swift** (NUEVO)
**Propósito:** ObservableObject compartido para manejar flags anti-loop

**Propiedades clave:**
```swift
@Published var backEtapas: Bool = false
@Published var backTareas: Bool = false
@Published var shouldReloadTareaFragment: Bool = false
```

**Métodos clave:**
```swift
func resetForNewProgram(programId: String)
func resetForBackToTasks()
func resetForBackToStages()
func updateContext(stageId:, taskId:, activityId:)
func printState()
```

---

### **2. ProgramCard.swift**
**Cambios:**
- ✅ Crea instancia de `NavigationState`
- ✅ Resetea flags al tocar un programa
- ✅ Pasa `navigationState` a `StagesView` via `.environmentObject()`

**Código:**
```swift
@StateObject private var navigationState = NavigationState()

Button {
    navigationState.resetForNewProgram(programId: program.Id)
    navigationState.printState()
    isPresentingStagesDetails = true
} label: {
    // ...
}
.navigationLink(isActive: $isPresentingStagesDetails) {
    StagesView(...)
        .environmentObject(navigationState)
}
```

---

### **3. StagesView.swift**
**Cambios:**
- ✅ Recibe `@EnvironmentObject var navigationState: NavigationState`
- ✅ Verifica TODAS las condiciones de Android antes de auto-skip
- ✅ Pasa `navigationState` a `TasksView`

**Condiciones de Auto-Skip:**
```swift
if listStage.totalSize == 1,
   let stage = listStage.records.first,
   stage.mostrarSiEsUnSoloRegistroC == false,  // ✅ NUEVO
   !navigationState.backEtapas,                 // ✅ NUEVO
   isFirstLoad {
    // Auto-navegar a TasksView
    navigationState.updateContext(stageId: stage.Id)
    goTask()
}
```

**Logs de Debug:**
```swift
print("🎯 [StagesView] AUTO-SKIP activado:")
print("   - Solo 1 etapa")
print("   - Mostrar_Si_Es_Un_Solo_Registro__c = false")
print("   - backEtapas = false")
print("   - Navegando directamente a TasksView...")
```

---

### **4. TasksView.swift**
**Cambios:**
- ✅ Recibe `@EnvironmentObject var navigationState: NavigationState`
- ✅ Verifica TODAS las condiciones de Android antes de auto-skip
- ✅ Pasa `navigationState` a `ElementsView`
- ✅ Marca `backTareas = true` en `.onDisappear`

**Condiciones de Auto-Skip:**
```swift
if totalTasks == 1,
   let task = singleTask,
   task.estadoC != "Completo",                  // ✅ NUEVO
   task.mostrarSiEsUnSoloRegistroC == false,    // ✅ NUEVO
   !navigationState.backTareas {                // ✅ NUEVO
    // Auto-navegar a ElementsView
    navigationState.updateContext(taskId: task.Id)
    self.navigateToElementsView = true
}
```

**Manejo de Back Navigation:**
```swift
.onDisappear {
    showAlert = false
    
    if shouldAutoNavigate {
        print("🔙 [TasksView] Marcando backTareas = true")
        navigationState.resetForBackToTasks()
    }
}
```

---

### **5. ElementsView.swift**
**Cambios:**
- ✅ Recibe `@EnvironmentObject var navigationState: NavigationState`
- ✅ Actualiza contexto con `taskId`
- ✅ Logs mejorados para debugging

**Lógica de Caminos:**
```swift
// CAMINO B: Cuestionario de concatenación
if taskData.saltarListaDeActividadesC == true {
    print("🎯 [ElementsView] CAMINO B: Navegando al cuestionario")
    navigateToQuestions = true
    isQuestionnaire = true
    
    // Desactivar loading después de navegar
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.isLoadingTasks = false
    }
}
// CAMINO A: Lista de actividades
else {
    print("📋 [ElementsView] CAMINO A: Mostrando lista")
    self.isLoadingTasks = false
}
```

---

## 🧪 Casos de Prueba

### **Caso 1: Auto-Skip Completo (1 Etapa → 1 Tarea → Cuestionario)**
**Escenario:**
- Programa con 1 etapa
- Etapa con 1 tarea
- Tarea con `saltarListaDeActividadesC = true`

**Comportamiento Esperado:**
1. ✅ ProgramCard → Resetea flags
2. ✅ StagesView → GET /programa-etapas → Auto-skip a TasksView
3. ✅ TasksView → GET /programa-tareas → Auto-skip a ElementsView
4. ✅ ElementsView → Camino B → Navega al cuestionario
5. ✅ Loading activo durante TODO el flujo
6. ✅ Loading se desactiva en ElementDetailsView

**Logs esperados:**
```
🔄 [NavigationState] Reset completo para nuevo programa: {id}
🎯 [StagesView] AUTO-SKIP activado: Solo 1 etapa...
🎯 [TasksView] AUTO-SKIP activado: Solo 1 tarea...
🎯 [ElementsView] CAMINO B: Navegando al cuestionario
✅ [ElementsView] Loading desactivado - Camino B completado
```

---

### **Caso 2: Auto-Skip con Lista Final (1 Etapa → 1 Tarea → Lista de Actividades)**
**Escenario:**
- Programa con 1 etapa
- Etapa con 1 tarea
- Tarea con `saltarListaDeActividadesC = false`

**Comportamiento Esperado:**
1. ✅ Auto-skip hasta ElementsView
2. ✅ ElementsView muestra lista de actividades (Camino A)
3. ✅ Loading se desactiva inmediatamente

**Logs esperados:**
```
🎯 [StagesView] AUTO-SKIP activado...
🎯 [TasksView] AUTO-SKIP activado...
📋 [ElementsView] CAMINO A: Mostrando lista de actividades
✅ [ElementsView] Loading desactivado - Camino A completado
```

---

### **Caso 3: No Auto-Skip por Estado "Completo"**
**Escenario:**
- Programa con 1 etapa
- Etapa con 1 tarea
- Tarea con `estadoC = "Completo"`

**Comportamiento Esperado:**
1. ✅ Auto-skip en StagesView
2. ✅ TasksView muestra lista (NO auto-skip por estar completa)
3. ✅ Loading se desactiva en TasksView

**Logs esperados:**
```
🎯 [StagesView] AUTO-SKIP activado...
📋 [TasksView] Mostrando lista (1 tarea pero no cumple condiciones)
   - Estado: Completo
✅ [TasksView] Loading desactivado
```

---

### **Caso 4: No Auto-Skip por "Mostrar_Si_Es_Un_Solo_Registro__c = true"**
**Escenario:**
- Programa con 1 etapa
- Etapa.mostrarSiEsUnSoloRegistroC = true

**Comportamiento Esperado:**
1. ✅ StagesView muestra lista (NO auto-skip)
2. ✅ Loading se desactiva inmediatamente

**Logs esperados:**
```
📋 [StagesView] Mostrando lista (1 etapa pero no cumple condiciones)
✅ [StagesView] Loading desactivado
```

---

### **Caso 5: Back Navigation - Evitar Loop Infinito**
**Escenario:**
- Usuario navega automáticamente: Programa → Etapa → Tarea → Actividades
- Usuario presiona "atrás" hasta TasksView

**Comportamiento Esperado:**
1. ✅ Al volver a TasksView, `backTareas = true`
2. ✅ TasksView NO auto-navega de nuevo (muestra lista)
3. ✅ Usuario puede navegar manualmente

**Logs esperados:**
```
🔙 [TasksView] Marcando backTareas = true
👁️ [TasksView] onAppear (volviendo de navegación)
🔍 [TasksView] backTareas: true
📋 [TasksView] Mostrando lista (no cumple condiciones de auto-skip)
```

---

### **Caso 6: Múltiples Etapas - Sin Auto-Skip**
**Escenario:**
- Programa con 3 etapas

**Comportamiento Esperado:**
1. ✅ StagesView muestra lista de 3 etapas
2. ✅ Loading se desactiva inmediatamente
3. ✅ Usuario elige manualmente

**Logs esperados:**
```
📋 [StagesView] Mostrando lista (3 etapas)
✅ [StagesView] Loading desactivado
```

---

## 🐛 Debugging

### **Ver Estado de NavigationState en Cualquier Momento:**
```swift
navigationState.printState()
```

**Output:**
```
🔍 [NavigationState] Estado actual:
   - backEtapas: false
   - backTareas: false
   - shouldReloadTareaFragment: false
   - Programa: a1X5e000000ABCD
   - Etapa: a1Y5e000000EFGH
   - Tarea: a1Z5e000000IJKL
   - Actividad: nil
```

### **Logs Clave a Buscar:**
- `🔄` → Reset de flags
- `🎯` → Auto-skip activado
- `📋` → Mostrando lista (no auto-skip)
- `🔙` → Back navigation detectada
- `✅` → Loading desactivado
- `❌` → Error

---

## 📊 Tabla de Comparación: Android vs iOS

| Aspecto | Android | iOS (Implementado) | Estado |
|---------|---------|-------------------|--------|
| Servicios siempre ejecutan | ✅ | ✅ | ✅ |
| Auto-skip en Etapas | ✅ | ✅ | ✅ |
| Auto-skip en Tareas | ✅ | ✅ | ✅ |
| Auto-skip en Actividades | ✅ | ✅ | ✅ |
| Verificar `Mostrar_Si_Es_Un_Solo_Registro__c` | ✅ | ✅ | ✅ |
| Verificar `Estado__c != "Completo"` | ✅ | ✅ | ✅ |
| Flag `backEtapas` | ✅ | ✅ | ✅ |
| Flag `backTareas` | ✅ | ✅ | ✅ |
| Loading continuo durante auto-skip | ✅ | ✅ | ✅ |
| Logs de debugging | ✅ | ✅ | ✅ |

---

## 🎉 Checklist de Implementación

- [✅] Crear `NavigationState.swift`
- [✅] Actualizar `ProgramCard.swift` con NavigationState
- [✅] Actualizar `StagesView.swift` con verificación de `mostrarSiEsUnSoloRegistroC` y `backEtapas`
- [✅] Actualizar `TasksView.swift` con verificación de `estadoC`, `mostrarSiEsUnSoloRegistroC` y `backTareas`
- [✅] Actualizar `ElementsView.swift` con NavigationState
- [✅] Mantener loading activo durante toda la cadena de auto-navegación
- [✅] Agregar logs de debugging en todos los puntos clave
- [✅] Manejar back navigation correctamente
- [ ] **Probar todos los casos de prueba**

---

## 🚨 Notas Importantes

1. **NavigationState es @StateObject en ProgramCard y @EnvironmentObject en hijos**
   - Esto garantiza que el estado se mantenga durante toda la navegación

2. **Los flags NO se resetean automáticamente al volver**
   - Solo se resetean al entrar a un NUEVO programa
   - Esto evita loops infinitos

3. **El loading se mantiene activo HASTA el destino final**
   - StagesView → TasksView → ElementsView → Cuestionario
   - Se desactiva SOLO cuando no hay más navegación automática

4. **Los servicios SIEMPRE se ejecutan**
   - El auto-skip decide QUÉ HACER con los datos después de recibirlos
   - NUNCA se salta la llamada al servicio

---

## 📚 Referencias

- Documentación de Android: Ver descripción del requerimiento inicial
- `CONCATENACION_LOGIC.md`: Lógica de concatenación de actividades
- `BUG_FIX_EVALUACION_BLOQUEADA.md`: Bugs relacionados con navegación

---

**Última actualización:** 13/02/2026
**Implementado por:** AI Assistant
**Status:** ✅ Completado - Pendiente de testing
