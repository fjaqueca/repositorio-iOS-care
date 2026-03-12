//
//  NavigationState.swift
//  CareAssistance
//
//  Created by AI Assistant on 13/02/2026.
//

import SwiftUI

/// Estado global de navegación para manejar flujos de auto-navegación
/// y evitar loops infinitos en el flujo: Programas → Etapas → Tareas → Actividades
@MainActor
class NavigationState: ObservableObject {
    
    // MARK: - Flags Anti-Loop
    
    /// Evita auto-skip infinito en Etapas al volver atrás desde TasksView
    @Published var backEtapas: Bool = false
    
    /// Evita auto-skip infinito en Tareas al volver atrás desde ElementsView/ActivitiesView
    @Published var backTareas: Bool = false
    
    /// Evita auto-navegación en ElementsView cuando el usuario navega hacia atrás desde otras vistas
    /// (Similar a opcionSeleccionada en Android - evita re-ejecutar checkAutoNavigationPath)
    @Published var backFromTasks: Bool = false
    
    /// Indica que se debe hacer dismiss hasta TasksView después de completar la última actividad
    @Published var shouldDismissToTasks: Bool = false
    
    /// Indica que se debe hacer dismiss hasta StagesView después de completar la última actividad
    @Published var shouldDismissToStages: Bool = false
    
    /// Indica que TareaFragment (ElementsView) debe recargar datos del servicio
    /// después de responder una actividad
    @Published var shouldReloadTareaFragment: Bool = false
    
    /// Indica que se debe recargar la lista de tareas al hacer resume
    @Published var shouldReloadTareas: Bool = false
    
    /// Indica que se debe recargar la lista de etapas al hacer resume
    @Published var shouldReloadEtapas: Bool = false
    
    /// Indica que se debe recargar la lista de programas al hacer resume
    @Published var shouldReloadProgramas: Bool = false
    
    // MARK: - Current Context IDs
    
    /// ID del programa actual (para tracking y debugging)
    @Published var currentProgramId: String?
    
    /// ID de la etapa actual
    @Published var currentStageId: String?
    
    /// ID de la tarea actual
    @Published var currentTaskId: String?
    
    /// ID de la actividad actual
    @Published var currentActivityId: String?
    
    // MARK: - Reset Methods
    
    /// Resetear TODOS los flags al entrar a un nuevo programa
    /// Se llama desde ProgramCard al tocar un programa
    func resetForNewProgram(programId: String) {
        print("🔄 [NavigationState] Reset completo para nuevo programa: \(programId)")
        backEtapas = false
        backTareas = false
        backFromTasks = false
        shouldDismissToTasks = false
        shouldDismissToStages = false
        shouldReloadTareaFragment = false
        shouldReloadTareas = false
        shouldReloadEtapas = false
        shouldReloadProgramas = false
        currentProgramId = programId
        currentStageId = nil
        currentTaskId = nil
        currentActivityId = nil
    }
    
    /// Resetear flags de tarea/actividad al volver a TasksView
    /// Mantiene el contexto de etapa
    func resetForBackToTasks() {
        print("🔙 [NavigationState] Volviendo a TasksView - Activando backTareas")
        backTareas = true
        backFromTasks = false  // Resetear al volver a tareas
        shouldReloadTareaFragment = false
        currentTaskId = nil
        currentActivityId = nil
    }
    
    /// Resetear flags de etapa al volver a StagesView
    func resetForBackToStages() {
        print("🔙 [NavigationState] Volviendo a StagesView - Activando backEtapas")
        backEtapas = true
        backTareas = false
        backFromTasks = false
        shouldReloadTareas = false
        currentStageId = nil
        currentTaskId = nil
        currentActivityId = nil
    }
    
    /// Marcar que se debe recargar datos después de responder una actividad
    func markForReload() {
        print("🔄 [NavigationState] Marcando para recarga de datos")
        shouldReloadTareaFragment = true
        shouldReloadTareas = true
        shouldReloadEtapas = true
    }
    
    /// Marcar que se debe recargar TODOS los niveles después de cambios en modo revisión
    func markForFullReload() {
        print("🔄 [NavigationState] Marcando para recarga COMPLETA de todos los niveles")
        shouldReloadTareaFragment = true
        shouldReloadTareas = true
        shouldReloadEtapas = true
        shouldReloadProgramas = true
    }
    
    /// Marcar recarga después de completar una actividad con "Terminar".
    /// A diferencia de markForFullReload(), NO activa shouldReloadProgramas,
    /// para que TasksView quede visible y recargue su lista en lugar de hacer dismiss.
    func markForReloadAfterTerminar() {
        print("🔄 [NavigationState] Marcando para recarga post-Terminar (TasksView queda visible)")
        shouldReloadTareaFragment = true
        shouldReloadTareas = true
        shouldReloadEtapas = true
        // shouldReloadProgramas = false → TasksView NO hace dismiss a StagesView
    }
    
    /// Actualizar el contexto de navegación actual
    func updateContext(stageId: String? = nil, taskId: String? = nil, activityId: String? = nil) {
        if let stageId = stageId {
            currentStageId = stageId
            print("📍 [NavigationState] Stage actual: \(stageId)")
        }
        if let taskId = taskId {
            currentTaskId = taskId
            print("📍 [NavigationState] Tarea actual: \(taskId)")
        }
        if let activityId = activityId {
            currentActivityId = activityId
            print("📍 [NavigationState] Actividad actual: \(activityId)")
        }
    }
    
    // MARK: - Debug Info
    
    /// Imprimir estado actual para debugging
    func printState() {
        print("""
        🔍 [NavigationState] Estado actual:
           - backEtapas: \(backEtapas)
           - backTareas: \(backTareas)
           - backFromTasks: \(backFromTasks)
           - shouldDismissToTasks: \(shouldDismissToTasks)
           - shouldDismissToStages: \(shouldDismissToStages)
           - shouldReloadTareaFragment: \(shouldReloadTareaFragment)
           - shouldReloadTareas: \(shouldReloadTareas)
           - shouldReloadEtapas: \(shouldReloadEtapas)
           - shouldReloadProgramas: \(shouldReloadProgramas)
           - Programa: \(currentProgramId ?? "nil")
           - Etapa: \(currentStageId ?? "nil")
           - Tarea: \(currentTaskId ?? "nil")
           - Actividad: \(currentActivityId ?? "nil")
        """)
    }
}
