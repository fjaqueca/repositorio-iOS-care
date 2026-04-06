//
//  CarritoExamView.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import SwiftUI

/// Vista del carrito de exámenes seleccionados
struct CarritoExamView: View {
    let carritoConfig: CarritoExamConfig
    @Binding var cartItems: [ExamenItem]
    var onVerResumen: () -> Void = {}
    var onLimpiarTodo: () -> Void = {}
    var onDismiss: () -> Void = {}

    /// Agrupa los items del carrito por categoría
    private var groupedByCategory: [(categoria: String, items: [ExamenItem])] {
        var dict: [String: [ExamenItem]] = [:]
        var order: [String] = []
        for item in cartItems {
            let cat = item.categoria.isEmpty ? "Sin categoría" : item.categoria
            if dict[cat] == nil { order.append(cat) }
            dict[cat, default: []].append(item)
        }
        return order.map { (categoria: $0, items: dict[$0] ?? []) }
    }

    /// Cantidad de categorías únicas
    private var categoriaCount: Int {
        Set(cartItems.map { $0.categoria }).count
    }

    var body: some View {
        NavigationViewCustom {
            VStack(spacing: 0) {
                Divider()

                if cartItems.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            // Exámenes agrupados por categoría
                            ForEach(groupedByCategory, id: \.categoria) { group in
                                VStack(alignment: .leading, spacing: 0) {
                                    // Header de categoría con fondo de color
                                    let catAttr = carritoConfig.categoriaAttr
                                    HStack(spacing: 8) {
                                        Text(group.categoria)
                                            .font(Font.custom(catAttr.font, size: CGFloat(Int(catAttr.size) ?? 14)))
                                            .foregroundColor(Color(hex: catAttr.color))
                                            .lineLimit(2)

                                        Spacer()

                                        // Badge de cantidad
                                        let cantAttr = carritoConfig.cantidadAttr
                                        Text("\(group.items.count)")
                                            .font(Font.custom(cantAttr.font, size: CGFloat(Int(cantAttr.size) ?? 11)))
                                            .foregroundColor(Color(hex: cantAttr.color))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white.opacity(0.3))
                                            )
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: catAttr.colorFondo.isEmpty ? carritoConfig.carritoColor : catAttr.colorFondo))
                                    )
                                    .padding(.horizontal, .margin)
                                    .padding(.bottom, 4)

                                    // Lista de exámenes de esta categoría
                                    let listaAttr = carritoConfig.nombresExamenesAttr
                                    ForEach(group.items) { item in
                                        VStack(spacing: 0) {
                                            HStack(spacing: 10) {
                                                Text(item.nombre)
                                                    .font(Font.custom(listaAttr.font, size: CGFloat(Int(listaAttr.size) ?? 12)))
                                                    .foregroundColor(Color(hex: listaAttr.color))

                                                Spacer()

                                                // Boton eliminar (icono basurero)
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.25)) {
                                                        if let idx = cartItems.firstIndex(where: { $0.id == item.id }) {
                                                            cartItems.remove(at: idx)
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "trash.fill")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(Color(hex: carritoConfig.basureroColor))
                                                }
                                            }
                                            .padding(.horizontal, .margin)
                                            .padding(.leading, 14)
                                            .padding(.vertical, 10)

                                            Divider()
                                                .padding(.leading, .margin + 14)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                                )
                                .padding(.horizontal, .margin)
                            }

                            // Total de exámenes agregados
                            let totalAttr = carritoConfig.totalExamenesAttr
                            HStack {
                                Text(carritoConfig.totalExamenesTexto)
                                    .font(Font.custom(totalAttr.font, size: CGFloat(Int(totalAttr.size) ?? 13)))
                                    .foregroundColor(Color(hex: totalAttr.color))

                                Spacer()

                                Text("\(cartItems.count) exámenes · \(categoriaCount) categoría\(categoriaCount > 1 ? "s" : "")")
                                    .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(totalAttr.size) ?? 13)))
                                    .foregroundColor(Color(hex: totalAttr.color))
                            }
                            .padding(.horizontal, .margin)
                            .padding(.top, 4)

                            Divider()
                                .padding(.horizontal, .margin)

                            // Texto "Antes de continuar" (viene del Main Record Elem 12)
                            if !carritoConfig.antesDeContinuarTexto.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    let antesAttr = carritoConfig.antesDeContinuarAttr
                                    Text(carritoConfig.antesDeContinuarTexto)
                                        .font(Font.custom(antesAttr.font, size: CGFloat(Int(antesAttr.size) ?? 14)))
                                        .foregroundColor(Color(hex: antesAttr.color))

                                    if !carritoConfig.subAntesDeContinuarTexto.isEmpty {
                                        let subAttr = carritoConfig.subAntesDeContinuarAttr
                                        Text(carritoConfig.subAntesDeContinuarTexto)
                                            .font(Font.custom(subAttr.font, size: CGFloat(Int(subAttr.size) ?? 12)))
                                            .foregroundColor(Color(hex: subAttr.color))
                                    }
                                }
                                .padding(.horizontal, .margin)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, .margin)
                    }

                    // Botones: Ver Resumen y Limpiar Todo
                    VStack(spacing: 10) {
                        // Botón Ver Resumen
                        let btnResumen = carritoConfig.btnVerResumen
                        Button {
                            onVerResumen()
                        } label: {
                            Text(btnResumen.texto.isEmpty ? "Ver Resumen" : btnResumen.texto)
                                .font(Font.custom(
                                    btnResumen.font.isEmpty ? "FiraSans-Bold" : btnResumen.font,
                                    size: CGFloat(Int(btnResumen.size) ?? 14)
                                ))
                                .foregroundColor(Color(hex: btnResumen.colorTexto.isEmpty ? "#FFFFFF" : btnResumen.colorTexto))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: btnResumen.colorFondo.isEmpty ? carritoConfig.carritoColor : btnResumen.colorFondo))
                                )
                        }

                        // Botón Limpiar Todo
                        let btnLimpiar = carritoConfig.btnLimpiar
                        if !btnLimpiar.texto.isEmpty {
                            Button {
                                onLimpiarTodo()
                            } label: {
                                Text(btnLimpiar.texto)
                                    .font(Font.custom(
                                        btnLimpiar.font.isEmpty ? "FiraSans-Bold" : btnLimpiar.font,
                                        size: CGFloat(Int(btnLimpiar.size) ?? 12)
                                    ))
                                    .foregroundColor(Color(hex: btnLimpiar.colorTexto.isEmpty ? "#333F48" : btnLimpiar.colorTexto))
                            }
                        }
                    }
                    .padding(.horizontal, .margin)
                    .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    let attr = carritoConfig.tituloAttr
                    Text(carritoConfig.titulo)
                        .font(Font.custom(
                            attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                            size: CGFloat(Int(attr.size) ?? 18)
                        ))
                        .foregroundColor(Color(hex: attr.color.isEmpty ? "#00BBDC" : attr.color))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.template)
                            .tint(Color(hex: carritoConfig.carritoColor))
                    }
                }
            }
            .configureNavigation()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cart")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.4))

            let sinAttr = carritoConfig.sinExamenesAttr
            Text(carritoConfig.sinExamenesTexto)
                .font(Font.custom(
                    sinAttr.font.isEmpty ? "FiraSans-Regular" : sinAttr.font,
                    size: CGFloat(Int(sinAttr.size) ?? 12)
                ))
                .foregroundColor(Color(hex: sinAttr.color.isEmpty ? "#333F48" : sinAttr.color))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
