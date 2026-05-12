//
//  FormularioGeneralView.swift
//  CareAssistance
//
//  Created on 11/03/2026.
//

import Foundation
import SwiftUI
import CachedAsyncImage
import Helpers

// MARK: - Vista principal del formulario dinámico

struct FormularioGeneralView: View {
    let formulario: FormularioGeneral
    let onComplete: ([String: Any]) -> Void
    let onClose: () -> Void
    let isCloseable: Bool // NUEVO: Indica si se puede cerrar el modal
    
    @State private var respuestas: [UUID: RespuestaPregunta] = [:]
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Color de fondo (blanco/gris claro como en la imagen)
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header con título y subtítulo
                            HeaderFormularioView(titulos: formulario.titulos)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            
                            // Preguntas dinámicas (cada una en su propia card)
                            ForEach(formulario.preguntas) { pregunta in
                                PreguntaView(
                                    pregunta: pregunta,
                                    estilos: formulario.estilos,
                                    respuesta: binding(for: pregunta.id)
                                )
                                .padding(.horizontal, 16)
                            }
                            
                            // Espaciado para los botones fijos
                            Spacer(minLength: 100)
                        }
                        .padding(.bottom, 16)
                    }
                    
                    // Botones fijos en la parte inferior (como en la imagen)
                    HStack(spacing: 12) {
                        // Botón "Cerrar" - Solo se muestra si isCloseable == true
                        if isCloseable {
                            Button(action: {
                                HapticManager.impact(style: .light)
                                onClose()
                            }) {
                                Text("Cerrar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.0, green: 0.75, blue: 0.85)) // Cyan como en la imagen
                            .cornerRadius(25)
                            .bounceOnTap()
                        }

                        // Botón "Completar"
                        Button(action: {
                            HapticManager.impact(style: .medium)
                            submitFormulario()
                        }) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(formulario.estilos.textoBoton)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormularioCompleto() ? Color(red: 0.2, green: 0.5, blue: 0.85) : Color.gray.opacity(0.4))
                        .cornerRadius(25)
                        .bounceOnTap()
                        .disabled(isSubmitting || !isFormularioCompleto())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Helper para binding de respuestas
    private func binding(for id: UUID) -> Binding<RespuestaPregunta> {
        Binding(
            get: { respuestas[id] ?? RespuestaPregunta() },
            set: { respuestas[id] = $0 }
        )
    }
    
    // Validar si el formulario está completo
    private func isFormularioCompleto() -> Bool {
        for pregunta in formulario.preguntas {
            guard let respuesta = respuestas[pregunta.id] else { return false }
            
            // Si tiene alternativas, debe haber al menos una seleccionada
            if pregunta.alternativas.tieneAlternativas {
                if respuesta.opcionesSeleccionadas.isEmpty && respuesta.textoLibre.isEmpty {
                    return false
                }
            }
            
            // Si es campo condicional activo, debe estar completo
            if let regla = pregunta.regla,
               respuesta.opcionesSeleccionadas.contains(regla.respuestaActivadora) {
                if respuesta.campoCondicional.isEmpty {
                    return false
                }
            }
        }
        return true
    }
    
    // Submit del formulario
    private func submitFormulario() {
        guard !isSubmitting else { return }
        isSubmitting = true
        
        // Construir payload con respuestas
        var payload: [String: Any] = [:]
        
        for (index, pregunta) in formulario.preguntas.enumerated() {
            if let respuesta = respuestas[pregunta.id] {
                let key = "pregunta_\(index + 1)"
                payload[key] = respuesta.toDict()
            }
        }
        
        print("📤 [FormularioGeneralView] Enviando respuestas al handler...")
        print("   Total de preguntas con respuesta: \(payload.count)")
        
        // Llamar callback con payload
        // El handler en HomeView se encargará de:
        // 1. Llamar al servicio
        // 2. Mostrar loading
        // 3. Cerrar el modal si es exitoso
        // 4. Mantener el modal abierto si falla (como en Android)
        onComplete(payload)
        
        // El estado isSubmitting se mantendrá hasta que el handler termine
        // (el loading se muestra a nivel de HomeView)
    }
}

// MARK: - Header del formulario (exactamente como en la imagen)

private struct HeaderFormularioView: View {
    let titulos: TitulosFormulario
    
    var body: some View {
        VStack(spacing: 0) {
            // Título principal - centrado y en azul oscuro
            Text(titulos.titulo)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            
            // Subtítulo - texto más pequeño y gris/azul
            if !titulos.subtitulo.isEmpty {
                Text(titulos.subtitulo)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Vista de una pregunta (exactamente como en la imagen)

private struct PreguntaView: View {
    let pregunta: PreguntaFormulario
    let estilos: EstilosFormulario
    @Binding var respuesta: RespuestaPregunta
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Texto de la pregunta - azul oscuro y bold
            Text(pregunta.texto)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Alternativas (si las tiene)
            if pregunta.alternativas.tieneAlternativas {
                AlternativasView(
                    alternativas: pregunta.alternativas,
                    estilos: estilos,
                    seleccionadas: $respuesta.opcionesSeleccionadas,
                    textoLibre: $respuesta.textoLibre
                )
            }
            
            // Campo condicional (si aplica)
            if let regla = pregunta.regla,
               respuesta.opcionesSeleccionadas.contains(regla.respuestaActivadora) {
                CampoCondicionalView(
                    regla: regla,
                    estilos: estilos,
                    valor: $respuesta.campoCondicional
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Vista de alternativas (dropdown limpio como en la imagen)

private struct AlternativasView: View {
    let alternativas: AlternativasPregunta
    let estilos: EstilosFormulario
    @Binding var seleccionadas: Set<String>
    @Binding var textoLibre: String
    
    @State private var seleccionUnica: String = ""
    @State private var mostrarSheetMultiple: Bool = false
    @State private var seleccionesTemporales: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if alternativas.permiteMultiple {
                // Para selección múltiple (chips apilados VERTICALMENTE)
                VStack(alignment: .leading, spacing: 12) {
                    if !seleccionadas.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(seleccionadas), id: \.self) { opcion in
                                HStack(spacing: 6) {
                                    Text(opcion)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        seleccionadas.remove(opcion)
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    
                    // Botón para abrir el sheet de selección múltiple
                    Button(action: {
                        seleccionesTemporales = seleccionadas
                        mostrarSheetMultiple = true
                    }) {
                        HStack {
                            Text(seleccionadas.isEmpty ? "Selecciona opciones" : "Agregar más opciones")
                                .font(.system(size: 15))
                                .foregroundColor(seleccionadas.isEmpty ? Color.gray.opacity(0.6) : .primary)
                            Spacer()
                            Image(systemName: "chevron.up")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $mostrarSheetMultiple) {
                        MultiSelectSheetView(
                            opciones: alternativas.listaOpciones,
                            seleccionadas: $seleccionesTemporales,
                            onConfirmar: {
                                seleccionadas = seleccionesTemporales
                                mostrarSheetMultiple = false
                            },
                            onCancelar: {
                                mostrarSheetMultiple = false
                            }
                        )
                    }
                }
            } else {
                // PICKER para selección única (exactamente como en la imagen)
                Menu {
                    ForEach(alternativas.listaOpciones, id: \.self) { opcion in
                        Button(action: {
                            seleccionUnica = opcion
                            seleccionadas.removeAll()
                            seleccionadas.insert(opcion)
                        }) {
                            HStack {
                                Text(opcion)
                                Spacer()
                                if seleccionUnica == opcion {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(seleccionUnica.isEmpty ? "Selecciona una opción" : seleccionUnica)
                            .font(.system(size: 15))
                            .foregroundColor(seleccionUnica.isEmpty ? Color.gray.opacity(0.5) : Color(red: 0.2, green: 0.2, blue: 0.2))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Cuadro de texto (si aplica)
            if alternativas.cuadroTexto {
                TextField("Escribe tu respuesta", text: $textoLibre)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            }
        }
        .onAppear {
            if !alternativas.permiteMultiple, let primera = seleccionadas.first {
                seleccionUnica = primera
            }
        }
    }
}

// MARK: - Campo condicional (estilo consistente con el resto)

private struct CampoCondicionalView: View {
    let regla: ReglaCondicional
    let estilos: EstilosFormulario
    @Binding var valor: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(regla.nombreCampo)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
            
            if regla.esPickList {
                // Picker/Dropdown
                Menu {
                    ForEach(regla.opciones, id: \.self) { opcion in
                        Button(action: {
                            valor = opcion
                        }) {
                            HStack {
                                Text(opcion)
                                Spacer()
                                if valor == opcion {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(valor.isEmpty ? "Selecciona una opción" : valor)
                            .font(.system(size: 15))
                            .foregroundColor(valor.isEmpty ? Color.gray.opacity(0.5) : Color(red: 0.2, green: 0.2, blue: 0.2))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            } else {
                // TextField
                TextField(regla.nombreCampo, text: $valor)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Sheet de selección múltiple

private struct MultiSelectSheetView: View {
    let opciones: [String]
    @Binding var seleccionadas: Set<String>
    let onConfirmar: () -> Void
    let onCancelar: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Lista de opciones con checkboxes
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(opciones, id: \.self) { opcion in
                            Button(action: {
                                if seleccionadas.contains(opcion) {
                                    seleccionadas.remove(opcion)
                                } else {
                                    seleccionadas.insert(opcion)
                                }
                            }) {
                                HStack(spacing: 12) {
                                    // Checkbox visual
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(seleccionadas.contains(opcion) ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if seleccionadas.contains(opcion) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    // Texto de la opción
                                    Text(opcion)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(Color.white)
                            }
                            
                            // Divider entre opciones
                            if opcion != opciones.last {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Botones fijos en la parte inferior
                VStack(spacing: 12) {
                    // Botón Confirmar
                    Button(action: onConfirmar) {
                        Text("Confirmar (\(seleccionadas.count) seleccionadas)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    // Botón Cancelar
                    Button(action: onCancelar) {
                        Text("Cancelar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
            }
            .navigationTitle("Selecciona opciones")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .applySheetDetentsIfAvailable()
    }
}

// MARK: - Helper para aplicar detents en iOS 16+
private extension View {
    @ViewBuilder
    func applySheetDetentsIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }
}

// MARK: - Modelo de respuesta

struct RespuestaPregunta {
    var opcionesSeleccionadas: Set<String>
    var textoLibre: String
    var campoCondicional: String
    
    // Inicializador vacío (para uso interno en el formulario)
    init() {
        self.opcionesSeleccionadas = []
        self.textoLibre = ""
        self.campoCondicional = ""
    }
    
    // Inicializador que acepta arrays (para reconstrucción desde handler)
    init(opcionesSeleccionadas: [String], textoLibre: String, campoCondicional: String) {
        self.opcionesSeleccionadas = Set(opcionesSeleccionadas)
        self.textoLibre = textoLibre
        self.campoCondicional = campoCondicional
    }
    
    func toDict() -> [String: Any] {
        // Convertir opciones seleccionadas a formato "Opcion1;Opcion2;Opcion3"
        let opcionesString = Array(opcionesSeleccionadas).joined(separator: ";")
        
        return [
            "opcionesSeleccionadas": opcionesString,
            "textoLibre": textoLibre,
            "campoCondicional": campoCondicional
        ]
    }
}
