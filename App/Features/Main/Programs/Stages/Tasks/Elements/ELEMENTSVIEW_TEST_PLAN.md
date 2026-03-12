# Plan de Pruebas: ElementsView - Lista Siempre Visible

## Objetivo
Verificar que la lista de actividades en `ElementsView` se muestre **siempre** de inmediato, sin importar el camino de navegación.

---

## Pre-requisitos

1. ✅ Usuario autenticado en la app
2. ✅ Programa activo con al menos una tarea
3. ✅ Tarea con múltiples actividades
4. ✅ Al menos una actividad con cuestionario de concatenación

---

## Casos de Prueba

### ✅ Caso 1: Primera Entrada a una Tarea

**Objetivo:** Verificar que la lista se muestre inmediatamente al entrar por primera vez.

**Pasos:**
1. Desde `ProgramsView`, seleccionar un programa
2. En `StagesView` (si aplica), seleccionar una etapa
3. En `TasksView`, seleccionar una tarea
4. Observar `ElementsView`

**Resultado Esperado:**
- ✅ Lista de actividades visible en < 1 segundo
- ✅ Barra de progreso muestra el porcentaje correcto
- ✅ No se muestra pantalla de loading prolongada
- ✅ Título "Lista de Actividades" visible

**Debug Logs Esperados:**
```
👁️ [ElementsView] onAppear
🔍 [ElementsView] shouldReloadTareaFragment: false
🔍 [ElementsView] backFromTasks: false
📊 [ElementsView] Progreso calculado:
   - Total actividades: N
   - Completadas: X
   - Porcentaje: Y%
📋 [ElementsView] Lista de actividades visible de inmediato
   - Actividades totales: N
   - Progreso calculado: Y%
🎯 [ElementsView] CAMINO C: Primera entrada a la tarea
   - Verificando si debe auto-navegar...
```

---

### ✅ Caso 2: Volver de Modo Revisión (Problema Original)

**Objetivo:** Verificar que la lista se muestre inmediatamente al volver de completar una actividad.

**Setup:**
1. Entrar a una tarea con actividades pendientes
2. Completar una actividad (responder cuestionario)
3. Presionar "Cerrar" o botón de navegación hacia atrás

**Pasos:**
1. Usuario está en `ElementDetailsView` (cuestionario)
2. Responder todas las preguntas
3. Presionar "Enviar"
4. Sistema envía datos al servidor
5. `navigationState.shouldReloadTareaFragment` se marca como `true`
6. Vista regresa a `ElementsView`

**Resultado Esperado:**
- ✅ Lista de actividades visible **inmediatamente** (< 1 segundo)
- ✅ Lista muestra datos **actuales** (antes de la recarga del servidor)
- ✅ Barra de progreso calculada con datos actuales
- ✅ **NO se muestra pantalla de loading prolongada** ← FIX PRINCIPAL
- ✅ Después de 1-3 segundos, lista se actualiza suavemente con datos frescos del servidor
- ✅ Progreso se recalcula con datos frescos

**Debug Logs Esperados:**
```
👁️ [ElementsView] onAppear
🔍 [ElementsView] shouldReloadTareaFragment: true
🔍 [ElementsView] backFromTasks: false
📊 [ElementsView] Progreso calculado:
   - Total actividades: N
   - Completadas: X
   - Porcentaje: Y%
📋 [ElementsView] Lista de actividades visible de inmediato
   - Actividades totales: N
   - Progreso calculado: Y%
🔄 [ElementsView] CAMINO A: Recarga solicitada desde modo revisión
   - Lista ya visible con datos actuales
   - Iniciando recarga en background...
🔄 [ElementsView] Recargando datos en background...
🔄 [ElementsView] Lista regenerada con nuevo ID: <UUID>
✅ [ElementsView] Datos actualizados en background - Progreso: Z%
   📌 Actividad 1: X/Y - Invisible: false
   📌 Actividad 2: X/Y - Invisible: false
```

**Verificación Visual:**
- [ ] Usuario ve la lista inmediatamente al volver
- [ ] No hay parpadeo o pantalla vacía
- [ ] Lista se mantiene visible durante la recarga
- [ ] Actividad completada muestra el nuevo estado después de 1-3 segundos

---

### ✅ Caso 3: Navegar Hacia Atrás desde TasksView

**Objetivo:** Verificar que la lista se muestre sin recargar datos innecesariamente.

**Pasos:**
1. Estar en `ElementsView` viendo la lista de actividades
2. Presionar botón de navegación hacia atrás (< Back)
3. Volver a `TasksView`
4. Re-seleccionar la **misma** tarea
5. Volver a `ElementsView`

**Resultado Esperado:**
- ✅ Lista visible inmediatamente
- ✅ Datos se mantienen (no se recarga del servidor)
- ✅ Progreso sigue siendo el mismo
- ✅ NO hay auto-navegación

**Debug Logs Esperados:**
```
👁️ [ElementsView] onAppear
🔍 [ElementsView] shouldReloadTareaFragment: false
🔍 [ElementsView] backFromTasks: true
📊 [ElementsView] Progreso calculado: Y%
📋 [ElementsView] Lista de actividades visible de inmediato
🔙 [ElementsView] CAMINO B: Navegación hacia atrás detectada
   - Lista visible sin auto-navegación
```

---

### ✅ Caso 4: Tarea Completa al 100%

**Objetivo:** Verificar que NO haya auto-navegación cuando la tarea está completa.

**Setup:**
1. Completar todas las actividades de una tarea
2. Volver a `TasksView`
3. Re-entrar a la misma tarea

**Pasos:**
1. En `TasksView`, seleccionar tarea completa (100%)
2. Entrar a `ElementsView`

**Resultado Esperado:**
- ✅ Lista visible inmediatamente
- ✅ Todas las actividades muestran checkmark verde
- ✅ Barra de progreso muestra 100%
- ✅ **NO hay auto-navegación** al cuestionario
- ✅ Usuario puede seleccionar manualmente cualquier actividad para revisarla

**Debug Logs Esperados:**
```
👁️ [ElementsView] onAppear
📊 [ElementsView] Progreso calculado:
   - Porcentaje: 100%
🛑 [ElementsView] Tarea ya completa al 100% - mostrando vista sin navegación automática
   El usuario debe seleccionar manualmente una actividad para revisar
✅ [ElementsView] Loading desactivado - Tarea completa, lista visible
```

---

### ✅ Caso 5: Concatenación - Primera Actividad

**Objetivo:** Verificar auto-navegación al cuestionario si `saltarListaDeActividadesC = true`.

**Setup:**
1. Tarea con `saltarListaDeActividadesC = true`
2. Tarea con `idInicioDeConcatenacionEnrolamientoC` configurado
3. Actividades pendientes (< 100%)

**Pasos:**
1. En `TasksView`, seleccionar la tarea
2. Observar `ElementsView`

**Resultado Esperado:**
- ✅ Lista se muestra brevemente (< 300ms)
- ✅ Auto-navegación al cuestionario de la primera actividad
- ✅ Usuario entra directamente al modo concatenación

**Debug Logs Esperados:**
```
👁️ [ElementsView] onAppear
📋 [ElementsView] Lista de actividades visible de inmediato
🎯 [ElementsView] CAMINO C: Primera entrada a la tarea
🎯 [ElementsView] CAMINO B: Navegando directamente al cuestionario de concatenación
   - Actividad pendiente: <Nombre>
   - Completado: X/Y
✅ [ElementsView] Loading desactivado - Camino B completado
```

---

### ✅ Caso 6: Concatenación - Volver de Última Actividad

**Objetivo:** Verificar que el dismiss funcione correctamente al completar la última actividad.

**Setup:**
1. Estar en la última actividad de una concatenación
2. Completar la actividad
3. Sistema marca `shouldDismissToTasks = true`

**Pasos:**
1. En `ElementDetailsView`, completar última actividad
2. Presionar "Enviar"
3. Observar navegación

**Resultado Esperado:**
- ✅ Vista hace dismiss **sin mostrar** `ElementsView`
- ✅ Usuario regresa directamente a `TasksView`
- ✅ `TasksView` recarga datos automáticamente
- ✅ Tarea muestra nuevo progreso (100%)

**Debug Logs Esperados:**
```
[ElementDetailsView] Última actividad completada
[ElementDetailsView] Marcando shouldDismissToTasks = true
👁️ [ElementsView] onAppear
🔙 [ElementsView] shouldDismissToTasks detectado - Haciendo dismiss hacia TasksView
```

---

## Checklist de Verificación General

### Visual
- [ ] Lista de actividades siempre visible en < 1 segundo
- [ ] No hay parpadeos o pantallas vacías
- [ ] Barra de progreso muestra porcentaje correcto
- [ ] Actividades completadas muestran checkmark verde
- [ ] Actividades pendientes muestran estado correcto
- [ ] Loading suave y no intrusivo durante recarga en background

### Funcional
- [ ] Auto-navegación funciona solo cuando debe (primera entrada con saltarLista = true)
- [ ] NO hay auto-navegación al volver de modo revisión
- [ ] NO hay auto-navegación al volver desde TasksView
- [ ] NO hay auto-navegación cuando tarea está al 100%
- [ ] Datos se actualizan correctamente en background
- [ ] Concatenación funciona correctamente
- [ ] Dismiss hacia TasksView funciona correctamente

### Performance
- [ ] Lista visible en < 1 segundo (idealmente < 300ms)
- [ ] Cálculo de progreso toma < 10ms
- [ ] Recarga en background no bloquea UI
- [ ] Memoria no aumenta significativamente
- [ ] No hay leaks de memoria

### Logs
- [ ] Todos los logs de debug aparecen correctamente
- [ ] Flags se consumen en el orden correcto
- [ ] Caminos (A, B, C) se ejecutan según corresponde
- [ ] No hay logs de error inesperados

---

## Casos Edge

### 🔹 Edge Case 1: Red Lenta
**Escenario:** Servidor tarda 10+ segundos en responder

**Resultado Esperado:**
- ✅ Lista visible de inmediato con datos actuales
- ✅ Usuario puede interactuar con la lista mientras espera
- ✅ Lista se actualiza cuando finalmente llegan los datos
- ✅ NO se muestra error si la recarga falla (silent failure con log)

---

### 🔹 Edge Case 2: Sin Conexión
**Escenario:** Usuario sin internet al volver de modo revisión

**Resultado Esperado:**
- ✅ Lista visible de inmediato con datos actuales
- ✅ Recarga en background falla silenciosamente
- ✅ Usuario puede seguir usando la app con datos cached
- ✅ Log de error aparece en consola

---

### 🔹 Edge Case 3: Múltiples Navegaciones Rápidas
**Escenario:** Usuario navega atrás y adelante rápidamente

**Resultado Esperado:**
- ✅ No hay crashes
- ✅ Flags se manejan correctamente
- ✅ Lista siempre visible en cada entrada
- ✅ No hay requests duplicados al servidor

---

### 🔹 Edge Case 4: Tarea Sin Actividades
**Escenario:** Tarea con `allActivities.records = []` o `nil`

**Resultado Esperado:**
- ✅ Vista se muestra sin crashes
- ✅ Mensaje apropiado (o lista vacía)
- ✅ Progreso = 0%
- ✅ No hay auto-navegación

---

## Criterios de Éxito

### Mínimo Viable ✅
- [x] Lista visible en < 1 segundo en TODOS los casos
- [x] NO hay pantalla vacía al volver de modo revisión (caso crítico)
- [x] Datos se actualizan en background correctamente

### Deseable ✅
- [x] Lista visible en < 300ms
- [x] Transiciones suaves
- [x] Logs de debug completos

### Excelente ✅
- [x] Lista visible en < 100ms
- [x] Paridad completa con Android
- [x] Código bien documentado

---

## Regresión

Verificar que NO se rompieron flujos existentes:

- [ ] Flujo normal de completar actividades
- [ ] Concatenación de actividades
- [ ] Subir imágenes
- [ ] Favoritos
- [ ] Navegación entre programas/etapas/tareas
- [ ] Loading indicators en otros lugares

---

## Herramientas de Testing

### Manual Testing
1. Dispositivo físico (iOS 15+)
2. Simulador (iOS 17)
3. Diferentes tamaños de pantalla
4. Network Link Conditioner (simular red lenta)

### Logs
- Xcode Console
- Filtrar por `[ElementsView]`
- Verificar timestamps entre logs

### Performance
- Instruments (Time Profiler)
- Verificar que `calculateProgress()` sea < 10ms
- Verificar que `onAppear` complete en < 50ms

---

## Reporte de Bugs

Si encuentras un bug, reportar con:

1. **Pasos para reproducir** (exactos)
2. **Resultado esperado** vs **resultado actual**
3. **Logs de consola** (filtrados por `[ElementsView]`)
4. **Screenshots/Videos** (si aplica)
5. **Versión de iOS**
6. **Dispositivo** (físico o simulador)

---

## Sign-Off

- [ ] Todos los casos de prueba pasados
- [ ] No hay regresiones
- [ ] Performance aceptable
- [ ] Logs de debug apropiados
- [ ] Código revisado
- [ ] Documentación actualizada

**Testers:**
- [ ] Developer (self-test)
- [ ] QA Team
- [ ] Product Owner

**Fecha de Prueba:** _________________

**Resultado:** ☐ PASS  ☐ FAIL  ☐ PASS WITH ISSUES

**Notas:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
