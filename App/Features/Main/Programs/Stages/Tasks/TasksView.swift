//
//  StagesTasksView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 13/04/2023.
//

import SwiftUI

// MARK: - Loading View Helper
/*private struct CenteredLoadingView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ProgressView()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}*/

struct TasksView: View {
    @Environment(\.presentationMode) var presentationMode
    let totalTask: Float?
    let stageTitle: String
    let stageId: String
    let stageDescription: String
    @State var isLoadingTasks: Bool = true
    @State var isLoadingStages: Bool = true
    @State var isLoadingFavorite: Bool = false
    @State var goals: [StageGoalsActivityComplition] = []
    @State var navigateToElementsView: Bool = false
    @State var onlyOneTask: Goals.Goal?
    @State var percentage: Float = 0.0
    @State var minimum: Int
    let program_id: String
    let puntosActivos: Bool
    let puntosObtener: Float
    let puntosAcumulados: Float
    @State var puntosObtenerEtapa: Float
    @State var puntosAcumuladosEtapa: Float
    @State var isFavorite: Bool = false
    @State var stages2: Stages? = nil
    @State private var showAlert: Bool = false
    let progressColor: Color = .primaryText
    
    // Índice de la etapa seleccionada (derivado de stageId)
    @State private var selectedStageIndex: Int = 0
    // Índice calculado de “etapa actual” (se mantiene si lo necesitas en otra lógica)
    @State var etapaActual: Int = 0
    
    // ✅ Control de navegación automática
    @State private var hasCheckedAutoNavigation: Bool = false
    @State private var shouldAutoNavigate: Bool = false

    // ✅ Evita que .task{} y onAppear lancen refreshData() simultáneamente.
    // Se pone a true en la primera ejecución de refreshData() y solo se resetea
    // cuando el flujo lo requiere explícitamente (ej: shouldDismissToTasks).
    @State private var isRefreshing: Bool = false
    
    // ✅ NUEVO: Recibir estado de navegación del padre
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Divider()
                ScrollView {
                    // ✅ MOSTRAR LOADING MIENTRAS SE CARGA O MIENTRAS SE DECIDE AUTO-NAVEGACIÓN
                    if isLoadingTasks || shouldAutoNavigate {
                        // Placeholder para mantener el ScrollView activo
                        Color.clear
                            .frame(height: 100)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(stageTitle)
                                .font(.appSubhead)
                                .foregroundColor(.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(stageDescription)
                                .font(.appCaptionLarge)
                                .foregroundColor(.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                //.padding(.top, 15)
                            
                            if !isLoadingStages {
                                progressView
                                    .padding(.vertical, .margin)
                            }
                            
                            HStack(alignment: .center) {
                                Text("Lista de tareas")
                                    .font(.appSubhead)
                                    .foregroundColor(.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, .margin)
                                
                                if puntosActivos {
                                    Spacer()

                                    PointsChipView(
                                        current: Int(puntosAcumuladosEtapa),
                                        total: Int(puntosObtenerEtapa)
                                    )

                                }

                            }
                            
                            
                            if goals.isEmpty {
                                VStack(spacing: 12) {
                                    LottieView(animationName: "Empty_Box")
                                        .frame(width: 200, height: 200)
                                    Text("No se encontraron tareas")
                                        .font(Font.custom("FiraSans-Bold", size: 19))
                                        .foregroundColor(Color(hex: "#5B6770"))
                                    Text("No hay tareas disponibles en esta etapa")
                                        .font(Font.custom("FiraSans-Regular", size: 15))
                                        .foregroundColor(Color(hex: "#C4C4C4"))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .popIn()
                            } else {
                                ForEach(goals, id: \.self) { tasks in
                                    ForEach(tasks.records, id: \.self) { task in
                                        ForEach(Array(task.goalsR.records.enumerated()), id: \.element) { index, t in
                                            TaskRowView(
                                                task: t,
                                                isLoadingFavorite: $isLoadingFavorite,
                                                isLoadingTasks: $isLoadingTasks,
                                                programId: program_id,
                                                puntosActivos: puntosActivos,
                                                puntosObtener: puntosObtener,
                                                puntosAcumulados: puntosAcumulados
                                            )
                                            .environmentObject(navigationState)
                                            .pressable()
                                            .springOnAppear(delay: Double(index) * 0.05)
                                            .onAppear {
                                                self.isFavorite = t.favoritoAppC ?? false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.margin)
                    }
                }
            }
            .navigationLink(isActive: $navigateToElementsView) {
                ForEach(goals, id: \.self) { tasks in
                    ForEach(tasks.records, id: \.self) { task in
                        ForEach(task.goalsR.records, id: \.self) { t in
                            if let activities = t.actividadesR {
                                ElementsView(
                                    totalActivities: Int(t.cantDeElementosPorTareaC ?? 0.0),
                                    taskTitle: t.nombrePersonalizadoC ?? "",
                                    taskId: t.Id ?? "",
                                    taskData: t,
                                    allActivities: activities,
                                    progress: Int(t.cumplimientoDeLaTareaC ?? 0),
                                    isFavorite: $isFavorite,
                                    isLoadingTasks: $isLoadingTasks,
                                    programa_id: program_id,
                                    puntosActivos: puntosActivos,
                                    puntosObtener: puntosObtener,
                                    puntosAcumulados: puntosAcumulados,
                                    stages: stages2
                                )
                                .environmentObject(navigationState)  // ✅ PASAR ESTADO
                            }
                        }
                    }
                }
            }
            .blur(radius: isLoadingFavorite ? 3 : 0.000001)
            
            // ✅ Loading centralizado para operaciones de favoritos
            if isLoadingFavorite {
                CenteredLoadingView()
            }
            
            // ✅ Loading: Skeleton mientras carga tareas
            if isLoadingTasks || shouldAutoNavigate {
                VStack {
                    SkeletonList(rows: 4)
                        .padding(.top, 20)
                    Spacer(minLength: 0)
                }
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
        .task {
            // ⚠️ NO llamar refreshData() aquí.
            // onAppear se ejecuta siempre justo después de .task en la carga inicial,
            // lo que causaba que refreshData() se lanzara DOS veces en paralelo y
            // una de las requests de red fuera cancelada con explicitlyCancelled.
            // Toda la lógica de carga vive en onAppear para tener un único punto de entrada.
            print("📱 TasksView - .task ejecutado (solo log, la carga ocurre en onAppear)")
        }
        .onAppear {
            let isFirstLoad = !hasCheckedAutoNavigation && goals.isEmpty
            print("👁️ [TasksView] onAppear - \(isFirstLoad ? "📱 CARGA INICIAL" : "🔄 retorno de navegación")")
            print("🔍 [TasksView] shouldAutoNavigate: \(shouldAutoNavigate)")
            print("🔍 [TasksView] backTareas: \(navigationState.backTareas)")
            print("🔍 [TasksView] backFromTasks: \(navigationState.backFromTasks)")
            print("🔍 [TasksView] shouldReloadTareas: \(navigationState.shouldReloadTareas)")
            print("🔍 [TasksView] shouldDismissToTasks: \(navigationState.shouldDismissToTasks)")
            print("🔍 [TasksView] shouldDismissToStages: \(navigationState.shouldDismissToStages)")
            print("🔍 [TasksView] shouldReloadProgramas: \(navigationState.shouldReloadProgramas)")
            
            // ✅ FIX #2B: shouldDismissToTasks ahora se consume en ElementsView ANTES de llegar aquí.
            // Si de alguna forma llega aquí (edge case), lo consumimos sin hacer dismiss,
            // ya que TasksView ES el destino final y debe quedarse visible.
            if navigationState.shouldDismissToTasks {
                print("✅ [TasksView] shouldDismissToTasks residual detectado - Consumiendo y quedándose en TasksView")
                navigationState.shouldDismissToTasks = false
                self.isLoadingTasks = false
                self.hasCheckedAutoNavigation = false
                self.isRefreshing = false
                Task {
                    await refreshData()
                }
                return
            }
            
            // ✅ NUEVO: Si debe volver a StagesView, hacer dismiss inmediato
            if navigationState.shouldDismissToStages {
                print("🔙 [TasksView] shouldDismissToStages detectado - Volviendo a StagesView")
                navigationState.shouldDismissToStages = false // Consumir el flag
                
                // Pequeño delay para que la UI se estabilice
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                return
            }
            
            // ✅ NUEVO: Si viene de completar la última actividad, volver a StagesView
            if navigationState.shouldReloadProgramas {
                print("🔙 [TasksView] Detectado shouldReloadProgramas - Volviendo a StagesView")
                navigationState.shouldReloadProgramas = false // Consumir el flag
                
                // Pequeño delay para que la UI se estabilice
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                return
            }
            
            // ✅ RESETEAR backFromTasks cuando volvemos a TasksView
            // Esto permite que si el usuario vuelve a entrar a ElementsView, la auto-navegación funcione correctamente
            if navigationState.backFromTasks {
                print("🔄 [TasksView] Reseteando backFromTasks - Usuario volvió a TasksView")
                navigationState.backFromTasks = false
            }
            
            // ✅ SI VOLVEMOS DE NAVEGACIÓN AUTOMÁTICA, PERMITIR QUE SE RECARGUE LA LISTA
            if shouldAutoNavigate {
                print("🔄 [TasksView] Regresando de auto-navegación - Resetear flags")
                shouldAutoNavigate = false
                isRefreshing = false  // Permitir nueva carga al volver del auto-skip
                // Activar backTareas aquí, ya que onDisappear no lo hizo durante el auto-skip
                navigationState.backTareas = true
                print("🔙 [TasksView] backTareas activado al regresar del auto-skip")
                // NO resetear hasCheckedAutoNavigation para evitar loop infinito
            } else if navigateToElementsView {
                // Viene de una navegación manual a ElementsView → activar backTareas
                isRefreshing = false  // Permitir recarga al volver de ElementsView manual
                navigationState.backTareas = true
                print("🔙 [TasksView] backTareas activado al regresar de ElementsView (manual)")
            }
            
            // ✅ SI VIENE DE MODO REVISIÓN CON CAMBIOS, RECARGAR DATOS
            if navigationState.shouldReloadTareas {
                print("🔄 [TasksView] Recarga solicitada desde modo revisión")
                navigationState.shouldReloadTareas = false // Resetear flag
                hasCheckedAutoNavigation = false // Permitir nueva verificación de auto-navegación
                isRefreshing = false // Permitir que refreshData() corra de nuevo
            }
            
            Task {
                await refreshData()
            }
        }
        .onDisappear {
            showAlert = false
            
            // ✅ SOLO marcar flags de back-navigation cuando el usuario navega
            // manualmente hacia adelante (TaskRowView). Si la salida fue por
            // auto-skip (shouldAutoNavigate == true) NO activamos backTareas
            // porque no es el usuario quien volvió atrás.
            if navigateToElementsView && !shouldAutoNavigate {
                print("🔙 [TasksView] Navegó a ElementsView (manual) - Marcando flags para evitar auto-navegación al volver")
                navigationState.resetForBackToTasks()
            } else if shouldAutoNavigate {
                print("🚀 [TasksView] Auto-skip activado - NO marcar backTareas para evitar bloqueo")
            }
        }
    }
    
    // MARK: - Helper para refrescar datos
    private func refreshData() async {
        // ✅ Guardia anti-duplicado: si ya hay una carga en curso, no lanzar otra.
        // Esto protege ante cualquier escenario donde onAppear se dispare más de
        // una vez antes de que la primera carga termine (ej: SwiftUI re-renders).
        guard !isRefreshing else {
            print("⏭️ [TasksView] refreshData() ya en curso - ignorando llamada duplicada")
            return
        }
        isRefreshing = true
        defer { isRefreshing = false }

        // ✅ Ejecutar stages y tasks en paralelo, esperando a que AMBAS terminen
        // antes de evaluar auto-navegación. Ninguna request queda "en vuelo"
        // cuando SwiftUI activa el push a ElementsView.
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.getStages() }
            group.addTask { await self.getTasksAsync() }
        }

        // ✅ Verificar auto-navegación SOLO después de que todas las requests
        // de red hayan completado exitosamente.
        await checkAutoNavigationToSingleActivity()
    }
    
    @ViewBuilder
    var progressView: some View {
        VStack {
            HStack {
                Text("Cumplimiento de Etapa")
                    .font(.appSmallMedium)
                    .foregroundColor(.primaryText)
                Spacer()
                Text("\(Int(stages2?.records[safe: selectedStageIndex]?.cumplimientoDeLaEtapaC ?? 0.0))%")
                    .font(.appSmallMedium)
                    .foregroundColor(.primaryText)
            }
            CustomAnimatedProgressView(
                colorFilled: progressColor,
                currentPercentage: (stages2?.records[safe: selectedStageIndex]?.cumplimientoDeLaEtapaC ?? 0.0) / 100
            )
        }
        .padding(.margin)
        .frame(height: 100)
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(Color.grayLight, lineWidth: 1)
                .shadow(color: .shadowLight, radius: 1, x: 1, y: 1)
        )
    }
    
    // MARK: - Funciones
    
    /// Versión async de getTasks para que pueda usarse con withTaskGroup y
    /// garantizar que TODAS las requests de red terminan antes de navegar.
    private func getTasksAsync() async {
        print("🔍 [TasksView] Fetching tareas para etapa: \(stageId)")
        print("🔍 [TasksView] puntosActivos: \(puntosActivos)")

        let result = await Network.shared.getTasks(stageId: stageId)

        switch result {
        case let .success(listTask):
            self.goals = listTask
            print("✅ [TasksView] Tareas cargadas")
            // La auto-navegación se evalúa después de que refreshData() complete,
            // es decir, cuando getStages() TAMBIÉN haya terminado.

        case let .failure(error):
            print("❌ [TasksView] Error cargando tareas: \(error)")
            AppStatusManager.error(error)
            self.isLoadingTasks = false
        }
    }

    // Wrapper para llamadas legacy que aún usan la firma sin async
    private func getTasks() {
        Task { await getTasksAsync() }
    }
    
    private func getStages() async {
        let result = await Network.shared.getStages(progamId: program_id)
        switch result {
        case let .success(listStage):
            self.stages2 = listStage

            // 1) Determinar índice de la etapa seleccionada por Id
            if let idx = listStage.records.firstIndex(where: { $0.Id == stageId }) {
                self.selectedStageIndex = idx
                
                // ✅ ACTUALIZAR los puntos de la etapa actual
                let currentStage = listStage.records[idx]
                self.puntosAcumuladosEtapa = currentStage.puntosAcumuladosC ?? 0.0
                self.puntosObtenerEtapa = currentStage.puntosAObtenerC ?? 0.0
            } else {
                self.selectedStageIndex = 0
            }

            // 2) Si aún quieres calcular “etapa actual” para otra lógica, puedes mantenerlo
            calcularEtapaActual()

            if listStage.records.count > 0 {
                showAlert = true
            }
            
            print("stages2:", stages2 ?? "")
            print("✅ Puntos actualizados - Acumulados: \(puntosAcumuladosEtapa), A obtener: \(puntosObtenerEtapa)")
            
        case let .failure(error):
            AppStatusManager.error(error)
        }
        self.isLoadingStages = false
    }
    
    private func calcularEtapaActual() {
        
        print("stages2?.records", stages2?.records ?? "-")
        
        guard let records = stages2?.records else {
            etapaActual = 0
            return
        }
        
        // Recorremos todas las etapas y buscamos la primera incompleta
        for (index, etapa) in records.enumerated() {
            let porcentaje = etapa.cumplimientoDeLaEtapaC ?? 0.0
            print("porcentaje", porcentaje)
            if porcentaje < 100.0 {
                etapaActual = index
                return
            }
            print("etapaActual", etapaActual)
        }
        
        
        // Si todas las etapas están completas, usamos la última
        etapaActual = max(records.count - 1, 0)

    }
    
    // ✅ NUEVA FUNCIÓN: Verificar si debe auto-navegar a una sola tarea
    @MainActor
    private func checkAutoNavigationToSingleActivity() async {
        // Solo verificar la primera vez que se carga la vista
        guard !hasCheckedAutoNavigation else {
            print("⏭️ [TasksView] Ya se verificó auto-navegación previamente")
            self.isLoadingTasks = false
            return
        }
        
        hasCheckedAutoNavigation = true
        
        // Contar el total de tareas
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
        
        print("📊 [TasksView] Total de tareas encontradas: \(totalTasks)")
        
        // ✅ VERIFICAR TODAS LAS CONDICIONES DE ANDROID:
        // 1. Solo 1 tarea (totalTasks == 1)
        // 2. Estado != "Completo"
        // 3. Mostrar_Si_Es_Un_Solo_Registro__c == false
        // 4. NO viene de back navigation (backTareas == false)
        
        if totalTasks == 1,
           let task = singleTask,
           task.estadoC != "Completo",
           task.mostrarSiEsUnSoloRegistroC == false,
           !navigationState.backTareas {
            
            print("🎯 [TasksView] AUTO-SKIP activado:")
            print("   - Solo 1 tarea")
            print("   - Estado: \(task.estadoC ?? "nil") (no es Completo)")
            print("   - Mostrar_Si_Es_Un_Solo_Registro__c = false")
            print("   - backTareas = false")
            print("   - Tarea: \(task.nombrePersonalizadoC ?? "Sin nombre")")
            print("   - Navegando automáticamente a ElementsView...")
            
            // Actualizar contexto de navegación
            navigationState.updateContext(taskId: task.Id)
            
            // Activar bandera para mantener loading visible
            self.shouldAutoNavigate = true
            self.onlyOneTask = task
            self.isFavorite = task.favoritoAppC ?? false
            
            // Pequeño delay para asegurar que la UI está lista
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
            
            // Activar navegación
            self.navigateToElementsView = true
            
            // El loading se desactivará cuando ElementsView haya decidido el camino (A o B)
            print("⏳ [TasksView] Loading mantenido activo hasta que ElementsView decida el camino")
            
        } else {
            // Hay 0 o más de 1 tarea, o no cumple condiciones - mostrar lista normal
            if totalTasks == 1 {
                print("📋 [TasksView] Mostrando lista (1 tarea pero no cumple condiciones de auto-skip)")
                if let task = singleTask {
                    print("   - Estado: \(task.estadoC ?? "nil")")
                    print("   - Mostrar_Si_Es_Un_Solo_Registro__c: \(task.mostrarSiEsUnSoloRegistroC ?? true)")
                    print("   - backTareas: \(navigationState.backTareas)")
                }
            } else {
                print("📋 [TasksView] Mostrando lista normal de tareas (\(totalTasks) tareas)")
            }
            
            self.shouldAutoNavigate = false
            self.isLoadingTasks = false
        }
    }
    
    func goElementView() {
        self.navigateToElementsView.toggle()
    }
}

struct PointsChipView: View {
    let current: Int
    let total: Int

    var body: some View {
        Text("\(current)/\(total) pts")
            .font(.caption.weight(.semibold))
            .foregroundColor(.primaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.primaryText.opacity(0.15))
            )
            .accessibilityLabel("Puntos \(current) de \(total)")
    }
}

/*struct CustomAnimatedProgressView: View {
    
    @State private var progressAmount: Float = 0.0
    let barHeight: CGFloat = 9
    let cornerRadius: CGFloat = 4
    let colorFilled: Color
    let currentPercentage: Float
    
    
    var isCompleted: Bool {
            currentPercentage >= 1.0
        }

        var barColor: Color {
            isCompleted ? .green : colorFilled
        }
    
    var body: some View {
        
        HStack(spacing: 2) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(uiColor: .systemGray5))
                        .frame(height: barHeight)
                        .cornerRadius(cornerRadius)
                    
                    Rectangle()
                        .fill(barColor)
                        .frame(width: geometry.size.width * CGFloat(progressAmount), height: barHeight)
                        .cornerRadius(cornerRadius)
                }
            }
            .frame(height: barHeight)
            
            Text("\(Int(currentPercentage * 100))%")
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 40, alignment: .trailing)
            
        }
        //.padding()
        .padding(.horizontal)
        .padding(.vertical, 2) // 👈 AQUÍ estaba el espacio
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    progressAmount = currentPercentage
                }
            }
        }
        .onChange(of: currentPercentage) { newValue in
            // Animar cada vez que cambie el porcentaje
            withAnimation(.easeInOut(duration: 1.2)) {
                progressAmount = newValue
            }
        }
    }
}*/

struct CustomAnimatedProgressView: View {

    @State private var progressAmount: Float = 0.0

    let barHeight: CGFloat = 9
    let cornerRadius: CGFloat = 4
    let colorFilled: Color
    let currentPercentage: Float

    // MARK: - Estado
    private enum ProgressState {
        case notStarted
        case inProgress
        case completed
    }

    private var progressState: ProgressState {
        if currentPercentage <= 0 {
            return .notStarted
        } else if currentPercentage >= 1 {
            return .completed
        } else {
            return .inProgress
        }
    }

    // MARK: - Colores
    private var barColor: Color {
        progressState == .completed ? .green : colorFilled
    }

    private var iconColor: Color {
        switch progressState {
        case .notStarted:
            return .gray
        case .inProgress:
            return barColor
        case .completed:
            return .green
        }
    }

    // MARK: - Iconos
    private var iconName: String {
        switch progressState {
        case .notStarted:
            return "circle.dashed"
        case .inProgress:
            return "clock.arrow.circlepath"
        case .completed:
            return "checkmark.circle.fill"
        }
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {

            // Icono de estado
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 20)

            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {

                    Rectangle()
                        .fill(Color(uiColor: .systemGray5))
                        .frame(height: barHeight)
                        .cornerRadius(cornerRadius)

                    Rectangle()
                        .fill(barColor)
                        .frame(
                            width: geometry.size.width * CGFloat(progressAmount),
                            height: barHeight
                        )
                        .cornerRadius(cornerRadius)
                }
            }
            .frame(height: barHeight)

            // Porcentaje
            Text("\(Int(currentPercentage * 100))%")
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 40, alignment: .trailing)
        }
        //.padding(.horizontal)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    progressAmount = currentPercentage
                }
            }
        }
        .onChange(of: currentPercentage) { newValue in
            withAnimation(.easeInOut(duration: 1.2)) {
                progressAmount = newValue
            }
        }
    }
}


// Safe index accessor para evitar crashes si el índice no existe
private extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
