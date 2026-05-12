//
//  ShimmerModifier.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Efecto shimmer reutilizable para skeleton loading.
//  Uso: cualquier vista puede aplicar .shimmer() para el efecto de destello.
//
//  Ejemplos:
//    RoundedRectangle(cornerRadius: 8)
//        .fill(Color.gray.opacity(0.3))
//        .frame(height: 20)
//        .shimmer()
//
//    Text("Cargando...")
//        .redacted(reason: .placeholder)
//        .shimmer()
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0
    var duration: Double
    var bounce: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * (geo.size.width + geo.size.width * 0.6))
                    .onAppear {
                        withAnimation(
                            .linear(duration: duration)
                            .repeatForever(autoreverses: bounce)
                        ) {
                            phase = 1.0
                        }
                    }
                }
            )
            .clipped()
    }
}

extension View {
    /// Aplica efecto shimmer (destello) sobre la vista.
    /// - Parameters:
    ///   - duration: Duración de un ciclo completo (default 1.2s)
    ///   - bounce: Si el efecto va y vuelve (default false, solo va)
    func shimmer(duration: Double = 1.2, bounce: Bool = false) -> some View {
        modifier(ShimmerModifier(duration: duration, bounce: bounce))
    }
}
