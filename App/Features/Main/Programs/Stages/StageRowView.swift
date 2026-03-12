//
//  ProgramStageRowView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 13/04/2023.
//

import SwiftUI

struct StageRowView: View {
    @State private var isPresentingDetails = false
    let stage: Stages.Stage
    @State var porsentajeTotal: Float = 0
    @State var showAlert: Bool = false
    @State var statusStage: String?
    
    //let onRefreshStage: () -> Void
    
    let programID: String
    let puntosActivos: Bool
    let puntosObtener: Float
    let puntosAcumulados: Float
    let puntosObtenerEtapa: Float
    let puntosAcumuladosEtapa: Float
    
    // ✅ NUEVO: Recibir estado de navegación del padre
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        Button(action: {
            // Permitir entrar tanto En Curso como Completo
            if statusStage == "En Curso" || statusStage == "Completo" {
                isPresentingDetails.toggle()
            }
        }) {
            VStack {
                HStack {
                    Text(stage.nombrePersonalizadoC ?? "Sin nombre")
                        .font(.appCaptionMedium)
                        .foregroundColor(.primaryText)
                    Spacer()
                    Text(stage.estadoC ?? "")
                        .font(.appCaptionMedium)
                        .foregroundColor(.primaryText)
                }
                .onAppear {
                    // Preparar animación: arrancar en 0 y luego animar al valor real
                    porsentajeTotal = 0
                    statusStage = stage.estadoC ?? "No Iniciado"
                    let target = stage.cumplimientoDeLaEtapaC ?? 0.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeInOut(duration: 1.2)) {
                            porsentajeTotal = target
                        }
                    }
                }
                .onChange(of: stage.cumplimientoDeLaEtapaC) { newValue in
                    // Cuando el modelo se refresca al volver desde ElementDetailsView
                    let target = newValue ?? 0.0
                    withAnimation(.easeInOut(duration: 1.2)) {
                        porsentajeTotal = target
                    }
                }
                
                HStack {
                    Text("\(Int(stage.cantDeTareasC ?? 0.0)) tareas")
                        .font(.appCaption)
                        .foregroundColor(.buttonPrimaryBackground)
                    Spacer()
                    
                    if puntosActivos {
                        Text("\(Int(stage.puntosAcumuladosC ?? 0.0))/\(Int(stage.puntosAObtenerC ?? 0.0))pts")
                            .font(.appCaption)
                            .foregroundColor(.buttonPrimaryBackground)
                    }
                }
                ProgressView(value: CGFloat(porsentajeTotal) / 100.0)
                    .progressViewStyle(
                        AnimatedIconProgressViewStyle(
                            icon: "timer",               // ícono SF Symbol
                            progressColor: .primaryText,
                            trackColor: .gray.opacity(0.15),
                            height: 8,
                            cornerRadius: 4,
                            colorTextPercentage: .primaryText,
                            showIcon: false
                        )
                    )
                    .animation(.easeInOut(duration: 1.2), value: porsentajeTotal)
                .frame(height: 10)
            }
            .padding(.margin)
            .frame(height: 75)
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.grayLight, lineWidth: 1)
                    .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
            )
            .navigationLink(isActive: $isPresentingDetails) {
                TasksView(
                    totalTask: stage.cantDeTareasC,
                    stageTitle: stage.nombrePersonalizadoC ?? "",
                    stageId: stage.Id ?? "",
                    stageDescription: stage.Description ?? "",
                    percentage: porsentajeTotal,
                    minimum: Int(stage.minimoParaEtapaCumplidaC ?? 0),
                    program_id: programID,
                    puntosActivos: puntosActivos,
                    puntosObtener: puntosObtener,
                    puntosAcumulados: puntosAcumulados,
                    puntosObtenerEtapa: puntosObtenerEtapa,
                    puntosAcumuladosEtapa: puntosAcumuladosEtapa
                )
                .environmentObject(navigationState)  // ✅ PASAR ESTADO
            }
        }
        .opacity((stage.estadoC == "En Curso" || stage.estadoC == "Completo") ? 1 : 0.5)
    }
    
    
    struct AnimatedIconProgressViewStyle: ProgressViewStyle {
        
        var icon: String
        var progressColor: Color
        var trackColor: Color
        var height: CGFloat
        var cornerRadius: CGFloat
        var showPercentage: Bool = true
        var colorTextPercentage: Color
        var showIcon: Bool = true

        func makeBody(configuration: Configuration) -> some View {
            
            let progress = configuration.fractionCompleted ?? 0
                    
            // Ícono dinámico:
            let displayedIcon = progress >= 1.0 ? "checkmark.circle.fill" : icon
            let currentProgressColor = progress >= 1.0 ? Color.green : progressColor
            
            HStack(spacing: 10) {
                
                if showIcon {
                    // Ícono a la izquierda
                    Image(systemName: displayedIcon)
                        .foregroundColor(currentProgressColor)
                        .font(.system(size: height * 1.4))
                }
                
                GeometryReader { geo in
                    let progress = CGFloat(configuration.fractionCompleted ?? 0)
                    
                    ZStack(alignment: .leading) {
                        
                        // Fondo del track
                        Rectangle()
                            .fill(trackColor)
                            .frame(height: height)
                            .cornerRadius(cornerRadius)
                        
                        // Barra de progreso
                        Rectangle()
                            .fill(currentProgressColor)
                            .frame(width: geo.size.width * progress,
                                   height: height)
                            .cornerRadius(cornerRadius)
                            .animation(.easeInOut(duration: 1.2), // ← animación suave
                                       value: progress)
                    }
                }
                .frame(height: height)
                
                // Porcentaje a la derecha
                if showPercentage {
                    Text("\(Int((configuration.fractionCompleted ?? 0) * 100))%")
                        .foregroundColor(colorTextPercentage)
                        .font(.system(size: height * 1.3, weight: .bold))
                        .animation(.easeInOut, value: configuration.fractionCompleted)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
