//
//  ChangelogSheetView.swift
//  CareAssistance
//
//  Created on 07/05/2026.
//

import SwiftUI

struct ChangelogEntry: Identifiable {
    let id = UUID()
    let version: String
    let date: String
    let changes: [String]
}

extension ChangelogEntry {
    static let allEntries: [ChangelogEntry] = [
        ChangelogEntry(
            version: "2.4.5",
            date: "11 de mayo, 2026",
            changes: [
                "Nuevo diseño premium en toda la aplicación con animaciones y transiciones suaves",
                "Rediseño visual de la vista de detalle de cita con cards elevadas y badge de estado",
                "Nuevo diseño de las tarjetas de citas agendadas en la agenda",
                "Rediseño del perfil con secciones agrupadas estilo iOS",
                "Popup de cancelar cita y confirmaciones modernizados con botones premium",
                "Animaciones de entrada en todas las secciones de la app",
                "Feedback táctil (vibración) en todos los botones y acciones",
                "Nuevas animaciones Lottie en la pantalla de bienvenida",
                "Soporte para GIF animados en el onboarding",
                "Skeleton loading mejorado en todas las vistas de carga",
                "Chip 'Ver todo' renovado en el inicio",
                "Opción para calificar la app desde el perfil",
                "Solicitud inteligente de calificación en el App Store al completar un logro",
                "Shake visual al detectar cita duplicada",
                "Nuevo Lottie exclusivo para grupo familiar sin cargas"
            ]
        ),
        ChangelogEntry(
            version: "2.4.4",
            date: "6 de mayo, 2026",
            changes: [
                "Correcciones de estabilidad general",
                "Mejoras en la sección de perfil de usuario",
                "Optimización del rendimiento de la aplicación"
            ]
        ),
        ChangelogEntry(
            version: "2.4.0",
            date: "27 de abril, 2026",
            changes: [
                "Nuevo diseño visual en citas médicas",
                "Mejoras en la sección de exámenes",
                "Actualización visual de recetas médicas",
                "Mejoras en la navegación de programas de salud",
                "Rediseño de la vista de material educativo",
                "Nuevo selector mejorado en formularios",
                "Mejoras visuales generales en toda la aplicación"
            ]
        ),
        ChangelogEntry(
            version: "2.1.0",
            date: "23 de abril, 2026",
            changes: [
                "Nueva funcionalidad de exámenes automatizados",
                "Gestión de grupo familiar mejorada",
                "Interfaz personalizada según tu empresa",
                "Nuevo flujo de eliminación de exámenes con confirmación",
                "Mejoras en el envío de órdenes de exámenes",
                "Mejoras generales de usabilidad"
            ]
        ),
    ]
}

struct ChangelogSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var headerAppeared: Bool = false
    @State private var cardAppeared: [Bool] = Array(repeating: false, count: ChangelogEntry.allEntries.count)
    @State private var sparklePhase: Int = 0
    @State private var badgeStartDate: Date = Date()

    private let tealGradient = LinearGradient(
        colors: [Color(hex: "#0095B3"), Color(hex: "#00BBDC"), Color(hex: "#33CFEA")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    changelogHeader
                        .padding(.bottom, 8)

                    ForEach(Array(ChangelogEntry.allEntries.enumerated()), id: \.element.id) { index, entry in
                        versionCard(index: index, entry: entry)
                            .opacity(cardAppeared[index] ? 1 : 0)
                            .offset(y: cardAppeared[index] ? 0 : 20)
                            .scaleEffect(cardAppeared[index] ? 1 : 0.97)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "#F7F8FA"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onAppear {
                triggerStaggeredAnimations()
            }
        }
    }

    // MARK: - Header

    private var changelogHeader: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(tealGradient)
                    .frame(width: 40, height: 40)
                    .shadow(color: Color(hex: "#00BBDC").opacity(0.3), radius: 6, x: 0, y: 3)

                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(sparklePhase == 1 ? 20 : 0))
                    .scaleEffect(sparklePhase == 0 ? 1.2 : (sparklePhase == 2 ? 1.0 : 1.05))
            }
            .scaleEffect(headerAppeared ? 1 : 0.5)
            .opacity(headerAppeared ? 1 : 0)
            .onAppear {
                startSparkleLoop()
            }

            Text("Novedades")
                .font(Font.custom("FiraSans-Bold", size: 22))
                .foregroundColor(Color(hex: "#2C3E50"))
                .opacity(headerAppeared ? 1 : 0)

            Text("Historial de actualizaciones")
                .font(Font.custom("FiraSans-Regular", size: 13))
                .foregroundColor(Color(hex: "#8A9199"))
                .opacity(headerAppeared ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Version Card

    private func versionCard(index: Int, entry: ChangelogEntry) -> some View {
        let isLatest = index == 0

        return VStack(alignment: .leading, spacing: 14) {
            // Header: version pill + badge + fecha
            HStack(alignment: .center) {
                // Version pill
                Text("v\(entry.version)")
                    .font(Font.custom("FiraSans-Bold", size: 13))
                    .foregroundColor(isLatest ? .white : Color(hex: "#0095B3"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isLatest ? AnyShapeStyle(tealGradient) : AnyShapeStyle(Color(hex: "#E6F9FC")))
                    )

                // Badge "Nuevo" con gradiente animado (dos paletas desfasadas)
                if isLatest {
                    AnimatedBadgeNuevo(startDate: badgeStartDate)
                }

                Spacer()

                Text(entry.date)
                    .font(Font.custom("FiraSans-Regular", size: 12))
                    .foregroundColor(Color(hex: "#8A9199"))
            }

            // Lista de cambios
            VStack(alignment: .leading, spacing: 10) {
                ForEach(entry.changes, id: \.self) { change in
                    HStack(alignment: .top, spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#E6F9FC"))
                                .frame(width: 20, height: 20)
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(hex: "#00BBDC"))
                        }
                        .padding(.top, 1)

                        Text(change)
                            .font(Font.custom("FiraSans-Regular", size: 14))
                            .foregroundColor(Color(hex: "#5B6770"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Animations

    private func startSparkleLoop() {
        // Fase 0: crece (scale 1.2)
        // Fase 1: gira (rotation 20°, scale 1.05)
        // Fase 2: se asienta (scale 1.0, rotation 0°)
        // Pausa: respira 450ms → reinicia

        func nextPhase() {
            // Crece
            withAnimation(.easeOut(duration: 0.4)) {
                sparklePhase = 0
            }
            // Gira
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    sparklePhase = 1
                }
            }
            // Se asienta
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.35)) {
                    sparklePhase = 2
                }
            }
            // Respira (pausa) → reinicia
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                nextPhase()
            }
        }

        // Iniciar después de la animación de entrada
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            nextPhase()
        }
    }

    private func triggerStaggeredAnimations() {
        // Header primero
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75, blendDuration: 0.2)) {
            headerAppeared = true
        }

        // Cards con stagger
        for i in cardAppeared.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 + 0.12 * Double(i)) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75, blendDuration: 0.2)) {
                    cardAppeared[i] = true
                }
            }
        }
    }
}

// MARK: - Badge "Nuevo" con gradiente animado (réplica del patrón Android)

/// Dos paletas de 6 colores desfasadas 2 posiciones, interpoladas en sRGB lineal.
/// Ciclo de 8s, linear, infinite restart — idéntico a Android ValueAnimator.ofArgb.
private struct AnimatedBadgeNuevo: View {
    let startDate: Date

    // Paleta base: Verde → Celeste → Azul → Morado → Rosa → Naranja
    private static let palette: [(r: Double, g: Double, b: Double)] = [
        (0x34, 0x99, 0x5E),  // #34995E Verde
        (0x00, 0xBB, 0xDC),  // #00BBDC Celeste
        (0x4A, 0x90, 0xE2),  // #4A90E2 Azul
        (0x9B, 0x59, 0xB6),  // #9B59B6 Morado
        (0xE9, 0x1E, 0x63),  // #E91E63 Rosa
        (0xFF, 0x98, 0x00),  // #FF9800 Naranja
    ]

    private static let cycleDuration: Double = 8.0
    private static let colorCount: Int = 6
    private static let offsetB: Int = 2  // Desfase de paleta B

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            let progress = (elapsed.truncatingRemainder(dividingBy: Self.cycleDuration)) / Self.cycleDuration
            let colorA = Self.interpolatedColor(progress: progress, offset: 0)
            let colorB = Self.interpolatedColor(progress: progress, offset: Self.offsetB)

            Text("Nuevo")
                .font(Font.custom("FiraSans-Medium", size: 11))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [colorA, colorB],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
    }

    /// Interpola el color en la paleta rotada por `offset`, dado un progreso 0…1.
    /// Réplica exacta de ArgbEvaluator de Android: interpolación canal por canal en sRGB.
    private static func interpolatedColor(progress: Double, offset: Int) -> Color {
        let totalSegments = Double(colorCount)
        let scaled = progress * totalSegments
        let segmentIndex = Int(scaled) % colorCount
        let fraction = scaled - Double(Int(scaled))

        let fromIndex = (segmentIndex + offset) % colorCount
        let toIndex = (segmentIndex + offset + 1) % colorCount

        let from = palette[fromIndex]
        let to = palette[toIndex]

        // Interpolación lineal sRGB canal por canal (igual que ArgbEvaluator)
        let r = (from.r + (to.r - from.r) * fraction) / 255.0
        let g = (from.g + (to.g - from.g) * fraction) / 255.0
        let b = (from.b + (to.b - from.b) * fraction) / 255.0

        return Color(red: r, green: g, blue: b)
    }
}
