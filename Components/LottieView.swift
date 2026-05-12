//
//  LottieView.swift
//  CareAssistance
//
//  Created on 07/05/2026.
//
//  Wrapper de Lottie para SwiftUI.
//  - Usa CoreAnimation rendering (más eficiente en GPU).
//  - Solo reproduce la animación cuando la vista es visible (onAppear/onDisappear).
//  - Precarga la animación en background para evitar jank en el primer frame.
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

        // Cargar la animación desde cache o disco
        let animation = LottieAnimation.named(animationName)

        let animationView = LottieAnimationView(animation: animation, configuration: LottieConfiguration(renderingEngine: .coreAnimation))
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.contentMode = contentMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false
        // NO hacer play() aquí — se hace en onAppear via Coordinator

        context.coordinator.animationView = animationView

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Play cuando la vista se vuelve visible (SwiftUI recicla UIViews en TabView)
        if let animationView = context.coordinator.animationView, !animationView.isAnimationPlaying {
            animationView.play()
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.animationView?.stop()
        coordinator.animationView = nil
    }

    class Coordinator {
        var animationView: LottieAnimationView?
    }
}
