//
//  ProgramCard.swift
//  CareAssistance
//
//  Created by Lara Dubs on 11/04/2023.
//

import SwiftUI
import CachedAsyncImage

// MARK: - Program Status Enum (Senior approach)
enum ProgramStatus: String {
    case noIniciado = "No Iniciado"
    case enCurso = "En Curso"
    case completo = "Completo"
    
    var iconName: String {
        switch self {
        case .noIniciado:
            return "circle.dashed"
        case .enCurso:
            return "timer"
        case .completo:
            return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .noIniciado:
            return Color(hex: "#94A3B8") // Azul profesional (contrasta con celeste)
        case .enCurso:
            return .yellow
        case .completo:
            return Color(hex: "#8CEEE2")
        }
    }
}

struct ProgramCard: View {
    let program: Program
    
    @State private var isPresentingStagesDetails: Bool = false
    @State private var showWebView = false
    
    // ✅ NUEVO: Estado de navegación compartido
    @StateObject private var navigationState = NavigationState()
    
    private let progressColorCard: Color = .yellow
    
    // Estado calculado (sin @State innecesario)
    private var status: ProgramStatus {
        ProgramStatus(rawValue: program.estadoC ?? "No Iniciado") ?? .noIniciado
    }

    var body: some View {
        Button {
            // ✅ RESETEAR FLAGS AL ENTRAR A UN NUEVO PROGRAMA
            navigationState.resetForNewProgram(programId: program.Id)
            navigationState.printState()
            
            isPresentingStagesDetails = true
            
            if status == .completo {
                openArchive()
            }
        } label: {
            VStack(spacing: 0) {
                
                // MARK: - Header Estado
                HStack(spacing: 8) {
                    Image(systemName: status.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(status.color)
                    
                    Text(program.estadoC ?? "Sin estado")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(status.color)
                    
                    Spacer()
                }

                // MARK: - Content
                VStack(spacing: 5) {
                    Group {
                        Text(program.nombrePersonalizadoC ?? "Sin nombre")
                            .padding(.top, 20)
                            .multilineTextAlignment(.leading)
                            .font(.appSubtitleBoldForProgramCard)

                        CustomAnimatedProgressView(
                            colorFilled: progressColorCard,
                            currentPercentage: (program.cumplimientoDelProgramaC ?? 0.0) / 100.0
                        )
                        .padding(.top, 15)

                        HStack {
                            Spacer()
                            
                            Text(program.healthcloudgaIsactiveC ?? true ? "" : "Ver informe")
                                .font(.appCaptionLarge)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                }
            }
        }
        .padding(.margin)
        .background {
            // ✅ Validar URL antes de intentar cargarla
            if let urlString = program.imagenProgramaMobileC,
               !urlString.isEmpty,
               let url = URL(string: urlString),
               url.scheme != nil { // Verificar que tenga un esquema válido (http, https, etc.)
                CachedAsyncImage(
                    url: url,
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    },
                    placeholder: {
                        Color.buttonPrimaryBackground
                    }
                )
            } else {
                // ✅ Mostrar color de fondo si no hay URL válida
                Color.buttonPrimaryBackground
            }
        }
        .cornerRadius(.cornerRadius)
        
        // MARK: - Navigation
        .navigationLink(isActive: $isPresentingStagesDetails) {
            StagesView(
                programId: program.Id,
                puntosActivos: program.puntosactivosC ?? false,
                puntosObtener: program.puntosAObtenerC ?? 0.0,
                puntosAcumulados: program.puntosAcumuladosC ?? 0.0,
                startWithOverlay: true
            )
            .environmentObject(navigationState)  // ✅ PASAR ESTADO DE NAVEGACIÓN
        }
        .sheet(isPresented: $showWebView) {
            SafariWebView(url: program.informeC ?? "")
        }
    }
    
    // MARK: - Helpers
    private func openArchive() {
        if let myUrl = program.informeC,
           let url = URL(string: myUrl),
           !url.absoluteString.isEmpty {
            showWebView.toggle()
        }
    }
}
