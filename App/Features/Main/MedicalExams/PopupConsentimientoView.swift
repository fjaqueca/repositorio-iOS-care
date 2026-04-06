//
//  PopupConsentimientoView.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import SwiftUI
import SDWebImageSwiftUI

/// Popup de consentimiento informado con checkbox
struct PopupConsentimientoView: View {
    let config: PopupConsentimientoConfig
    var onAccept: () -> Void = {}
    var onCancel: () -> Void = {}

    @State private var isChecked = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }


            VStack(spacing: 16) {
                // Icono
                if !config.iconURL.isEmpty, let url = URL(string: config.iconURL) {
                    WebImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }

                // Titulo
                if !config.titulo.isEmpty {
                    let attr = config.tituloAttr
                    Text(config.titulo)
                        .font(Font.custom(
                            attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                            size: CGFloat(Int(attr.size) ?? 18)
                        ))
                        .foregroundColor(Color(hex: attr.color.isEmpty ? "#333F48" : attr.color))
                        .multilineTextAlignment(.center)
                }

                // Descripcion (scrollable, soporta **negrita** y <br> saltos de linea)
                if !config.descripcion.isEmpty {
                    let attr = config.descripcionAttr
                    let font = attr.font.isEmpty ? "FiraSans-Regular" : attr.font
                    let size = CGFloat(Int(attr.size) ?? 13)
                    let color = Color(hex: attr.color.isEmpty ? "#333F48" : attr.color)
                    ScrollView(.vertical, showsIndicators: true) {
                        parseSalesforceText(config.descripcion, font: font, size: size, color: color)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                }

                // Checkbox
                if !config.checkboxTexto.isEmpty {
                    let attr = config.checkboxTextoAttr
                    let textAlign = textAlignment(from: attr.alignment)
                    let frameAlign = frameAlignment(from: attr.alignment)
                    Button {
                        isChecked.toggle()
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(isChecked
                                    ? Color(hex: config.checkboxColor.isEmpty ? "#00BBDC" : config.checkboxColor)
                                    : Color.gray)

                            Text(config.checkboxTexto)
                                .font(Font.custom(
                                    attr.font.isEmpty ? "FiraSans-Regular" : attr.font,
                                    size: CGFloat(Int(attr.size) ?? 12)
                                ))
                                .foregroundColor(Color(hex: attr.color.isEmpty ? "#333F48" : attr.color))
                                .multilineTextAlignment(textAlign)
                                .frame(maxWidth: .infinity, alignment: frameAlign)
                        }
                        .frame(maxWidth: .infinity, alignment: frameAlign)
                    }
                }

                // Botones: Cancelar (izq) + Aceptar (der)
                HStack(spacing: 12) {
                    // Cancelar
                    if !config.btnCancelar.texto.isEmpty {
                        Button {
                            onCancel()
                        } label: {
                            Text(config.btnCancelar.texto)
                                .font(Font.custom("FiraSans-Medium", size: 14))
                                .foregroundColor(Color(hex: config.btnCancelar.colorTexto.isEmpty ? "#666666" : config.btnCancelar.colorTexto))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: config.btnCancelar.colorFondo.isEmpty ? "#E0E0E0" : config.btnCancelar.colorFondo))
                                .cornerRadius(8)
                        }
                    }

                    // Aceptar (deshabilitado si no marca checkbox)
                    Button {
                        if isChecked { onAccept() }
                    } label: {
                        let isActive = isChecked
                        Text(config.btnAceptar.texto.isEmpty ? "Aceptar" : config.btnAceptar.texto)
                            .font(Font.custom("FiraSans-Medium", size: 14))
                            .foregroundColor(Color(hex: isActive ? activeTextColor : inactiveTextColor))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: isActive ? activeBgColor : inactiveBgColor))
                            .cornerRadius(8)
                    }
                    .disabled(!isChecked)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.horizontal, 32)
        }
        .onAppear {
            logPopupConfig()
        }
    }

    // MARK: - Alignment helpers

    private func textAlignment(from raw: String) -> TextAlignment {
        switch raw.trimmingCharacters(in: .whitespaces).lowercased() {
        case "center": return .center
        case "right":  return .trailing
        default:       return .leading
        }
    }

    private func frameAlignment(from raw: String) -> Alignment {
        switch raw.trimmingCharacters(in: .whitespaces).lowercased() {
        case "center": return .center
        case "right":  return .trailing
        default:       return .leading
        }
    }

    private var activeTextColor: String {
        config.btnAceptar.colorTextoActivo.isEmpty ? "#FFFFFF" : config.btnAceptar.colorTextoActivo
    }
    private var activeBgColor: String {
        config.btnAceptar.colorFondoActivo.isEmpty ? "#387FC2" : config.btnAceptar.colorFondoActivo
    }
    private var inactiveTextColor: String {
        config.btnAceptar.colorTextoInactivo.isEmpty ? "#999999" : config.btnAceptar.colorTextoInactivo
    }
    private var inactiveBgColor: String {
        config.btnAceptar.colorFondoInactivo.isEmpty ? "#CCCCCC" : config.btnAceptar.colorFondoInactivo
    }

    // MARK: - Logging

    private func logPopupConfig() {
        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [PopupConsentimiento] CONFIGURACION DINAMICA (Elemento 6)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   iconURL: \"\(config.iconURL.isEmpty ? "(vacio)" : config.iconURL.prefix(60).description)\"")
        print("   titulo: \"\(config.titulo)\"")
        print("   tituloAttr: font=\(config.tituloAttr.font) size=\(config.tituloAttr.size) color=\(config.tituloAttr.color) align=\(config.tituloAttr.alignment)")
        print("   descripcion: \"\(config.descripcion.prefix(80))\"")
        print("   descripcionAttr: font=\(config.descripcionAttr.font) size=\(config.descripcionAttr.size) color=\(config.descripcionAttr.color) align=\(config.descripcionAttr.alignment)")
        print("   checkboxTexto: \"\(config.checkboxTexto)\"")
        print("   checkboxTextoAttr: font=\(config.checkboxTextoAttr.font) size=\(config.checkboxTextoAttr.size) color=\(config.checkboxTextoAttr.color)")
        print("   checkboxColor: \"\(config.checkboxColor)\"")
        print("   btnAceptar: texto=\"\(config.btnAceptar.texto)\" textoActivo=\(config.btnAceptar.colorTextoActivo) textoInactivo=\(config.btnAceptar.colorTextoInactivo) fondoActivo=\(config.btnAceptar.colorFondoActivo) fondoInactivo=\(config.btnAceptar.colorFondoInactivo)")
        print("   btnCancelar: texto=\"\(config.btnCancelar.texto)\" colorTexto=\(config.btnCancelar.colorTexto) colorFondo=\(config.btnCancelar.colorFondo)")
        print("")
        print("   [Computed] activeTextColor=\(activeTextColor) activeBgColor=\(activeBgColor)")
        print("   [Computed] inactiveTextColor=\(inactiveTextColor) inactiveBgColor=\(inactiveBgColor)")
        print("   [Estado] isChecked=\(isChecked)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
    }
}
