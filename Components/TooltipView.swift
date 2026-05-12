//
//  TooltipView.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Tooltip/Spotlight para descubrimiento de features.
//  Muestra un mensaje contextual con flecha apuntando al elemento.
//  100% nativo SwiftUI, no requiere librería externa.
//
//  Ejemplos de uso:
//
//  1. Tooltip simple sobre un botón:
//     Button("Agendar") { ... }
//         .tooltip(isPresented: $showTip, text: "¡Nuevo! Agenda citas directamente")
//
//  2. Spotlight (overlay oscuro que destaca un elemento):
//     MyView()
//         .spotlight(isPresented: $showSpotlight, text: "Toca aquí para ver tus exámenes")
//

import SwiftUI

// MARK: - Arrow Direction

enum TooltipArrow {
    case top, bottom
}

// MARK: - Tooltip View

struct TooltipBubble: View {
    let text: String
    var arrow: TooltipArrow = .bottom
    var backgroundColor: Color = Color(hex: "333333")
    var textColor: Color = .white
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            if arrow == .bottom {
                bubbleContent
                arrowShape
                    .rotationEffect(.degrees(180))
            } else {
                arrowShape
                bubbleContent
            }
        }
    }

    private var bubbleContent: some View {
        HStack {
            Text(text)
                .font(Font.custom("FiraSans-Regular", size: 14))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            if onDismiss != nil {
                Button {
                    onDismiss?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(textColor.opacity(0.7))
                        .font(.system(size: 16))
                }
                .padding(.trailing, 12)
            }
        }
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    private var arrowShape: some View {
        Triangle()
            .fill(backgroundColor)
            .frame(width: 16, height: 8)
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Tooltip Modifier

struct TooltipModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String
    var arrow: TooltipArrow

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isPresented {
                        TooltipBubble(
                            text: text,
                            arrow: arrow,
                            onDismiss: { isPresented = false }
                        )
                        .fixedSize()
                        .offset(y: arrow == .bottom ? -60 : 50)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(999)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
            )
    }
}

// MARK: - Spotlight Modifier

struct SpotlightModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if isPresented {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .reverseMask {
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(
                                        width: geo.size.width + 16,
                                        height: geo.size.height + 16
                                    )
                                    .position(
                                        x: geo.size.width / 2,
                                        y: geo.size.height / 2
                                    )
                            }
                            .overlay(
                                TooltipBubble(
                                    text: text,
                                    arrow: .top,
                                    onDismiss: { isPresented = false }
                                )
                                .fixedSize()
                                .position(
                                    x: geo.size.width / 2,
                                    y: geo.size.height + 50
                                )
                            )
                            .onTapGesture {
                                isPresented = false
                            }
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isPresented)
            )
    }
}

// MARK: - Reverse Mask Helper

extension View {
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                mask()
                    .blendMode(.destinationOut)
            }
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Muestra un tooltip con texto sobre el elemento.
    func tooltip(isPresented: Binding<Bool>, text: String, arrow: TooltipArrow = .bottom) -> some View {
        modifier(TooltipModifier(isPresented: isPresented, text: text, arrow: arrow))
    }

    /// Muestra un spotlight que oscurece todo excepto este elemento, con un tooltip.
    func spotlight(isPresented: Binding<Bool>, text: String) -> some View {
        modifier(SpotlightModifier(isPresented: isPresented, text: text))
    }
}
