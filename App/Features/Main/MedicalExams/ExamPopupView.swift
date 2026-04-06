//
//  ExamPopupView.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import SwiftUI
import SDWebImageSwiftUI

/// Parsea texto de Salesforce con **negrita** y <br><br> como saltos de linea
/// Retorna un Text compuesto con los estilos aplicados
func parseSalesforceText(_ raw: String, font: String, size: CGFloat, color: Color) -> Text {
    // Primero reemplazar <br><br> y <br> por saltos de linea
    let cleaned = raw
        .replacingOccurrences(of: "<br><br>", with: "\n\n")
        .replacingOccurrences(of: "<br>", with: "\n")

    // Separar por ** para encontrar segmentos en negrita
    let segments = cleaned.components(separatedBy: "**")
    var result = Text("")
    let boldFont = font.contains("Bold") ? font : font.replacingOccurrences(of: "Regular", with: "Bold").replacingOccurrences(of: "Medium", with: "Bold")

    for (index, segment) in segments.enumerated() {
        if segment.isEmpty { continue }
        if index % 2 == 1 {
            // Impar = dentro de ** ** = negrita
            result = result + Text(segment)
                .font(Font.custom(boldFont.isEmpty ? "FiraSans-Bold" : boldFont, size: size))
                .foregroundColor(color)
        } else {
            // Par = texto normal
            result = result + Text(segment)
                .font(Font.custom(font.isEmpty ? "FiraSans-Regular" : font, size: size))
                .foregroundColor(color)
        }
    }
    return result
}

/// Popup genérico reutilizable para PopupExamConfig
/// Usado por: PopupCategorias, PopupConfirmDatos, PopupExamenSinCosto,
///            PopupEnviarEmail, PopupExamenRealizado, PopupSugerencia
struct ExamPopupView: View {
    let config: PopupExamConfig
    var onAccept: () -> Void = {}
    var onClose: () -> Void = {}

    // Para PopupConfirmDatos: datos del paciente
    var patientData: [(label: String, value: String)]? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

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

                // Descripcion (soporta **negrita** y <br> saltos de linea)
                if !config.descripcion.isEmpty {
                    let attr = config.descripcionAttr
                    let font = attr.font.isEmpty ? "FiraSans-Regular" : attr.font
                    let size = CGFloat(Int(attr.size) ?? 14)
                    let color = Color(hex: attr.color.isEmpty ? "#333F48" : attr.color)
                    parseSalesforceText(config.descripcion, font: font, size: size, color: color)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // Datos del paciente (para PopupConfirmDatos)
                if let data = patientData, !data.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.label)
                                    .font(Font.custom(
                                        config.labelAttr.font.isEmpty ? "FiraSans-Bold" : config.labelAttr.font,
                                        size: CGFloat(Int(config.labelAttr.size) ?? 12)
                                    ))
                                    .foregroundColor(Color(hex: config.labelAttr.color.isEmpty ? "#666666" : config.labelAttr.color))
                                Text(item.value)
                                    .font(Font.custom(
                                        config.respuestaAttr.font.isEmpty ? "FiraSans-Regular" : config.respuestaAttr.font,
                                        size: CGFloat(Int(config.respuestaAttr.size) ?? 14)
                                    ))
                                    .foregroundColor(Color(hex: config.respuestaAttr.color.isEmpty ? "#333F48" : config.respuestaAttr.color))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }

                // Botones
                HStack(spacing: 12) {
                    // Boton cerrar/cancelar
                    if !config.btnCerrar.texto.isEmpty {
                        Button {
                            onClose()
                        } label: {
                            Text(config.btnCerrar.texto)
                                .font(Font.custom("FiraSans-Medium", size: 14))
                                .foregroundColor(Color(hex: config.btnCerrar.colorTexto.isEmpty ? "#666666" : config.btnCerrar.colorTexto))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: config.btnCerrar.colorFondo.isEmpty ? "#E0E0E0" : config.btnCerrar.colorFondo))
                                .cornerRadius(8)
                        }
                    }

                    // Boton aceptar/continuar
                    if !config.btnAceptar.texto.isEmpty {
                        Button {
                            onAccept()
                        } label: {
                            Text(config.btnAceptar.texto)
                                .font(Font.custom("FiraSans-Medium", size: 14))
                                .foregroundColor(Color(hex: acceptTextColor))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: acceptBgColor))
                                .cornerRadius(8)
                        }
                    }
                }

                // Si no hay botones configurados, mostrar boton por defecto
                if config.btnAceptar.texto.isEmpty && config.btnCerrar.texto.isEmpty {
                    Button {
                        onClose()
                    } label: {
                        Text("Cerrar")
                            .font(Font.custom("FiraSans-Medium", size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#387FC2"))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.horizontal, 32)
        }
    }

    // Usa colores activos si existen, sino los normales
    private var acceptTextColor: String {
        if !config.btnAceptar.colorTextoActivo.isEmpty {
            return config.btnAceptar.colorTextoActivo
        }
        return config.btnAceptar.colorTexto.isEmpty ? "#FFFFFF" : config.btnAceptar.colorTexto
    }

    private var acceptBgColor: String {
        if !config.btnAceptar.colorFondoActivo.isEmpty {
            return config.btnAceptar.colorFondoActivo
        }
        return config.btnAceptar.colorFondo.isEmpty ? "#387FC2" : config.btnAceptar.colorFondo
    }
}
