//
//  ConvenioLoadingDialog.swift
//  CareAssistance
//
//  Created by Care Assistance on 16/04/2026.
//

import SwiftUI

/// Dialog reutilizable "Cargando tu convenio" con engranaje animado + barra de progreso.
/// Paridad con Android ProgressBarDialog.kt — se usa en login, registro, selección
/// de empresa inicial y cambio de convenio desde perfil.
///
/// Uso:
/// ```
/// ConvenioLoadingDialog(isPresented: $show, shouldComplete: $complete) {
///     // acción post-cierre
/// }
/// ```
/// Para cerrar: setear `shouldComplete = true` → la barra va a 100% → se cierra solo.
struct ConvenioLoadingDialog: View {
    @Binding var isPresented: Bool
    /// Setear a `true` cuando el trabajo termine — la barra irá a 100% y se cerrará.
    @Binding var shouldComplete: Bool
    /// Acción a ejecutar después de cerrar el dialog.
    var onDismissed: (() -> Void)?

    @State private var isActive = true
    @State private var gearScale: CGFloat = 0.0
    @State private var gearRotation: Double = 0.0
    @State private var loadingProgress: CGFloat = 0.0
    @State private var pulseTimer: Timer? = nil

    init(isPresented: Binding<Bool>, shouldComplete: Binding<Bool>, onDismissed: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self._shouldComplete = shouldComplete
        self.onDismissed = onDismissed
    }

    /// Color de la barra según tramo (paridad Android).
    private var progressBarColor: Color {
        if loadingProgress < 0.34 {
            return Color(hex: "#00BBDC")
        } else if loadingProgress < 0.67 {
            return Color(hex: "#0082C7")
        } else {
            return Color(hex: "#0254A5")
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#0254A5"))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(gearRotation))
                    .scaleEffect(gearScale)
                    .opacity(gearScale > 0 ? 1.0 : 0.0)
                    .padding(.top, 24)

                Text("Cargando tu convenio")
                    .font(Font.custom("FiraSans-Bold", size: 17))
                    .foregroundColor(Color(hex: "#0254A5"))
                    .multilineTextAlignment(.center)

                Text("Estamos configurando todo para ti")
                    .font(Font.custom("FiraSans-Regular", size: 13))
                    .foregroundColor(Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "#E8EEF3"))
                            .frame(height: 10)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(progressBarColor)
                            .frame(width: geo.size.width * loadingProgress, height: 10)
                            .animation(.easeInOut(duration: 0.6), value: progressBarColor)
                    }
                }
                .frame(height: 10)
                .padding(.horizontal, 8)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.88)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
        }
        .onAppear {
            startAnimations()
            startLoadingProgress()
        }
        .onDisappear {
            isActive = false
            stopTimers()
        }
        // Interceptar loading global mientras este dialog esté visible
        .onReceive(AppStatusManager.onLoading) { isGlobalLoading in
            if isGlobalLoading {
                AppStatusManager.setLoading(false)
            }
        }
        // Cuando el caller indica que terminó → completar barra y cerrar
        .onChange(of: shouldComplete) { newValue in
            if newValue {
                completeAndDismiss()
            }
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        gearScale = 0.0
        gearRotation = 0.0
        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
            gearScale = 1.0
        }
        // Rotación continua que nunca se detiene
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            gearRotation = 360
        }
        pulseTimer?.invalidate()
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 0.6)) {
                gearScale = 1.12
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 0.6)) {
                    gearScale = 1.0
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 0.6)) {
                gearScale = 1.12
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 0.6)) {
                    gearScale = 1.0
                }
            }
        }
    }

    private func stopTimers() {
        pulseTimer?.invalidate()
        pulseTimer = nil
    }

    // MARK: - Progress

    private func startLoadingProgress() {
        loadingProgress = 0.0
        withAnimation(.easeInOut(duration: 6.0)) {
            loadingProgress = 0.80
        }
    }

    private func completeAndDismiss() {
        // Cerrar lo más rápido posible una vez que el work terminó.
        // Antes: 0.6s bar + 0.8s pausa + 0.2s fade = 1.6s de padding.
        // Ahora: 0.25s bar + 0.15s pausa + 0.2s fade = 0.6s de padding.
        // El padding mínimo existe solo para que el ojo perciba el "100%"
        // antes de que desaparezca — si fuera 0s se vería como un corte seco.
        withAnimation(.easeInOut(duration: 0.25)) {
            loadingProgress = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard isActive else { return }
            stopTimers()
            AppStatusManager.setLoading(false)
            shouldComplete = false
            withAnimation(.easeInOut(duration: 0.2)) {
                isPresented = false
            }
            onDismissed?()
        }
    }
}
