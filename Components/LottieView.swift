//
//  LottieView.swift
//  CareAssistance
//
//  Created on 07/05/2026.
//
//  Wrapper de Lottie para SwiftUI.
//  - Usa CoreAnimation rendering (más eficiente en GPU).
//  - Solo reproduce la animación cuando la vista es visible (onAppear/onDisappear).
//  - Soporta AMBOS formatos:
//      • .lottie (dotLottie, ZIP-compressed, recomendado — pesa menos)
//      • .json   (Bodymovin clásico, fallback)
//    Si existen ambos en el bundle con el mismo nombre, gana .lottie.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let animationView = LottieAnimationView(
            configuration: LottieConfiguration(renderingEngine: .coreAnimation)
        )
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.contentMode = contentMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        context.coordinator.animationView = animationView

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        loadAnimation(into: animationView)

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Play cuando la vista se vuelve visible (SwiftUI recicla UIViews en TabView).
        // Si la animación aún no terminó de cargar (caso dotLottie async),
        // el play() se dispara en el callback de carga.
        if let animationView = context.coordinator.animationView,
           animationView.animation != nil,
           !animationView.isAnimationPlaying {
            animationView.play()
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.animationView?.stop()
        coordinator.animationView = nil
    }

    // MARK: - Loader (.lottie preferido, .json como fallback)

    private func loadAnimation(into animationView: LottieAnimationView) {
        // Snapshot de la config que el caller pidió — necesario para
        // RE-aplicarla después del loadAnimation(from: dotLottie), porque
        // el SDK sobrescribe loopMode/speed con lo que diga el manifest.json
        // interno del .lottie (muchos manifests no traen loop explícito y el
        // SDK los carga como .playOnce → animación se queda congelada).
        let desiredLoopMode = self.loopMode
        let desiredSpeed = self.speed

        // Si existe .lottie en el bundle → usarlo (más eficiente, pesa menos).
        if Bundle.main.url(forResource: animationName, withExtension: "lottie") != nil {
            DotLottieFile.named(animationName) { result in
                switch result {
                case .success(let dotLottieFile):
                    DispatchQueue.main.async {
                        animationView.loadAnimation(from: dotLottieFile)
                        // Re-imponer la config del caller (el manifest del
                        // dotLottie no debe ganar sobre lo que pide la vista).
                        animationView.loopMode = desiredLoopMode
                        animationView.animationSpeed = desiredSpeed
                        animationView.play()
                    }
                case .failure(let error):
                    print("⚠️ [LottieView] Falló carga de dotLottie '\(animationName).lottie': \(error.localizedDescription) — intentando fallback .json")
                    DispatchQueue.main.async {
                        if let animation = LottieAnimation.named(animationName) {
                            animationView.animation = animation
                            animationView.loopMode = desiredLoopMode
                            animationView.animationSpeed = desiredSpeed
                            animationView.play()
                        } else {
                            print("❌ [LottieView] Tampoco se encontró '\(animationName).json' en el bundle")
                        }
                    }
                }
            }
            return
        }

        // Fallback: cargar .json sincronicamente (comportamiento legacy).
        if let animation = LottieAnimation.named(animationName) {
            animationView.animation = animation
        } else {
            print("❌ [LottieView] No se encontró '\(animationName)' ni como .lottie ni como .json en el bundle")
        }
    }

    class Coordinator {
        var animationView: LottieAnimationView?
    }
}
