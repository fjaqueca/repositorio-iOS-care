//
//  TypewriterText.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Texto con efecto typewriter (se escribe letra a letra)
//  y puntos suspensivos animados en loop al terminar.
//  Paridad con TypewriterTextView.kt de Android.
//
//  Usa Task con cancelación: al destruirse o re-crearse,
//  el Task anterior se cancela automáticamente (equivalente
//  a cancelAll() + text="" de Android).
//
//  Uso:
//    TypewriterText("Sin programas asociados",
//                   font: "FiraSans-Bold", size: 19,
//                   color: Color(hex: "#5B6770"))
//
//    TypewriterText("Descripción aquí",
//                   font: "FiraSans-Regular", size: 15,
//                   color: Color(hex: "#C4C4C4"),
//                   speed: 0.06, showDots: true, delay: 1.8)
//

import SwiftUI

struct TypewriterText: View {
    let fullText: String
    var font: String
    var size: CGFloat
    var color: Color
    var speed: Double
    var showDots: Bool
    var delay: Double
    var alignment: TextAlignment
    var onComplete: (() -> Void)?

    init(_ fullText: String,
         font: String = "FiraSans-Regular",
         size: CGFloat = 15,
         color: Color = .gray,
         speed: Double = 0.04,
         showDots: Bool = true,
         delay: Double = 0.0,
         alignment: TextAlignment = .center,
         onComplete: (() -> Void)? = nil) {
        self.fullText = fullText
        self.font = font
        self.size = size
        self.color = color
        self.speed = speed
        self.showDots = showDots
        self.delay = delay
        self.alignment = alignment
        self.onComplete = onComplete
    }

    @State private var displayed: String = ""
    @State private var typingTask: Task<Void, Never>? = nil

    var body: some View {
        Text(displayed)
            .font(Font.custom(font, size: size))
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
            .onAppear {
                restart()
            }
            .onDisappear {
                // Equivalente a onDetachedFromWindow → cancelAll() + text=""
                // Cancelar el Task Y limpiar el texto para no dejar
                // callbacks huérfanos ni estado corrupto en re-entradas
                typingTask?.cancel()
                typingTask = nil
                displayed = ""
            }
    }

    // Equivalente a typewrite() de Android:
    // cancelAll() → text = "" → startTyping()
    private func restart() {
        typingTask?.cancel()
        displayed = ""

        typingTask = Task {
            // startDelay antes de empezar a tipear
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }

            // Tipear letra a letra
            for char in fullText {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    displayed += String(char)
                }
                guard !Task.isCancelled else { return }
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
            }

            // Callback al terminar de tipear
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                onComplete?()
            }

            // Loop de puntos suspensivos
            guard !Task.isCancelled, showDots else { return }
            await loopDots()
        }
    }

    // Loop infinito: . → .. → ... → (pausa) → . → ...
    private func loopDots() async {
        // Pausa antes de empezar los puntos
        try? await Task.sleep(nanoseconds: 500_000_000)

        while !Task.isCancelled {
            for dotCount in 1...3 {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    displayed = fullText + String(repeating: ".", count: dotCount)
                }
                guard !Task.isCancelled else { return }
                try? await Task.sleep(nanoseconds: 400_000_000)
            }
            // Pausa al reiniciar ciclo
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                displayed = fullText
            }
            guard !Task.isCancelled else { return }
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }
}
