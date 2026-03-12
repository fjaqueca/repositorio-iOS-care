# Comparación Técnica: Android vs iOS - ElementsView/TareaFragment

## Arquitectura de Estado Compartido

### Android: Activity-Based State
```kotlin
class ProgramasMainActivity : AppCompatActivity() {
    // ✅ Estado persistente que sobrevive a la destrucción de Fragments
    var actividades = ""  // JSON raw
    var listActividades: MutableList<Actividad> = mutableListOf()
    var opcionSeleccionada: Int = ETAPAS
    var shouldReloadTareaFragment = false
}

class TareaFragment : Fragment() {
    // Fragment se destruye y recrea, pero Activity mantiene el estado
    lateinit var mainActivityProgramas: ProgramasMainActivity
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        // Siempre accede a mainActivityProgramas.actividades
        loadActividadesData()  // Parsea el JSON
        showActividades()      // Renderiza
    }
}
```

**Ciclo de vida Android:**
```
Activity CREADA
    ↓
Fragment A CREADO → DESTRUIDO
    ↓
Fragment B CREADO → DESTRUIDO
    ↓
Fragment A CREADO (otra vez)
    └── Activity.actividades sigue existiendo ✅
```

---

### iOS: SwiftUI State Management
```swift
// NavigationState: Similar al Activity, pero con @Published
@MainActor
class NavigationState: ObservableObject {
    @Published var shouldReloadTareaFragment = false
    @Published var backFromTasks = false
    // Estado compartido entre vistas
}

struct ElementsView: View {
    // @State: Estado local que persiste mientras la vista existe
    @State var allActivities: Activities  // Datos ya parseados
    @State var progress: Int = 0
    
    // @EnvironmentObject: Estado compartido desde el padre
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        // SwiftUI renderiza automáticamente cuando cambian los @State
    }
}
```

**Ciclo de vida SwiftUI:**
```
TasksView EXISTE
    ↓
ElementsView CREADA
    ↓ (usuario navega adelante)
ElementDetailsView CREADA
    └── ElementsView sigue en memoria (oculta) ✅
    ↓ (usuario navega atrás)
ElementDetailsView DESTRUIDA
ElementsView RE-APARECE (.onAppear se ejecuta)
    └── @State var allActivities sigue existiendo ✅
```

**Diferencia clave:**
- **Android:** Fragment se **destruye** y **recrea**, por eso necesita re-parsear el JSON
- **iOS:** SwiftUI View permanece en memoria (oculta), por eso los `@State` persisten

---

## Parseo y Renderizado de Datos

### Android: Parseo en cada onViewCreated()

```kotlin
fun loadActividadesData() {
    // ✅ SIEMPRE limpia y re-parsea desde cero
    mainActivityProgramas.listActividades.clear()
    
    if (mainActivityProgramas.actividades != null) {
        val jsonArrayActividades = JSONObject(mainActivityProgramas.actividades)
            .getJSONArray("records")
        
        for (i in 0 until jsonArrayActividades.length()) {
            val actividad = Actividad()
            // ... parsea todos los campos ...
            mainActivityProgramas.listActividades.add(actividad)
        }
    }
    
    binding.cantElementos.text = "Lista de actividades"
}

fun showActividades() {
    // ✅ SIEMPRE limpia y re-renderiza desde cero
    binding.elementosContainer.removeAllViews()
    
    for (i in 0 until mainActivityProgramas.listActividades.size) {
        val actividad = mainActivityProgramas.listActividades.get(i)
        if (!actividad.Actividad_Invisible__c) {
            val item = layoutInflater.inflate(...)
            // ... configurar item ...
            binding.elementosContainer.addView(item)
        }
    }
}
```

**Por qué funciona:**
- `clear()` + `removeAllViews()` garantizan que no haya datos/vistas duplicadas
- Re-parseo desde JSON asegura datos frescos
- Sincrónico → se ejecuta antes de `binding.contentScrollView.visibility = View.VISIBLE`

---

### iOS: Cálculo con datos existentes

```swift
private func calculateProgress() {
    // ✅ Calcula con allActivities ya parseado (no re-parsea)
    guard let activities = allActivities.records else {
        progress = 0
        return
    }
    
    let completedActivities = activities.filter { activity in
        let completed = Int(activity.cantTaskCompletionC ?? 0)
        let total = Int((activity.totalTaskCompletion2C ?? 0) / 
                         (activity.totalTaskComTemplateC ?? 1))
        return completed >= total
    }
    
    progress = Int((Double(completedActivities.count) / 
                    Double(activities.count)) * 100)
}

// SwiftUI se encarga del renderizado automáticamente
var body: some View {
    ScrollView {
        ForEach(activities, id: \.Id) { activity in
            if !(activity.actividadInvisibleC ?? false) {
                ElementRowView(activity: activity, ...)
            }
        }
    }
    .id(listRefreshId)  // Forzar recreación cuando sea necesario
}
```

**Por qué funciona:**
- `allActivities` ya viene parseado desde `TasksView`
- SwiftUI renderiza automáticamente cuando cambia `@State`
- `listRefreshId = UUID()` fuerza recreación si es necesario
- Sincrónico → se ejecuta antes de `isLoadingTasks = false`

---

## Manejo de Recarga desde Servidor

### Android: Callback Explícito

```kotlin
override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    if (mainActivityProgramas.shouldReloadTareaFragment) {
        mainActivityProgramas.shouldReloadTareaFragment = false
        
        // Mostrar lista con datos actuales
        loadTareaDataWithoutAnimation()
        loadActividadesData()
        showActividades()
        
        // Recargar desde servidor (asíncrono)
        reloadTareaData()  // ← Hace GET al servidor
    }
}

fun reloadTareaData() {
    val service = RetrofitInstance.retrofitInstance!!.create(RequestService::class.java)
    val call = service.getTarea(...)
    
    call.enqueue(object : Callback<TareaResponse> {
        override fun onResponse(call: Call<TareaResponse>, response: Response<TareaResponse>) {
            // ✅ Callback explícito
            serviceResponse2(response, RETURN_RELOAD_TAREA)
        }
    })
}

fun serviceResponse2(response: Response<TareaResponse>, action: Int) {
    if (action == RETURN_RELOAD_TAREA) {
        // Actualizar JSON en Activity
        mainActivityProgramas.actividades = response.body()!!.Actividades__r.toString()
        
        // Re-parsear y re-renderizar
        loadActividadesData()
        showActividades()
        loadTareaData()
        
        // Mostrar contenido
        binding.contentScrollView.visibility = View.VISIBLE
    }
}
```

**Flujo:**
```
onViewCreated()
    ↓
loadActividadesData() + showActividades()  [Lista visible con datos actuales]
    ↓
reloadTareaData() → GET servidor
    ↓ (1-3 segundos)
onResponse()
    ↓
serviceResponse2(RETURN_RELOAD_TAREA)
    ↓
loadActividadesData() + showActividades()  [Lista actualizada con datos frescos]
```

---

### iOS: Async/Await con Task

```swift
.onAppear {
    // Mostrar lista con datos actuales
    calculateProgress()
    self.isLoadingTasks = false
    
    if shouldReload {
        // Recargar desde servidor (asíncrono)
        Task { @MainActor in
            await refreshDataInBackground()
        }
    }
}

private func refreshDataInBackground() async {
    let result = await Network.shared.getActivities(taskId: taskId)
    
    switch result {
    case .success(let updatedActivities):
        await MainActor.run {
            self.allActivities = updatedActivities
            self.listRefreshId = UUID()  // Forzar recreación
            calculateProgress()          // Recalcular
        }
    case .failure(let error):
        print("❌ Error: \(error)")
    }
}
```

**Flujo:**
```
onAppear()
    ↓
calculateProgress()  [Sincrónico]
    ↓
isLoadingTasks = false  [Lista visible con datos actuales]
    ↓
Task { await refreshDataInBackground() }  [No bloquea]
    ↓ (1-3 segundos, en paralelo)
Success
    ↓
MainActor.run {
    allActivities = ...  [SwiftUI re-renderiza automáticamente]
    listRefreshId = UUID()
}
```

**Diferencias:**
- **Android:** Callbacks explícitos (`enqueue(callback)`)
- **iOS:** Async/await con `Task` + `@MainActor`

---

## Comparación de Flags de Estado

### Android
```kotlin
class ProgramasMainActivity {
    var shouldReloadTareaFragment = false
    var shouldReloadTareas = false
    var shouldReloadEtapas = false
    var opcionSeleccionada: Int = ETAPAS  // ← Evita auto-navegación
}
```

**Uso:**
- `opcionSeleccionada` cambia al navegar entre fragments
- Si vuelves al mismo fragment, `opcionSeleccionada` ya está seteada
- El código NO re-ejecuta la lógica de auto-navegación

---

### iOS
```swift
@MainActor
class NavigationState: ObservableObject {
    @Published var shouldReloadTareaFragment = false
    @Published var backFromTasks = false  // ← Equivalente a opcionSeleccionada
    @Published var shouldDismissToTasks = false
}
```

**Uso:**
- `backFromTasks` se activa al navegar hacia atrás
- Si vuelves a la misma vista, el flag evita auto-navegación
- Similar a Android, pero usando `@Published` en lugar de `var`

---

## Tabla Comparativa

| Aspecto | Android | iOS |
|---------|---------|-----|
| **Estado compartido** | `Activity` con `var` | `NavigationState` con `@Published` |
| **Persistencia de datos** | JSON raw en Activity, parseo en cada `onViewCreated()` | Objetos Swift en `@State`, persisten mientras la vista existe |
| **Renderizado** | Imperativo: `addView()`, `removeAllViews()` | Declarativo: SwiftUI re-renderiza automáticamente |
| **Recarga asíncrona** | Callbacks: `enqueue(callback)` | Async/await: `Task { await ... }` |
| **Flag anti-navegación** | `opcionSeleccionada` | `backFromTasks` |
| **Lifecycle** | Fragment se destruye y recrea | View permanece en memoria (oculta) |
| **Parseo de datos** | Siempre (cada `onViewCreated()`) | Solo cuando llegan datos del servidor |
| **Forzar recreación** | `removeAllViews()` + `addView()` | `listRefreshId = UUID()` |

---

## Lecciones Aprendidas

### 1. SwiftUI es declarativo, no imperativo

**Android (imperativo):**
```kotlin
binding.elementosContainer.removeAllViews()  // Limpia
for (actividad in listActividades) {
    binding.elementosContainer.addView(item)  // Agrega
}
```

**iOS (declarativo):**
```swift
ForEach(activities, id: \.Id) { activity in
    ElementRowView(activity: activity)
}
.id(listRefreshId)  // SwiftUI maneja la recreación
```

SwiftUI observa los cambios en `@State` y re-renderiza automáticamente.

---

### 2. onAppear != onViewCreated

**Android `onViewCreated()`:**
- Se ejecuta **cada vez** que el Fragment se crea
- Fragment se destruye al navegar hacia adelante

**iOS `onAppear`:**
- Se ejecuta **cada vez** que la View aparece (incluso si ya existía)
- View puede permanecer en memoria al navegar hacia adelante

Por eso necesitamos `backFromTasks` para diferenciar:
- Primera entrada (ejecutar auto-navegación)
- Re-entrada (NO ejecutar auto-navegación)

---

### 3. Persistencia de estado diferente

**Android:**
```
Activity.actividades = JSON  ← Persiste
Fragment.listActividades     ← Se pierde al destruir Fragment
```

**iOS:**
```
@State var allActivities      ← Persiste mientras la View existe
@EnvironmentObject navigationState  ← Persiste en toda la jerarquía
```

---

### 4. Operaciones sincrónicas vs asíncronas

**Clave:** Las operaciones que afectan la visibilidad de la UI deben ser **sincrónicas**.

**Android:** `loadActividadesData()` es sincrónico → se ejecuta **antes** de `visibility = View.VISIBLE`

**iOS:** `calculateProgress()` es sincrónico → se ejecuta **antes** de `isLoadingTasks = false`

Las recargas del servidor pueden ser asíncronas porque la lista ya está visible.

---

## Conclusión

Aunque Android e iOS usan paradigmas diferentes (imperativo vs declarativo), la **lógica de negocio** es la misma:

1. **Siempre mostrar contenido de inmediato** con datos actuales
2. **Recargar en background** si es necesario
3. **Actualizar UI suavemente** cuando lleguen datos frescos
4. **Usar flags** para evitar auto-navegación indeseada

La implementación en iOS ahora replica fielmente la experiencia de Android.
