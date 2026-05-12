//
//  PopupViewModifier.swift
//  CareAssistance
//
//  Created by Lara Dubs on 31/10/2022.
//

import SwiftUI

struct PopupViewModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dismissOnTap: Bool
    @ViewBuilder
    var popupContent: () -> PopupContent
    
    // note: The Z index are to fix an animation bug on swiftUI
    // reference: https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
    func body(content: Content) -> some View {
        ZStack {
            content
                .animation(nil, value: false)
                .zIndex(1)
            Group {
                if isPresented {
                    Color(white: 0.0, opacity: 0.30)
                        .onTapGesture {
                            if dismissOnTap {
                                isPresented = false
                            }
                        }
                        .zIndex(2)
                    popupContent()
                        .zIndex(3)
                }
            }
            .ignoresSafeArea()
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isPresented)
    }
}

struct Popup {
    let image: String?
    let title: String
    let message: String?
    let actionTitle: String
    let action: () -> Void
    let isCancellable: Bool
    let cancelTitle: String?
    let cancelAction: (() -> Void)?
    let UIStateTitle: GreetingUIState?
    let UIStateMessage: GreetingUIState?
    let UIStateButton: GreetingUIState?
    let UIStateCancelButton: GreetingUIState?

    init(image: String? = nil, title: String, message: String? = nil, actionTitle: String, action: @escaping () -> Void, isCancellable: Bool = false, cancelTitle: String? = nil, UIStateTitle: GreetingUIState?, UIStateMessage: GreetingUIState?, UIStateButton: GreetingUIState?, UIStateCancelButton: GreetingUIState?, cancelAction: (() -> Void)? = nil) {
        self.image = image
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.isCancellable = isCancellable
        self.cancelTitle = cancelTitle
        self.cancelAction = cancelAction
        self.UIStateTitle = UIStateTitle
        self.UIStateMessage = UIStateMessage
        self.UIStateButton = UIStateButton
        self.UIStateCancelButton = UIStateCancelButton
    }
}

extension View {
    @ViewBuilder
    func popup<Content: View>(isPresented: Binding<Bool>, addBackground: Bool = true, dismissOnTap: Bool = true, @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(PopupViewModifier(isPresented: isPresented, dismissOnTap: dismissOnTap) {
            if addBackground {
                content()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, .margin)
            } else {
                content()
            }
        })
    }

    @ViewBuilder
    func popup<Content: View, Item>(item: Binding<Item?>, addBackground: Bool = true, dismissOnTap: Bool = true, @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        popup(
            isPresented: .init(get: { item.wrappedValue != nil }, set: { if !$0 { item.wrappedValue = nil } }),
            addBackground: addBackground,
            dismissOnTap: dismissOnTap,
            content: {
                if let item = item.wrappedValue {
                    content(item)
                } else {
                    EmptyView()
                }
            }
        )
    }

    func popup(item binding: Binding<Popup?>) -> some View {
        popup(item: binding, dismissOnTap: binding.wrappedValue?.isCancellable ?? false) { item in
            PopupView(
                image: item.image,
                title: item.title,
                message: item.message,
                UIStateTitle: item.UIStateTitle,
                UIStateMessage: item.UIStateMessage,
                UIStateButton: item.UIStateButton,
                UIStateCancelButton: item.UIStateCancelButton
            ) {
                // Botones estilo pill (paridad Grupo Familiar)
                Group {
                    if item.isCancellable {
                        // Dos botones: No (izquierda) + Sí (derecha)
                        HStack(spacing: 12) {
                            Button {
                                HapticManager.impact(style: .light)
                                binding.wrappedValue?.cancelAction?()
                                binding.wrappedValue = nil
                            } label: {
                                Text(item.cancelTitle ?? "Cancelar")
                                    .font(Font.custom(item.UIStateCancelButton?.font ?? "FiraSans-Bold", size: 15))
                                    .foregroundColor(Color(hex: item.UIStateCancelButton?.color.isEmpty == false ? item.UIStateCancelButton!.color : "#555555"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color(hex: "#CCCCCC"), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .bounceOnTap()

                            Button {
                                HapticManager.impact(style: .medium)
                                item.action()
                                binding.wrappedValue = nil
                            } label: {
                                Text(item.actionTitle)
                                    .font(Font.custom(item.UIStateButton?.font ?? "FiraSans-Bold", size: 15))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color(hex: item.UIStateButton?.color.isEmpty == false ? item.UIStateButton!.color : "#00BBDC"))
                                    )
                            }
                            .buttonStyle(.plain)
                            .bounceOnTap()
                        }
                    } else {
                        // Un solo botón centrado (Aceptar)
                        Button {
                            HapticManager.impact(style: .medium)
                            item.action()
                            binding.wrappedValue = nil
                        } label: {
                            Text(item.actionTitle)
                                .font(Font.custom(item.UIStateButton?.font ?? "FiraSans-Bold", size: 15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: item.UIStateButton?.color.isEmpty == false ? item.UIStateButton!.color : "#00BBDC"))
                                )
                        }
                        .buttonStyle(.plain)
                        .bounceOnTap()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
