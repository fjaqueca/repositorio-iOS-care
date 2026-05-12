//
//  NavigationTransitions.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Transiciones premium para navegación entre pantallas.
//  Reemplaza los "hard cuts" por entradas suaves con spring.
//
//  Uso:
//    SomeView()
//        .slideInFromRight()        // entrada spring desde la derecha
//
//    SomeView()
//        .heroSendEffect(isActive: $isNavigating)  // pulse + fade al navegar
//

import SwiftUI

// MARK: - Slide In from Right (entrada de pantalla con spring)

struct SlideInFromRightModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double

    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : 40)
            .opacity(isVisible ? 1.0 : 0.0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        isVisible = true
                    }
                }
            }
    }
}

// MARK: - Hero Send Effect (la card pulsa y se desvanece al navegar)

struct HeroSendModifier: ViewModifier {
    @Binding var isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 0.92 : 1.0)
            .opacity(isActive ? 0.6 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}

// MARK: - Staggered Grid Appear (grid de items aparece escalonado)

struct StaggeredGridAppearModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .onAppear {
                let delay = baseDelay + Double(index) * 0.08
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isVisible = true
                    }
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Entrada spring suave desde la derecha. Ideal para pantallas que entran via NavigationLink.
    func slideInFromRight(delay: Double = 0.05) -> some View {
        modifier(SlideInFromRightModifier(delay: delay))
    }

    /// Efecto "envío" en una card al navegar: se achica y desvanece.
    func heroSendEffect(isActive: Binding<Bool>) -> some View {
        modifier(HeroSendModifier(isActive: isActive))
    }

    /// Entrada escalonada para items de grid. Cada item aparece con scale spring.
    func staggeredAppear(index: Int, baseDelay: Double = 0.1) -> some View {
        modifier(StaggeredGridAppearModifier(index: index, baseDelay: baseDelay))
    }
}
