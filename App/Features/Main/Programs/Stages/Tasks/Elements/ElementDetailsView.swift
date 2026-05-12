//
//  ElementDetailsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 17/04/2023.
//

import SwiftUI
import MultiPicker
import Combine

struct ElementDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var activityName: String
    @State var activityInstruction: String
    @State var completion: ActivityCompletion
    @State var exams: [FunctionFilterExamResponse.PatientExams] = []
    @State var activity: Activities.Activity
    @State var isLoading: Bool = true
    @State var imgData: String = ""
    @State var completionResponse: [String : String] = [:]
    @State var showAlert: Bool = false
    @State var alertAuthEvent: AlertAuthEvent?
    @State var anyAnswerSend: Bool = false
    @Binding var isLoadingTasks: Bool
    var publisher = PassthroughSubject<Void, Never>()
    @Binding var isQuestionnaire: Bool
    @State var activities: Activities?
    let program_ID: String
    let puntosActivos: Bool
    let puntosObtener: Float
    let puntosAcumulados: Float
    @State var stages: Stages? = nil
    @State var positionOfPicklist: Int = 0
    @State var numericNextQuestionnaireId: String = ""
    @State var showAlert2: Bool = false // ✅ Cambiar a false para no mostrar debug
    @State var defaultAgreementId = false
    
    // ✅ CAMBIO: En lugar de un solo array, usamos un diccionario por templateId
    @State private var selectedItemsByTemplate: [String: [ChipItem]] = [:]
    
    // ✅ NUEVOS ESTADOS PARA CONCATENACIÓN
    @State private var navigateToNextActivity: Bool = false
    @State private var nextActivity: Activities.Activity? = nil
    @State private var existingCompletionIds: [String: String] = [:] // templateId: completionId para editar
    @State private var completedTemplateIds: Set<String> = [] // IDs de templates ya respondidos
    @State private var isCheckingProgress: Bool = false // Para mostrar loading al verificar progreso

    // ✅ NUEVO: navegación a StagesView al finalizar
    @State private var navigateToStages: Bool = false
    // ✅ NUEVO: bandera para diferir la navegación hasta que se cierre el Alert
    @State private var shouldNavigateToStagesAfterAlert: Bool = false
    // ✅ FIX TERMINAR: Bloquea resumeToFirstUnansweredInChain en onAppear cuando
    // estamos en medio de un dismiss programático (después de pulsar "Terminar").
    // Sin este flag, el dismiss del Alert dispara onAppear, que llama a
    // resumeToFirstUnansweredInChain(), que detecta todas las actividades completadas
    // y llama loadFirstActivityOfFlow() — manteniendo el usuario atascado en la vista.
    @State private var isDismissingAfterComplete: Bool = false
    @State private var showConfetti: Bool = false

    // ✅ NUEVO: baseline para detectar cambios reales
    @State private var originalCompletionResponse: [String: String] = [:]

    // ✅ NUEVO: historial y caché local por actividad (para Anterior sin POST)
    @State private var activityHistory: [Activities.Activity] = []
    @State private var answersCache: [String: [String: String]] = [:]              // activityId -> respuestas actuales
    @State private var originalAnswersCache: [String: [String: String]] = [:]      // activityId -> baseline original
    @State private var existingIdsCache: [String: [String: String]] = [:]          // activityId -> existingCompletionIds
    
    // ✅ NUEVO: Detectar si estamos revisando una tarea ya completada al 100%
    @State private var isReviewingCompletedTask: Bool = false
    
    // ✅ NUEVO: Recibir estado de navegación del padre
    @EnvironmentObject var navigationState: NavigationState

    enum AlertAuthEvent: Identifiable {
        var id: Int { hashValue }
        case SuccesSendData
        case FailSendData
        case ImgError
    }
    
    
    // MARK: - ✅ FUNCIÓN AUXILIAR: Determinar si un campo es requerido
    func isFieldRequired(_ field: ActivityCompletion.Completion) -> Bool {
        guard let completions = completion.records else { return false }
        
        // Contar campos que NO son Label
        let nonLabelFields = completions.filter { $0.tipoDeDatosC != "Label" }
        
        // Si solo hay 1 campo no-Label, siempre es requerido
        if nonLabelFields.count == 1 {
            return true
        }
        
        // Si hay más de 1, respetar el campo Requerido__c
        return field.requeridoC ?? false
    }

    // MARK: - ✅ VALIDACIÓN GLOBAL MEJORADA
    var areRequiredFieldsSatisfied: Bool {
        guard let completions = completion.records else { return true }
        
        for field in completions {
            // Ignorar Labels
            if field.tipoDeDatosC == "Label" {
                continue
            }
            
            // Verificar si es requerido según las reglas
            if isFieldRequired(field) {
                let response = completionResponse[field.Id ?? ""]
                
                // Validar según el tipo de dato
                switch field.tipoDeDatosC {
                case "Checkbox":
                    if response != "true" {
                        print("⚠️ [Validación] Checkbox requerido sin marcar. TemplateId=\(field.Id ?? "-")")
                        return false
                    }
                case "Texto URL (Archivo multimedia)":
                    if response != "true" {
                        print("⚠️ [Validación] URL multimedia requerida no confirmada. TemplateId=\(field.Id ?? "-")")
                        return false
                    }
                case "Texto", "Número", "Picklist", "Picklist Múltiple", "Subir Archivo":
                    let trimmed = (response ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if trimmed.isEmpty {
                        print("⚠️ [Validación] Campo requerido vacío. Tipo=\(field.tipoDeDatosC ?? "-") TemplateId=\(field.Id ?? "-")")
                        return false
                    }
                default:
                    break
                }
            }
        }
        
        return true
    }
    
    // ✅ TODAS LAS PREGUNTAS ACCIONABLES RESPONDIDAS (no-Label)
    var allActionableAnswered: Bool {
        guard let templates = completion.records else { return true }
        for t in templates where t.tipoDeDatosC != "Label" {
            let id = t.Id ?? ""
            let val = (completionResponse[id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if t.tipoDeDatosC == "Checkbox" || t.tipoDeDatosC == "Texto URL (Archivo multimedia)" {
                if val != "true" { return false }
            } else {
                if val.isEmpty { return false }
            }
        }
        return true
    }
    
    // ✅ NUEVO: Verificar si todas las preguntas tienen respuestas previas (existingCompletionIds)
    // Esto indica que estamos REVISANDO una actividad ya completada
    var isActivityFullyAnsweredPreviously: Bool {
        guard let templates = completion.records else { return false }
        let actionableTemplates = templates.filter { $0.tipoDeDatosC != "Label" }
        
        // Si no hay templates accionables, retornar false
        guard !actionableTemplates.isEmpty else { return false }
        
        // Verificar que TODOS los templates accionables tengan una respuesta previa
        for template in actionableTemplates {
            guard let templateId = template.Id else { continue }
            // Si algún template NO tiene respuesta previa, no estamos revisando
            if existingCompletionIds[templateId] == nil {
                return false
            }
        }
        
        return true
    }

    // ✅ hasChanges real (creates/updates) para habilitar botón y decidir POST
    var hasChanges: Bool {
        let changes = computeChanges()
        return !changes.creates.isEmpty || !changes.updates.isEmpty
    }

    // ✅ Habilitar Siguiente/Completar
    var isSubmitEnabled: Bool {
        (hasChanges && areRequiredFieldsSatisfied) || allActionableAnswered
    }
    
    // MARK: - ✅ Editable: permitir edición según respuesta previa y Editable__c
    func isEditable(for field: ActivityCompletion.Completion) -> Bool {
        guard let templateId = field.Id else { return true }
        let hasPrevious = existingCompletionIds[templateId] != nil
        if hasPrevious {
            let editable = field.editableC ?? false
            if !editable {
                print("🔒 [Editabilidad] Campo bloqueado por Editable__c=false. TemplateId=\(templateId) Nombre=\(field.nombrePersonalizadoC ?? "-")")
            } else {
                print("✏️ [Editabilidad] Campo editable con respuesta previa. TemplateId=\(templateId)")
            }
            return editable
        } else {
            print("🆕 [Editabilidad] Campo sin respuesta previa, editable. TemplateId=\(templateId)")
            return true
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Divider()

                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text(activityName)
                                .font(.appSubhead)
                                .foregroundColor(.primaryText)
                            Spacer()
                        }
                        .padding(.top, .margin)

                        Text(activityInstruction)
                            .font(.appCaptionLarge)
                            .foregroundColor(.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        dataBody

                        // ✅ MENSAJE GLOBAL
                        if !areRequiredFieldsSatisfied {
                            Text("Completa todos los campos obligatorios para continuar")
                                .font(.appCaption)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }
                }
                .alert(item: $alertAuthEvent) { tipe in
                    switch tipe {
                    case .SuccesSendData:
                        return Alert(
                            title: Text("¡Completado!"),
                            message: Text("Actividad completada correctamente"),
                            dismissButton: .default(Text("OK"), action: {
                                // ✅ Al cerrar el alert, cubrimos la pantalla con loader y marcamos intención de navegar
                                print("✅ [Alert] Dismiss de éxito. Activando overlay y marcando navegación")
                                self.isCheckingProgress = true
                                // ✅ FIX TERMINAR: Marcar que estamos en dismiss programático.
                                // Bloquea onAppear → resumeToFirstUnansweredInChain() que de lo contrario
                                // detecta todas las actividades completas y llama loadFirstActivityOfFlow(),
                                // dejando al usuario atascado en ElementDetailsView.
                                self.isDismissingAfterComplete = true
                                self.shouldNavigateToStagesAfterAlert = true
                            })
                        )
                    case .FailSendData:
                        return Alert(
                            title: Text(""),
                            message: Text("Error al enviar ejercicios"),
                            dismissButton: .default(Text("OK"))
                        )
                    case .ImgError:
                        return Alert(
                            title: Text(""),
                            message: Text("Error al subir la imagen"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }

                // MARK: - BOTONES ANTERIOR / SIGUIENTE
                HStack(spacing: 12) {
                    // ✅ MOSTRAR "ANTERIOR" SOLO SI:
                    // - Hay historial (segunda pregunta en adelante en concatenación)
                    if !activityHistory.isEmpty {
                        PrimaryButton(title: "Anterior", backgroundColor: .gray) {
                            HapticManager.impact(style: .light)
                            print("⬅️ [UI] Tap en Anterior")
                            handleBackNavigation()
                        }
                        .bounceOnTap()
                    }

                    // ✅ LÓGICA DEL TÍTULO DEL BOTÓN:
                    // 1. Si estamos en la última pregunta y la actividad está 100% contestada previamente → "Cerrar"
                    // 2. Si hay más preguntas en la concatenación → "Siguiente"
                    // 3. Si es la última pregunta y NO está previamente completada → "Completar Actividad"
                    let nextTitle: String = {
                        let hasNextActivity = determineNextActivity() != nil
                        
                        if !hasNextActivity {
                            // Estamos en la última pregunta del flujo
                            if isActivityFullyAnsweredPreviously {
                                return "Cerrar"
                            } else {
                                return "Terminar"
                            }
                        } else {
                            return "Siguiente"
                        }
                    }()
                    
                    PrimaryButton(title: nextTitle) {
                        HapticManager.impact(style: .medium)
                        print("➡️ [UI] Tap en \(nextTitle)")
                        handleComplete()
                    }
                    .bounceOnTap()
                    .disabled(!isSubmitEnabled)
                    .opacity(isSubmitEnabled ? 1 : 0.5)
                }
            }
            .padding(.horizontal, .margin)
            .padding(.bottom, .margin)
            .slideInFromRight()
            .opacity((isLoading || isCheckingProgress) ? 0 : 1)
            
            // ✅ NAVEGACIÓN A SIGUIENTE ACTIVIDAD EN CONCATENACIÓN (no se usa en el nuevo flujo, se mantiene por compatibilidad)
            .navigationLink(isActive: $navigateToNextActivity) {
                if let nextAct = nextActivity,
                   let nextCompletion = nextAct.taskCompletionTemplateR {
                    ElementDetailsView(
                        activityName: nextAct.nombrePersonalizadoC ?? "Sin nombre",
                        activityInstruction: nextAct.descripcionLargaC ?? "",
                        completion: nextCompletion,
                        activity: nextAct,
                        isLoadingTasks: $isLoadingTasks,
                        publisher: publisher,
                        isQuestionnaire: $isQuestionnaire,
                        activities: activities,
                        program_ID: program_ID,
                        puntosActivos: puntosActivos,
                        puntosObtener: puntosObtener,
                        puntosAcumulados: puntosAcumulados,
                        stages: stages
                    )
                    .environmentObject(navigationState)  // ✅ PASAR ESTADO
                }
            }
            // ⛔️ REMOVIDO: NavigationLink a StagesView
            // Ya no navegamos hacia adelante, sino que usamos publisher.send() para volver atrás
            // Esto evita crear una nueva StagesView en el navigation stack
            /*
            .navigationLink(isActive: $navigateToStages) {
                StagesView(programId: program_ID,
                           puntosActivos: puntosActivos,
                           puntosObtener: puntosObtener,
                           puntosAcumulados: puntosAcumulados,
                           startWithOverlay: true
                )
                .environmentObject(navigationState)  // ✅ PASAR ESTADO
            }
            .transaction { transaction in
                // ⭐️ Desactivar animación predeterminada durante la navegación a StagesView
                // Esto evita el flash causado por la interpolación de vistas
                if navigateToStages {
                    transaction.disablesAnimations = true
                }
            }
            */
            
            .alert("completion.records: ",
                   isPresented: $showAlert2) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(String(describing: completion.records))

            }

            // ✅ OVERLAY DE PANTALLA COMPLETA: solo loader y fondo opaco
            if (isLoading || isCheckingProgress) {
                CenteredLoadingView()
                    .background(Color(.systemBackground).ignoresSafeArea())
                    .zIndex(999) // ⭐️ Asegurar que esté encima de TODO, incluso durante navegación
                    .transition(.identity) // ⭐️ Sin animación de transición para evitar flash
            }
        }
        .confettiLight(isActive: $showConfetti)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Mis Programas")
                    .font(.appTabTitleBold)
                    .foregroundColor(.primaryText)
            }
        }
        .onAppear {
            print("👋 [onAppear] ElementDetailsView Apareció. ActivityId=\(activity.Id ?? "-") Nombre=\(activityName)")
            // ✅ FIX TERMINAR: Si estamos en medio de un dismiss programático
            // (el usuario acaba de pulsar OK en el alert de éxito), NO relanzar
            // resumeToFirstUnansweredInChain(). Esa función detectaría todas las
            // actividades como completadas y llamaría loadFirstActivityOfFlow(),
            // reengananchando al usuario en la vista en lugar de dejarla cerrar.
            guard !isDismissingAfterComplete else {
                print("🚫 [onAppear] isDismissingAfterComplete=true — omitiendo resume para permitir dismiss")
                return
            }
            Task {
                await resumeToFirstUnansweredInChain()
            }
        }
        .onDisappear {
            print("👋 [onDisappear] ElementDetailsView desapareció. ActivityId=\(activity.Id ?? "-")")
            // ✅ FIX: Resetear isDismissingAfterComplete aquí, cuando la vista ya
            // desapareció de verdad. Si lo reseteamos antes (en el Task del onChange),
            // onAppear puede dispararse aún con la vista en pantalla y relanzar
            // resumeToFirstUnansweredInChain(), bloqueando la navegación de salida.
            if isDismissingAfterComplete {
                print("🔓 [onDisappear] Reseteando isDismissingAfterComplete (dismiss programático completado)")
                isDismissingAfterComplete = false
            }
        }
        // ✅ Detecta cuando el Alert de éxito se cierra y navega recién ahí
        .onChange(of: alertAuthEvent?.id) { newValue in
            print("🔄 [onChange] alertAuthEvent cambio: \(String(describing: newValue)). shouldNavigateToStagesAfterAlert=\(shouldNavigateToStagesAfterAlert)")
            if newValue == nil && shouldNavigateToStagesAfterAlert {
                shouldNavigateToStagesAfterAlert = false

                // ✅ PATRÓN ANDROID: POST → GET reload → decide destino en un solo paso
                // Flujo corregido:
                // 1. ElementDetailsView hace presentationMode.dismiss() → pop a ElementsView
                // 2. ElementsView.onAppear ve shouldDismissToTasks=true → consume el flag
                //    y hace su propio dismiss() → pop a TasksView
                // 3. TasksView ve shouldReloadTareas=true y recarga su lista
                //
                // NOTA: NO usar publisher.send() — el publisher en ElementDetailsView es una
                // copia del PassthroughSubject de ElementsView (Swift lo pasa por valor),
                // por lo que publisher.send() en la vista hija NUNCA llega a onReceive en ElementsView.
                Task { @MainActor in
                    print("🔄 [Flow] Recargando actividades post-Terminar (patrón Android)…")

                    // Marcar recarga para los niveles superiores (TasksView, StagesView, etc.)
                    // Usamos markForReloadAfterTerminar() en lugar de markForFullReload() para que
                    // TasksView NO haga dismiss automático (shouldReloadProgramas queda en false).
                    self.navigationState.markForReloadAfterTerminar()

                    // ⚠️ PARIDAD ANDROID: En Android, el cumplimiento se lee del servidor
                    // (TareaFragment.kt:2186: cumplimientoDeLaTareaC), NO se calcula localmente.
                    // 
                    // En iOS, ElementsView.calculateProgress() ya implementa esto correctamente,
                    // leyendo taskData.cumplimientoDeLaTareaC del servidor.
                    //
                    // Aquí en ElementDetailsView NO intentamos calcular el cumplimiento porque:
                    // 1. getActivities() solo devuelve Activities[], no el objeto Task con cumplimientoDeLaTareaC
                    // 2. Los campos de actividad (totalTaskCompletion2C, totalTaskComTemplateC) pueden tener
                    //    valores corruptos (0, NaN, Infinity) que causan crashes al convertir a Int
                    // 3. La decisión de navegación (TasksView vs ElementsView) la toma ElementsView.onAppear
                    //    basándose en shouldDismissToTasks, NO en un cálculo local
                    //
                    // ✅ SOLUCIÓN: Simplemente navegamos. ElementsView recalculará desde el servidor.
                    print("📊 [Flow] Navegando post-Terminar. ElementsView leerá progreso del servidor.")

                    // Dismiss de ElementDetailsView → aparece ElementsView.
                    // ElementsView.onAppear ve shouldDismissToTasks=true → consume el flag
                    // y hace dismiss() → aparece TasksView con shouldReloadTareas=true.
                    self.navigationState.shouldDismissToTasks = true
                    self.isLoadingTasks = true
                    self.presentationMode.wrappedValue.dismiss()

                    // Pequeño delay para limpiar el overlay tras el dismiss
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    self.isCheckingProgress = false
                    // ✅ NO resetear isDismissingAfterComplete aquí — ver onDisappear
                }
            }
        }
    }

    @ViewBuilder
    var dataBody: some View {
        VStack {
            if let completion = completion.records?.sorted(by: {
                ($0.ordenDeVisibilidadC ?? 1) < ($1.ordenDeVisibilidadC ?? 1)
            }) {

                let uniqueIds = Set(completion.compactMap { $0.agrupamientoC })

                ForEach(Array(uniqueIds).sorted(), id: \.self) { uniqueId in
                    VStack {
                        ForEach(
                            Array(completion.filter { $0.agrupamientoC == uniqueId }.enumerated()),
                            id: \.element
                        ) { index, com in

                            // ✅ CHECKBOX
                            if com.tipoDeDatosC == "Checkbox" {
                                VStack(alignment: .leading, spacing: 4) {
                                    CheckBoxRow(
                                        idCom: com.Id ?? "",
                                        name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        isRequired: com.requeridoC ?? false,
                                        response: $completionResponse,
                                        canEdit: isEditable(for: com)
                                    )
                                }
                                .disabled(!isEditable(for: com))
                            }

                            // ✅ PICKER
                            if com.tipoDeDatosC == "Picklist" {
                                VStack(alignment: .leading, spacing: 4) {
                                    PickerRow(
                                        dataPicker: com.posiblesValoresC ?? "",
                                        idCom: com.Id ?? "",
                                        name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        isRequired: com.requeridoC ?? false,
                                        response: $completionResponse,
                                        positionOfPicklist: $positionOfPicklist,
                                        canEdit: isEditable(for: com)
                                    )
                                }
                                .disabled(!isEditable(for: com))
                            }

                            // ✅ COMMENT (TEXTO)
                            if com.tipoDeDatosC == "Texto" {
                                VStack(alignment: .leading, spacing: 4) {
                                    CommentRow(
                                        isRequired: com.requeridoC ?? false,
                                        response: $completionResponse,
                                        idCom: com.Id ?? "",
                                        name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        canEdit: isEditable(for: com)
                                    )
                                }
                                .disabled(!isEditable(for: com))
                            }

                            if com.tipoDeDatosC == "Número" {
                                NumericRow(
                                    idCom: com.Id ?? "",
                                    name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                    isRequired: com.requeridoC ?? false,
                                    response: $completionResponse,
                                    numericNextQuestionnaireId: $numericNextQuestionnaireId,
                                    conditionsOfNumericQuestionnaire: com.posiblesValoresC,
                                    possibilityOfId: com.concatenacionPicklistEnrolamientoC,
                                    canEdit: isEditable(for: com)
                                )
                                .disabled(!isEditable(for: com))
                            }

                            if com.tipoDeDatosC == "Subir Archivo" {
                                FileRow(
                                    showDescription: true,
                                    instrucciones: com.posiblesValoresC ?? "",
                                    response: $completionResponse,
                                    idCom: com.Id ?? "",
                                    name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                    subname: com.tipoDeDatosC ?? "Sin Nombre",
                                    isRequired: com.requeridoC ?? false
                                )
                                .disabled(!isEditable(for: com))
                            }
                            
                            if com.tipoDeDatosC == "Picklist Múltiple" {
                                let templateId = com.Id ?? ""
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    MultiSelectField(
                                        label: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        placeholder: "Selecciona una o más opciones",
                                        selectedItems: Binding(
                                            get: { selectedItemsByTemplate[templateId] ?? [] },
                                            set: { selectedItemsByTemplate[templateId] = $0 }
                                        ),
                                        allOptions: com.posiblesValoresC ?? "",
                                        isRequired: com.requeridoC ?? false,
                                        isValid: !(completionResponse[templateId]?.isEmpty ?? true),
                                        canEdit: isEditable(for: com)
                                    )
                                }
                                .onAppear {
                                    // ✅ Inicializar el diccionario de items seleccionados si no existe
                                    if selectedItemsByTemplate[templateId] == nil {
                                        // Parsear valor previo si existe
                                        let prevValue = completionResponse[templateId] ?? ""
                                        selectedItemsByTemplate[templateId] = ChipItem.parse(prevValue)
                                        print("🔵 [Picklist Múltiple onAppear] TemplateId=\(templateId) Parseado='\(prevValue)' → Items=\(selectedItemsByTemplate[templateId]?.count ?? 0)")
                                    }
                                    
                                    // Si no hay respuesta previa, inicializamos vacío
                                    if completionResponse[templateId] == nil {
                                        completionResponse[templateId] = ""
                                    }
                                }
                                .onChange(of: selectedItemsByTemplate[templateId]) { newValue in
                                    let stringValue = ChipItem.toString(newValue ?? [])
                                    completionResponse[templateId] = stringValue
                                    print("🧩 [Picklist Múltiple] Selección actualizada TemplateId=\(templateId) Valor='\(stringValue)'")
                                }
                                .disabled(!isEditable(for: com))
                            }
                            
                            if com.tipoDeDatosC == "Texto URL (Archivo multimedia)" {
                                openURLRowView(for: com)
                            }

                            
                            if com.tipoDeDatosC == "Label" {
                                LabelRow(
                                    text: com.nombrePersonalizadoC ?? "Sin Nombre",
                                    isTitle: index == 0
                                )
                            }
                        }
                    }
                    .padding(.margin)
                    .overlay(
                        RoundedRectangle(cornerRadius: .cornerRadius)
                            .stroke(Color.grayLight, lineWidth: 1)
                            .shadow(color: .shadowLight, radius: 1, x: 1, y: 1)
                    )
                    .padding(.horizontal, .margin)
                }
            }
        }
    }
    
    // MARK: - Reanudación de cuestionario: saltar a la primera actividad con preguntas sin responder
    func resumeToFirstUnansweredInChain() async {
        await MainActor.run {
            isLoading = true
            activityHistory = [] // ← limpiar historial al reanudar
            print("🔁 [Resume] Iniciando reanudación. ActivityId=\(activity.Id ?? "-")")
        }
        
        print("puntosActivos en ElementDetailsView:", puntosActivos)
        
        var visited = Set<String>()
        var currentActivity = self.activity
        var path: [Activities.Activity] = [] // ← actividades previas completamente contestadas
        
        while true {
            guard let currentId = currentActivity.Id else {
                print("❌ [Resume] Activity sin Id. Abortando.")
                break
            }
            if visited.contains(currentId) {
                print("♻️ [Resume] Detectado ciclo en actividad \(currentId). Abortando.")
                break
            }
            visited.insert(currentId)
            print("🔍 [Resume] Revisando actividad \(currentId) '\(currentActivity.nombrePersonalizadoC ?? "-")'")
            
            // 1) Traer completions de la actividad actual
            let result = await Network.shared.getActivityCompletions(id_activity: currentId)
            switch result {
            case .failure(let error):
                print("❌ [Resume] Error getActivityCompletions(\(currentId)): \(error)")
                // Cargar UI con actividad actual y salir
                await loadActivityUI(currentActivity, with: [:], existingIds: [:])
                return
                
            case .success(let response):
                print("✅ [Resume] getActivityCompletions OK. Parsing respuestas previas…")
                // ✅ LLAVE COMPUESTA: Nombre_de_la_Actividad__c || Tipo_de_Datos__c
                let completionsByCompositeKey = buildCompletionsByCompositeKey(from: response.data)
                
                // ✅ Construir diccionario de respuestas (answers) y existingCompletionIds para esta actividad
                // usando la LLAVE COMPUESTA para emparejar template con completion
                var answers: [String:String] = [:]
                var existingIds: [String:String] = [:]
                var localPositionIndex: Int = 0
                
                if let templates = currentActivity.taskCompletionTemplateR?.records {
                    for template in templates {
                        guard let templateId = template.Id else { continue }
                        let tipo = template.tipoDeDatosC ?? ""
                        
                        // ✅ Buscar completion usando llave compuesta
                        let prev = findCompletion(for: template, in: completionsByCompositeKey)
                        let prevValue = prev?.valorDeRespuestaC?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        
                        switch tipo {
                        case "Checkbox", "Texto URL (Archivo multimedia)":
                            answers[templateId] = prevValue.isEmpty ? "false" : prevValue
                        case "Texto", "Número", "Picklist", "Picklist Múltiple", "Subir Archivo":
                            answers[templateId] = prevValue
                            
                            if tipo == "Picklist" {
                                // Calcular índice de picklist si hace falta
                                if let opts = template.posiblesValoresC, !opts.isEmpty {
                                    let options = opts.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                                    if let idx = options.firstIndex(of: prevValue) {
                                        localPositionIndex = idx
                                    }
                                } else if let idx = parsePicklistIndex(from: prevValue) {
                                    localPositionIndex = idx
                                }
                            }
                        default:
                            break
                        }
                        
                        if let existingId = prev?.Id {
                            existingIds[templateId] = existingId
                        }
                    }
                }
                
                print("🧮 [Resume] Templates=\(currentActivity.taskCompletionTemplateR?.records?.count ?? 0) AnswersConstruidas=\(answers.count) ExistingIds=\(existingIds.count)")
                
                // 2) ¿Esta actividad tiene algún template (no Label) sin respuesta?
                if !allNonLabelTemplatesHaveAnswer(in: currentActivity, answers: answers) {
                    print("⛳️ [Resume] Actividad con preguntas pendientes. Cargando UI aquí.")
                    // ← Poblamos el historial con el camino ya transitado
                    await MainActor.run { self.activityHistory = path }
                    await loadActivityUI(currentActivity, with: answers, existingIds: existingIds, positionIndex: localPositionIndex)
                    return
                }
                
                // 3) Todo contestado en esta actividad → cachear y seguir concatenación
                cacheActivityState(currentActivity, answers: answers, existingIds: existingIds, positionIndex: localPositionIndex)
                
                if let nextId = determineNextActivity(in: currentActivity, answers: answers) {
                    print("➡️ [Resume] Actividad completa. Siguiente en cadena: \(nextId)")
                    if let nextAct = activities?.records?.first(where: { $0.Id == nextId }) {
                        path.append(currentActivity) // ← agregar al historial (completada)
                        currentActivity = nextAct
                        continue
                    } else {
                        print("⚠️ [Resume] Siguiente actividad no está en lista local. Cargando UI actual y terminando.")
                        await MainActor.run { self.activityHistory = path }
                        await loadActivityUI(currentActivity, with: answers, existingIds: existingIds, positionIndex: localPositionIndex)
                        return
                    }
                } else {
                    print("🏁 [Resume] No hay más concatenación. Cargando primera actividad del flujo.")
                    await MainActor.run { self.activityHistory = path }
                    await loadFirstActivityOfFlow()
                    return
                }
            }
        }
        
        // Fallback
        print("⚠️ [Resume] Fallback: cargando actividad original.")
        await loadActivityUI(self.activity, with: [:], existingIds: [:])
    }
    
    // Cachear estado de una actividad visitada (sin cambiar UI)
    func cacheActivityState(_ act: Activities.Activity,
                            answers: [String:String],
                            existingIds: [String:String],
                            positionIndex: Int = 0) {
        guard let actId = act.Id else { return }
        answersCache[actId] = answers
        originalAnswersCache[actId] = answers
        existingIdsCache[actId] = existingIds
    }
    
    // Aplica la actividad y sus respuestas a la UI
    @MainActor
    func loadActivityUI(_ act: Activities.Activity,
                        with answers: [String:String],
                        existingIds: [String:String],
                        positionIndex: Int = 0) {
        print("🖼️ [UI] loadActivityUI ActivityId=\(act.Id ?? "-") Nombre=\(act.nombrePersonalizadoC ?? "-") Answers=\(answers.count) ExistingIds=\(existingIds.count) PickIndex=\(positionIndex)")
        self.activity = act
        // Si tenemos templates en el objeto de actividad, úsalo. Si no, deja el que venía.
        if let comp = act.taskCompletionTemplateR {
            self.completion = comp
        }
        self.activityName = act.nombrePersonalizadoC ?? activityName
        self.activityInstruction = act.descripcionLargaC ?? activityInstruction
        
        self.completionResponse = answers
        self.originalCompletionResponse = answers
        self.existingCompletionIds = existingIds
        self.positionOfPicklist = positionIndex
        
        // ✅ NUEVO: Inicializar selectedItemsByTemplate para Picklist Múltiple
        if let templates = act.taskCompletionTemplateR?.records {
            for template in templates {
                guard let templateId = template.Id,
                      template.tipoDeDatosC == "Picklist Múltiple" else { continue }
                
                let prevValue = answers[templateId] ?? ""
                if !prevValue.isEmpty {
                    self.selectedItemsByTemplate[templateId] = ChipItem.parse(prevValue)
                    print("🟣 [UI LoadActivity] Picklist Múltiple inicializado TemplateId=\(templateId) Valor='\(prevValue)' → Items=\(self.selectedItemsByTemplate[templateId]?.count ?? 0)")
                } else {
                    self.selectedItemsByTemplate[templateId] = []
                    print("🟣 [UI LoadActivity] Picklist Múltiple vacío TemplateId=\(templateId)")
                }
            }
        }
        
        // Cachear baseline para esta actividad
        if let actId = act.Id {
            self.answersCache[actId] = answers
            self.originalAnswersCache[actId] = answers
            self.existingIdsCache[actId] = existingIds
        }

        self.isLoading = false
        print("✅ [UI] Carga aplicada. isLoading=false")
    }
    
    // Guardar estado actual en caché antes de cambiar de actividad
    func saveCurrentActivityStateToCache() {
        guard let actId = activity.Id else { return }
        answersCache[actId] = completionResponse
        originalAnswersCache[actId] = originalCompletionResponse
        existingIdsCache[actId] = existingCompletionIds
    }

    // Cargar (o traer) respuestas de una actividad objetivo
    func fetchAnswersAndLoad(_ act: Activities.Activity) {
        Task {
            await MainActor.run {
                isLoading = true
            }
            if let actId = act.Id {
                if let cached = answersCache[actId],
                   let cachedOriginal = originalAnswersCache[actId],
                   let cachedExisting = existingIdsCache[actId] {
                    await loadActivityUI(act, with: cached, existingIds: cachedExisting)
                    self.originalCompletionResponse = cachedOriginal
                    return
                }
            }
            // Si no está en caché, traer del servidor (mismo patrón que resume)
            guard let actId = act.Id else {
                await MainActor.run { isLoading = false }
                return
            }
            let result = await Network.shared.getActivityCompletions(id_activity: actId)
            switch result {
            case .failure(let error):
                print("❌ [FetchLoad] Error getActivityCompletions(\(actId)): \(error)")
                await loadActivityUI(act, with: [:], existingIds: [:])
            case .success(let response):
                // ✅ LLAVE COMPUESTA
                let completionsByCompositeKey = buildCompletionsByCompositeKey(from: response.data)
                
                var answers: [String:String] = [:]
                var existingIds: [String:String] = [:]
                var localPositionIndex: Int = 0
                if let templates = act.taskCompletionTemplateR?.records {
                    for template in templates {
                        guard let templateId = template.Id else { continue }
                        let tipo = template.tipoDeDatosC ?? ""
                        
                        // ✅ Buscar completion usando llave compuesta
                        let prev = findCompletion(for: template, in: completionsByCompositeKey)
                        let prevValue = prev?.valorDeRespuestaC?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        switch tipo {
                        case "Checkbox", "Texto URL (Archivo multimedia)":
                            answers[templateId] = prevValue.isEmpty ? "false" : prevValue
                        case "Texto", "Número", "Picklist", "Picklist Múltiple", "Subir Archivo":
                            answers[templateId] = prevValue
                            if tipo == "Picklist" {
                                if let opts = template.posiblesValoresC, !opts.isEmpty {
                                    let options = opts.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                                    if let idx = options.firstIndex(of: prevValue) {
                                        localPositionIndex = idx
                                    }
                                } else if let idx = parsePicklistIndex(from: prevValue) {
                                    localPositionIndex = idx
                                }
                            }
                        default:
                            break
                        }
                        if let existingId = prev?.Id {
                            existingIds[templateId] = existingId
                        }
                    }
                }
                await loadActivityUI(act, with: answers, existingIds: existingIds, positionIndex: localPositionIndex)
            }
        }
    }
    
    // MARK: - Lógica previa (consulta simple para la actividad actual)
    func getActivityCompletionsFunctionFilter() {
        DispatchQueue.main.async { self.isLoading = true }
        
        print("🔎 [Legacy] getActivityCompletionsFunctionFilter para activity.Id:", activity.Id ?? "")
        
        Task {
            let activityCompletionsResult = await Network.shared.getActivityCompletions(id_activity: activity.Id ?? "")
            
            switch activityCompletionsResult {
            case .success(let response):
                // --- BLOQUE PARA PRINT LEGIBLE ---
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                
                if let jsonData = try? encoder.encode(response),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📦 [Legacy] JSON RECIBIDO (ESTRUCTURADO)")
                    print(jsonString)
                }

                DispatchQueue.main.async {
                    // ✅ LLAVE COMPUESTA
                    let completionsByCompositeKey = self.buildCompletionsByCompositeKey(from: response.data)
                    
                    if let templates = self.completion.records {
                        for template in templates {
                            guard let templateId = template.Id else { continue }
                            let tipo = template.tipoDeDatosC ?? ""
                            
                            // ✅ Buscar completion usando llave compuesta
                            let prev = self.findCompletion(for: template, in: completionsByCompositeKey)
                            let prevValue = prev?.valorDeRespuestaC?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            
                            switch tipo {
                            case "Checkbox", "Texto URL (Archivo multimedia)":
                                self.completionResponse[templateId] = prevValue.isEmpty ? "false" : prevValue
                                
                            case "Texto":
                                self.completionResponse[templateId] = prevValue
                                
                            case "Número":
                                self.completionResponse[templateId] = prevValue
                                
                            case "Picklist":
                                self.completionResponse[templateId] = prevValue
                                if let concatenacionIds = template.concatenacionPicklistEnrolamientoC,
                                   !concatenacionIds.isEmpty {
                                    if let opts = template.posiblesValoresC, !opts.isEmpty {
                                        let options = opts
                                            .components(separatedBy: ";")
                                            .map { $0.trimmingCharacters(in: .whitespaces) }
                                        if let idx = options.firstIndex(of: prevValue) {
                                            self.positionOfPicklist = idx
                                        }
                                    } else {
                                        if let idx = parsePicklistIndex(from: prevValue) {
                                            self.positionOfPicklist = idx
                                        }
                                    }
                                }
                                
                            case "Picklist Múltiple":
                                self.completionResponse[templateId] = prevValue
                                // ✅ Parsear y asignar al diccionario específico del template
                                self.selectedItemsByTemplate[templateId] = ChipItem.parse(prevValue)
                                print("🟢 [Picklist Múltiple Parse] TemplateId=\(templateId) Valor='\(prevValue)' → Items=\(self.selectedItemsByTemplate[templateId]?.count ?? 0)")
                                
                            case "Subir Archivo":
                                self.completionResponse[templateId] = prevValue
                                
                            case "Label":
                                break
                                
                            default:
                                self.completionResponse[templateId] = prevValue
                            }
                            
                            if let existingId = prev?.Id {
                                self.existingCompletionIds[templateId] = existingId
                            }
                        }
                    }
                    
                    // baseline
                    self.originalCompletionResponse = self.completionResponse
                    if let actId = self.activity.Id {
                        self.answersCache[actId] = self.completionResponse
                        self.originalAnswersCache[actId] = self.originalCompletionResponse
                        self.existingIdsCache[actId] = self.existingCompletionIds
                    }

                    self.isLoading = false
                    print("✅ [Legacy] getActivityCompletionsFunctionFilter terminado. isLoading=false")
                }

            case .failure(let error):
                print("❌ [Legacy] Error en la petición:", error)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - ✅ NUEVO: Cálculo de cambios (creates/updates)
    func computeChanges() -> (creates: [ActivityCompletion.Completion], updates: [ActivityCompletion.Completion], response: [String:String], changedIds: Set<String>) {
        guard let allTemplates = completion.records else {
            return ([], [], [:], [])
        }
        var creates: [ActivityCompletion.Completion] = []
        var updates: [ActivityCompletion.Completion] = []
        var filteredResponse: [String:String] = [:]
        var changedIds = Set<String>()
        
        for template in allTemplates where template.tipoDeDatosC != "Label" {
            guard let id = template.Id else { continue }
            // Solo considerar editables
            guard isEditable(for: template) else { continue }
            
            let currentRaw = completionResponse[id] ?? ""
            let originalRaw = originalCompletionResponse[id] ?? ""
            
            // Normalización simple
            let current = currentRaw.trimmingCharacters(in: .whitespacesAndNewlines)
            let original = originalRaw.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let hasExisting = (existingCompletionIds[id] != nil)
            
            // ¿Hay respuesta "presente"?
            let isAnsweredNow: Bool = {
                if template.tipoDeDatosC == "Checkbox" || template.tipoDeDatosC == "Texto URL (Archivo multimedia)" {
                    return current == "true"
                } else {
                    return !current.isEmpty
                }
            }()
            
            if !hasExisting {
                // CREATE si hay respuesta presente
                if isAnsweredNow {
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

    // MARK: - ✅ NUEVA FUNCIÓN: Enviar con concatenación automática (compat)
    func sendInfoWithConcatenation() {
        print("⚠️ [Compat] sendInfoWithConcatenation → delega en handleComplete()")
        handleComplete()
    }
    
    // MARK: - Subir imágenes a S3
    func uploadImagesToS3() async {
        print("🖼️ [S3] Verificando archivos a subir…")
        if let completions = completion.records {
            for com in completions where com.tipoDeDatosC == "Subir Archivo" {
                guard let id = com.Id else { continue }
                
                // Solo si hay valor
                guard let data = completionResponse[id], !data.isEmpty else { continue }
                
                // Si ya es URL (S3), no subimos de nuevo
                let lower = data.lowercased()
                if lower.hasPrefix("http://") || lower.hasPrefix("https://") {
                    print("↪️ [S3] Ya es URL, no se sube de nuevo. TemplateId=\(id)")
                    continue
                }
                
                print("⬆️ [S3] Subiendo archivo para TemplateId=\(id)…")
                let result = await Network.shared.postSendS3(
                    base64: data,
                    archivExtension: "png"
                )
                
                switch result {
                case .success(let urlString):
                    for url in urlString.data {
                        self.completionResponse[id] = url
                        print("✅ [S3] Subida OK. URL asignada a TemplateId=\(id)")
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        AppStatusManager.error(error)
                        self.alertAuthEvent = .ImgError
                        self.showAlert = true
                        self.isLoading = false
                        print("❌ [S3] Error subiendo imagen: \(error)")
                    }
                    return
                }
            }
        }
    }

    // Subir imágenes sólo para un subconjunto de templates
    func uploadImagesToS3(onlyFor templateIds: Set<String>) async {
        print("🖼️ [S3] Verificando archivos a subir para ids: \(templateIds)")
        if let completions = completion.records {
            for com in completions where com.tipoDeDatosC == "Subir Archivo" {
                guard let id = com.Id, templateIds.contains(id) else {
                    if com.tipoDeDatosC == "Subir Archivo" {
                        print("   ⏭️ [S3] Saltando template \(com.Id ?? "N/A") - no está en changedIds")
                    }
                    continue
                }
                
                print("   📎 [S3] Template de archivo encontrado: \(id)")
                
                guard let data = completionResponse[id], !data.isEmpty else {
                    print("   ⚠️ [S3] Sin datos para template \(id)")
                    continue
                }
                
                let lower = data.lowercased()
                if lower.hasPrefix("http://") || lower.hasPrefix("https://") {
                    print("   ✅ [S3] Template \(id) ya es URL: \(data.prefix(50))...")
                    continue
                }
                
                print("   ⬆️ [S3] Subiendo archivo base64 (\(data.count) caracteres) para template \(id)...")
                let result = await Network.shared.postSendS3(base64: data, archivExtension: "png")
                switch result {
                case .success(let urlString):
                    for url in urlString.data {
                        self.completionResponse[id] = url
                        print("   ✅ [S3] Archivo subido exitosamente. URL: \(url)")
                        print("   🔄 [S3] completionResponse[\(id)] actualizado con URL")
                    }
                case .failure(let error):
                    print("   ❌ [S3] Error subiendo archivo: \(error)")
                    DispatchQueue.main.async {
                        AppStatusManager.error(error)
                        self.alertAuthEvent = .ImgError
                        self.showAlert = true
                        self.isLoading = false
                    }
                    return
                }
            }
        }
        print("🖼️ [S3] Proceso de subida de archivos completado")
    }
    
    
    // MARK: - Enviar datos filtrados (Solo lo modificado/editable)
    func postTaskWithConcatenation() async {
        guard let allTemplates = completion.records else {
            DispatchQueue.main.async { self.isLoading = false }
            print("⚠️ [Send] No hay templates en completion.records")
            return
        }
        
        print("🧹 [Send] Filtrando templates para envío… Total=\(allTemplates.count)")
        // 1. Filtrar Templates: Solo aquellos que son editables
        // y tienen una respuesta en el diccionario.
        let filteredTemplates = allTemplates.filter { template in
            guard let id = template.Id else { return false }
            let isEditableField = isEditable(for: template)
            let hasResponse = !(completionResponse[id]?.isEmpty ?? true)
            let include = isEditableField && hasResponse
            if include {
                print("  • ✅ Incluido TemplateId=\(id) Tipo=\(template.tipoDeDatosC ?? "-") Valor='\(completionResponse[id] ?? "")'")
            } else {
                print("  • ❌ Excluido TemplateId=\(id) editable=\(isEditableField) hasResponse=\(hasResponse)")
            }
            return include
        }
        
        // 2. Filtrar Care Program (Respuestas): Solo las que corresponden a los templates filtrados
        var filteredResponse: [String: String] = [:]
        for template in filteredTemplates {
            if let id = template.Id, let value = completionResponse[id] {
                filteredResponse[id] = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // 3. Si no hay nada que enviar, salimos temprano
        if filteredTemplates.isEmpty {
            print("⚠️ [Send] No hay cambios detectados para enviar. Saltando POST.")
            await handleConcatenationFlow()
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📦 [postTaskWithConcatenation] POST con \(filteredTemplates.count) templates y \(filteredResponse.count) respuestas")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📝 Templates a enviar:")
        for (index, template) in filteredTemplates.enumerated() {
            let templateId = template.Id ?? "N/A"
            let isCreate = existingCompletionIds[templateId] == nil
            let completionId = existingCompletionIds[templateId] ?? "N/A (CREATE)"
            let responseValue = filteredResponse[templateId] ?? "N/A"
            let action = isCreate ? "CREATE" : "UPDATE"
            
            print("   [\(index + 1)] \(action)")
            print("       • Template ID: \(templateId)")
            print("       • Completion ID: \(completionId)")
            print("       • Nombre: \(template.nombrePersonalizadoC ?? "N/A")")
            print("       • Tipo: \(template.tipoDeDatosC ?? "N/A")")
            print("       • Valor Respuesta: \(responseValue)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        let result = await Network.shared.postTask(
            activityData: filteredTemplates, // Solo enviará los N objetos modificados
            response: filteredResponse,      // Solo los IDs correspondientes
            existingCompletionIds: existingCompletionIds
        )
        
        switch result {
        case .success:
            print("✅ [Send] Datos enviados correctamente (Solo modificados)")
            await handleConcatenationFlow()
            
        case .failure(let error):
            DispatchQueue.main.async {
                AppStatusManager.error(error)
                self.alertAuthEvent = .FailSendData
                self.showAlert = true
                self.isLoading = false
                print("❌ [Send] Error al enviar datos: \(error)")
            }
        }
    }
    
    // MARK: - ✅ Manejar flujo de concatenación
    func handleConcatenationFlow() async {
        print("🔗 [Flow] Evaluando siguiente actividad por concatenación…")
        // 1. Determinar siguiente actividad según concatenación
        let nextActivityId = determineNextActivity()
        
        if let nextId = nextActivityId {
            // ✅ Hay más concatenación - navegar sin pop-up
            print("➡️ [Flow] Siguiente actividad: \(nextId)")
            await navigateToActivity(nextId)
        } else {
            // ✅ No hay más concatenación - mostrar pop-up y volver
            print("🏁 [Flow] Última pregunta del flujo. Mostrando pop-up de éxito.")
            await completeActivityAndReturn()
        }
    }
    
    // MARK: - Helpers de concatenación (para la actividad actual en UI)

    // Devuelve índice seleccionado del Picklist para un template.
    // 1) Intenta matchear contra Posibles_Valores__c
    // 2) Si no hay opciones, intenta inferir por letra inicial "A) / B) / C) ..."
    func selectedIndexForPicklist(_ template: ActivityCompletion.Completion) -> Int? {
        guard let templateId = template.Id else { return nil }
        let value = (completionResponse[templateId] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return nil }
        
        if let opts = template.posiblesValoresC, !opts.isEmpty {
            let options = opts
                .components(separatedBy: ";")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            if let idx = options.firstIndex(of: value) {
                print("🔢 [Picklist] Índice por opciones: \(idx) para valor '\(value)'")
                return idx
            }
        }
        // Fallback: inferir por letra de prefijo (A/B/C/...)
        let parsed = parsePicklistIndex(from: value)
        print("🔡 [Picklist] Índice por prefijo: \(String(describing: parsed)) para valor '\(value)'")
        return parsed
    }

    // Parsea "A) ..." -> 0, "B) ..." -> 1, etc.
    func parsePicklistIndex(from answer: String) -> Int? {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return nil }
        let upper = String(first).uppercased()
        let map: [String: Int] = [
            "A": 0, "B": 1, "C": 2, "D": 3, "E": 4, "F": 5, "G": 6
        ]
        return map[upper]
    }
    
    // MARK: - ✅ FUNCIÓN AUXILIAR: Construir mapa de completions usando LLAVE COMPUESTA
    /// Esta función resuelve el problema de matching entre templates y completions
    /// cuando hay múltiples componentes con el mismo `Nombre_de_la_Actividad__c` pero diferente `Tipo_de_Datos__c`
    ///
    /// Llave Compuesta: `"Nombre_de_la_Actividad__c || Tipo_de_Datos__c"`
    ///
    /// Ejemplo:
    /// - Template: "¿Cómo te sientes?" || "Label"     → No tiene completion
    /// - Template: "¿Cómo te sientes?" || "Picklist"  → Completion con Valor="Bien"
    /// - Template: "Observaciones" || "Texto"         → Completion con Valor="Todo ok"
    ///
    /// Sin la llave compuesta, solo usar `nombreDeLaActividadC` causaría sobrescritura
    /// y matching incorrecto entre templates y completions.
    ///
    /// - Parameter responseData: El array de datos del servicio RETURN_GET_TASK_COMPLETION_RESUME
    /// - Returns: Diccionario con la llave compuesta como key y el completion como value
    func buildCompletionsByCompositeKey(from responseData: [[String: [FunctionFilterResponse2.CompanyFilter]]]) -> [String: FunctionFilterResponse2.CompanyFilter] {
        var completionsByCompositeKey: [String: FunctionFilterResponse2.CompanyFilter] = [:]
        
        for item in responseData {
            if let completions = item["Task_Completion__c"] {
                for comp in completions {
                    if let nombreActividad = comp.nombreDeLaActividadC,
                       let tipoDatos = comp.tipoDeDatosC {
                        let compositeKey = "\(nombreActividad)||\(tipoDatos)"
                        completionsByCompositeKey[compositeKey] = comp
                        print("🔑 [CompositeKey] Indexado: '\(compositeKey)' → Valor='\(comp.valorDeRespuestaC ?? "∅")' Id=\(comp.Id ?? "-")")
                    }
                }
            }
        }
        
        return completionsByCompositeKey
    }
    
    // MARK: - ✅ FUNCIÓN AUXILIAR: Buscar completion usando llave compuesta
    /// Busca el completion correcto para un template usando la llave compuesta
    /// - Parameters:
    ///   - template: El template del cual queremos obtener el completion
    ///   - completionsMap: El mapa de completions indexado por llave compuesta
    /// - Returns: El completion correspondiente, o nil si no existe
    func findCompletion(for template: ActivityCompletion.Completion,
                        in completionsMap: [String: FunctionFilterResponse2.CompanyFilter]) -> FunctionFilterResponse2.CompanyFilter? {
        guard let nombreActividad = template.nombreDeLaActividadC,
              let tipoDatos = template.tipoDeDatosC else {
            return nil
        }
        
        let compositeKey = "\(nombreActividad)||\(tipoDatos)"
        let completion = completionsMap[compositeKey]
        
        if completion != nil {
            print("✅ [Match] Template '\(compositeKey)' → Completion encontrado")
        } else {
            print("⚠️ [NoMatch] Template '\(compositeKey)' → Sin completion (primera vez o Label)")
        }
        
        return completion
    }

    func splitAndTrim(_ input: String) -> [String] {
        input.split(separator: ";")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func findActivityIdByTemplateId(_ templateId: String) -> String? {
        guard let allActivities = activities?.records else { return nil }
        for act in allActivities {
            if let templates = act.taskCompletionTemplateR?.records,
               templates.contains(where: { $0.Id == templateId }) {
                return act.Id
            }
        }
        return nil
    }

    // MARK: - ✅ Determinar siguiente actividad (robusto) usando el estado actual
    func determineNextActivity() -> String? {
        print("🧭 [Concat] determineNextActivity (estado actual de UI)")
        // 1) Explorar templates de tipo Picklist para resolver concatenación
        if let records = completion.records {
            for record in records where record.tipoDeDatosC == "Picklist" {
                let idx = selectedIndexForPicklist(record)
                print("   • Picklist TemplateId=\(record.Id ?? "-") idx=\(String(describing: idx))")

                // 1.a) Enrolamiento
                if let concatEnrol = record.concatenacionPicklistEnrolamientoC,
                   !concatEnrol.isEmpty {
                    
                    let ids = splitAndTrim(concatEnrol)
                    if ids.count == 1 {
                        print("   → Concat Enrol (único id): \(ids[0])")
                        return ids[0]
                    } else if let i = idx, i < ids.count {
                        print("   → Concat Enrol por índice \(i): \(ids[i])")
                        return ids[i]
                    } else {
                        print("   → Concat Enrol sin índice válido. ids=\(ids)")
                    }
                }

                // 1.b) Template
                if let concatTpl = record.concatenacionPicklistTemplateC,
                   !concatTpl.isEmpty {
                    
                    let tplIds = splitAndTrim(concatTpl)
                    let chosenTplId: String? = {
                        if tplIds.count == 1 { return tplIds[0] }
                        if let i = idx, i < tplIds.count { return tplIds[i] }
                        return tplIds.first
                    }()
                    if let tplId = chosenTplId,
                       let actId = findActivityIdByTemplateId(tplId) {
                        print("   → Concat Template → ActivityId: \(actId) (tplId=\(tplId))")
                        return actId
                    } else {
                        print("   → Concat Template sin mapeo a actividad. tplIds=\(tplIds)")
                    }
                }
            }
        }
        
        // 2) Fallback final: a nivel de Actividad
        if let activityFallback = activity.idActividadConcatenadaEnrolamientoC,
           !activityFallback.isEmpty {
            print("   → Fallback actividad: \(activityFallback)")
            return activityFallback
        }
        print("   → Sin siguiente actividad.")
        return nil
    }
    
    // MARK: - ✅ Helpers para reanudación (trabajan “por actividad”)

    func allNonLabelTemplatesHaveAnswer(in act: Activities.Activity, answers: [String:String]) -> Bool {
        guard let templates = act.taskCompletionTemplateR?.records else { return true }
        for t in templates where t.tipoDeDatosC != "Label" {
            guard let id = t.Id else { continue }
            let val = (answers[id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            // Para Checkbox/URL multimedia consideramos "true" como respondido
            if t.tipoDeDatosC == "Checkbox" || t.tipoDeDatosC == "Texto URL (Archivo multimedia)" {
                if val != "true" {
                    print("⛔️ [ResumeCheck] Falta respuesta en TemplateId=\(id) Tipo=\(t.tipoDeDatosC ?? "-")")
                    return false
                }
            } else {
                if val.isEmpty {
                    print("⛔️ [ResumeCheck] Falta respuesta en TemplateId=\(id) Tipo=\(t.tipoDeDatosC ?? "-")")
                    return false
                }
            }
        }
        print("✅ [ResumeCheck] Todos los templates no-Label respondidos.")
        return true
    }

    func selectedIndexForPicklist(_ template: ActivityCompletion.Completion, answers: [String:String]) -> Int? {
        guard let templateId = template.Id else { return nil }
        let value = (answers[templateId] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return nil }
        if let opts = template.posiblesValoresC, !opts.isEmpty {
            let options = opts.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
            if let idx = options.firstIndex(of: value) {
                print("🔢 [ResumePicklist] Índice por opciones: \(idx) para valor '\(value)'")
                return idx
            }
        }
        let parsed = parsePicklistIndex(from: value)
        print("🔡 [ResumePicklist] Índice por prefijo: \(String(describing: parsed)) para valor '\(value)'")
        return parsed
    }

    func determineNextActivity(in act: Activities.Activity, answers: [String:String]) -> String? {
        print("🧭 [ResumeConcat] determineNextActivity(in:answers:)")
        if let records = act.taskCompletionTemplateR?.records {
            for record in records where record.tipoDeDatosC == "Picklist" {
                let idx = selectedIndexForPicklist(record, answers: answers)
                
                if let concatEnrol = record.concatenacionPicklistEnrolamientoC, !concatEnrol.isEmpty {
                    let ids = splitAndTrim(concatEnrol)
                    if ids.count == 1 { print("   → Enrol único: \(ids[0])"); return ids[0] }
                    if let i = idx, i < ids.count { print("   → Enrol idx \(i): \(ids[i])"); return ids[i] }
                }
                
                if let concatTpl = record.concatenacionPicklistTemplateC, !concatTpl.isEmpty {
                    let tplIds = splitAndTrim(concatTpl)
                    let chosenTplId: String? = {
                        if tplIds.count == 1 { return tplIds[0] }
                        if let i = idx, i < tplIds.count { return tplIds[i] }
                        return tplIds.first
                    }()
                    if let tplId = chosenTplId,
                       let actId = findActivityIdByTemplateId(tplId) {
                        print("   → Template → ActivityId: \(actId) (tplId=\(tplId))")
                        return actId
                    }
                }
            }
        }
        
        if let fallback = act.idActividadConcatenadaEnrolamientoC, !fallback.isEmpty {
            print("   → Fallback actividad: \(fallback)")
            return fallback
        }
        print("   → Sin siguiente actividad.")
        return nil
    }
    
    // MARK: - ✅ Navegar a siguiente actividad
    func navigateToActivity(_ activityId: String) async {
        print("🧭 [Navigate] Buscar ActivityId=\(activityId) en lista local…")
        guard let allActivities = activities?.records else {
            print("⚠️ [Navigate] No hay activities en memoria. Finalizando flujo.")
            await completeActivityAndReturn()
            return
        }
        
        if let nextAct = allActivities.first(where: { $0.Id == activityId }) {
            print("✅ [Navigate] Actividad encontrada: \(nextAct.nombrePersonalizadoC ?? "Sin nombre")")
            // Guardar estado actual y apilar en historial
            saveCurrentActivityStateToCache()
            activityHistory.append(activity)
            fetchAnswersAndLoad(nextAct)
        } else {
            print("❌ [Navigate] Actividad \(activityId) no encontrada en lista local. Finalizando flujo.")
            await completeActivityAndReturn()
        }
    }
    
    // ✅ Retroceder en historial sin POST
    func handleBackNavigation() {
        guard let prev = activityHistory.popLast() else {
            // Si no hay historial, salir a la lista
            presentationMode.wrappedValue.dismiss()
            return
        }
        // Guardar estado actual antes de retroceder
        saveCurrentActivityStateToCache()
        // Cargar desde caché si existe
        if let actId = prev.Id,
           let cached = answersCache[actId],
           let cachedOriginal = originalAnswersCache[actId],
           let cachedExisting = existingIdsCache[actId] {
            Task { await loadActivityUI(prev, with: cached, existingIds: cachedExisting) }
            self.originalCompletionResponse = cachedOriginal
        } else {
            fetchAnswersAndLoad(prev)
        }
    }
    
    // ✅ Completar actividad y volver a lista
    func completeActivityAndReturn() async {
        print("🎉 [Complete] Actividad completada al 100% - última pregunta del flujo")
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.isCheckingProgress = true // ⭐️ Activar overlay ANTES del alert para evitar flash
            HapticManager.success()
            self.showConfetti = true
            self.alertAuthEvent = .SuccesSendData
            self.showAlert = true
            ReviewManager.shared.requestReviewIfNeeded()
            print("🔔 [Complete] Mostrando Alert de éxito con overlay activo")
        }
    }

    // MARK: - ✅ Botón Siguiente/Completar (POST condicional)
    func handleComplete() {
        Task {
            // 0) Si estamos revisando y presionamos "Cerrar", navegar según lógica de Android
            let hasNextActivity = determineNextActivity() != nil
            if !hasNextActivity && isActivityFullyAnsweredPreviously {
                print("🔙 [Complete] Modo revisión - última actividad de concatenación")
                
                // 0.1) Detectar cambios comparando respuestas actuales vs baseline original
                let (creates, updates, _, _) = computeChanges()
                let hasChanges = !creates.isEmpty || !updates.isEmpty
                
                print("🔍 [Complete] ¿Hay cambios? \(hasChanges) (creates: \(creates.count), updates: \(updates.count))")
                
                if !hasChanges {
                    // ========== CASO A: SIN CAMBIOS ==========
                    // Solo revisó, no editó nada
                    // → NO ejecutar servicios
                    // → Navegar a TAREAS directamente
                    // → TasksView ejecutará su GET al cargar (con posible auto-skip)
                    //
                    // ⚠️ PARIDAD ANDROID: NO setear shouldReloadTareaFragment aquí.
                    // Android solo setea ese flag tras un POST exitoso (ActividadItemsFragment.kt:3260, 4356).
                    // Setearlo sin POST hacía que ElementsView entrara al "CAMINO A" y disparara
                    // refreshDataInBackground(), cuya regeneración de lista (nuevo UUID) causaba
                    // que la lista desapareciera ~1 segundo después de mostrarse.
                    print("📋 [Caso A] Sin cambios - Navegando a TAREAS sin POST")
                    
                    await MainActor.run {
                        // Activar overlay durante navegación
                        self.isCheckingProgress = true
                        
                        // ✅ Solo marcar recarga de niveles superiores (tareas/etapas),
                        // NO shouldReloadTareaFragment → ElementsView entrará al "CAMINO B"
                        // (backFromTasks) y mostrará la lista estable sin recargar en background.
                        navigationState.shouldReloadTareas = true
                        navigationState.shouldReloadEtapas = true
                        // navigationState.shouldReloadTareaFragment queda en false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // Dismiss directo de ElementDetailsView → ElementsView.
                            // ElementsView.onAppear ve shouldDismissToTasks=true → hace su dismiss → TasksView.
                            // NO usar publisher.send(): es una copia del subject y nunca llega a ElementsView.
                            self.navigationState.shouldDismissToTasks = true
                            self.isLoadingTasks = true
                            self.presentationMode.wrappedValue.dismiss()
                            self.isCheckingProgress = false
                        }
                    }
                    return
                    
                } else {
                    // ========== CASO B: CON CAMBIOS ==========
                    // Editó alguna respuesta
                    // → POST /task-completions (servicio 1)
                    // → GET reload de tareas (servicio 2 - manejado por navigationState)
                    // → Navegar a TAREAS
                    // → TasksView ejecutará GET al cargar (servicio 3, con posible auto-skip)
                    print("✏️ [Caso B] Con cambios - POST + Navegando a TAREAS")
                    
                    await MainActor.run {
                        self.isCheckingProgress = true
                    }
                    
                    // POST: Enviar solo lo modificado
                    // ⚠️ IMPORTANTE: Subir imágenes TANTO de creates como de updates
                    let allChangedTemplateIds = Set(creates.map { $0.Id ?? "" } + updates.map { $0.Id ?? "" })
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("🔼 [Caso B] Iniciando subida de archivos a S3")
                    print("   allChangedTemplateIds (creates + updates): \(allChangedTemplateIds)")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    await uploadImagesToS3(onlyFor: allChangedTemplateIds)
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("🔽 [Caso B] Subida de archivos completada")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("")
                    
                    let unionTemplates = creates + updates
                    
                    // ⚠️ IMPORTANTE: Reconstruir filteredResponse DESPUÉS de subir a S3
                    // para que incluya las URLs en lugar del base64
                    let filteredResponse = unionTemplates.reduce(into: [String: String]()) { dict, template in
                        if let id = template.Id, let value = completionResponse[id] {
                            dict[id] = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    
                    // 🔎 LOG DETALLADO DEL REQUEST BODY ANTES DE ENVIAR (CASO B)
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("✏️ [Caso B] Modo Revisión con Cambios - POST /postTask")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("📊 Resumen:")
                    print("   • Creates (nuevos): \(creates.count)")
                    print("   • Updates (modificados): \(updates.count)")
                    print("   • Total templates a enviar: \(unionTemplates.count)")
                    print("   • Total respuestas: \(filteredResponse.count)")
                    print("")
                    print("📝 Templates a enviar:")
                    for (index, template) in unionTemplates.enumerated() {
                        let templateId = template.Id ?? "N/A"
                        let isCreate = existingCompletionIds[templateId] == nil
                        let completionId = existingCompletionIds[templateId] ?? "N/A (CREATE)"
                        let responseValue = filteredResponse[templateId] ?? "N/A"
                        let action = isCreate ? "CREATE" : "UPDATE"
                        
                        print("   [\(index + 1)] \(action)")
                        print("       • Template ID: \(templateId)")
                        print("       • Completion ID: \(completionId)")
                        print("       • Nombre: \(template.nombrePersonalizadoC ?? "N/A")")
                        print("       • Tipo: \(template.tipoDeDatosC ?? "N/A")")
                        
                        // ✅ MOSTRAR VALOR TRUNCADO PARA ARCHIVOS
                        if template.tipoDeDatosC == "Subir Archivo" {
                            if responseValue.lowercased().hasPrefix("http") {
                                print("       • Valor Respuesta: \(responseValue) [URL - S3]")
                            } else {
                                print("       • Valor Respuesta: [Base64 - \(responseValue.count) chars] ⚠️ NO CONVERTIDO A URL")
                            }
                        } else {
                            print("       • Valor Respuesta: \(responseValue)")
                        }
                    }
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("")
                    
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
                                // Dismiss directo de ElementDetailsView → ElementsView.
                                // ElementsView.onAppear ve shouldDismissToTasks=true → hace su dismiss → TasksView.
                                // NO usar publisher.send(): es una copia del subject y nunca llega a ElementsView.
                                self.navigationState.shouldDismissToTasks = true
                                self.isLoadingTasks = true
                                self.presentationMode.wrappedValue.dismiss()
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
            }
            
            // 1) Validación básica (si está deshabilitado no debería entrar, pero por seguridad)
            guard isSubmitEnabled else { return }
            
            // 2) Detectar cambios
            let (creates, updates, filteredResponse, changedIds) = computeChanges()
            let shouldPost = !creates.isEmpty || !updates.isEmpty
            print("🧮 [Complete] creates=\(creates.count) updates=\(updates.count) shouldPost=\(shouldPost)")
            
            if shouldPost {
                await MainActor.run { isLoading = true }
                
                // 2.a) Subir imágenes solo para ids cambiados
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔼 [handleComplete] Iniciando subida de archivos a S3")
                print("   changedIds: \(changedIds)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                await uploadImagesToS3(onlyFor: changedIds)
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔽 [handleComplete] Subida de archivos completada")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
                
                // 2.b) RECONSTRUIR filteredResponse DESPUÉS de subir a S3
                // ⚠️ IMPORTANTE: Ahora completionResponse tiene las URLs, no el base64
                let unionTemplates = creates + updates
                var updatedFilteredResponse: [String: String] = [:]
                for template in unionTemplates {
                    if let id = template.Id, let value = completionResponse[id] {
                        updatedFilteredResponse[id] = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                // 2.c) POST: enviar solo los templates modificados
                // 2.c) POST: enviar solo los templates modificados
                
                // 🔎 LOG DETALLADO DEL REQUEST BODY ANTES DE ENVIAR
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🎯 ElementDetailsView - Preparando POST /postTask")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📊 Resumen:")
                print("   • Creates (nuevos): \(creates.count)")
                print("   • Updates (modificados): \(updates.count)")
                print("   • Total templates a enviar: \(unionTemplates.count)")
                print("   • Total respuestas filtradas: \(updatedFilteredResponse.count)")
                print("")
                print("📝 Templates a enviar:")
                for (index, template) in unionTemplates.enumerated() {
                    let templateId = template.Id ?? "N/A"
                    let isCreate = existingCompletionIds[templateId] == nil
                    let completionId = existingCompletionIds[templateId] ?? "N/A (CREATE)"
                    let responseValue = updatedFilteredResponse[templateId] ?? "N/A"
                    let action = isCreate ? "CREATE" : "UPDATE"
                    
                    print("   [\(index + 1)] \(action)")
                    print("       • Template ID: \(templateId)")
                    print("       • Completion ID: \(completionId)")
                    print("       • Nombre: \(template.nombrePersonalizadoC ?? "N/A")")
                    print("       • Tipo: \(template.tipoDeDatosC ?? "N/A")")
                    
                    // ✅ MOSTRAR VALOR TRUNCADO PARA ARCHIVOS
                    if template.tipoDeDatosC == "Subir Archivo" {
                        if responseValue.lowercased().hasPrefix("http") {
                            print("       • Valor Respuesta: \(responseValue) [URL - S3]")
                        } else {
                            print("       • Valor Respuesta: [Base64 - \(responseValue.count) chars] ⚠️ NO CONVERTIDO A URL")
                        }
                    } else {
                        print("       • Valor Respuesta: \(responseValue)")
                    }
                    print("")
                }
                print("🗂️ Diccionario de respuestas (updatedFilteredResponse):")
                for (key, value) in updatedFilteredResponse {
                    if let template = unionTemplates.first(where: { $0.Id == key }), 
                       template.tipoDeDatosC == "Subir Archivo" {
                        if value.lowercased().hasPrefix("http") {
                            print("   • \(key): \(value) [URL - S3]")
                        } else {
                            print("   • \(key): [Base64 - \(value.count) chars] ⚠️")
                        }
                    } else {
                        print("   • \(key): \(value)")
                    }
                }
                print("")
                print("🔑 Diccionario de existingCompletionIds:")
                for (key, value) in existingCompletionIds {
                    print("   • Template \(key) → Completion \(value)")
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
                
                let result = await Network.shared.postTask(
                    activityData: unionTemplates,
                    response: updatedFilteredResponse,
                    existingCompletionIds: existingCompletionIds
                )
                
                switch result {
                case .success:
                    print("✅ [Complete] POST exitoso. Refrescando baseline desde servidor…")
                    // 3) Refrescar respuestas del servidor para actualizar baseline y existing ids
                    if let currentId = activity.Id {
                        let r = await Network.shared.getActivityCompletions(id_activity: currentId)
                        switch r {
                        case .failure(let error):
                            print("⚠️ [Complete] Error refrescando baseline: \(error). Igual seguimos con concatenación.")
                            // A falta de servidor, usar el estado actual como baseline
                            await MainActor.run {
                                originalCompletionResponse = completionResponse
                                if let actId = activity.Id {
                                    originalAnswersCache[actId] = originalCompletionResponse
                                    answersCache[actId] = completionResponse
                                }
                            }
                        case .success(let response):
                            // ✅ Reconstruir baseline usando LLAVE COMPUESTA
                            let completionsByCompositeKey = buildCompletionsByCompositeKey(from: response.data)
                            
                            var answers: [String:String] = [:]
                            var existingIds: [String:String] = [:]
                            if let templates = completion.records {
                                for template in templates {
                                    guard let templateId = template.Id else { continue }
                                    let tipo = template.tipoDeDatosC ?? ""
                                    
                                    let prev = findCompletion(for: template, in: completionsByCompositeKey)
                                    let prevValue = prev?.valorDeRespuestaC?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                                    switch tipo {
                                    case "Checkbox", "Texto URL (Archivo multimedia)":
                                        answers[templateId] = prevValue.isEmpty ? "false" : prevValue
                                    default:
                                        answers[templateId] = prevValue
                                    }
                                    if let existingId = prev?.Id {
                                        existingIds[templateId] = existingId
                                    }
                                }
                            }
                            await MainActor.run {
                                completionResponse = answers
                                originalCompletionResponse = answers
                                existingCompletionIds = existingIds
                                if let actId = activity.Id {
                                    answersCache[actId] = answers
                                    originalAnswersCache[actId] = answers
                                    existingIdsCache[actId] = existingIds
                                }
                            }
                        }
                    }
                    
                    // 4) Concatenación / navegación
                    await handleConcatenationFlow()
                    
                case .failure(let error):
                    await MainActor.run {
                        AppStatusManager.error(error)
                        self.alertAuthEvent = .FailSendData
                        self.showAlert = true
                        self.isLoading = false
                    }
                }
            } else {
                // No hay nada nuevo → NO POST. Navegar usando respuestas existentes
                print("ℹ️ [Complete] Sin cambios. Navegar por concatenación con respuestas guardadas.")
                await handleConcatenationFlow()
            }
        }
    }

    // MARK: - ⚠️ FUNCIÓN ANTIGUA (Para compatibilidad)
    func sendInfo() {
        print("⚠️ [Compat] sendInfo() → delega en sendInfoWithConcatenation()")
        sendInfoWithConcatenation()
    }
    
    func postTask() {
        print("⚠️ [Compat] postTask() → delega en postTaskWithConcatenation()")
        Task {
            await postTaskWithConcatenation()
        }
    }

    func reloadView() { }
    func questionnaireWithConditionalEnlistment() { }
    
    // MARK: - ✅ NUEVOS HELPERS: Cargar la primera actividad del flujo
    func findFirstActivityIdInFlow() -> String? {
        guard let allActs = activities?.records, !allActs.isEmpty else { return nil }
        
        // Conjunto de actividades "referenciadas" por cualquier concatenación
        var referenced = Set<String>()
        
        for act in allActs {
            // Concatenación a nivel de actividad
            if let nextId = act.idActividadConcatenadaEnrolamientoC, !nextId.isEmpty {
                referenced.insert(nextId)
            }
            // Concatenación a nivel de template (Picklist / Template)
            if let templates = act.taskCompletionTemplateR?.records {
                for t in templates {
                    if let concatEnrol = t.concatenacionPicklistEnrolamientoC, !concatEnrol.isEmpty {
                        let ids = splitAndTrim(concatEnrol)
                        ids.forEach { referenced.insert($0) }
                    }
                    if let concatTpl = t.concatenacionPicklistTemplateC, !concatTpl.isEmpty {
                        let tplIds = splitAndTrim(concatTpl)
                        for tplId in tplIds {
                            if let actId = findActivityIdByTemplateId(tplId) {
                                referenced.insert(actId)
                            }
                        }
                    }
                }
            }
        }
        
        // La raíz del flujo será la primera actividad cuyo Id NO esté referenciado
        if let root = allActs.first(where: { idAct in
            if let id = idAct.Id {
                return !referenced.contains(id)
            }
            return false
        }) {
            return root.Id
        }
        
        // Fallback: la primera de la lista
        return allActs.first?.Id
    }
    
    func loadFirstActivityOfFlow() async {
        print("🧷 [FlowRoot] Intentando cargar la primera actividad del flujo…")
        await MainActor.run {
            self.activityHistory = [] // ← al cargar raíz, el historial debe estar vacío
        }
        guard let allActs = activities?.records, !allActs.isEmpty else {
            print("⚠️ [FlowRoot] No hay actividades en memoria. Cargando actual.")
            await loadActivityUI(self.activity, with: [:], existingIds: [:])
            return
        }
        
        let rootId = findFirstActivityIdInFlow()
        guard let rootActId = rootId,
              let rootAct = allActs.first(where: { $0.Id == rootActId }) else {
            print("⚠️ [FlowRoot] No se pudo determinar la raíz. Cargando actual.")
            await loadActivityUI(self.activity, with: [:], existingIds: [:])
            return
        }
        
        print("✅ [FlowRoot] Raíz detectada ActivityId=\(rootActId) '\(rootAct.nombrePersonalizadoC ?? "-")'. Cargando respuestas previas…")
        
        // Traer respuestas previas para la raíz
        let result = await Network.shared.getActivityCompletions(id_activity: rootActId)
        switch result {
        case .failure(let error):
            print("❌ [FlowRoot] Error getActivityCompletions(\(rootActId)): \(error). Cargando UI sin respuestas.")
            await loadActivityUI(rootAct, with: [:], existingIds: [:])
            return
            
        case .success(let response):
            // ✅ LLAVE COMPUESTA
            let completionsByCompositeKey = buildCompletionsByCompositeKey(from: response.data)
            
            var answers: [String:String] = [:]
            var existingIds: [String:String] = [:]
            var localPositionIndex: Int = 0
            
            if let templates = rootAct.taskCompletionTemplateR?.records {
                for template in templates {
                    guard let templateId = template.Id else { continue }
                    let tipo = template.tipoDeDatosC ?? ""
                    
                    // ✅ Buscar completion usando llave compuesta
                    let prev = findCompletion(for: template, in: completionsByCompositeKey)
                    let prevValue = prev?.valorDeRespuestaC?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    switch tipo {
                    case "Checkbox", "Texto URL (Archivo multimedia)":
                        answers[templateId] = prevValue.isEmpty ? "false" : prevValue
                    case "Texto", "Número", "Picklist", "Picklist Múltiple", "Subir Archivo":
                        answers[templateId] = prevValue
                        
                        if tipo == "Picklist" {
                            if let opts = template.posiblesValoresC, !opts.isEmpty {
                                let options = opts.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                                if let idx = options.firstIndex(of: prevValue) {
                                    localPositionIndex = idx
                                }
                            } else if let idx = parsePicklistIndex(from: prevValue) {
                                localPositionIndex = idx
                            }
                        }
                    default:
                        break
                    }
                    
                    if let existingId = prev?.Id {
                        existingIds[templateId] = existingId
                    }
                }
            }
            
            await loadActivityUI(rootAct, with: answers, existingIds: existingIds, positionIndex: localPositionIndex)
            return
        }
    }
}

// MARK: - Helper para reducir complejidad en ViewBuilder
extension ElementDetailsView {
    @ViewBuilder
    func openURLRowView(for com: ActivityCompletion.Completion) -> some View {
        let canEdit = isEditable(for: com)
        let name = com.nombrePersonalizadoC ?? "Sin Nombre"
        let id = com.Id ?? ""
        let url = com.posiblesValoresC ?? ""
        let required = com.requeridoC ?? false

        OpenURLRow(
            response: $completionResponse,
            name: name,
            idCom: id,
            url: url,
            isRequired: required,
            canEditToggle: canEdit
        )
    }
}
