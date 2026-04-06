//
//  PopupConfirmDatosView.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import SwiftUI
import SDWebImageSwiftUI

/// Popup de confirmacion de datos personales con campos editables
/// Paso 6 del flujo: Nombre, Apellido, RUT (readonly), Fecha Nacimiento, Direccion
struct PopupConfirmDatosView: View {
    let config: PopupExamConfig
    var onConfirm: (_ nombre: String, _ apellido: String, _ fechaNacimiento: String, _ direccion: String, _ hasChanges: Bool) -> Void = { _, _, _, _, _ in }
    var onClose: () -> Void = {}
    @Binding var isLoading: Bool
    var spinnerColor: String = "#00BBDC"

    // Valores originales del paciente (para comparar cambios)
    let originalNombre: String
    let originalApellido: String
    let originalRut: String
    let originalFechaNacimiento: String
    let originalDireccion: String

    @State private var nombre: String = ""
    @State private var apellido: String = ""
    @State private var fechaNacimiento: String = ""
    @State private var direccion: String = ""
    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    private var allFieldsFilled: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !apellido.trimmingCharacters(in: .whitespaces).isEmpty &&
        !fechaNacimiento.trimmingCharacters(in: .whitespaces).isEmpty &&
        !direccion.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var hasChanges: Bool {
        nombre != originalNombre ||
        apellido != originalApellido ||
        fechaNacimiento != originalFechaNacimiento ||
        direccion != originalDireccion
    }

    // Atributos dinamicos de los labels de campos
    private var labelFont: String { config.labelAttr.font.isEmpty ? "FiraSans-Bold" : config.labelAttr.font }
    private var labelSize: CGFloat { CGFloat(Int(config.labelAttr.size) ?? 14) }
    private var labelColor: Color { Color(hex: config.labelAttr.color.isEmpty ? "#333F48" : config.labelAttr.color) }

    // Atributos dinamicos de los valores/respuestas de campos
    private var respFont: String { config.respuestaAttr.font.isEmpty ? "FiraSans-Regular" : config.respuestaAttr.font }
    private var respSize: CGFloat { CGFloat(Int(config.respuestaAttr.size) ?? 14) }
    private var respColor: Color { Color(hex: config.respuestaAttr.color.isEmpty ? "#5B6770" : config.respuestaAttr.color) }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { if !isLoading { onClose() } }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    // Icono
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
                        let size = CGFloat(Int(attr.size) ?? 13)
                        let color = Color(hex: attr.color.isEmpty ? "#333F48" : attr.color)
                        parseSalesforceText(config.descripcion, font: font, size: size, color: color)
                            .multilineTextAlignment(.center)
                    }

                    // Campos editables con labels dinamicos
                    VStack(spacing: 10) {
                        fieldWithLabel(label: "Nombre", text: $nombre, editable: true)
                        fieldWithLabel(label: "Apellido", text: $apellido, editable: true)
                        readonlyFieldWithLabel(label: "RUT", value: originalRut)
                        dateFieldWithLabel(label: "Fecha de Nacimiento")
                        fieldWithLabel(label: "Direccion", text: $direccion, editable: true)
                    }

                    // Botones
                    HStack(spacing: 12) {
                        // Cerrar
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
                            .disabled(isLoading)
                        }

                        // Confirmar / Continuar
                        Button {
                            if allFieldsFilled {
                                onConfirm(nombre, apellido, fechaNacimiento, direccion, hasChanges)
                            }
                        } label: {
                            Text(config.btnAceptar.texto.isEmpty ? "Continuar" : config.btnAceptar.texto)
                                .font(Font.custom("FiraSans-Medium", size: 14))
                                .foregroundColor(Color(hex: allFieldsFilled ? activeTextColor : inactiveTextColor))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: allFieldsFilled ? activeBgColor : inactiveBgColor))
                                .cornerRadius(8)
                        }
                        .disabled(!allFieldsFilled || isLoading)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 10)
                .padding(.horizontal, 32)
                .padding(.vertical, 60)
            }

            // Loading overlay con blur — mismo estilo que busqueda de examenes por categoria
            if isLoading {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(
                                tint: Color(hex: spinnerColor.isEmpty ? "#00BBDC" : spinnerColor)
                            ))
                            .scaleEffect(1.5)
                    )
            }
        }
        .onAppear {
            nombre = originalNombre
            apellido = originalApellido
            direccion = originalDireccion
            // Parse date y convertir a formato display (dd/MM/yyyy)
            if let date = parseDate(originalFechaNacimiento) {
                selectedDate = date
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "dd/MM/yyyy"
                fechaNacimiento = displayFormatter.string(from: date)
            } else {
                fechaNacimiento = originalFechaNacimiento
            }

            logPopupConfig()
        }
    }

    // MARK: - Field Views con labels dinamicos

    private func fieldWithLabel(label: String, text: Binding<String>, editable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Font.custom(labelFont, size: labelSize))
                .foregroundColor(labelColor)
            TextField(label, text: text)
                .font(Font.custom(respFont, size: respSize))
                .foregroundColor(respColor)
                .padding(10)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(text.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty ? Color.red.opacity(0.6) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private func readonlyFieldWithLabel(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Font.custom(labelFont, size: labelSize))
                .foregroundColor(labelColor)
            Text(value.isEmpty ? label : value)
                .font(Font.custom(respFont, size: respSize))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private func dateFieldWithLabel(label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Font.custom(labelFont, size: labelSize))
                .foregroundColor(labelColor)
            Button {
                showDatePicker.toggle()
            } label: {
                HStack {
                    Text(fechaNacimiento.isEmpty ? label : fechaNacimiento)
                        .font(Font.custom(respFont, size: respSize))
                        .foregroundColor(fechaNacimiento.isEmpty ? .gray : respColor)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding(10)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(fechaNacimiento.trimmingCharacters(in: .whitespaces).isEmpty ? Color.red.opacity(0.6) : Color.gray.opacity(0.2), lineWidth: 1)
                )
            }

            if showDatePicker {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: selectedDate) { newValue in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd/MM/yyyy"
                        fechaNacimiento = formatter.string(from: newValue)
                        showDatePicker = false
                    }
            }
        }
    }

    // MARK: - Helpers

    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) { return date }
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: dateString)
    }

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

    // MARK: - Logging

    private func logPopupConfig() {
        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [PopupConfirmDatos] CONFIGURACION DINAMICA (Elemento 5)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   iconURL: \"\(config.iconURL.isEmpty ? "(vacio)" : config.iconURL.prefix(60).description)\"")
        print("   titulo: \"\(config.titulo)\"")
        print("   tituloAttr: font=\(config.tituloAttr.font) size=\(config.tituloAttr.size) color=\(config.tituloAttr.color)")
        print("   descripcion: \"\(config.descripcion)\"")
        print("   descripcionAttr: font=\(config.descripcionAttr.font) size=\(config.descripcionAttr.size) color=\(config.descripcionAttr.color)")
        print("   labelAttr: font=\(config.labelAttr.font) size=\(config.labelAttr.size) color=\(config.labelAttr.color)")
        print("   respuestaAttr: font=\(config.respuestaAttr.font) size=\(config.respuestaAttr.size) color=\(config.respuestaAttr.color)")
        print("   btnAceptar: texto=\"\(config.btnAceptar.texto)\" textoActivo=\(config.btnAceptar.colorTextoActivo) textoInactivo=\(config.btnAceptar.colorTextoInactivo) fondoActivo=\(config.btnAceptar.colorFondoActivo) fondoInactivo=\(config.btnAceptar.colorFondoInactivo)")
        print("   btnCerrar: texto=\"\(config.btnCerrar.texto)\" colorTexto=\(config.btnCerrar.colorTexto) colorFondo=\(config.btnCerrar.colorFondo)")
        print("")
        print("   [Computed] labelFont=\"\(labelFont)\" labelSize=\(labelSize) labelColor=\(config.labelAttr.color)")
        print("   [Computed] respFont=\"\(respFont)\" respSize=\(respSize) respColor=\(config.respuestaAttr.color)")
        print("   [Computed] activeTextColor=\(activeTextColor) activeBgColor=\(activeBgColor)")
        print("   [Computed] inactiveTextColor=\(inactiveTextColor) inactiveBgColor=\(inactiveBgColor)")
        print("")
        print("   DATOS DEL PACIENTE (valores originales):")
        print("     nombre: \"\(originalNombre)\"")
        print("     apellido: \"\(originalApellido)\"")
        print("     rut: \"\(originalRut)\"")
        print("     fechaNacimiento: \"\(originalFechaNacimiento)\"")
        print("     direccion: \"\(originalDireccion)\"")
        print("")
        print("   ESTADO CAMPOS:")
        print("     nombre vacio: \(originalNombre.trimmingCharacters(in: .whitespaces).isEmpty)")
        print("     apellido vacio: \(originalApellido.trimmingCharacters(in: .whitespaces).isEmpty)")
        print("     fechaNac vacia: \(originalFechaNacimiento.trimmingCharacters(in: .whitespaces).isEmpty)")
        print("     direccion vacia: \(originalDireccion.trimmingCharacters(in: .whitespaces).isEmpty)")
        print("     allFieldsFilled: \(allFieldsFilled)")
        print("     boton Continuar HABILITADO: \(allFieldsFilled)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
    }
}
