//
//  SeleccionarExamenesView.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import SwiftUI

/// Modelo de examen individual dentro de una categoría
struct ExamenItem: Identifiable, Hashable {
    let id = UUID()
    var nombre: String = ""
    var codigo: String = ""       // Id de Salesforce
    var name: String = ""         // Name (ej: "EX-00123")
    var sexo: String = ""         // "Ambos", "Femenino", "Masculino"
    var edadInicio: Int = 0
    var edadFin: Int = 999
    var categoria: String = ""    // Nombre de la categoria de origen
    var categoriaNum: Int = 0     // Numero de categoria (1-32), para mapear a Campo_(N+5)__c
    var isSelected: Bool = false
    var isInCart: Bool = false     // Ya estaba en el carrito
}

/// Vista de selección múltiple de exámenes de una categoría
struct SeleccionarExamenesView: View {
    let seleccionConfig: SeleccionExamenesConfig
    let categoria: CategoriaExamen
    @Binding var examenes: [ExamenItem]
    var onAgregar: ([ExamenItem]) -> Void = { _ in }
    var onCancelar: () -> Void = {}

    @State private var selectAll = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancelar() }

            VStack(spacing: 0) {
                // Header: titulo categoría + X para cerrar
                HStack(alignment: .top) {
                    let titleAttr = seleccionConfig.tituloCategoriaAttr
                    Text(categoria.nombre)
                        .font(Font.custom(
                            titleAttr.font.isEmpty ? "FiraSans-Bold" : titleAttr.font,
                            size: CGFloat(Int(titleAttr.size) ?? 18)
                        ))
                        .foregroundColor(Color(hex: titleAttr.color.isEmpty ? "#00BBDC" : titleAttr.color))

                    Spacer()

                    Button { onCancelar() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#666666"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 4)

                // Subtítulo dinámico desde Salesforce (solo si hay exámenes tras filtrar)
                if !seleccionConfig.subtituloTexto.isEmpty && !examenes.isEmpty {
                    let subAttr = seleccionConfig.subtituloAttr
                    Text(seleccionConfig.subtituloTexto)
                        .font(Font.custom(
                            subAttr.font.isEmpty ? "FiraSans-Regular" : subAttr.font,
                            size: CGFloat(Int(subAttr.size) ?? 13)
                        ))
                        .foregroundColor(Color(hex: subAttr.color.isEmpty ? "#5B6770" : subAttr.color))
                        .frame(maxWidth: .infinity, alignment: subAttr.alignment.lowercased() == "center" ? .center : (subAttr.alignment.lowercased() == "right" ? .trailing : .leading))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)

                    Divider()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }

                if examenes.isEmpty {
                    // Estado vacío: sin exámenes para seleccionar (filtrado por género/edad)
                    emptyState
                } else {
                    // Contenido normal: lista de exámenes
                    examListContent
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Estado vacío (sin exámenes tras filtro por perfil)
    private var emptyState: some View {
        VStack(spacing: 20) {
            let sinAttr = seleccionConfig.sinExamenesAttr
            let textoSin = seleccionConfig.sinExamenesTexto.isEmpty
                ? "No se encontraron exámenes para seleccionar según género o edad que tienes..."
                : seleccionConfig.sinExamenesTexto
            let sinFont = sinAttr.font.isEmpty ? "FiraSans-Regular" : sinAttr.font
            let sinSize = CGFloat(Int(sinAttr.size) ?? 18)
            let sinColor = Color(hex: sinAttr.color.isEmpty ? "#333F48" : sinAttr.color)
            parseSalesforceText(textoSin, font: sinFont, size: sinSize, color: sinColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            // Botón cancelar/cerrar
            Button {
                onCancelar()
            } label: {
                let btn = seleccionConfig.btnCancelar
                Text(btn.texto.isEmpty ? "Cancelar" : btn.texto)
                    .font(Font.custom("FiraSans-SemiBold", size: 15))
                    .foregroundColor(Color(hex: btn.colorTexto.isEmpty ? "#5B6770" : btn.colorTexto))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: btn.colorFondo.isEmpty ? "#EDEDED" : btn.colorFondo))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Lista de exámenes (contenido normal)
    private var examListContent: some View {
        VStack(spacing: 0) {
            // Seleccionar todos (solo afecta los que NO estan en carrito)
            Button {
                selectAll.toggle()
                for i in examenes.indices where !examenes[i].isInCart {
                    examenes[i].isSelected = selectAll
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: selectAll ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18))
                        .foregroundColor(selectAll
                            ? Color(hex: seleccionConfig.checkboxColorSeleccionado.isEmpty ? "#00BBDC" : seleccionConfig.checkboxColorSeleccionado)
                            : Color(hex: "#CCCCCC"))

                    let attr = seleccionConfig.seleccionarTodosAttr
                    Text(seleccionConfig.seleccionarTodosTexto.isEmpty ? "Seleccionar todos los examenes" : seleccionConfig.seleccionarTodosTexto)
                        .font(Font.custom(
                            attr.font.isEmpty ? "FiraSans-Regular" : attr.font,
                            size: CGFloat(Int(attr.size) ?? 13)
                        ))
                        .foregroundColor(Color(hex: attr.color.isEmpty ? "#333F48" : attr.color))

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }

            // Lista de examenes
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 8) {
                    ForEach($examenes) { $examen in
                        Button {
                            if !examen.isInCart {
                                examen.isSelected.toggle()
                                updateSelectAll()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: examen.isSelected || examen.isInCart ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 18))
                                    .foregroundColor(examen.isInCart
                                        ? Color.gray
                                        : (examen.isSelected
                                            ? Color(hex: seleccionConfig.checkboxColorSeleccionado.isEmpty ? "#00BBDC" : seleccionConfig.checkboxColorSeleccionado)
                                            : Color(hex: "#CCCCCC")))

                                let attr = seleccionConfig.textoListaAttr
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(examen.nombre)
                                        .font(Font.custom(
                                            attr.font.isEmpty ? "FiraSans-Regular" : attr.font,
                                            size: CGFloat(Int(attr.size) ?? 14)
                                        ))
                                        .foregroundColor(examen.isInCart ? Color.gray : Color(hex: attr.color.isEmpty ? "#333F48" : attr.color))
                                        .multilineTextAlignment(.leading)

                                    if examen.isInCart {
                                        Text("(Ya en carrito)")
                                            .font(Font.custom("FiraSans-Regular", size: 11))
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        examen.isInCart
                                            ? Color.gray.opacity(0.3)
                                            : (examen.isSelected
                                                ? Color(hex: seleccionConfig.checkboxColorSeleccionado.isEmpty ? "#00BBDC" : seleccionConfig.checkboxColorSeleccionado).opacity(0.5)
                                                : Color(hex: "#E0E0E0")),
                                        lineWidth: 1
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(examen.isInCart
                                                ? Color(hex: "#F5F5F5")
                                                : (examen.isSelected
                                                    ? Color(hex: seleccionConfig.colorFondoSeleccionado.isEmpty ? "#E8F5E9" : seleccionConfig.colorFondoSeleccionado).opacity(0.3)
                                                    : Color.white))
                                    )
                            )
                        }
                        .disabled(examen.isInCart)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 600)

            // Contador - usa template de 6.6 si viene (ej: "/ de / exámenes seleccionados")
            let selectedCount = examenes.filter { $0.isSelected && !$0.isInCart }.count
            let cAttr = seleccionConfig.contadorAttr
            let contadorText: String = {
                let template = seleccionConfig.contadorTexto
                if template.contains("/") {
                    // Reemplazar los "/" por los valores reales
                    let parts = template.components(separatedBy: "/")
                    if parts.count >= 3 {
                        return "\(selectedCount)\(parts[1])\(examenes.count)\(parts[2])"
                    }
                }
                return "\(selectedCount) de \(examenes.count) exámenes seleccionados"
            }()
            Text(contadorText)
                .font(Font.custom(
                    cAttr.font.isEmpty ? "FiraSans-Regular" : cAttr.font,
                    size: CGFloat(Int(cAttr.size) ?? 12)
                ))
                .foregroundColor(Color(hex: cAttr.color.isEmpty ? "#666666" : cAttr.color))
                .padding(.vertical, 8)

            // Botones: Cancelar (izq) + Agregar (der)
            HStack(spacing: 12) {
                // Cancelar
                Button {
                    onCancelar()
                } label: {
                    let btn = seleccionConfig.btnCancelar
                    Text(btn.texto.isEmpty ? "Cancelar" : btn.texto)
                        .font(Font.custom("FiraSans-SemiBold", size: 15))
                        .foregroundColor(Color(hex: btn.colorTexto.isEmpty ? "#5B6770" : btn.colorTexto))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: btn.colorFondo.isEmpty ? "#EDEDED" : btn.colorFondo))
                        )
                }

                // Agregar
                Button {
                    let selected = examenes.filter { $0.isSelected && !$0.isInCart }
                    onAgregar(selected)
                } label: {
                    let btn = seleccionConfig.btnAgregar
                    Text(btn.texto.isEmpty ? "Agregar" : btn.texto)
                        .font(Font.custom("FiraSans-SemiBold", size: 15))
                        .foregroundColor(Color(hex: selectedCount > 0
                            ? (btn.colorTextoActivo.isEmpty ? (btn.colorTexto.isEmpty ? "#FFFFFF" : btn.colorTexto) : btn.colorTextoActivo)
                            : (btn.colorTextoInactivo.isEmpty ? "#5B6770" : btn.colorTextoInactivo)))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: selectedCount > 0
                                    ? (btn.colorFondoActivo.isEmpty ? (btn.colorFondo.isEmpty ? "#00BBDC" : btn.colorFondo) : btn.colorFondoActivo)
                                    : (btn.colorFondoInactivo.isEmpty ? "#EDEDED" : btn.colorFondoInactivo)))
                        )
                }
                .disabled(selectedCount == 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func updateSelectAll() {
        let selectableExams = examenes.filter { !$0.isInCart }
        selectAll = !selectableExams.isEmpty && selectableExams.allSatisfy(\.isSelected)
    }
}
