//
//  FormularioGeneralModels.swift
//  CareAssistance
//
//  Created on 11/03/2026.
//

import Foundation
import SwiftUI

// MARK: - Modelos de datos para Formulario General

/// Estilos parseados desde formato "fuente;tamaño;color;posicion"
struct EstiloTexto {
    let fuente: String
    let tamanio: Int
    let color: String
    let alineacion: TextAlignment
    
    var colorSwiftUI: Color {
        Color(hex: color)
    }
    
    var font: Font {
        Font.custom(fuente, size: CGFloat(tamanio))
    }
    
    static func parse(_ raw: String) -> EstiloTexto? {
        let parts = raw.split(separator: ";").map(String.init)
        guard parts.count >= 4 else { return nil }
        
        let alignment: TextAlignment
        switch parts[3].lowercased() {
        case "center": alignment = .center
        case "right": alignment = .trailing
        default: alignment = .leading
        }
        
        return EstiloTexto(
            fuente: parts[0],
            tamanio: Int(parts[1]) ?? 16,
            color: parts[2],
            alineacion: alignment
        )
    }
}

/// Estilos del botón "fuente;tamaño;colorTexto;colorFondo"
struct EstiloBoton {
    let fuente: String
    let tamanio: Int
    let colorTexto: String
    let colorFondo: String
    
    var colorTextoSwiftUI: Color {
        Color(hex: colorTexto)
    }
    
    var colorFondoSwiftUI: Color {
        Color(hex: colorFondo)
    }
    
    var font: Font {
        Font.custom(fuente, size: CGFloat(tamanio))
    }
    
    static func parse(_ raw: String) -> EstiloBoton? {
        let parts = raw.split(separator: ";").map(String.init)
        guard parts.count >= 4 else { return nil }
        
        return EstiloBoton(
            fuente: parts[0],
            tamanio: Int(parts[1]) ?? 16,
            colorTexto: parts[2],
            colorFondo: parts[3]
        )
    }
}

/// Encabezados del modal
struct TitulosFormulario {
    let logoURL: String?
    let titulo: String
    let estiloTitulo: EstiloTexto?
    let subtitulo: String
    let estiloSubtitulo: EstiloTexto?
}

/// Estilos globales del formulario
struct EstilosFormulario {
    let titulosPreguntas: EstiloTexto?
    let opcionesPreguntas: EstiloTexto?
    let respuestasPreguntas: EstiloTexto?
    let cuadroTexto: EstiloTexto?
    let textoBoton: String
    let estiloBoton: EstiloBoton?
    let colorFondoFormulario: String?
    let colorAcento: String?
}

/// Alternativas de una pregunta
struct AlternativasPregunta {
    let tieneAlternativas: Bool
    let seleccionMultiple: String // "No", "SiNinguno", etc.
    let listaOpciones: [String]
    let cuadroTexto: Bool
    
    var permiteMultiple: Bool {
        seleccionMultiple.lowercased().contains("si")
    }
    
    static func parse(_ raw: String) -> AlternativasPregunta {
        let parts = raw.split(separator: ";").map(String.init)
        guard parts.count >= 3 else {
            return AlternativasPregunta(
                tieneAlternativas: false,
                seleccionMultiple: "No",
                listaOpciones: [],
                cuadroTexto: false
            )
        }
        
        let tieneAlt = parts[0].lowercased() == "si"
        let selMultiple = parts[1]
        let cuadro = parts.last?.lowercased() == "si"
        
        // Opciones están en medio: parts[2..last-1]
        let opciones = parts.count > 3 ? Array(parts[2..<parts.count-1]) : []
        
        return AlternativasPregunta(
            tieneAlternativas: tieneAlt,
            seleccionMultiple: selMultiple,
            listaOpciones: opciones,
            cuadroTexto: cuadro
        )
    }
}

/// Regla condicional (campo que aparece según respuesta)
struct ReglaCondicional {
    let respuestaActivadora: String
    let tipoCampo: String // "Texto" o "PickList"
    let nombreCampo: String
    let opciones: [String]
    
    var esPickList: Bool {
        tipoCampo.lowercased() == "picklist"
    }
    
    static func parse(_ raw: String) -> ReglaCondicional? {
        guard !raw.isEmpty else { return nil }
        let parts = raw.split(separator: ";").map(String.init)
        guard parts.count >= 3 else { return nil }
        
        let opciones = parts.count > 3 ? Array(parts[3...]) : []
        
        return ReglaCondicional(
            respuestaActivadora: parts[0],
            tipoCampo: parts[1],
            nombreCampo: parts[2],
            opciones: opciones
        )
    }
}

/// Una pregunta completa del formulario
struct PreguntaFormulario: Identifiable {
    let id = UUID()
    let texto: String
    let alternativas: AlternativasPregunta
    let regla: ReglaCondicional?
}

/// Modelo completo del formulario
struct FormularioGeneral {
    let titulos: TitulosFormulario
    let estilos: EstilosFormulario
    let preguntas: [PreguntaFormulario]
    let nombreFlujoServicio: String?
}

// MARK: - Par Atributo-Valor auxiliar
struct AtributoValor {
    let atributo: String
    let valor: String
}
