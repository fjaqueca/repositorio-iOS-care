//
//  SpringModifiers.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Modificadores de animación con física de resorte/spring.
//  Dan sensación de vida y naturalidad a las interacciones.
//  100% nativo SwiftUI, no requiere librería externa.
//
//  Ejemplos de uso:
//
//    Button("Agendar") { ... }
//        .bounceOnTap()              // efecto squeeze al presionar
//
//    CardView()
//        .pressable()                // se achica al presionar, rebota al soltar
//
//    Text("Nuevo")
//        .popIn()                    // aparece con efecto pop animado
//
//    Image("icon")
//        .springOnAppear()           // entra con spring desde abajo
//

import SwiftUI

// MARK: - Bounce on Tap (squeeze + rebote)

struct BounceOnTapModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: isPressed)
            .onLongPressGesture(minimumDuration: 0.15, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - Pressable (efecto presión con profundidad)
// Usa LongPressGesture para NO interferir con scroll en ScrollView/List.
// El efecto se activa al mantener presionado brevemente (0.15s).

struct PressableModifier: ViewModifier {
    @State private var isPressed = false
    var scale: CGFloat
    var opacity: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .opacity(isPressed ? opacity : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: 0.15, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - Pop In (aparece con efecto pop)

struct PopInModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.5)
            .opacity(isVisible ? 1.0 : 0.0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        isVisible = true
                    }
                }
            }
    }
}

// MARK: - Spring on Appear (entra desde abajo con spring)

struct SpringOnAppearModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var offsetY: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(y: isVisible ? 0 : offsetY)
            .opacity(isVisible ? 1.0 : 0.0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isVisible = true
                    }
                }
            }
    }
}

// MARK: - Fade Slide In (entrada suave con slide)

struct FadeSlideInModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var direction: Edge

    var offset: CGSize {
        switch direction {
        case .top: return CGSize(width: 0, height: -20)
        case .bottom: return CGSize(width: 0, height: 20)
        case .leading: return CGSize(width: -20, height: 0)
        case .trailing: return CGSize(width: 20, height: 0)
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : offset.width, y: isVisible ? 0 : offset.height)
            .opacity(isVisible ? 1.0 : 0.0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        isVisible = true
                    }
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Efecto squeeze/rebote al hacer tap. Ideal para botones.
    func bounceOnTap() -> some View {
        modifier(BounceOnTapModifier())
    }

    /// Efecto de presión con escala y opacidad personalizables. Ideal para cards y tiles.
    func pressable(scale: CGFloat = 0.95, opacity: Double = 0.9) -> some View {
        modifier(PressableModifier(scale: scale, opacity: opacity))
    }

    /// Aparece con efecto pop animado (escala desde pequeño).
    func popIn(delay: Double = 0.0) -> some View {
        modifier(PopInModifier(delay: delay))
    }

    /// Entra desde abajo con animación spring.
    func springOnAppear(delay: Double = 0.0, offsetY: CGFloat = 30) -> some View {
        modifier(SpringOnAppearModifier(delay: delay, offsetY: offsetY))
    }

    /// Entrada suave con slide desde una dirección.
    func fadeSlideIn(delay: Double = 0.0, from direction: Edge = .bottom) -> some View {
        modifier(FadeSlideInModifier(delay: delay, direction: direction))
    }

    /// Shake horizontal para indicar error de validación. Incrementar `attempts` con animación para activar.
    func shake(attempts: Int) -> some View {
        modifier(ShakeEffect(shakes: attempts))
    }
}

// MARK: - Shake Effect (error de validación)
/// Shake horizontal con amortiguación exponencial.
/// La oscilación se atenúa gradualmente (3 ciclos, amplitud 8→0px).
/// Uso: incrementar `shakes` con `withAnimation(.default)` para activar.

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let progress = animatableData - CGFloat(Int(animatableData))
        let amplitude: CGFloat = 8 * (1 - progress)
        let offset = sin(progress * .pi * 6) * amplitude
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}
