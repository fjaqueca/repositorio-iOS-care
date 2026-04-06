//
//  PopupConfirmEmailView.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import SwiftUI
import SDWebImageSwiftUI

/// Popup de confirmacion de email del paciente
/// Paso 8 del flujo: campo email editable con validacion regex
/// Usa Elemento 7 del record ExamenesAutomatizados (PopUpEnviarExamenEmail)
struct PopupConfirmEmailView: View {
    let config: PopupExamConfig
    let originalEmail: String
    var onConfirm: (_ email: String, _ hasChanges: Bool) -> Void = { _, _ in }
    var onClose: () -> Void = {}

    @State private var email: String = ""
    @State private var hasEdited = false

    private var isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: email)
    }

    private var hasChanges: Bool {
        email != originalEmail
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 16) {
                // 7.1: Icono
                if !config.iconURL.isEmpty, let url = URL(string: config.iconURL) {
                    WebImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                }

                // 7.2-7.3: Titulo
                if !config.titulo.isEmpty {
                    let attr = config.tituloAttr
                    Text(config.titulo)
                        .font(Font.custom(
                            attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                            size: CGFloat(Int(attr.size) ?? 16)
                        ))
                        .foregroundColor(Color(hex: attr.color.isEmpty ? "#00BBDC" : attr.color))
                        .multilineTextAlignment(.center)
                }

                // 7.4-7.5: Descripcion
                if !config.descripcion.isEmpty {
                    let attr = config.descripcionAttr
                    let font = attr.font.isEmpty ? "FiraSans-Regular" : attr.font
                    let size = CGFloat(Int(attr.size) ?? 14)
                    let color = Color(hex: attr.color.isEmpty ? "#333F48" : attr.color)
                    parseSalesforceText(config.descripcion, font: font, size: size, color: color)
                        .multilineTextAlignment(.center)
                }

                // 7.6-7.10: Campo email con label y estilos dinámicos
                VStack(alignment: .leading, spacing: 4) {
                    // 7.6: Label "Correo" + 7.7: labelAttr
                    let labelAttr = config.labelAttr
                    Text("Correo")
                        .font(Font.custom(
                            labelAttr.font.isEmpty ? "FiraSans-Bold" : labelAttr.font,
                            size: CGFloat(Int(labelAttr.size) ?? 14)
                        ))
                        .foregroundColor(Color(hex: labelAttr.color.isEmpty ? "#333F48" : labelAttr.color))

                    // 7.8: respuestaAttr para el campo de texto
                    let respAttr = config.respuestaAttr
                    TextField("correo@ejemplo.com", text: $email)
                        .font(Font.custom(
                            respAttr.font.isEmpty ? "FiraSans-Regular" : respAttr.font,
                            size: CGFloat(Int(respAttr.size) ?? 14)
                        ))
                        .foregroundColor(Color(hex: respAttr.color.isEmpty ? "#5B6770" : respAttr.color))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(10)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    // 7.9: colorBordeConTexto, 7.10: colorBordeSinTexto
                                    hasEdited && !isValidEmail
                                        ? Color(hex: config.colorBordeSinTexto)
                                        : Color(hex: !email.isEmpty ? config.colorBordeConTexto : "#E0E0E0"),
                                    lineWidth: 1
                                )
                        )
                        .onChange(of: email) { _ in
                            hasEdited = true
                        }

                    if hasEdited && !isValidEmail {
                        Text("Ingrese un correo electrónico válido")
                            .font(Font.custom("FiraSans-Regular", size: 11))
                            .foregroundColor(Color(hex: config.colorBordeSinTexto))
                    }
                }

                // 7.11-7.12: Botones — Volver (izq) + Aceptar (der)
                HStack(spacing: 12) {
                    // 7.12: Botón Volver/Cerrar
                    if !config.btnCerrar.texto.isEmpty {
                        Button {
                            onClose()
                        } label: {
                            Text(config.btnCerrar.texto)
                                .font(Font.custom("FiraSans-Medium", size: 14))
                                .foregroundColor(Color(hex: config.btnCerrar.colorTexto.isEmpty ? "#FFFFFF" : config.btnCerrar.colorTexto))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: config.btnCerrar.colorFondo.isEmpty ? "#5B6770" : config.btnCerrar.colorFondo))
                                .cornerRadius(8)
                        }
                    }

                    // 7.11: Botón Aceptar/Continuar (con estados activo/inactivo)
                    Button {
                        if isValidEmail {
                            onConfirm(email, hasChanges)
                        }
                    } label: {
                        Text(config.btnAceptar.texto.isEmpty ? "Aceptar" : config.btnAceptar.texto)
                            .font(Font.custom("FiraSans-Medium", size: 14))
                            .foregroundColor(Color(hex: isValidEmail ? activeTextColor : inactiveTextColor))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: isValidEmail ? activeBgColor : inactiveBgColor))
                            .cornerRadius(8)
                    }
                    .disabled(!isValidEmail)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.horizontal, 32)
        }
        .onAppear {
            email = originalEmail
            logPopupEmailConfig()
        }
    }

    // MARK: - Logging

    private func logPopupEmailConfig() {
        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [PopupConfirmEmail] CONFIGURACION DINAMICA (Elemento 7 - PopUpEnviarExamenEmail)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   [7.1] iconURL: \"\(config.iconURL.isEmpty ? "(vacio)" : String(config.iconURL.prefix(60)))\"")
        print("   [7.2] titulo: \"\(config.titulo)\"")
        print("   [7.3] tituloAttr: font=\(config.tituloAttr.font) size=\(config.tituloAttr.size) color=\(config.tituloAttr.color)")
        print("   [7.4] descripcion: \"\(config.descripcion)\"")
        print("   [7.5] descripcionAttr: font=\(config.descripcionAttr.font) size=\(config.descripcionAttr.size) color=\(config.descripcionAttr.color)")
        print("   [7.7] labelAttr: font=\(config.labelAttr.font) size=\(config.labelAttr.size) color=\(config.labelAttr.color)")
        print("   [7.8] respuestaAttr: font=\(config.respuestaAttr.font) size=\(config.respuestaAttr.size) color=\(config.respuestaAttr.color)")
        print("   [7.9] colorBordeConTexto: \(config.colorBordeConTexto)")
        print("   [7.10] colorBordeSinTexto: \(config.colorBordeSinTexto)")
        print("   [7.11] btnAceptar: texto=\"\(config.btnAceptar.texto)\" textoActivo=\(config.btnAceptar.colorTextoActivo) textoInactivo=\(config.btnAceptar.colorTextoInactivo) fondoActivo=\(config.btnAceptar.colorFondoActivo) fondoInactivo=\(config.btnAceptar.colorFondoInactivo)")
        print("   [7.12] btnCerrar: texto=\"\(config.btnCerrar.texto)\" colorTexto=\(config.btnCerrar.colorTexto) colorFondo=\(config.btnCerrar.colorFondo)")
        print("")
        print("   EMAIL PACIENTE:")
        print("     originalEmail: \"\(originalEmail)\"")
        print("     isValidEmail: \(isValidEmail)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
    }

    // 7.11: Colores activo/inactivo del botón Aceptar
    private var activeTextColor: String {
        config.btnAceptar.colorTextoActivo.isEmpty
            ? (config.btnAceptar.colorTexto.isEmpty ? "#FFFFFF" : config.btnAceptar.colorTexto)
            : config.btnAceptar.colorTextoActivo
    }
    private var activeBgColor: String {
        config.btnAceptar.colorFondoActivo.isEmpty
            ? (config.btnAceptar.colorFondo.isEmpty ? "#00BBDC" : config.btnAceptar.colorFondo)
            : config.btnAceptar.colorFondoActivo
    }
    private var inactiveTextColor: String {
        config.btnAceptar.colorTextoInactivo.isEmpty ? "#5B6770" : config.btnAceptar.colorTextoInactivo
    }
    private var inactiveBgColor: String {
        config.btnAceptar.colorFondoInactivo.isEmpty ? "#EDEDED" : config.btnAceptar.colorFondoInactivo
    }
}
