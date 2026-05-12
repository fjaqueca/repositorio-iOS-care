//
//  ProgramsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/04/2023.
//

import Foundation
import SwiftUI
import RealmSwift
import CachedAsyncImage

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

struct ProgramsView: View {
    var programIconUrl: String = ""
    @State var programs: Programs? = nil
    @State private var showFilterView: Bool = false
    @State var isLoading: Bool = true
    @State private var emptyStateReady: Bool = false

    var body: some View {
        NavigationViewCustom {
            VStack(spacing: 0) {
                Divider()

                let hasPrograms: Bool = {
                    guard let program = programs else { return false }
                    return !Array(program.records.filter {
                        ($0.estadoC == "En Curso" || $0.estadoC == "Completo" || $0.estadoC == "No Iniciado") && $0.ocultarListaProgramasC == false
                    }).isEmpty
                }()

                if isLoading {
                    // Branch A — Skeleton loading (visible desde frame 1)
                    VStack(spacing: 20) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonCard()
                        }
                    }
                    .padding(.margin)
                    .padding(.top, .margin)
                } else if hasPrograms {
                    // Branch B — Programas con cards
                    ScrollView {
                        VStack(spacing: 20) {
                            if let program = programs {
                                let visiblePrograms = Array(program.records.filter {
                                    ($0.estadoC == "En Curso" || $0.estadoC == "Completo" || $0.estadoC == "No Iniciado") && $0.ocultarListaProgramasC == false
                                })
                                ForEach(Array(visiblePrograms.enumerated()), id: \.element.id) { index, p in
                                    ProgramCard(program: p)
                                        .pressable()
                                        .springOnAppear(delay: Double(index) * 0.08)
                                }
                            }
                        }
                        .padding(.margin)
                    }
                    .padding(.top, .margin)
                } else {
                    // Branch C — Empty state animado
                    emptyStateView
                        .padding(.top, .margin)
                }
            }
            .fadeSlideIn(delay: 0.05, from: .bottom)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Mis Programas")
                        .font(Font.custom("FiraSans-Bold", size: 17))
                        .foregroundColor(.primaryText)
                }
            }
            .configureNavigation()
        }
        // Equivalente a onResume() de Android:
        // Se dispara CADA VEZ que la vista se vuelve visible
        // (entrada inicial, volver de detalle, cambiar de tab)
        .onAppear {
            showLoadingState()
            getPrograms()
        }
        .onDisappear {
            // Equivalente a onDetachedFromWindow — limpia animaciones
            emptyStateReady = false
        }
        .accentColor(.blue)
    }

    // MARK: - showLoadingState (paridad Android)
    // Resetea UI a estado loading antes de cada llamada.
    // En re-entradas la vista puede estar en branch B o C de la última visita,
    // acá la volvemos al estado loading.
    private func showLoadingState() {
        isLoading = true
        emptyStateReady = false
    }

    // MARK: - Empty State (paridad con Web/Android)
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            LottieView(animationName: "Empty_Box")
                .frame(width: 280, height: 280)
                .padding(.top, 30)

            if emptyStateReady {
                TypewriterText("Sin programas asociados",
                              font: "FiraSans-Bold", size: 19,
                              color: Color(hex: "#5B6770"),
                              speed: 0.07, showDots: false, delay: 0.3)

                TypewriterText("Aún no has hecho uso de tus programas disponibles",
                              font: "FiraSans-Regular", size: 15,
                              color: Color(hex: "#C4C4C4"),
                              speed: 0.06, showDots: true, delay: 1.8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popIn()
        .onAppear {
            // Solo activa typewriter cuando el empty state es visible en pantalla
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                emptyStateReady = true
            }
        }
    }

    // MARK: - loadData (paridad Android)
    // Equivalente a loadData() de Android: apaga skeleton y decide branch B o C.
    // Las animaciones del empty state se disparan SOLO cuando branch C se renderiza.
    func getPrograms() {
        Task {
            let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
            let programResult = await Network.shared.getPrograms(accountId: accountId)

            print("programResult:", programResult)

            await MainActor.run {
                switch programResult {
                case let .success(program):
                    self.programs = program
                    print("programs:", programs ?? "nill")

                case let .failure(error):
                    AppStatusManager.error(error)
                }
                // Skeleton OFF → SwiftUI evalúa hasPrograms → branch B o C
                self.isLoading = false
            }
        }
    }
}

