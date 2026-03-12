# 📋 Lógica de Concatenación - Documentación Técnica

## 🎯 Problema Actual
El código actual marca una actividad como completada al 100% tan pronto como se responde la primera pregunta de un cuestionario con concatenación. Esto es incorrecto porque la concatenación permite crear flujos de preguntas dinámicos donde cada respuesta determina la siguiente pregunta.

## ✅ Solución Requerida

### 1. 🔗 Concatenación a Nivel de Task_Completion_Template__c

**Campo:** `Concatenacion_Picklist_Enrolamiento__c`

Cuando un Picklist tiene 3 opciones separadas por punto y coma (`;`), este campo puede contener 3 IDs de actividades también separados por punto y coma.

**Ejemplo:**
```
Posibles_Valores__c: "Opción A;Opción B;Opción C"
Concatenacion_Picklist_Enrolamiento__c: "Act001;Act002;Act003"
```

**Comportamiento:**
- Usuario selecciona "Opción A" (índice 0) → Navegar a actividad "Act001"
- Usuario selecciona "Opción B" (índice 1) → Navegar a actividad "Act002"
- Usuario selecciona "Opción C" (índice 2) → Navegar a actividad "Act003"

**Implementación en ElementDetailsView:**
```swift
func handlePicklistResponse(selectedIndex: Int, concatenacionIds: String?) -> String? {
    guard let concatenacion = concatenacionIds, !concatenacion.isEmpty else {
        return nil
    }
    
    let ids = concatenacion.split(separator: ";")
        .map { String($0).trimmingCharacters(in: .whitespaces) }
    
    guard selectedIndex < ids.count else {
        return nil
    }
    
    return ids[selectedIndex]
}
```

### 2. 🔗 Concatenación a Nivel de Actividad_Programa__c

**Campo:** `Id_Actividad_Concatenada_Enrolamiento__c`

Si `Concatenacion_Picklist_Enrolamiento__c` está vacío, se debe revisar este campo a nivel de la actividad.

**Comportamiento:**
- Si tiene un ID válido → Navegar a esa actividad
- Si está vacío → FIN del flujo de concatenación

**Implementación:**
```swift
func getNextActivityId(from activity: Activities.Activity, picklistIndex: Int? = nil) -> String? {
    // 1. Primero verificar concatenación de Picklist
    if let templates = activity.taskCompletionTemplateR?.records {
        for template in templates where template.tipoDeDatosC == "Picklist" {
            if let nextId = handlePicklistResponse(
                selectedIndex: picklistIndex ?? 0,
                concatenacionIds: template.concatenacionPicklistEnrolamientoC
            ) {
                return nextId
            }
        }
    }
    
    // 2. Si no hay concatenación de Picklist, revisar nivel de actividad
    if let nextActivityId = activity.idActividadConcatenadaEnrolamientoC,
       !nextActivityId.isEmpty {
        return nextActivityId
    }
    
    // 3. No hay más concatenación
    return nil
}
```

### 3. 📝 Campo Requerido__c

**Reglas de Validación:**

1. **Si el Task_Completion_Template tiene solo 1 tipo de dato (distinto de Label):**
   - Siempre es REQUERIDO (ignorar valor de `Requerido__c`)

2. **Si el Task_Completion_Template tiene más de 1 tipo de dato (distinto de Label):**
   - Respetar el valor de `Requerido__c`

**Implementación en ElementDetailsView:**
```swift
func isFieldRequired(completion: [ActivityCompletion.Completion], field: ActivityCompletion.Completion) -> Bool {
    // Filtrar solo los campos que NO son Label
    let nonLabelFields = completion.filter { $0.tipoDeDatosC != "Label" }
    
    // Si solo hay 1 campo no-Label, siempre es requerido
    if nonLabelFields.count == 1 {
        return true
    }
    
    // Si hay más de 1, respetar el campo Requerido__c
    return field.requeridoC ?? false
}

var canSubmit: Bool {
    guard let completions = completion.records else { return false }
    let nonLabelFields = completions.filter { $0.tipoDeDatosC != "Label" }
    
    for field in nonLabelFields {
        let isRequired = isFieldRequired(completion: completions, field: field)
        
        if isRequired {
            let response = completionResponse[field.Id ?? ""]
            if response == nil || response?.isEmpty == true {
                return false // Campo requerido sin completar
            }
        }
    }
    
    return true // Todos los campos requeridos están completos
}
```

**Mostrar/Ocultar Botón "Enviar Datos":**
```swift
if canSubmit {
    PrimaryButton(title: "Enviar datos") {
        sendInfo()
    }
} else {
    Text("Completa todos los campos obligatorios")
        .font(.appCaption)
        .foregroundColor(.red)
}
```

### 4. 🔄 Reanudar Cuestionario (function_filter)

Cuando el usuario sale a mitad de un cuestionario y vuelve a entrar, debe continuar desde la primera pregunta NO respondida.

**Endpoint:** `function_filter`

**Paso 1: Consultar Task_Completion ya respondidos**
```swift
func fetchCompletedTemplates(activityId: String) async -> Set<String> {
    // Llamar a function_filter para obtener todos los Task_Completion
    // de esta actividad que ya tienen respuesta
    
    let result = await Network.shared.functionFilter(
        apiName: "Task_Completion__c",
        expectedFields: ["Id", "Task_Completion_Template__c", "Respuesta__c"],
        filters: [
            Filter(field: "Actividad_Programa__c", value: activityId)
        ]
    )
    
    var completedTemplateIds = Set<String>()
    
    switch result {
    case .success(let data):
        for completion in data {
            if let templateId = completion.taskCompletionTemplateC,
               let respuesta = completion.respuestaC,
               !respuesta.isEmpty {
                completedTemplateIds.insert(templateId)
            }
        }
    case .failure(let error):
        print("❌ Error fetching completed templates: \(error)")
    }
    
    return completedTemplateIds
}
```

**Paso 2: Navegar a la primera pregunta NO respondida**
```swift
func findNextUnansweredTemplate(
    activity: Activities.Activity,
    completedTemplates: Set<String>
) -> String? {
    guard let templates = activity.taskCompletionTemplateR?.records else {
        return nil
    }
    
    // Encontrar el primer template sin responder
    for template in templates.sorted(by: { ($0.ordenDeVisibilidadC ?? 0) < ($1.ordenDeVisibilidadC ?? 0) }) {
        if !completedTemplates.contains(template.Id ?? "") {
            return template.Id
        }
    }
    
    return nil // Todos están respondidos
}
```

**Paso 3: Continuar concatenación según respuestas anteriores**
```swift
func resumeQuestionnaire(activityId: String) async {
    // 1. Obtener templates ya completados
    let completedTemplates = await fetchCompletedTemplates(activityId: activityId)
    
    // 2. Obtener la última respuesta para saber por dónde seguir
    let lastAnswer = await getLastAnswer(activityId: activityId)
    
    // 3. Determinar siguiente actividad según concatenación
    if let lastPicklistAnswer = lastAnswer?.picklistIndex,
       let activity = findActivity(activityId) {
        
        if let nextActivityId = getNextActivityId(
            from: activity,
            picklistIndex: lastPicklistAnswer
        ) {
            // Navegar a la siguiente actividad en la concatenación
            navigateToActivity(nextActivityId)
        } else {
            // No hay más concatenación, buscar siguiente template en misma actividad
            if let nextTemplateId = findNextUnansweredTemplate(
                activity: activity,
                completedTemplates: completedTemplates
            ) {
                showTemplate(nextTemplateId)
            } else {
                // Todo completado al 100%
                markActivityAsCompleted(activityId)
            }
        }
    }
}
```

### 5. ✏️ Campo Editable__c

**Comportamiento:**
- `Editable__c == true` → Permitir editar respuestas ya enviadas
- `Editable__c == false` → No permitir edición

**Implementación:**

**Al cargar la vista:**
```swift
func loadExistingAnswers(templateId: String) async {
    let result = await Network.shared.functionFilter(
        apiName: "Task_Completion__c",
        expectedFields: ["Id", "Respuesta__c", "Task_Completion_Template__c"],
        filters: [
            Filter(field: "Task_Completion_Template__c", value: templateId)
        ]
    )
    
    switch result {
    case .success(let completions):
        if let completion = completions.first {
            // Cargar respuesta existente
            completionResponse[templateId] = completion.respuestaC
            existingCompletionId = completion.Id // Guardar ID para actualizar
        }
    case .failure(let error):
        print("❌ Error loading existing answers: \(error)")
    }
}
```

**Al enviar datos (UPDATE vs CREATE):**
```swift
func postTask() {
    Task {
        if let completions = completion.records {
            for com in completions {
                guard let response = completionResponse[com.Id ?? ""] else { continue }
                
                // Verificar si es editable y ya existe un registro
                if com.editableC == true, let existingId = existingCompletionId {
                    // ✅ ACTUALIZAR registro existente
                    let result = await Network.shared.updateTaskCompletion(
                        completionId: existingId,
                        newResponse: response
                    )
                } else {
                    // ✅ CREAR nuevo registro
                    let result = await Network.shared.postTask(
                        activityData: [com],
                        response: [com.Id ?? "": response]
                    )
                }
            }
        }
    }
}
```

**Mostrar respuesta existente en la UI:**
```swift
.onAppear {
    // Si es editable, cargar respuesta existente
    if completion.editableC == true {
        Task {
            await loadExistingAnswers(templateId: completion.Id ?? "")
        }
    }
}
```

### 6. 👁️ Campo Actividad_Invisible__c

**Comportamiento:**
- `Actividad_Invisible__c == true` → NO mostrar en la lista
- `Actividad_Invisible__c == false` → SÍ mostrar en la lista

**Implementación en ElementsView:**
```swift
ScrollView {
    VStack(spacing: 0) {
        if let activities = allActivities.records {
            ForEach(activities, id: \.self) { activity in
                // ✅ FILTRAR ACTIVIDADES INVISIBLES
                if !(activity.actividadInvisibleC ?? false) {
                    ElementRowView(
                        activity: activity,
                        // ... otros parámetros
                    )
                }
            }
        }
    }
}
```

### 7. ❌ NO Mostrar Pop-up al Enviar Datos

**Comportamiento Actual (INCORRECTO):**
```swift
if anyAnswerSend {
    self.alertAuthEvent = .SuccesSendData  // ❌ Muestra pop-up
    self.showAlert.toggle()
}
```

**Comportamiento Correcto:**
```swift
func postTaskWithAutoContinuation() async {
    // 1. Enviar datos sin mostrar alert
    let result = await Network.shared.postTask(
        activityData: completions,
        response: completionResponse
    )
    
    switch result {
    case .success:
        print("✅ Datos enviados correctamente")
        
        // 2. Determinar siguiente paso en la concatenación
        if let nextActivityId = determineNextActivity() {
            // Continuar con siguiente actividad
            await navigateToNextActivity(nextActivityId)
        } else {
            // No hay más concatenación - marcar actividad como completa
            markActivityAsCompleted(currentActivityId)
            
            // Volver a la lista de actividades
            self.presentationMode.wrappedValue.dismiss()
            self.isLoadingTasks = true
        }
        
    case .failure(let error):
        // ❌ SOLO mostrar alert en caso de ERROR
        self.alertAuthEvent = .FailSendData
        self.showAlert.toggle()
    }
}
```

### 8. 📊 Barras de Progreso Reactivas

**Actualización en Tiempo Real:**
```swift
// Cada vez que se envía una respuesta, actualizar el progreso
func updateProgress() {
    Task {
        // Recargar datos del programa
        let result = await Network.shared.getTasks(stageId: stageId)
        
        switch result {
        case .success(let updatedData):
            // Actualizar datos locales
            self.allActivities = updatedData.activities
            
            // Calcular nuevo progreso
            let completedCount = allActivities.records?.filter {
                ($0.cantTaskCompletionC ?? 0) >= ($0.totalTaskCompletion2C ?? 0)
            }.count ?? 0
            
            let totalCount = allActivities.records?.count ?? 1
            self.progress = Int((Double(completedCount) / Double(totalCount)) * 100)
            
        case .failure(let error):
            print("❌ Error updating progress: \(error)")
        }
    }
}
```

### 9. 🎨 Consistencia Visual con Web

**Efectos a Implementar:**

1. **Barras de carga animadas:**
```swift
ProgressView(value: CGFloat(progress) / 100.0)
    .progressViewStyle(
        AnimatedIconProgressViewStyle(
            icon: "checkmark.circle.fill",
            progressColor: .blue,
            trackColor: .gray.opacity(0.25),
            height: 9,
            cornerRadius: 4,
            showPercentage: true,
            colorTextPercentage: .blue
        )
    )
    .animation(.easeInOut(duration: 0.5), value: progress)
```

2. **Negrita en títulos de grupos:**
```swift
if index == 0 { // Primer elemento del grupo
    Text(com.nombrePersonalizadoC ?? "")
        .font(.appSubheadBold)  // ✅ Bold
        .foregroundColor(.primaryText)
} else {
    Text(com.nombrePersonalizadoC ?? "")
        .font(.appCaption)  // Regular
        .foregroundColor(.primaryText)
}
```

## 🧪 Casos de Prueba

### Caso 1: Picklist con Concatenación
1. Responder Picklist con opción "A"
2. Verificar que navega a la actividad correspondiente a "A"
3. NO debe aparecer pop-up de "datos enviados"
4. La barra de progreso debe actualizarse

### Caso 2: Concatenación a Nivel de Actividad
1. Completar actividad sin Picklist
2. Verificar que navega a `Id_Actividad_Concatenada_Enrolamiento__c`
3. Si está vacío, marcar actividad al 100%

### Caso 3: Reanudar Cuestionario
1. Responder 2 preguntas de 5
2. Salir de la app
3. Volver a entrar
4. Verificar que muestra la pregunta 3 (no la 1)

### Caso 4: Campo Editable
1. Responder pregunta con `Editable__c = true`
2. Salir y volver a entrar
3. Verificar que muestra la respuesta anterior
4. Modificar respuesta
5. Verificar que se ACTUALIZA (no crea nuevo registro)

### Caso 5: Actividad Invisible
1. Crear actividad con `Actividad_Invisible__c = true`
2. Verificar que NO aparece en la lista
3. Pero SÍ se puede acceder vía concatenación

## 📝 Checklist de Implementación

- [✅] Filtrar actividades invisibles en ElementsView
- [✅] Eliminar textos de debug ("444", "111", etc.)
- [✅] Remover pop-up de "datos enviados" en flujo normal
- [✅] Barra de progreso sin límite mínimo
- [ ] Implementar lógica de concatenación de Picklist
- [ ] Implementar lógica de concatenación de Actividad
- [ ] Validación de campos requeridos según reglas
- [ ] Integrar function_filter para reanudar cuestionarios
- [ ] Implementar lógica de Editable__c (UPDATE vs CREATE)
- [ ] Actualización reactiva de barras de progreso
- [ ] Navegación automática entre actividades concatenadas
- [ ] Marcar actividad al 100% solo cuando termine toda la concatenación
- [ ] Efectos visuales consistentes con versión web
- [ ] Manejo de todos los tipos de datos (Checkbox, Texto, Número, Picklist, etc.)

## 🚨 Errores Comunes a Evitar

1. **NO marcar actividad como completa después de la primera pregunta**
2. **NO mostrar pop-up en flujo de concatenación**
3. **NO ignorar respuestas existentes cuando Editable__c = true**
4. **NO mostrar actividades con Actividad_Invisible__c = true en la lista**
5. **NO aplicar límite mínimo a las barras de progreso**

