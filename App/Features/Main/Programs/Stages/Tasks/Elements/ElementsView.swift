//
//  ElementsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/04/2023.
//

import SwiftUI
import Combine

struct ElementsView: View {
    @Environment(\.presentationMode) var presentationMode
    let totalActivities: Int
    let taskTitle: String
    let taskId: String
    @State var taskData: Goals.Goal
    @State var isLoading: Bool = false
    @State var allActivities: Activities
    @State var progress: Int = 0
    @State var imgData: String = ""
    @State var completionResponse: [String : String] = [:]
    @State var showAlert: Bool = false
    @State var alertAuthEvent: AlertAuthElements?
    @State var anyAnswerSend: Bool = false
    @Binding var isFavorite: Bool
    @Binding var isLoadingTasks: Bool
    let programa_id: String
    let puntosActivos: Bool
    let puntosObtener: Float
    let puntosAcumulados: Float
    @State var stages: Stages? = nil
    @State var navigateToQuestions: Bool = false
    @State var isQuestionnaire: Bool = false
    @State private var showWebView = false
    
    // ✅ NUEVOS ESTADOS PARA CONCATENACIÓN
    @State private var currentActivityId: String? = nil
    @State private var currentTemplateId: String? = nil
    @State private var navigationPath: [String] = [] // Para rastrear el camino de concatenación
    @State private var completedTemplates: Set<String> = [] // Templates ya respondidos

    // ✅ FIX #2C: Bandera que indica que la salida de ElementsView fue PROGRAMÁTICA
    // (dismiss automático por tarea completada), NO iniciada por el usuario.
    // Cuando es true, onDisappear NO activa backFromTasks para no dejar flags residuales.
    @State private var isProgrammaticDismiss: Bool = false
    
    
    // ✅ NUEVO: Recibir estado de navegación del padre (opcional para evitar crashes)
    @EnvironmentObject var navigationState: NavigationState
    
    var publisher = PassthroughSubject<Void, Never>()
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Divider()
                VStack(spacing: 10) {
                    Text(taskTitle)
                        .font(.appSubhead)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(taskData.instruccionesC ?? "")
                        .font(.appCaptionLarge)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if taskData.instruccionesLinkC != nil{
                        Text(taskData.textoBotonC ?? "Ver Instrucciones")
                            .font(.appCaptionLarge)
                            .foregroundColor(.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                openArchive()
                            }
                    }
                    progressView
                        .padding(.vertical, .margin)
                    
                    Text("Lista de Actividades")
                        .font(.appSmallMedium)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let activities = allActivities.records, !activities.filter({ !($0.actividadInvisibleC ?? false) }).isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(activities, id: \.Id) { activity in
                                    // ✅ FILTRAR ACTIVIDADES INVISIBLES
                                    if !(activity.actividadInvisibleC ?? false) {
                                        if let totalCom = activity.taskCompletionTemplateR {
                                            if totalCom.totalSize == 1 {
                                                ElementRowView(
                                                    activity: activity,
                                                    isSingleCompletion: true,
                                                    completionResponse: $completionResponse,
                                                    isLoadingTasks: $isLoadingTasks,
                                                    //showAlertActivityReady: $showAlertActivityReady,
                                                    alertAuthEvent: $alertAuthEvent,
                                                    publisher: self.publisher,
                                                    isQuestionnaire: $isQuestionnaire,
                                                    allActivities: allActivities,
                                                    programa_ID: programa_id,
                                                    puntosActivos: puntosActivos,
                                                    puntosObtener: puntosObtener,
                                                    puntosAcumulados: puntosAcumulados
                                                )
                                                .environmentObject(navigationState)  // ✅ PASAR ESTADO
                                            } else {
                                                ElementRowView(
                                                    activity: activity,
                                                    completionResponse: $completionResponse,
                                                    isLoadingTasks: $isLoadingTasks,
                                                    //showAlertActivityReady: $showAlert,
                                                    alertAuthEvent: $alertAuthEvent,
                                                    publisher: self.publisher,
                                                    isQuestionnaire: $isQuestionnaire,
                                                    allActivities: allActivities,
                                                    programa_ID: programa_id,
                                                    puntosActivos: puntosActivos,
                                                    puntosObtener: puntosObtener,
                                                    puntosAcumulados: puntosAcumulados
                                                )
                                                .environmentObject(navigationState)  // ✅ PASAR ESTADO
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else if !isLoading {
                        VStack(spacing: 12) {
                            Spacer()
                            Spacer()
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(Color(.systemGray3))
                            Text("No se encontraron actividades")
                                .font(Font.custom("FiraSans-Bold", size: 19))
                                .foregroundColor(Color(hex: "#5B6770"))
                            Text("No hay actividades disponibles en esta tarea")
                                .font(Font.custom("FiraSans-Regular", size: 15))
                                .foregroundColor(Color(hex: "#C4C4C4"))
                                .multilineTextAlignment(.center)
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    // ⛔️ ELIMINADO: .id(listRefreshId)
                    // Cambiar el ID forzaba a SwiftUI a destruir y recrear la lista entera,
                    // causando que desapareciera ~1 segundo tras el reload.
                    // SwiftUI ya re-renderiza automáticamente cuando allActivities cambia.
                }
                .alert(item: $alertAuthEvent, content: { tipe in
                    switch tipe{
                    case .SuccesSendData:
                        return Alert(title: Text(""), message: Text("Informacion enviadas correctamente"),
                                     dismissButton: .default(Text("OK"),
                                            action: {
                                            self.isLoadingTasks = true
                                            self.presentationMode.wrappedValue.dismiss()
                                        }))
                    case .FailSendData:
                        return Alert(title: Text(""), message: Text("Error al enviar ejercicios"), dismissButton: .default(Text("OK")))
                    case .ImgError:
                        return Alert(title: Text(""), message: Text("Error al subir la imagen, Porfavor seleccione otra"), dismissButton: .default(Text("OK")))
                    case .NothingToSend:
                        return Alert(title: Text(""), message: Text("Sin actividades realizadas para enviar"), dismissButton: .default(Text("OK")))
                    case .CompleteTask:
                        return Alert(title: Text(""),
                                     message: Text("¿Está seguro de completar la tarea?"),
                                     primaryButton: .default(
                                                     Text("Confirmar"),
                                                     action: {
                                                         completeTask()
                                                     }
                                                 ),
                                     secondaryButton: .default(
                                                     Text("Cancelar")
                                                 )
                        )
                    }
                    
                })
                .padding(.margin)
            }
            .onAppear {
                isFavorite = taskData.favoritoAppC ?? false
                
                print("👁️ [ElementsView] onAppear")
                print("🔍 [ElementsView] shouldReloadTareaFragment: \(navigationState.shouldReloadTareaFragment)")
                print("🔍 [ElementsView] backFromTasks: \(navigationState.backFromTasks)")
                print("🔍 [ElementsView] shouldDismissToTasks: \(navigationState.shouldDismissToTasks)")
                print("🔍 [ElementsView] shouldDismissToStages: \(navigationState.shouldDismissToStages)")
                print("🔍 [ElementsView] navigateToQuestions: \(navigateToQuestions)")
                print("🔍 [ElementsView] progress: \(progress)%")
                print("🔍 [ElementsView] allActivities.records count: \(allActivities.records?.count ?? 0)")
                
                // ✅ PROTECCIÓN #0A: Si debe volver a TasksView, hacer dismiss inmediato
                if navigationState.shouldDismissToTasks {
                    print("🔙 [ElementsView] shouldDismissToTasks detectado - Haciendo dismiss hacia TasksView")
                    // ✅ FIX #2A: Consumir el flag AQUÍ antes de hacer dismiss.
                    // Si no lo consumimos, TasksView también lo verá en su onAppear y ejecutará
                    // shouldDismissToTasks otra vez, generando "Trying to pop to a missing destination".
                    navigationState.shouldDismissToTasks = false
                    // ✅ FIX #2C: Marcar como dismiss programático para que onDisappear
                    // NO active backFromTasks (evita flags residuales).
                    isProgrammaticDismiss = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    return
                }
                
                // ✅ PROTECCIÓN #0B: Si debe volver a StagesView, hacer dismiss inmediato
                if navigationState.shouldDismissToStages {
                    print("🔙 [ElementsView] shouldDismissToStages detectado - Haciendo dismiss hacia TasksView (pasando a través)")
                    // NO consumir el flag aquí, TasksView también lo necesita
                    isProgrammaticDismiss = true  // ✅ FIX #2C: No dejar backFromTasks residual
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    return
                }
                
                // ✅ RESETEAR navigateToQuestions al entrar a la vista
                // Esto permite que onDisappear funcione correctamente
                navigateToQuestions = false
                // ✅ Resetear isProgrammaticDismiss en cada nueva entrada
                isProgrammaticDismiss = false
                
                // ═══════════════════════════════════════════════════════════════════════
                // ✅ CAMBIO CLAVE: SIEMPRE mostrar la lista primero (como Android)
                // ═══════════════════════════════════════════════════════════════════════
                // En Android, loadActividadesData() + showActividades() se ejecutan SIEMPRE
                // en onViewCreated(), independientemente del camino (A o B).
                // La recarga del servidor (si es necesaria) ocurre DESPUÉS en background.
                //
                // Esto garantiza que "Lista de actividades" siempre sea visible de inmediato.
                // ═══════════════════════════════════════════════════════════════════════
                
                // ✅ FIX #4A: Capturar el taskId ANTERIOR antes de actualizarlo
                // Esto nos permite detectar si es la MISMA tarea (modo revisión) o una TAREA NUEVA
                let previousTaskId = navigationState.currentTaskId
                print("🔍 [ElementsView] TaskId anterior en contexto: \(previousTaskId ?? "nil")")
                print("🔍 [ElementsView] TaskId actual (nuevo): \(taskId)")
                
                // Actualizar contexto de navegación con el nuevo taskId
                navigationState.updateContext(taskId: taskId)
                
                // ✅ PASO 1: Calcular y mostrar progreso actual (sincrónico, como Android)
                calculateProgress()
                
                // ✅ PASO 2: Decidir el camino de visualización
                let shouldReload = navigationState.shouldReloadTareaFragment
                let comesFromBack = navigationState.backFromTasks
                
                // Consumir flags inmediatamente
                if shouldReload {
                    navigationState.shouldReloadTareaFragment = false
                }
                if comesFromBack {
                    navigationState.backFromTasks = false
                }
                
                // ✅ PASO 3: Mostrar contenido de inmediato
                // La lista ya está renderizada porque @State var allActivities se pasó al init
                // Solo necesitamos asegurar que isLoadingTasks sea false
                self.isLoadingTasks = false
                
                print("📋 [ElementsView] Lista de actividades visible de inmediato")
                print("   - Actividades totales: \(allActivities.records?.count ?? 0)")
                print("   - Progreso calculado: \(progress)%")
                
                // ✅ PASO 4: Determinar acción post-renderizado
                // 🔄 PARIDAD ANDROID: En Android, cuando seleccionas una nueva tarea desde TareasListaFragment,
                // updateFragment() crea un nuevo TareaFragment con datos locales (NO red).
                // shouldReloadTareaFragment puede estar residual del flujo "Terminar" anterior,
                // pero NO debe causar reload si es una TAREA DIFERENTE.
                
                // ✅ FIX #4B: Verificar si es la MISMA tarea que la anterior (modo revisión real)
                // vs. una TAREA NUEVA (primera entrada después de completar otra tarea)
                // Comparar con el previousTaskId (antes de actualizar el contexto)
                let isSameTaskAsContext = previousTaskId == taskId
                print("🔍 [ElementsView] ¿Es la misma tarea? \(isSameTaskAsContext)")
                print("   - previousTaskId: \(previousTaskId ?? "nil")")
                print("   - taskId actual: \(taskId)")
                
                if shouldReload && !comesFromBack && isSameTaskAsContext {
                    // CAMINO A: Viene de modo revisión con POST real → Recargar en background.
                    // Solo si es la MISMA tarea que la del contexto actual.
                    print("🔄 [ElementsView] CAMINO A: Recarga solicitada desde modo revisión (MISMA tarea)")
                    print("   - previousTaskId: \(previousTaskId ?? "nil")")
                    print("   - taskId actual: \(taskId)")
                    print("   - Lista ya visible con datos actuales")
                    
                    // ✅ PARIDAD ANDROID (TareaFragment.kt:183-186):
                    // Si el progreso ya es 100%, NO hacer background reload ni auto-navegación.
                    if progress >= 100 {
                        print("🛑 [ElementsView] CAMINO A + 100% → Lista estable sin background reload")
                        print("   (Paridad Android: porcentajeCumplimiento >= 100 → NO recargar ni auto-navegar)")
                    } else {
                        print("   - Iniciando recarga en background...")
                        Task { @MainActor in
                            await refreshDataInBackground()
                        }
                    }
                    
                } else if comesFromBack || shouldReload {
                    // CAMINO B: Navegación hacia atrás (usuario pulsó Back) O
                    //           shouldReload residual con tarea DIFERENTE (flag del flujo anterior).
                    // En ambos casos: mostrar lista estable sin auto-navegación ni background reload.
                    print("🔙 [ElementsView] CAMINO B: Mostrando lista sin auto-navegación")
                    if comesFromBack && shouldReload {
                        print("   ⚠️ Flags residuales detectados (shouldReload+backFromTasks) - ignorando reload")
                    }
                    if shouldReload && !isSameTaskAsContext {
                        print("   ⚠️ shouldReload residual de tarea anterior - ignorando reload")
                        print("      (previousTaskId: \(previousTaskId ?? "nil"), taskId actual: \(taskId))")
                    }
                    
                } else {
                    // CAMINO C: Primera entrada → Verificar auto-navegación
                    print("🎯 [ElementsView] CAMINO C: Primera entrada a la tarea")
                    print("   - Verificando si debe auto-navegar...")
                    
                    checkAutoNavigationPath()
                }
            }
            .onDisappear {
                print("👋 [ElementsView] onDisappear - Usuario saliendo de ElementsView")
                print("   navigateToQuestions: \(navigateToQuestions)")
                print("   isProgrammaticDismiss: \(isProgrammaticDismiss)")
                
                if isProgrammaticDismiss {
                    // ✅ FIX #2C: Dismiss programático (tarea completada, publisher.send(), etc.)
                    // NO activar backFromTasks para no dejar flags residuales que confundan
                    // la lógica de re-entrada en ElementsView.
                    print("🤖 [ElementsView] Dismiss programático - NO activar backFromTasks")
                    // Resetear para el próximo ciclo de vida
                    isProgrammaticDismiss = false
                } else if !navigateToQuestions {
                    // Navegación hacia atrás iniciada por el usuario (botón Back)
                    print("🔙 [ElementsView] Navegación hacia atrás detectada - Activando backFromTasks")
                    navigationState.backFromTasks = true
                } else {
                    print("➡️ [ElementsView] Navegando hacia cuestionario - NO activar backFromTasks")
                }
            }
            .onReceive(publisher, perform: { _ in
                        // ✅ FIX #2C: Dismiss vía publisher también es programático.
                        // No debe activar backFromTasks en onDisappear.
                        // isLoadingTasks = true le indica a TasksView que debe refrescar.
                        DispatchQueue.main.async {
                            self.isLoadingTasks = true
                            self.isProgrammaticDismiss = true
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    })
            .navigationLink(isActive: $navigateToQuestions) {
                if let activities = allActivities.records {
                    ForEach(activities, id: \.self) { activity in
                        if taskData.idInicioDeConcatenacionEnrolamientoC == activity.Id{
                            if let completion = activity.taskCompletionTemplateR{
                                ElementDetailsView(
                                    activityName: activity.nombreC ?? "Sin nombre",
                                    activityInstruction: activity.descripcionLargaC ?? "Sin intrucciones",
                                    completion: completion,
                                    activity: activity,
                                    isLoadingTasks: $isLoadingTasks,
                                    publisher: self.publisher,
                                    isQuestionnaire: $isQuestionnaire,
                                    activities: allActivities,
                                    program_ID: programa_id,
                                    puntosActivos: puntosActivos,
                                    puntosObtener: puntosObtener,
                                    puntosAcumulados: puntosAcumulados,
                                    stages: stages
                                )
                                .environmentObject(navigationState)  // ✅ PASAR ESTADO
                            }
                        }
                        
                    }
                }
            }
            .sheet(isPresented: $showWebView) {
                SafariWebView(url: taskData.instruccionesLinkC ?? "")
            }
            .blur(radius: isLoading ? 3 : 0.000001)
            
            if isLoading {
                CenteredLoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Mis Programas")
                    .font(.appTabTitleBold)
                    .foregroundColor(.primaryText)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    changeFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(.secondaryText)
                }
            }
        }
    }
    
    @ViewBuilder
    var progressView: some View {
        VStack {
            HStack {
                Text("Cumplimiento de tarea")
                    .font(.appSmallMedium)
                    .foregroundColor(.primaryText)
                Spacer()
                Text("\(progress)%")
                    .font(.appSmallMedium)
                    .foregroundColor(.primaryText)
            }
            
            CustomAnimatedProgressView(
                colorFilled: .blue,
                currentPercentage: Float(progress) / 100.0
            )
            
        }
        .padding(.margin)
        .frame(height: 100)
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(Color.grayLight, lineWidth: 1)
                .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
        )
    }
    
    // MARK: - Helper Functions
    
    // ✅ Función para calcular progreso basado en actividades actuales (sincrónica)
    // 🔄 PARIDAD ANDROID: Leer progreso directamente del servidor (TareaFragment.kt:2186-2193)
    // En Android:
    // val cumplimientoServidor = tareaJson.optDouble("Cumplimiento_de_la_Tarea__c").toInt()
    // mainActivityProgramas.porcentajeCumplimiento = cumplimientoServidor
    private func calculateProgress() {
        // ✅ CAMBIO ARQUITECTURAL: Leer progreso del servidor (como Android)
        // En lugar de calcular localmente, usar el campo cumplimientoDeLaTareaC
        let cumplimientoServidor = taskData.cumplimientoDeLaTareaC ?? 0.0
        
        // Validar que el valor sea válido antes de convertir
        guard cumplimientoServidor.isFinite else {
            print("⚠️ [ElementsView] Valor de cumplimiento inválido (NaN o infinito), usando 0")
            progress = 0
            return
        }
        
        progress = Int(cumplimientoServidor)
        
        print("📊 [ElementsView] Progreso leído del servidor (como Android):")
        print("   - cumplimientoDeLaTareaC: \(cumplimientoServidor)")
        print("   - Porcentaje: \(progress)%")
        print("   ℹ️ Android equivalente: Cumplimiento_de_la_Tarea__c")
    }
    
    // ✅ NUEVA FUNCIÓN: Verificar completitud de actividad individual (para UI de lista)
    // Equivalente a showActividades() en Android (TareaFragment.kt:741-796)
    private func isActivityCompleted(_ activity: Activities.Activity) -> Bool {
        // Android (showActividades):
        // var repeticiones = if (actividad.CantItems > 1)
        //     actividad.Cant_Task_Completion__c / actividad.Total_Task_Com_Template__c
        // else
        //     actividad.Cant_Task_Completion__c
        //
        // var totalRepeticiones = actividad.Total_Task_Completion2__c / actividad.Total_Task_Com_Template__c
        // val completa = repeticiones >= totalRepeticiones
        
        let totalTaskComTemplate = activity.totalTaskComTemplateC ?? 1.0
        
        // Evitar división por cero
        guard totalTaskComTemplate > 0 else {
            print("⚠️ [ElementsView] totalTaskComTemplateC es 0 para actividad \(activity.Id ?? "desconocida")")
            return false
        }
        
        // Calcular repeticiones (equivalente a Android)
        let cantItems = Int(totalTaskComTemplate)
        let repeticiones: Float
        
        if cantItems > 1 {
            repeticiones = (activity.cantTaskCompletionC ?? 0) / totalTaskComTemplate
        } else {
            repeticiones = activity.cantTaskCompletionC ?? 0
        }
        
        // Calcular total de repeticiones esperadas
        let totalRepeticiones = (activity.totalTaskCompletion2C ?? 0) / totalTaskComTemplate
        
        // Validar que los valores sean finitos
        guard repeticiones.isFinite && totalRepeticiones.isFinite else {
            print("⚠️ [ElementsView] Valores NaN/infinito en actividad \(activity.nombrePersonalizadoC ?? "sin nombre")")
            return false
        }
        
        let completa = repeticiones >= totalRepeticiones
        
        print("   📌 \(activity.nombrePersonalizadoC ?? "Sin nombre"):")
        print("      - cantTaskCompletionC: \(activity.cantTaskCompletionC ?? 0)")
        print("      - totalTaskCompletion2C: \(activity.totalTaskCompletion2C ?? 0)")
        print("      - totalTaskComTemplateC: \(totalTaskComTemplate)")
        print("      - repeticiones: \(repeticiones)")
        print("      - totalRepeticiones: \(totalRepeticiones)")
        print("      - completa: \(completa)")
        
        return completa
    }
    
    // ✅ Función para refrescar datos en background (sin bloquear la UI)
    // Equivalente a reloadTareaData() en Android - se ejecuta DESPUÉS de mostrar la lista
    private func refreshDataInBackground() async {
        print("🔄 [ElementsView] Recargando datos en background...")
        
        // NO mostrar loading global, la lista ya está visible
        // Solo un indicador sutil si es necesario
        
        let result = await Network.shared.getActivities(taskId: taskId)
        
        switch result {
        case .success(let updatedActivities):
            await MainActor.run {
                // Guardar respuestas pendientes antes de actualizar
                let pendingResponses = self.completionResponse
                
                self.allActivities = updatedActivities
                
                // Restaurar respuestas que el usuario pudo haber ingresado
                self.completionResponse = pendingResponses
                
                // ⛔️ ELIMINADO: self.listRefreshId = UUID()
                // SwiftUI re-renderiza automáticamente cuando allActivities cambia.
                // Regenerar el UUID destruía la vista completa causando que la lista desapareciera.
                
                // Recalcular progreso con datos frescos
                calculateProgress()
                
                print("✅ [ElementsView] Datos actualizados en background - Progreso: \(self.progress)%")
                
                // 🔥 FIREBASE LOGGING: Actividades actualizadas exitosamente
                FirebaseLogger.shared.log("✅ Actividades actualizadas - Progreso: \(self.progress)%")
                
                // ✅ DEBUG: Mostrar estado actualizado de cada actividad usando isActivityCompleted
                if let activities = updatedActivities.records {
                    print("📋 [ElementsView] Estado de actividades:")
                    for activity in activities {
                        let invisible = activity.actividadInvisibleC ?? false
                        let completa = self.isActivityCompleted(activity)
                        print("   ✓ Completa: \(completa) - Invisible: \(invisible)")
                    }
                }
            }
            
        case .failure(let error):
            print("❌ [ElementsView] Error al refrescar en background: \(error)")
            
            // 🔥 FIREBASE LOGGING: Error con contexto de red
            FirebaseLogger.shared.log("❌ Error al refrescar actividades: \(error.localizedDescription)")
            FirebaseLogger.shared.recordNetworkError(
                error,
                endpoint: "/api/tasks/\(taskId)/activities",
                httpCode: (error as? AppError)?.httpCode,
                method: "GET"
            )
            FirebaseLogger.shared.setCustomValues([
                "task_id": taskId,
                "error_context": "refresh_activities_background"
            ])
            
            AppStatusManager.error(error)
        }
    }
    
    // ✅ Función LEGACY para refrescar datos (se mantiene por compatibilidad, pero ya no se usa en el flujo principal)
    private func refreshData() async {
        print("🔄 [ElementsView] Refrescando datos de actividades...")
        isLoading = true
        
        // Recargar actividades
        let result = await Network.shared.getActivities(taskId: taskId)
        
        switch result {
        case .success(let updatedActivities):
            await MainActor.run {
                self.allActivities = updatedActivities
                
                // ⛔️ ELIMINADO: self.listRefreshId = UUID()
                // SwiftUI re-renderiza automáticamente cuando allActivities cambia.
                // El UUID destruía la lista causando que desapareciera visualmente.
                
                // Recalcular progreso
                calculateProgress()
                
                print("📊 [ElementsView] Actividades actualizadas:")
                print("   - Progreso del servidor: \(self.progress)%")
                
                // ✅ DEBUG: Mostrar estado de cada actividad usando isActivityCompleted
                if let activities = updatedActivities.records {
                    print("📋 [ElementsView] Estado de actividades:")
                    for activity in activities {
                        let invisible = activity.actividadInvisibleC ?? false
                        let completa = self.isActivityCompleted(activity)
                        print("   ✓ Completa: \(completa) - Invisible: \(invisible)")
                    }
                }
                
                self.isLoading = false
                
                // ✅ IMPORTANTE: Después de recargar, NO auto-navegar
                // Según Android: "NO navegar automáticamente tras reload"
                print("🛑 [ElementsView] Datos recargados - NO auto-navegación tras reload")
                print("✅ [ElementsView] Datos actualizados - Progreso: \(self.progress)%")
                
                // 🔥 FIREBASE LOGGING: Datos refrescados exitosamente
                FirebaseLogger.shared.log("✅ Datos de actividades refrescados - Progreso: \(self.progress)%")
                
                // ✅ DESACTIVAR LOADING PARA QUE SE VEA LA LISTA
                self.isLoadingTasks = false
            }
            
        case .failure(let error):
            print("❌ [ElementsView] Error al refrescar: \(error)")
            
            // 🔥 FIREBASE LOGGING: Error con contexto de red
            FirebaseLogger.shared.log("❌ Error al refrescar datos: \(error.localizedDescription)")
            FirebaseLogger.shared.recordNetworkError(
                error,
                endpoint: "/api/tasks/\(taskId)/activities",
                httpCode: (error as? AppError)?.httpCode,
                method: "GET"
            )
            FirebaseLogger.shared.setCustomValues([
                "task_id": taskId,
                "error_context": "refresh_activities"
            ])
            
            AppStatusManager.error(error)
            await MainActor.run {
                self.isLoading = false
                self.isLoadingTasks = false
            }
        }
    }
    
    func sendInfo(){
        self.isLoading = true
        Task { @MainActor in
            // ✅ 1. PRIMERO SUBIR IMÁGENES A S3
            if let activities = allActivities.records {
                for activity in activities {
                    if let totalCom = activity.taskCompletionTemplateR{
                        if totalCom.totalSize == 1{
                            if let completion = totalCom.records{
                                for com in completion{
                                    if com.tipoDeDatosC ?? "" == "Subir Archivo"{
                                        if ((completionResponse[com.Id ?? ""]) != nil){
                                            if let data = completionResponse[com.Id ?? ""] {
                                                let result = await Network.shared.postSendS3(base64: data, archivExtension: "png")
                                                switch result {
                                                case let .success(urlString):
                                                    for url in urlString.data{
                                                        self.completionResponse[com.Id ?? ""] = url
                                                    }
                                                case let .failure(error):
                                                    AppStatusManager.error(error)
                                                    self.isLoading = false
                                                    return
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // ✅ 2. ENVIAR DATOS SIN MOSTRAR POPUP - El flujo continúa automáticamente
            postTaskWithoutAlert()
        }
    }
    
    // ✅ NUEVA FUNCIÓN: Enviar sin popup, para concatenación
    func postTaskWithoutAlert(){
        Task { @MainActor in
            var hasDataToSend = false
            
            // 🔥 FIREBASE LOGGING: Inicio de envío de tareas
            FirebaseLogger.shared.log("🔄 Enviando respuestas de actividades")
            
            if let activities = allActivities.records {
                for activity in activities {
                    if let totalCom = activity.taskCompletionTemplateR{
                        if totalCom.totalSize == 1{
                            if let completion = totalCom.records{
                                if (completionResponse[completion[0].Id ?? ""] != nil) {
                                    hasDataToSend = true
                                    let result = await Network.shared.postTask(activityData: completion, response: completionResponse)
                                    switch result {
                                    case .success:
                                        print("✅ Success send - activity: \(activity.Id ?? "")")
                                        // 🔥 FIREBASE LOGGING: Actividad enviada
                                        FirebaseLogger.shared.log("✅ Actividad enviada: \(activity.Id ?? "N/A")")
                                        self.anyAnswerSend = true
                                        
                                    case let .failure(error):
                                        // 🔥 FIREBASE LOGGING: Error al enviar actividad
                                        FirebaseLogger.shared.log("❌ Error al enviar actividad: \(error.localizedDescription)")
                                        FirebaseLogger.shared.recordNetworkError(
                                            error,
                                            endpoint: "/api/tasks/\(activity.Id ?? "unknown")/complete",
                                            httpCode: (error as? AppError)?.httpCode,
                                            method: "POST"
                                        )
                                        FirebaseLogger.shared.setCustomValues([
                                            "task_id": taskId,
                                            "activity_id": activity.Id ?? "N/A",
                                            "error_context": "post_task_completion"
                                        ])
                                        
                                        AppStatusManager.error(error)
                                        self.isLoading = false
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if hasDataToSend {
                // ✅ NO MOSTRAR POPUP - Solo recargar datos
                print("✅ Datos enviados correctamente - recargando...")
                self.isLoadingTasks = true
                self.completionResponse.removeAll() // Limpiar respuestas enviadas
            } else {
                self.alertAuthEvent = .NothingToSend
                self.showAlert.toggle()
            }
                
            self.isLoading = false
        }
    }
    func completeTask(){
        self.isLoading = true
        
        // 🔥 FIREBASE LOGGING: Inicio de completar tarea
        FirebaseLogger.shared.log("🔄 Completando tarea: \(taskId)")
        FirebaseLogger.shared.setCustomValue(taskId, forKey: "completing_task_id")
        
        // 🔎 LOG DETALLADO: Inicio del proceso de completar tarea
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🚀 INICIO: Completar Tarea desde ElementsView")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔹 Task ID: \(taskId)")
        print("🔹 Task Title: \(taskTitle)")
        print("🔹 SObject Type: \(taskData.attributes?.type ?? "unknown")")
        print("🔹 Programa ID: \(programa_id)")
        print("🔹 Timestamp: \(Date())")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
        
        Task { @MainActor in
            let result = await Network.shared.postCompletado(taskId: taskId, SObject: taskData.attributes?.type ?? "")
            switch result {
            case .success(let response):
                // 🔥 FIREBASE LOGGING: Tarea completada exitosamente
                FirebaseLogger.shared.log("✅ Tarea completada exitosamente: \(taskId)")
                FirebaseLogger.shared.logEvent("task_completed", attributes: [
                    "task_id": taskId,
                    "task_type": taskData.attributes?.type ?? "unknown"
                ])
                
                // 🔎 LOG DETALLADO: Éxito
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("✅ ÉXITO: Tarea completada correctamente")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔹 Task ID: \(taskId)")
                print("🔹 Response: \(response)")
                print("🔹 Timestamp: \(Date())")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
                
                self.alertAuthEvent = .SuccesSendData
                self.showAlert.toggle()
                
            case let .failure(error):
                // 🔥 FIREBASE LOGGING: Error al completar tarea
                FirebaseLogger.shared.log("❌ Error al completar tarea: \(error.localizedDescription)")
                FirebaseLogger.shared.recordNetworkError(
                    error,
                    endpoint: "/api/tasks/\(taskId)/complete",
                    httpCode: (error as? AppError)?.httpCode,
                    method: "POST"
                )
                FirebaseLogger.shared.setCustomValues([
                    "task_id": taskId,
                    "task_type": taskData.attributes?.type ?? "unknown",
                    "error_context": "complete_task"
                ])
                
                // 🔎 LOG DETALLADO: Error
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("❌ ERROR: Fallo al completar la tarea")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔹 Task ID: \(taskId)")
                print("🔹 Error: \(error)")
                print("🔹 Error Description: \(error.localizedDescription)")
                if let appError = error as? AppError {
                    print("🔹 HTTP Code: \(appError.httpCode ?? -1)")
                    print("🔹 Error ID: \(appError.id)")
                    print("🔹 Error Message: \(appError.message)")
                }
                print("🔹 Timestamp: \(Date())")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
                
                AppStatusManager.error(error)
                return
            }
            self.isLoading = false
        }
    }
    func changeFavorite(){
        let data = !isFavorite
        self.isLoading = true
        Task { @MainActor in
            let result = await Network.shared.postFavorite(registerId: taskData.Id ?? "", objet: taskData.attributes?.type ?? "", data: data)
            switch result {
                case .success:
                self.isFavorite = data
                await AppStatusManager.loadFavoriteTask()
                case let .failure(error):
                    AppStatusManager.error(error)
            }
            self.isLoading = false
            self.isLoadingTasks = true
        }
    }
    func openArchive(){
        let myUrl = taskData.instruccionesLinkC ?? ""
        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
            self.showWebView.toggle()
        }
    }
    
    func checkIsQuestionnaire(){
        // ✅ Usar Task directamente sin DispatchQueue
        Task { @MainActor in
            if let _ = taskData.idInicioDeConcatenacionEnrolamientoC{
                if (taskData.saltarListaDeActividadesC ?? false) {
                    if let activities = allActivities.records{
                        for activity in activities {
                            // Usar isActivityCompleted en lugar de cálculo manual
                            if !isActivityCompleted(activity) {
                                self.navigateToQuestions.toggle()
                                self.isQuestionnaire = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ✅ NUEVA FUNCIÓN: Determinar siguiente actividad basada en concatenación
    func getNextActivityId(from activity: Activities.Activity, selectedPicklistIndex: Int? = nil) -> String? {
        // 1. Verificar concatenación a nivel de Template (Picklist)
        if let templates = activity.taskCompletionTemplateR?.records {
            for template in templates {
                if template.tipoDeDatosC == "Picklist",
                   let concatenacionIds = template.concatenacionPicklistEnrolamientoC,
                   !concatenacionIds.isEmpty {
                    
                    let ids = concatenacionIds.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespaces) }
                    
                    if let index = selectedPicklistIndex, index < ids.count {
                        return ids[index]
                    }
                }
            }
        }
        
        // 2. Si no hay concatenación de Picklist, verificar concatenación a nivel de Actividad
        if let nextActivityId = activity.idActividadConcatenadaEnrolamientoC,
           !nextActivityId.isEmpty {
            return nextActivityId
        }
        
        // 3. Si no hay ninguna concatenación, retornar nil (fin del flujo)
        return nil
    }
    
    // ✅ NUEVA FUNCIÓN: Verificar si hay más concatenación
    func hasMoreConcatenation(activityId: String) -> Bool {
        guard let activities = allActivities.records else { return false }
        
        if let activity = activities.first(where: { $0.Id == activityId }) {
            // Verificar si tiene concatenación de Picklist
            if let templates = activity.taskCompletionTemplateR?.records {
                for template in templates {
                    if template.tipoDeDatosC == "Picklist",
                       let concatenacion = template.concatenacionPicklistEnrolamientoC,
                       !concatenacion.isEmpty {
                        return true
                    }
                }
            }
            
            // Verificar si tiene concatenación de Actividad
            if let nextId = activity.idActividadConcatenadaEnrolamientoC,
               !nextId.isEmpty {
                return true
            }
        }
        
        return false
    }
    
    // ✅ NUEVA FUNCIÓN: Verificar camino de auto-navegación (A o B)
    func checkAutoNavigationPath() {
        print("🔍 [ElementsView] Verificando camino de auto-navegación")
        print("🔍 [ElementsView] saltarListaDeActividadesC: \(taskData.saltarListaDeActividadesC ?? false)")
        print("🔍 [ElementsView] idInicioDeConcatenacionEnrolamientoC: \(taskData.idInicioDeConcatenacionEnrolamientoC ?? "nil")")
        print("🔍 [ElementsView] progress (cumplimiento): \(progress)%")
        print("🔍 [ElementsView] allActivities.records count: \(allActivities.records?.count ?? 0)")
        
        // Actualizar contexto de navegación
        navigationState.updateContext(taskId: taskId)
        
        // ✅ PROTECCIÓN #1: Si la tarea está completa al 100%, NO auto-navegar
        // Según Android (líneas 183-187): Solo auto-navega si porcentajeCumplimiento < 100
        // Esto permite que el usuario entre manualmente en modo revisión
        if progress >= 100 {
            print("🛑 [ElementsView] Tarea ya completa al 100% - mostrando vista sin navegación automática")
            print("   El usuario debe seleccionar manualmente una actividad para revisar")
            print("   📋 Mostrando lista de \(allActivities.records?.count ?? 0) actividades")
            
            // Desactivar loading inmediatamente
            self.isLoadingTasks = false
            print("✅ [ElementsView] Loading desactivado - Tarea completa, lista visible")
            return
        }
        
        // CAMINO B: Si debe saltar directo a la concatenación (cuestionario)
        // Solo si la tarea NO está completa al 100%
        if let _ = taskData.idInicioDeConcatenacionEnrolamientoC,
           taskData.saltarListaDeActividadesC == true {
            
            // Verificar si hay actividades pendientes usando isActivityCompleted
            if let activities = allActivities.records {
                for activity in activities {
                    let completa = isActivityCompleted(activity)
                    
                    if !completa {
                        print("🎯 [ElementsView] CAMINO B: Navegando directamente al cuestionario de concatenación")
                        print("   - Actividad pendiente: \(activity.nombreC ?? "Sin nombre")")
                        print("   - Completa: \(completa)")
                        
                        // Navegar al cuestionario
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.navigateToQuestions = true
                            self.isQuestionnaire = true
                            
                            // ✅ LOADING SE DESACTIVA DESPUÉS DE NAVEGAR
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.isLoadingTasks = false
                                print("✅ [ElementsView] Loading desactivado - Camino B completado")
                            }
                        }
                        return
                    }
                }
            }
        }
        
        // CAMINO A: Mostrar lista normal de actividades
        print("📋 [ElementsView] CAMINO A: Mostrando lista de actividades normal")
        print("   - Total actividades: \(allActivities.records?.count ?? 0)")
        
        // ✅ DESACTIVAR LOADING inmediatamente para que se vea la lista
        self.isLoadingTasks = false
        print("✅ [ElementsView] Loading desactivado - Lista de actividades visible")
    }
    
    // ✅ NUEVA FUNCIÓN: Marcar actividad como completada al 100%
    func markActivityAsCompleted(activityId: String) {
        print("✅ Actividad \(activityId) completada al 100%")
        // Aquí se puede agregar lógica adicional si es necesario
        // Por ejemplo, actualizar el progreso en tiempo real
    }
    
}

enum AlertAuthElements: Identifiable{
    var id: Int{
        hashValue
    }
    case SuccesSendData
    case FailSendData
    case ImgError
    case NothingToSend
    case CompleteTask
}
