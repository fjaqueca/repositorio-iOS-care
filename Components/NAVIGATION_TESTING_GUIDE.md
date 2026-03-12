# 🧪 Guía de Testing - Navegación Automática iOS

## 🎯 Objetivo
Verificar que la lógica de navegación automática funciona correctamente en todos los escenarios posibles, replicando exactamente el comportamiento de Android.

---

## ✅ Pre-requisitos

Antes de comenzar el testing, verificar:

1. **Xcode compilando sin errores**
   ```bash
   ⌘ + B (Build)
   ```

2. **Ningún warning relacionado con NavigationState**

3. **Logs de debugging habilitados** (por defecto están activos)

---

## 📋 Casos de Prueba

### **Caso 1: Auto-Skip Completo (Triple Nivel)**
**Setup:**
- Programa con 1 etapa
- `Etapa.mostrarSiEsUnSoloRegistroC = false`
- Etapa con 1 tarea
- `Tarea.mostrarSiEsUnSoloRegistroC = false`
- `Tarea.estadoC != "Completo"`
- `Tarea.saltarListaDeActividadesC = true`

**Pasos:**
1. Abrir ProgramsView
2. Tocar el programa
3. Observar navegación automática

**Resultado Esperado:**
- ✅ Loading visible durante TODO el flujo
- ✅ NO se muestra StagesView
- ✅ NO se muestra TasksView
- ✅ Se muestra ElementDetailsView (cuestionario) directamente
- ✅ Loading se desactiva al llegar al cuestionario

**Logs Esperados:**
```
🔄 [NavigationState] Reset completo para nuevo programa: {id}
🎯 [StagesView] AUTO-SKIP activado:
   - Solo 1 etapa
   - Mostrar_Si_Es_Un_Solo_Registro__c = false
   - backEtapas = false
   - Navegando directamente a TasksView...
📍 [NavigationState] Stage actual: {stage_id}
🎯 [TasksView] AUTO-SKIP activado:
   - Solo 1 tarea
   - Estado: En Curso (no es Completo)
   - Mostrar_Si_Es_Un_Solo_Registro__c = false
   - backTareas = false
   - Tarea: {task_name}
   - Navegando automáticamente a ElementsView...
📍 [NavigationState] Tarea actual: {task_id}
🎯 [ElementsView] CAMINO B: Navegando directamente al cuestionario de concatenación
   - Actividad pendiente: {activity_name}
✅ [ElementsView] Loading desactivado - Camino B completado
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 2: Auto-Skip Parcial (Solo Etapa)**
**Setup:**
- Programa con 1 etapa
- `Etapa.mostrarSiEsUnSoloRegistroC = false`
- Etapa con 3 tareas

**Pasos:**
1. Abrir ProgramsView
2. Tocar el programa
3. Observar navegación

**Resultado Esperado:**
- ✅ Auto-skip de StagesView a TasksView
- ✅ TasksView muestra lista de 3 tareas
- ✅ Loading se desactiva al llegar a TasksView

**Logs Esperados:**
```
🔄 [NavigationState] Reset completo para nuevo programa: {id}
🎯 [StagesView] AUTO-SKIP activado...
📋 [TasksView] Mostrando lista normal de tareas (3 tareas)
✅ [TasksView] Loading desactivado
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 3: Sin Auto-Skip (Estado Completo)**
**Setup:**
- Programa con 1 etapa
- `Etapa.mostrarSiEsUnSoloRegistroC = false`
- Etapa con 1 tarea
- `Tarea.estadoC = "Completo"` ← CLAVE

**Pasos:**
1. Abrir ProgramsView
2. Tocar el programa
3. Observar navegación

**Resultado Esperado:**
- ✅ Auto-skip de StagesView a TasksView
- ✅ TasksView muestra lista (NO auto-skip por estar completa)
- ✅ Loading se desactiva en TasksView

**Logs Esperados:**
```
🎯 [StagesView] AUTO-SKIP activado...
📋 [TasksView] Mostrando lista (1 tarea pero no cumple condiciones de auto-skip)
   - Estado: Completo
   - Mostrar_Si_Es_Un_Solo_Registro__c: false
   - backTareas: false
✅ [TasksView] Loading desactivado
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 4: Sin Auto-Skip (Mostrar_Si_Es_Un_Solo_Registro__c = true)**
**Setup:**
- Programa con 1 etapa
- `Etapa.mostrarSiEsUnSoloRegistroC = true` ← CLAVE

**Pasos:**
1. Abrir ProgramsView
2. Tocar el programa
3. Observar navegación

**Resultado Esperado:**
- ✅ StagesView muestra lista (NO auto-skip)
- ✅ Loading se desactiva inmediatamente

**Logs Esperados:**
```
📋 [StagesView] Mostrando lista (1 etapa pero no cumple condiciones de auto-skip)
✅ [StagesView] Loading desactivado
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 5: Back Navigation - Anti-Loop en Tareas**
**Setup:**
- Mismo setup que Caso 1 (triple auto-skip)

**Pasos:**
1. Navegar automáticamente hasta el cuestionario
2. Presionar "atrás" hasta llegar a TasksView
3. Observar comportamiento

**Resultado Esperado:**
- ✅ TasksView muestra lista de tareas (NO auto-skip de nuevo)
- ✅ Flag `backTareas = true` está activo
- ✅ Usuario puede tocar la tarea manualmente

**Logs Esperados:**
```
🔙 [TasksView] Marcando backTareas = true para evitar auto-skip al volver
👁️ [TasksView] onAppear (volviendo de navegación)
🔍 [TasksView] shouldAutoNavigate: true
🔍 [TasksView] backTareas: true
📋 [TasksView] Mostrando lista (1 tarea pero no cumple condiciones de auto-skip)
   - backTareas: true
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 6: Back Navigation - Anti-Loop en Etapas**
**Setup:**
- Mismo setup que Caso 1

**Pasos:**
1. Navegar automáticamente hasta el cuestionario
2. Presionar "atrás" hasta llegar a StagesView
3. Observar comportamiento

**Resultado Esperado:**
- ✅ StagesView muestra lista de etapas (NO auto-skip de nuevo)
- ✅ Flag `backEtapas = true` está activo

**Logs Esperados:**
```
🔙 [StagesView] Posible back navigation
👁️ [StagesView] onAppear
🔍 [StagesView] backEtapas: true
📋 [StagesView] Mostrando lista (1 etapa pero no cumple condiciones)
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 7: Cambio de Programa - Reset de Flags**
**Setup:**
- Navegar al Programa A (con auto-skip)
- Volver a ProgramsView
- Entrar al Programa B (con auto-skip)

**Pasos:**
1. Navegar al Programa A
2. Presionar "atrás" hasta ProgramsView
3. Tocar Programa B
4. Observar navegación

**Resultado Esperado:**
- ✅ Programa B hace auto-skip normalmente (flags reseteados)
- ✅ NO arrastra los flags de Programa A

**Logs Esperados:**
```
🔄 [NavigationState] Reset completo para nuevo programa: {programa_B_id}
🎯 [StagesView] AUTO-SKIP activado...
🎯 [TasksView] AUTO-SKIP activado...
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 8: Múltiples Etapas - Sin Auto-Skip**
**Setup:**
- Programa con 3 etapas

**Pasos:**
1. Abrir ProgramsView
2. Tocar el programa
3. Observar navegación

**Resultado Esperado:**
- ✅ StagesView muestra lista de 3 etapas
- ✅ NO hay auto-skip
- ✅ Loading se desactiva inmediatamente

**Logs Esperados:**
```
📋 [StagesView] Mostrando lista (3 etapas)
✅ [StagesView] Loading desactivado
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 9: Camino A (Lista de Actividades)**
**Setup:**
- Programa con 1 etapa, 1 tarea
- `Tarea.saltarListaDeActividadesC = false` ← CLAVE

**Pasos:**
1. Navegar al programa
2. Observar comportamiento

**Resultado Esperado:**
- ✅ Auto-skip hasta ElementsView
- ✅ ElementsView muestra lista de actividades (Camino A)
- ✅ NO navega al cuestionario

**Logs Esperados:**
```
🎯 [StagesView] AUTO-SKIP activado...
🎯 [TasksView] AUTO-SKIP activado...
📋 [ElementsView] CAMINO A: Mostrando lista de actividades normal
✅ [ElementsView] Loading desactivado - Camino A completado
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

### **Caso 10: Camino B (Cuestionario Directo)**
**Setup:**
- Programa con 1 etapa, 1 tarea
- `Tarea.saltarListaDeActividadesC = true` ← CLAVE
- Actividades pendientes por completar

**Pasos:**
1. Navegar al programa
2. Observar comportamiento

**Resultado Esperado:**
- ✅ Auto-skip hasta ElementsView
- ✅ ElementsView navega automáticamente al cuestionario (Camino B)
- ✅ NO muestra lista de actividades

**Logs Esperados:**
```
🎯 [StagesView] AUTO-SKIP activado...
🎯 [TasksView] AUTO-SKIP activado...
🎯 [ElementsView] CAMINO B: Navegando directamente al cuestionario de concatenación
   - Actividad pendiente: {activity_name}
   - Completado: 0/5
✅ [ElementsView] Loading desactivado - Camino B completado
```

**Status:** [ ] PASS [ ] FAIL

**Notas:**
_______________________

---

## 🐛 Problemas Comunes

### **Problema 1: Loading no se desactiva**
**Síntoma:** Spinner girando infinitamente

**Posibles Causas:**
- `isLoadingTasks` no se está cambiando a `false`
- NavigationState no se está pasando correctamente

**Solución:**
1. Verificar logs para ver dónde se detiene el flujo
2. Verificar que `.environmentObject(navigationState)` está en todas las vistas
3. Verificar que `isLoadingTasks` se cambia a `false` al final del camino

---

### **Problema 2: Auto-skip cuando no debería**
**Síntoma:** Navega automáticamente aunque hay múltiples registros

**Posibles Causas:**
- Condiciones de auto-skip mal implementadas
- Flags no se están reseteando correctamente

**Solución:**
1. Verificar logs: `"📊 Total de tareas encontradas: X"`
2. Verificar valor de `mostrarSiEsUnSoloRegistroC` en el servidor
3. Verificar que `estadoC` no es "Completo"

---

### **Problema 3: Loop infinito**
**Síntoma:** Navega automáticamente, presiono atrás, y vuelve a navegar automáticamente

**Posibles Causas:**
- Flags `backEtapas`/`backTareas` no se están activando
- `.onDisappear` no se está ejecutando

**Solución:**
1. Verificar logs: Debe aparecer `"🔙 [TasksView] Marcando backTareas = true"`
2. Verificar que `.onDisappear` está implementado en TasksView
3. Verificar que el flag se está usando en la condición de auto-skip

---

## 📊 Resumen de Testing

**Total de Casos:** 10

**Resultados:**
- ✅ PASS: ___ / 10
- ❌ FAIL: ___ / 10

**Observaciones Generales:**
_________________________________________________
_________________________________________________
_________________________________________________

**Bugs Encontrados:**
_________________________________________________
_________________________________________________
_________________________________________________

**Fecha de Testing:** ___/___/______
**Tester:** _________________________
**Build:** __________________________

---

## 🚀 Siguiente Paso

Una vez completado el testing:
1. Corregir bugs encontrados
2. Volver a ejecutar casos fallidos
3. Documentar soluciones en este archivo
4. Hacer commit con descripción detallada

---

**Última actualización:** 13/02/2026
