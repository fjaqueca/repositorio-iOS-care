//
//  ProgramStagesView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 12/04/2023.
//

import SwiftUI

// MARK: - Loading View Helper
/*private struct CenteredLoadingView: View {
    var body: some View {
        ZStack {
            // ✅ Fondo blanco/del sistema para ocultar completamente el contenido
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                    .padding()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}*/

struct StagesView: View {
    let programId: String
    let puntosActivos: Bool
    let puntosObtener: Float
    let puntosAcumulados: Float
    // ✅ Nuevo: arrancar con overlay para transiciones limpias
    let startWithOverlay: Bool

    @State var stages: Stages? = nil
    @State private var isLoading: Bool = true
    @State var navigateToTaskView: Bool = false
    // ✅ Nuevo: overlay de pantalla completa (fondo + spinner)
    @State private var showOverlay: Bool = false
    // ✅ Bandera para controlar si es la primera carga (para navegación automática)
    @State private var isFirstLoad: Bool = true
    // ✅ Task de carga para poder cancelarla si es necesario
    @State private var loadTask: Task<Void, Never>? = nil
    
    // ✅ NUEVO: Recibir estado de navegación del padre
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        ZStack {
            // ✅ NUEVO: Solo mostrar contenido cuando NO esté cargando
            if !isLoading && !showOverlay {
                VStack(spacing: 0) {
                    Divider()
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack(alignment: .center) {
                                Text("Etapas")
                                    .font(.appSubhead)
                                    .foregroundColor(.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if puntosActivos {
                                    Spacer()

                                    PointsChipView(
                                        current: Int(puntosAcumulados),
                                        total: Int(puntosObtener)
                                    )

                                }

                            }
                            
                            if let stages = stages {
                                ForEach(stages.records, id: \.self) { stage in
                                    StageRowView(
                                        stage: stage,
                                        programID: programId,
                                        puntosActivos: puntosActivos,
                                        puntosObtener: puntosObtener,
                                        puntosAcumulados: puntosAcumulados,
                                        puntosObtenerEtapa: stage.puntosAObtenerC ?? 0.0,
                                        puntosAcumuladosEtapa: stage.puntosAcumuladosC ?? 0.0
                                    )
                                    .environmentObject(navigationState)  // ✅ PASAR ESTADO A StageRowView
                                }
                            }
                        }
                        .padding(.margin)
                    }
                    // Navegación programática
                    .navigationLink(isActive: $navigateToTaskView) {
                        if let stageRecords = stages?.records {
                            TasksView(
                                totalTask: stageRecords.first?.cantDeTareasC,
                                stageTitle: stageRecords.first?.nombrePersonalizadoC ?? "",
                                stageId: stageRecords.first?.Id ?? "",
                                stageDescription: stageRecords.first?.Description ?? "",
                                percentage: Float(stageRecords.first?.cumplimientoDeLaEtapaC ?? 0),
                                minimum: Int(stageRecords.first?.minimoParaEtapaCumplidaC ?? 0),
                                program_id: programId,
                                puntosActivos: puntosActivos,
                                puntosObtener: puntosObtener,
                                puntosAcumulados: puntosAcumulados,
                                puntosObtenerEtapa: stageRecords.first?.puntosAObtenerC ?? 0.0,
                                puntosAcumuladosEtapa: stageRecords.first?.puntosAcumuladosC ?? 0.0
                            )
                            .environmentObject(navigationState)  // ✅ PASAR ESTADO
                        }
                    }
                }
            }
            
            // ✅ LOADING: Pantalla completa con solo el spinner, SIN contenido debajo
            if isLoading || showOverlay {
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
        // ✅ CLAVE: .onAppear se ejecuta CADA VEZ que la vista entra en pantalla
        .onAppear {
            print("👁️ [StagesView] onAppear")
            print("🔍 [StagesView] backEtapas: \(navigationState.backEtapas)")
            print("🔍 [StagesView] isFirstLoad: \(isFirstLoad)")
            print("🔍 [StagesView] shouldReloadEtapas: \(navigationState.shouldReloadEtapas)")
            
            // ✅ SI VIENE DE MODO REVISIÓN CON CAMBIOS, RECARGAR DATOS
            if navigationState.shouldReloadEtapas {
                print("🔄 [StagesView] Recarga solicitada desde modo revisión")
                navigationState.shouldReloadEtapas = false // Resetear flag
                isFirstLoad = false // Evitar auto-skip después de revisión
            }
            
            // Arrancar con overlay si viene desde ElementDetailsView
            showOverlay = startWithOverlay
            refreshData()
        }
        .onDisappear {
            // ✅ Cancelar task de carga si la vista se desmonta
            loadTask?.cancel()
            
            // ✅ MARCAR QUE VIENE DE BACK NAVIGATION si navegó automáticamente
            if !isFirstLoad && stages?.totalSize == 1 {
                print("🔙 [StagesView] Posible back navigation - Preparando para evitar auto-skip")
            }
        }
        // ✅ Cuando se activa la navegación a TasksView, desactivamos el loading
        .onChange(of: navigateToTaskView) { active in
            if active {
                // Desactivamos el loading al navegar a TasksView
                isLoading = false
                showOverlay = false
                print("⏩ [StagesView] Navegando a TasksView - Loading desactivado")
            }
        }
    }
    
    /// Encapsulamos la llamada en una función para mantener limpio el onAppear
    private func refreshData() {
        isLoading = true
        getStages()
    }

    private func getStages() {
        // Cancelar task anterior si existe
        loadTask?.cancel()
        
        loadTask = Task {
            print("🔍 [StagesView] Fetching stages para programa: \(programId)")
            print("🔍 [StagesView] puntosActivos: \(puntosActivos)")
            
            let result = await Network.shared.getStages(progamId: programId)
            
            // ✅ Verificar si la tarea fue cancelada
            if Task.isCancelled {
                print("⚠️ [StagesView] Request cancelado - Vista desmontada")
                return
            }
            
            switch result {
            case let .success(listStage):
                self.stages = listStage
                
                print("✅ [StagesView] Etapas cargadas: \(listStage.totalSize ?? 0)")
                
                // ✅ LÓGICA DE AUTO-NAVEGACIÓN CON TODAS LAS CONDICIONES DE ANDROID
                // Condiciones:
                // 1. Solo 1 etapa (totalSize == 1)
                // 2. Mostrar_Si_Es_Un_Solo_Registro__c == false
                // 3. NO viene de back navigation (backEtapas == false)
                // 4. Es la primera carga (isFirstLoad == true)
                
                if listStage.totalSize == 1,
                   let stage = listStage.records.first,
                   stage.mostrarSiEsUnSoloRegistroC == false,
                   !navigationState.backEtapas,
                   isFirstLoad {
                    
                    print("🎯 [StagesView] AUTO-SKIP activado:")
                    print("   - Solo 1 etapa")
                    print("   - Mostrar_Si_Es_Un_Solo_Registro__c = false")
                    print("   - backEtapas = false")
                    print("   - Navegando directamente a TasksView...")
                    
                    // Actualizar contexto de navegación
                    navigationState.updateContext(stageId: stage.Id)
                    
                    // Marcar que ya no es la primera carga
                    isFirstLoad = false
                    
                    // Navegar a TasksView
                    // El loading se mantiene activo y se desactivará en TasksView
                    goTask()
                    return
                }
                
                // ✅ Si NO cumple condiciones de auto-skip, mostrar lista normal
                if listStage.totalSize == 1 {
                    print("📋 [StagesView] Mostrando lista (1 etapa pero no cumple condiciones de auto-skip)")
                } else {
                    print("📋 [StagesView] Mostrando lista (\(listStage.totalSize ?? 0) etapas)")
                }
                
                self.isLoading = false
                self.showOverlay = false
                
            case let .failure(error):
                // ✅ Solo mostrar error si no fue una cancelación explícita
                // Alamofire usa AFError.explicitlyCancelled para cancelaciones
                let errorDescription = "\(error)"
                if !errorDescription.contains("explicitlyCancelled") && !errorDescription.contains("cancelled") {
                    print("❌ [StagesView] Error cargando etapas: \(error)")
                    AppStatusManager.error(error)
                } else {
                    print("⚠️ [StagesView] Request cancelado - ignorando error")
                }
                self.isLoading = false
                self.showOverlay = false
            }
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

    
    func goTask() {
        self.navigateToTaskView = true
    }
}
