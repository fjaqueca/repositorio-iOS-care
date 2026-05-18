//
//  AutomatedExams+Extension.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import Foundation
import RealmSwift

// MARK: - Helpers de parseo
private func parseFontName(_ raw: String) -> String {
    switch raw.lowercased().trimmingCharacters(in: .whitespaces) {
    case "firasans_bold":   return "FiraSans-Bold"
    case "firasans_italic": return "FiraSans-Italic"
    case "firasans_medium": return "FiraSans-Medium"
    default:                return "FiraSans-Regular"
    }
}

/// Mapea nombres de iconos en convención Salesforce a SF Symbols.
/// Soporta tres convenciones de naming:
///   - prefix `ic_*` (ic_calendar, ic_heart, etc.)
///   - inglés/español natural ("Calendar", "Calendario", "Filter", "Filtro")
///   - identificadores compactos (downloadicon, shareicon, deleteicon)
/// Fallback: nombre en minúsculas tal cual (intento de match directo con SF Symbol).
private func parseIconName(_ raw: String) -> String {
    let key = raw.trimmingCharacters(in: .whitespaces).lowercased()
    switch key {
    // Convención `ic_*`
    case "ic_stethoscope":                                  return "stethoscope"
    case "ic_pill", "ic_pills":                             return "pills.fill"
    case "ic_doc", "ic_document":                           return "doc.text"
    case "ic_heart":                                        return "heart.fill"
    case "ic_calendar":                                     return "calendar"
    case "ic_person_datos", "ic_person":                    return "person.fill"
    // Convención natural (es/en)
    case "calendar", "calendario":                          return "calendar"
    case "filtro", "filter":                                return "line.3.horizontal.decrease"
    case "descargar", "download":                           return "square.and.arrow.down"
    case "compartir", "share":                              return "square.and.arrow.up"
    case "eliminar", "delete", "trash":                     return "trash"
    case "estrella", "star":                                return "star"
    case "stethoscope":                                     return "stethoscope"
    case "pill", "pills":                                   return "pills.fill"
    case "heart":                                           return "heart.fill"
    case "person", "person_datos":                          return "person.fill"
    // Convención compacta
    case "downloadicon":                                    return "square.and.arrow.down"
    case "shareicon":                                       return "square.and.arrow.up"
    case "deleteicon":                                      return "trash"
    // Iconos de los containers de subir-examen (Elemento 10.7 / 10.8)
    case "clip", "ic_clip", "paperclip":                    return "paperclip"
    case "imagen", "image", "photo", "ic_image":            return "photo"
    case "cancelar", "cancel", "close", "x", "xmark":       return "xmark.circle.fill"
    default:                                                return key
    }
}

/// Parsea "font;size;color;align" -> TextExamAttributes (4 partes)
private func parseTextAttributes(_ raw: String?) -> TextExamAttributes {
    guard let raw = raw else { return TextExamAttributes() }
    let parts = raw.components(separatedBy: ";")
    var attr = TextExamAttributes()
    if parts.count >= 1 { attr.font = parseFontName(parts[0]) }
    if parts.count >= 2 { attr.size = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { attr.color = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { attr.alignment = parts[3].trimmingCharacters(in: .whitespaces) }
    return attr
}

/// Parsea "font;size;color;colorFondo;align" -> TextExamAttributes (5 partes con colorFondo)
private func parseTextAttributes5(_ raw: String?) -> TextExamAttributes {
    guard let raw = raw else { return TextExamAttributes() }
    let parts = raw.components(separatedBy: ";")
    var attr = TextExamAttributes()
    if parts.count >= 1 { attr.font = parseFontName(parts[0]) }
    if parts.count >= 2 { attr.size = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { attr.color = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { attr.colorFondo = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { attr.alignment = parts[4].trimmingCharacters(in: .whitespaces) }
    return attr
}

/// Parsea "texto;colorTexto;colorFondo" -> ButtonExamConfig (3 partes)
private func parseButton3(_ raw: String?) -> ButtonExamConfig {
    guard let raw = raw else { return ButtonExamConfig() }
    let parts = raw.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.colorTexto = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { btn.colorFondo = parts[2].trimmingCharacters(in: .whitespaces) }
    return btn
}

/// Parsea "texto;colorTextoActivo;colorTextoInactivo;colorBotonActivo;colorBotonInactivo" -> ButtonExamConfig (5 partes)
/// Orden Salesforce: Texto;ColorTextoActivo;ColorTextoInactivo;ColorBotonActivo;ColorBotonInactivo
private func parseButton5(_ raw: String?) -> ButtonExamConfig {
    guard let raw = raw else { return ButtonExamConfig() }
    let parts = raw.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.colorTextoActivo = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { btn.colorTextoInactivo = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.colorFondoActivo = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { btn.colorFondoInactivo = parts[4].trimmingCharacters(in: .whitespaces) }
    return btn
}

/// Parsea "texto;colorTextoInactivo;colorBotonInactivo;colorTextoActivo;colorBotonActivo" -> ButtonExamConfig
/// Orden invertido del Elem 6.10: Texto;ColorTextoInactivo;ColorBotonInactivo;ColorTextoActivo;ColorBotonActivo
private func parseButton5Inverted(_ raw: String?) -> ButtonExamConfig {
    guard let raw = raw else { return ButtonExamConfig() }
    let parts = raw.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.colorTextoInactivo = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { btn.colorFondoInactivo = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.colorTextoActivo = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { btn.colorFondoActivo = parts[4].trimmingCharacters(in: .whitespaces) }
    return btn
}

/// Parsea "texto;tipoFuente;size;colorTexto;colorFondo;posicion" -> ButtonExamConfig (6 partes con font)
private func parseButton6(_ raw: String?) -> ButtonExamConfig {
    guard let raw = raw else { return ButtonExamConfig() }
    let parts = raw.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.font = parseFontName(parts[1]) }
    if parts.count >= 3 { btn.size = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.colorTexto = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { btn.colorFondo = parts[4].trimmingCharacters(in: .whitespaces) }
    return btn
}

/// Parsea "texto;tipoFuente;size;colorTexto;colorHover" -> ButtonExamConfig (5 partes con font y hover)
private func parseButtonWithFont(_ raw: String?) -> ButtonExamConfig {
    guard let raw = raw else { return ButtonExamConfig() }
    let parts = raw.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.font = parseFontName(parts[1]) }
    if parts.count >= 3 { btn.size = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.colorTexto = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { btn.colorHover = parts[4].trimmingCharacters(in: .whitespaces) }
    return btn
}

/// Parsea "texto;tipoFuente;size;colorTexto" -> ButtonExamConfig (4 partes: botón volver)
private func parseButton4(_ raw: String?) -> ButtonExamConfig {
    guard let raw = raw else { return ButtonExamConfig() }
    let parts = raw.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.font = parseFontName(parts[1]) }
    if parts.count >= 3 { btn.size = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.colorTexto = parts[3].trimmingCharacters(in: .whitespaces) }
    return btn
}

// MARK: - Acceso dinamico a campos del BrandAccount
private extension BrandAccount {
    func getValor(section: Int, field: Int) -> String? {
        // Intentar primero con el formato camelCase (valorXYC)
        let camelKey = "valor\(section)\(field)C"
        if let val = valueForKey(camelKey) { return val }
        // Fallback: formato Salesforce explícito (Valor_X_Y__c)
        let sfKey = "Valor_\(section)_\(field)__c"
        return valueForKey(sfKey)
    }

    func getAtributo(section: Int, field: Int) -> String? {
        // Intentar primero con el formato camelCase (atributoXYC)
        let camelKey = "atributo\(section)\(field)C"
        if let val = valueForKey(camelKey) { return val }
        // Fallback: formato Salesforce explícito (Atributo_X_Y__c)
        let sfKey = "Atributo_\(section)_\(field)__c"
        return valueForKey(sfKey)
    }

    func getNombreElemento(_ index: Int) -> String? {
        return valueForKey("nombreElemento\(index)C")
    }

    private func valueForKey(_ key: String) -> String? {
        // Verificar que la propiedad existe en el schema antes de acceder por KVC
        guard objectSchema[key] != nil else { return nil }
        return (self as NSObject).value(forKey: key) as? String
    }
}

// MARK: - Parser principal
extension ExamsView {

    func loadAutomatedExamsConfig() -> AutomatedExamsUIState {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔬 [ExamenesAutomatizados] INICIO - loadAutomatedExamsConfig()")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        var state = AutomatedExamsUIState()

        guard let records = self.items.first?.records else {
            print("❌ [ExamenesAutomatizados] No hay records en BrandAccounts - items.first?.records es nil")
            print("   items.count = \(self.items.count)")
            return state
        }

        print("📋 [ExamenesAutomatizados] Total de records en BrandAccounts: \(records.count)")
        print("📋 [ExamenesAutomatizados] Nombres de records disponibles:")
        for (idx, record) in records.enumerated() {
            print("   [\(idx)] Name = \"\(record.Name ?? "nil")\"")
        }

        var customRecord: BrandAccount?
        var mainRecord: BrandAccount?
        var custom2Record: BrandAccount?

        for record in records {
            if record.Name == "ExamenesAutomatizadosCustom" {
                customRecord = record
            }
            if record.Name == "ExamenesAutomatizados" {
                mainRecord = record
            }
            if record.Name == "ExamenesAutomatizadosCustom2" {
                custom2Record = record
            }
        }

        // --- CUSTOM RECORD ---
        if let custom = customRecord {
            print("")
            print("✅ [ExamenesAutomatizados] Record 'ExamenesAutomatizadosCustom' ENCONTRADO")
            // ── DUMP COMPLETO del record Custom ──
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  DUMP COMPLETO: Record Name='ExamenesAutomatizadosCustom'   ║")
            print("╚══════════════════════════════════════════════════════════════╝")
            for elemIdx in 1...16 {
                guard let nombreElem = custom.getNombreElemento(elemIdx) else { continue }
                print("┌─ Elemento \(elemIdx): Nombre=\"\(nombreElem)\"")
                for fieldIdx in 1...16 {
                    let attr = custom.getAtributo(section: elemIdx, field: fieldIdx)
                    let val = custom.getValor(section: elemIdx, field: fieldIdx)
                    guard attr != nil || val != nil else { continue }
                    print("│  [\(elemIdx).\(fieldIdx)] Atributo=\"\(attr ?? "(nil)")\" → Valor=\"\((val ?? "(nil)").prefix(80))\"")
                }
                print("└────────────────────────────────────────────────")
            }
            print("═══════════════════════════════════════════════════════════════")
            print("")
            print("─── Parseando CUSTOM RECORD ───")
            loadBannersHub(from: custom, into: &state)
            print("   🖼️ BannersHub cargados: \(state.bannersHub.count)")
            for (i, b) in state.bannersHub.enumerated() {
                print("      Banner[\(i)]: imageURL=\(b.imageURL.prefix(60))...")
            }
            loadHeaderConfig(from: custom, into: &state)
            print("   📝 Header titulo: \"\(state.header.titulo)\"")
            print("   📝 Header descripcion: \"\(state.header.descripcion.prefix(80))\"")
            print("   📝 Header blockPosition: \"\(state.header.blockPosition)\"")
            print("   📝 Header botonVolver: texto=\"\(state.header.botonVolver.texto)\" color=\(state.header.botonVolver.colorTexto)")
            print("   📝 Header backArrowColor (2.8): \(state.header.backArrowColor)")
            loadSeccionesIniciales(from: custom, into: &state)
            print("   🔘 Secciones cargadas: \(state.secciones.count)")
            for sec in state.secciones {
                print("      Seccion \(sec.numero): \"\(sec.nombre)\" iconURL=\(sec.iconURL.isEmpty ? "(vacio)" : sec.iconURL.prefix(50).description)")
            }
            loadCategoriasListaConfig(from: custom, into: &state)
            print("   📋 CategoriasListaConfig:")
            print("      titulo: \"\(state.categoriasListaConfig.titulo)\"")
            print("      subtitulo: \"\(state.categoriasListaConfig.subtitulo.prefix(60))\"")
            print("      blockPosition: \"\(state.categoriasListaConfig.blockPosition)\"")
            loadCarritoConfig(from: custom, into: &state)
            print("   🛒 CarritoConfig:")
            print("      titulo: \"\(state.carrito.titulo)\"")
            print("      carritoColor: \(state.carrito.carritoColor)")
            print("      basureroColor: \(state.carrito.basureroColor)")
            print("      btnVerResumen: \"\(state.carrito.btnVerResumen.texto)\"")
            print("      btnLimpiar: \"\(state.carrito.btnLimpiar.texto)\"")
            loadModalSeleccionConfig(from: custom, into: &state)
            let sel = state.seleccionExamenes
            print("   🔘 ModalSeleccionConfig (Elemento 6):")
            print("      [6.1] tituloCategoriaAttr: font=\(sel.tituloCategoriaAttr.font) size=\(sel.tituloCategoriaAttr.size) color=\(sel.tituloCategoriaAttr.color)")
            print("      [6.2] seleccionarTodosTexto: \"\(sel.seleccionarTodosTexto)\"")
            print("      [6.3] seleccionarTodosAttr: font=\(sel.seleccionarTodosAttr.font) size=\(sel.seleccionarTodosAttr.size) color=\(sel.seleccionarTodosAttr.color)")
            print("      [6.4] textoListaAttr: font=\(sel.textoListaAttr.font) size=\(sel.textoListaAttr.size) color=\(sel.textoListaAttr.color) colorFondo=\(sel.textoListaAttr.colorFondo)")
            print("      [6.5] checkboxColor: \(sel.checkboxColorSeleccionado)")
            print("      [6.6] contadorTexto: \"\(sel.contadorTexto)\"")
            print("      [6.7] contadorAttr: font=\(sel.contadorAttr.font) size=\(sel.contadorAttr.size) color=\(sel.contadorAttr.color)")
            print("      [6.8] sinExamenesTexto: \"\(sel.sinExamenesTexto)\"")
            print("      [6.9] sinExamenesAttr: font=\(sel.sinExamenesAttr.font) size=\(sel.sinExamenesAttr.size) color=\(sel.sinExamenesAttr.color)")
            print("      [6.10] btnAgregar: texto=\"\(sel.btnAgregar.texto)\" textoActivo=\(sel.btnAgregar.colorTextoActivo) fondoActivo=\(sel.btnAgregar.colorFondoActivo) textoInactivo=\(sel.btnAgregar.colorTextoInactivo) fondoInactivo=\(sel.btnAgregar.colorFondoInactivo)")
            print("      [6.11] btnCancelar: texto=\"\(sel.btnCancelar.texto)\" colorTexto=\(sel.btnCancelar.colorTexto) colorFondo=\(sel.btnCancelar.colorFondo)")
            print("      [6.12] colorBarraScroll: \(sel.colorBarraScroll)")
            print("      [6.13] colorSpinner: \(sel.colorSpinner)")
            print("      colorFondoSeleccionado (derivado): \(sel.colorFondoSeleccionado)")
            loadPopupDetalleCarrito(from: custom, into: &state)
            print("   📋 PopupDetalleCarrito:")
            print("      titulo: \"\(state.popupDetalleCarrito.titulo)\"")
            print("      btnAceptar: \"\(state.popupDetalleCarrito.btnAceptar.texto)\"")
            print("      btnCerrar: \"\(state.popupDetalleCarrito.btnCerrar.texto)\"")
            loadVistaDetalleMisArchivos(from: custom, into: &state)
            let vdma = state.vistaDetalleMisArchivos
            print("   📁 VistaDetalleMisArchivos (Elemento 8): titulo=\"\(vdma.tituloTexto)\" backArrow=\(vdma.backArrowColor) btnEliminar=\"\(vdma.botonEliminar.texto)\"")
            // OLD: loadSeleccionarTodosConfig (Custom Elemento 9 era SeleccionarTodos)
            // NEW: Elemento 9 ahora es VistaDetallePrescripcionesMedicas — config
            // completa del detalle de una prescripción al hacer click sobre una card.
            loadVistaDetallePrescripcionesMedicas(from: custom, into: &state)
            let det = state.vistaDetallePrescripciones
            print("   📋 VistaDetallePrescripcionesMedicas (Elemento 9):")
            print("      [9.1] backArrow: \(det.backArrowColor)")
            print("      [9.2] titulo: \"\(det.tituloTexto)\" font=\(det.tituloAttr.font) size=\(det.tituloAttr.size) color=\(det.tituloAttr.color)")
            print("      [9.3] iconoEstrella: size=\(det.iconoEstrellaSize) color=\(det.iconoEstrellaColor)")
            print("      [9.4] tituloCard: font=\(det.tituloCardAttr.font) size=\(det.tituloCardAttr.size) color=\(det.tituloCardAttr.color)")
            print("      [9.5] badgeCreadoPaciente: texto=\"\(det.badgeCreadoPaciente.texto)\" icono=\(det.badgeCreadoPaciente.icono) colorTexto=\(det.badgeCreadoPaciente.colorTexto) colorFondo=\(det.badgeCreadoPaciente.colorFondo)")
            print("      [9.6] fecha: font=\(det.fechaAttr.font) size=\(det.fechaAttr.size) color=\(det.fechaAttr.color) formato=\"\(det.fechaFormato)\" icono=\"\(det.fechaIcono)\" colorIcono=\(det.fechaIconoColor)")
            print("      [9.7] indicacionesTitulo: \"\(det.indicacionesTitulo)\" font=\(det.indicacionesTituloAttr.font) size=\(det.indicacionesTituloAttr.size) color=\(det.indicacionesTituloAttr.color)")
            print("      [9.8] indicacionesTexto: font=\(det.indicacionesTextoAttr.font) size=\(det.indicacionesTextoAttr.size) color=\(det.indicacionesTextoAttr.color)")
            print("      [9.9] examenAdjuntoTitulo: \"\(det.examenAdjuntoTitulo)\" font=\(det.examenAdjuntoTituloAttr.font) size=\(det.examenAdjuntoTituloAttr.size) color=\(det.examenAdjuntoTituloAttr.color)")
            print("      [9.10] examenAdjuntoIcono: color=\(det.examenAdjuntoIconoColor) size=\(det.examenAdjuntoIconoSize)")
            print("      [9.11] btnDescargar: texto=\"\(det.botonDescargar.texto)\" colorTexto=\(det.botonDescargar.colorTexto) colorFondo=\(det.botonDescargar.colorFondo) icono=\(det.botonDescargar.icono) colorIcono=\(det.botonDescargar.colorIcono) colorBorde=\(det.botonDescargar.colorBorde)")
            print("      [9.12] btnCompartir: texto=\"\(det.botonCompartir.texto)\" colorTexto=\(det.botonCompartir.colorTexto) colorFondo=\(det.botonCompartir.colorFondo) icono=\(det.botonCompartir.icono) colorIcono=\(det.botonCompartir.colorIcono) colorBorde=\(det.botonCompartir.colorBorde)")
            print("      [9.13] btnSubirExamen: texto=\"\(det.botonSubirExamen.texto)\" colorTexto=\(det.botonSubirExamen.colorTexto) colorFondo=\(det.botonSubirExamen.colorFondo)")
            print("      [9.14] badgeRecetaMedica: texto=\"\(det.badgeRecetaMedica.texto)\" icono=\(det.badgeRecetaMedica.icono)")
            print("      [9.15] badgeExamenMedico: texto=\"\(det.badgeExamenMedico.texto)\" icono=\(det.badgeExamenMedico.icono)")
            print("      [9.16] btnVerDocumentoEnviado: texto=\"\(det.botonVerDocumentoEnviado.texto)\" size=\(det.botonVerDocumentoEnviado.size) colorTexto=\(det.botonVerDocumentoEnviado.colorTexto) colorFondo=\(det.botonVerDocumentoEnviado.colorFondo) font=\(det.botonVerDocumentoEnviado.font)")
            // OLD: loadSeccionMisArchivosDeSalud (Custom Elemento 10 era SeccionMisArchivosDeSalud)
            // NEW: Elemento 10 ahora es VistaSubirExamenDetallePrescripcionesMedicasMisArchivosDeSalud
            //      — config completa de la pantalla "Subir Examen".
            loadVistaSubirExamenDetalle(from: custom, into: &state)
            let sub = state.vistaSubirExamen
            print("   📋 VistaSubirExamenDetalle (Elemento 10):")
            print("      [10.1] backArrow: \(sub.backArrowColor)")
            print("      [10.2] titulo: \"\(sub.tituloTexto)\" font=\(sub.tituloAttr.font) size=\(sub.tituloAttr.size) color=\(sub.tituloAttr.color)")
            print("      [10.3] tipoDocumento: \"\(sub.tipoDocumentoTexto)\" font=\(sub.tipoDocumentoAttr.font) size=\(sub.tipoDocumentoAttr.size) color=\(sub.tipoDocumentoAttr.color) align=\(sub.tipoDocumentoAttr.alignment)")
            print("      [10.4] badgeCargado: texto=\"\(sub.badgeCargadoPorPaciente.texto)\" icono=\(sub.badgeCargadoPorPaciente.icono) colorFondo=\(sub.badgeCargadoPorPaciente.colorFondo)")
            print("      [10.5] adjuntarArchivo: \"\(sub.adjuntarArchivoTexto)\" font=\(sub.adjuntarArchivoAttr.font) size=\(sub.adjuntarArchivoAttr.size) color=\(sub.adjuntarArchivoAttr.color)")
            print("      [10.6] descripcionAdjuntar: \"\(sub.descripcionAdjuntarTexto)\" font=\(sub.descripcionAdjuntarAttr.font) size=\(sub.descripcionAdjuntarAttr.size) color=\(sub.descripcionAdjuntarAttr.color)")
            print("      [10.7] containerSinArchivo: borde=\(sub.containerSinArchivo.colorBorde) icono=\(sub.containerSinArchivo.icono) colorIcono=\(sub.containerSinArchivo.colorIcono) size=\(sub.containerSinArchivo.sizeIcono) fondo=\(sub.containerSinArchivo.colorFondoContainer)")
            print("      [10.8] containerConArchivo: borde=\(sub.containerConArchivo.colorBorde) icono=\(sub.containerConArchivo.icono) colorIcono=\(sub.containerConArchivo.colorIcono) size=\(sub.containerConArchivo.sizeIcono) textoFormato=\(sub.containerConArchivo.colorTextoFormato) iconoCancelar=\(sub.containerConArchivo.iconoCancelar) colorFondoBoton=\(sub.containerConArchivo.colorFondoBotonCancelar) colorCruz=\(sub.containerConArchivo.colorCruz) fondoContainer=\(sub.containerConArchivo.colorFondoContainer)")
            print("      [10.9] textoNota: \"\(sub.notaTexto)\" font=\(sub.notaAttr.font) size=\(sub.notaAttr.size) color=\(sub.notaAttr.color) align=\(sub.notaAttr.alignment)")
            print("      [10.10] botonEnviar: texto=\"\(sub.botonEnviar.texto)\" size=\(sub.botonEnviar.size) colorTexto=\(sub.botonEnviar.colorTexto) colorFondo=\(sub.botonEnviar.colorFondo) font=\(sub.botonEnviar.font)")
            loadDialogEliminarExamen(from: custom, into: &state)
            let dlg = state.dialogEliminarExamen
            print("   🗑️ DialogEliminarExamen (Elemento 11): titulo=\"\(dlg.titulo)\" descripcion=\"\(dlg.descripcion.prefix(60))\" btnAceptar=\"\(dlg.botonAceptar.texto)\" btnCancelar=\"\(dlg.botonCancelar.texto)\"")
            loadBadgesMisExamenes(from: custom, into: &state)
            let bdg = state.vistaMisArchivos
            print("   🏷️ VistaMisArchivos (Elemento 12): imagen=\"\(bdg.badgeExamenImagen.texto)\" receta=\"\(bdg.badgeRecetaMedica.texto)\" lab=\"\(bdg.badgeExamenLaboratorio.texto)\" orden=\"\(bdg.badgeOrdenExamen.texto)\" informe=\"\(bdg.badgeInformeMedico.texto)\" otros=\"\(bdg.badgeOtros.texto)\"")
            loadBotonesDetalleExamen(from: custom, into: &state)
            let btns = state.botonesDetalleExamen
            print("   🔘 BotonesDetalleExamen (Elemento 13): eliminar=\"\(btns.botonEliminar.texto)\" colorFondo=\(btns.botonEliminar.colorFondo) icono=\(btns.botonEliminar.icono) colorBorde=\(btns.botonEliminar.colorBorde) | descargar=\"\(btns.botonDescargar.texto)\" colorFondo=\(btns.botonDescargar.colorFondo) icono=\(btns.botonDescargar.icono) colorBorde=\(btns.botonDescargar.colorBorde) | compartir=\"\(btns.botonCompartir.texto)\" colorFondo=\(btns.botonCompartir.colorFondo) icono=\(btns.botonCompartir.icono) colorBorde=\(btns.botonCompartir.colorBorde) | titulo=\"\(btns.tituloArchivosAdjuntos)\"")
        } else {
            print("⚠️ [ExamenesAutomatizados] Record 'ExamenesAutomatizadosCustom' NO encontrado")
        }

        // --- MAIN RECORD ---
        if let main = mainRecord {
            print("")
            print("✅ [ExamenesAutomatizados] Record 'ExamenesAutomatizados' ENCONTRADO")
            // ── DUMP COMPLETO del record ──
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  DUMP COMPLETO: Record Name='ExamenesAutomatizados'         ║")
            print("╚══════════════════════════════════════════════════════════════╝")
            for elemIdx in 1...13 {
                guard let nombreElem = main.getNombreElemento(elemIdx) else { continue }
                print("┌─ Elemento \(elemIdx): Nombre=\"\(nombreElem)\"")
                for fieldIdx in 1...16 {
                    let attr = main.getAtributo(section: elemIdx, field: fieldIdx)
                    let val = main.getValor(section: elemIdx, field: fieldIdx)
                    guard attr != nil || val != nil else { continue }
                    print("│  [\(elemIdx).\(fieldIdx)] Atributo=\"\(attr ?? "(nil)")\" → Valor=\"\(val ?? "(nil)")\"")
                }
                print("└────────────────────────────────────────────────")
            }
            print("═══════════════════════════════════════════════════════════════")
            print("")
            print("─── Parseando MAIN RECORD ───")
            loadCategorias(from: main, into: &state)
            print("   📂 Categorias cargadas: \(state.categorias.count)")
            for (i, cat) in state.categorias.enumerated() {
                print("      Cat[\(i)]: \"\(cat.nombre)\" claveApi=\(cat.claveApi) tituloTip=\"\(cat.tituloTip.prefix(40))\" iconURL=\(cat.iconURL.isEmpty ? "(vacio)" : cat.iconURL.prefix(50).description)")
            }
            loadValidacion(from: main, into: &state)
            print("   🔍 Validacion: paisExamen=\"\(state.validacion.paisExamen)\" tipoExamen=\"\(state.validacion.tipoExamen)\" colorSpinner=\(state.validacion.colorSpinner)")
            loadPopups(from: main, into: &state)
            print("   💬 Popups cargados:")
            print("      PopupCategorias: titulo=\"\(state.popupCategorias.titulo)\" btnAceptar=\"\(state.popupCategorias.btnAceptar.texto)\"")
            print("      PopupConfirmDatos: titulo=\"\(state.popupConfirmDatos.titulo)\" btnAceptar=\"\(state.popupConfirmDatos.btnAceptar.texto)\"")
            print("      PopupConsentimiento: titulo=\"\(state.popupConsentimiento.titulo)\" checkbox=\"\(state.popupConsentimiento.checkboxTexto.prefix(40))\"")
            print("      PopupExamenSinCosto: titulo=\"\(state.popupExamenSinCosto.titulo)\"")
            print("      PopupEnviarEmail: titulo=\"\(state.popupEnviarEmail.titulo)\"")
            print("      PopupExamenRealizado:")
            print("         titulo: \"\(state.popupExamenRealizado.titulo)\"")
            print("         btnAceptar: texto=\"\(state.popupExamenRealizado.btnAceptar.texto)\"")
            print("         btnCerrar: texto=\"\(state.popupExamenRealizado.btnCerrar.texto)\"")
            print("      PopupCarga:")
            print("         titulo: \"\(state.popupCarga.titulo)\"")
            print("         colorSpinner: \(state.popupCarga.colorSpinner)")
            print("         segundosMostrar: \(state.popupCarga.segundosMostrar)")
            print("      PopupSugerencia: titulo=\"\(state.popupSugerencia.titulo)\"")
            loadSeleccionExamenesFromMain(from: main, into: &state)
            print("   📝 SeleccionExamenes (complemento Main Record):")
            print("      subtituloTexto: \"\(state.seleccionExamenes.subtituloTexto)\"")
            print("      subtituloAttr: font=\(state.seleccionExamenes.subtituloAttr.font) size=\(state.seleccionExamenes.subtituloAttr.size) color=\(state.seleccionExamenes.subtituloAttr.color)")
            loadCarritoFromMain(from: main, into: &state)
            print("   🛒 Carrito (complemento Main Record):")
            print("      antesDeContinuarTexto: \"\(state.carrito.antesDeContinuarTexto)\"")
            print("      antesDeContinuarAttr: font=\(state.carrito.antesDeContinuarAttr.font) size=\(state.carrito.antesDeContinuarAttr.size)")
            print("      subAntesDeContinuarTexto: \"\(state.carrito.subAntesDeContinuarTexto)\"")
            print("      subAntesDeContinuarAttr: font=\(state.carrito.subAntesDeContinuarAttr.font) size=\(state.carrito.subAntesDeContinuarAttr.size)")
            loadBadgesPrescripcionesMedicas(from: main, into: &state)
            print("   🏷️ BadgesPrescripcionesMedicas (Elemento 13): examenAuto=\"\(state.badgeExamenAutomatizado.texto)\" font=\(state.badgeExamenAutomatizado.font) size=\(state.badgeExamenAutomatizado.size) colorTexto=\(state.badgeExamenAutomatizado.colorTexto) colorFondo=\(state.badgeExamenAutomatizado.colorFondo)")
            print("      examenMedico=\"\(state.badgeOrdenMedica.texto)\" font=\(state.badgeOrdenMedica.font) size=\(state.badgeOrdenMedica.size) colorTexto=\(state.badgeOrdenMedica.colorTexto) colorFondo=\(state.badgeOrdenMedica.colorFondo)")
            print("      recetaMedica=\"\(state.badgeRecetaMedica.texto)\" font=\(state.badgeRecetaMedica.font) size=\(state.badgeRecetaMedica.size) colorTexto=\(state.badgeRecetaMedica.colorTexto) colorFondo=\(state.badgeRecetaMedica.colorFondo)")
            loadVistaPrincipalPrescripcionesMedicas(from: main, into: &state)
            let vista = state.vistaPrincipalPrescripciones
            print("   📋 VistaPrincipalPrescripcionesMedicas (Elemento 13):")
            print("      [13.1] backArrowColor: \"\(vista.backArrowColor)\"")
            print("      [13.2] titulo: \"\(vista.tituloTexto)\" font=\(vista.tituloAttr.font) size=\(vista.tituloAttr.size) color=\(vista.tituloAttr.color)")
            print("      [13.3] placeholder: \"\(vista.placeholderTexto)\" font=\(vista.placeholderAttr.font) size=\(vista.placeholderAttr.size) color=\(vista.placeholderAttr.color)")
            print("      [13.4] iconoFiltro: nombre=\"\(vista.iconoFiltro.nombre)\" size=\(vista.iconoFiltro.size) color=\(vista.iconoFiltro.color)")
            print("      [13.5] seleccionarTodos: texto=\"\(vista.seleccionarTodosTexto)\" font=\(vista.seleccionarTodosAttr.font) size=\(vista.seleccionarTodosAttr.size) color=\(vista.seleccionarTodosAttr.color) checkbox=\(vista.seleccionarTodosCheckboxColor)")
            print("      [13.6] contador: font=\(vista.contadorAttr.font) size=\(vista.contadorAttr.size) color=\(vista.contadorAttr.color)")
            print("      [13.7] botonDescargar: texto=\"\(vista.botonDescargar.texto)\" colorTexto=\(vista.botonDescargar.colorTexto) colorFondo=\(vista.botonDescargar.colorFondo) icono=\(vista.botonDescargar.icono)")
            print("      [13.8] botonCompartir: texto=\"\(vista.botonCompartir.texto)\" colorTexto=\(vista.botonCompartir.colorTexto) colorFondo=\(vista.botonCompartir.colorFondo) icono=\(vista.botonCompartir.icono)")
            print("      [13.9] atributosCard: barraV=\(vista.cardColorBarraVertical) checkbox=\(vista.cardColorCheckboxActivo) borde=\(vista.cardColorBordeActivo) estrella=\(vista.cardColorEstrella)")
            print("      [13.10] tituloCard: font=\(vista.tituloCardAttr.font) size=\(vista.tituloCardAttr.size) color=\(vista.tituloCardAttr.color)")
            print("      [13.14] fechaCard: font=\(vista.fechaCardAttr.font) size=\(vista.fechaCardAttr.size) color=\(vista.fechaCardAttr.color) formato=\"\(vista.fechaCardFormato)\" icono=\"\(vista.fechaCardIcono)\" colorIcono=\(vista.fechaCardIconoColor)")
            print("      [13.15] emptyState: texto=\"\(vista.emptyStateTexto)\" font=\(vista.emptyStateAttr.font) size=\(vista.emptyStateAttr.size) color=\(vista.emptyStateAttr.color)")
            print("      [13.16] descripcionCard: font=\(vista.descripcionCardAttr.font) size=\(vista.descripcionCardAttr.size) color=\(vista.descripcionCardAttr.color)")
        } else {
            print("⚠️ [ExamenesAutomatizados] Record 'ExamenesAutomatizados' NO encontrado")
        }

        // --- CUSTOM2 RECORD ---
        if let custom2 = custom2Record {
            print("")
            print("✅ [ExamenesAutomatizados] Record 'ExamenesAutomatizadosCustom2' ENCONTRADO")
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  DUMP COMPLETO: Record Name='ExamenesAutomatizadosCustom2'  ║")
            print("╚══════════════════════════════════════════════════════════════╝")
            for elemIdx in 1...11 {
                guard let nombreElem = custom2.getNombreElemento(elemIdx) else { continue }
                print("┌─ Elemento \(elemIdx): Nombre=\"\(nombreElem)\"")
                for fieldIdx in 1...16 {
                    let attr = custom2.getAtributo(section: elemIdx, field: fieldIdx)
                    let val = custom2.getValor(section: elemIdx, field: fieldIdx)
                    guard attr != nil || val != nil else { continue }
                    print("│  [\(elemIdx).\(fieldIdx)] Atributo=\"\(attr ?? "(nil)")\" → Valor=\"\((val ?? "(nil)").prefix(80))\"")
                }
                print("└────────────────────────────────────────────────")
            }
            print("═══════════════════════════════════════════════════════════════")
            print("")
            print("─── Parseando CUSTOM2 RECORD ───")
            loadDialogExamenesEnviados(from: custom2, into: &state)
            let dlgEnv = state.dialogExamenesEnviados
            print("   ✅ DialogExamenesEnviados (Elemento 1): icono=\"\(dlgEnv.icono)\" titulo=\"\(dlgEnv.titulo)\" descripcion=\"\(dlgEnv.descripcion.prefix(60))\" btnAceptar=\"\(dlgEnv.botonAceptar.texto)\"")
            loadDialogEliminarDocOrden(from: custom2, into: &state)
            let dlgElim = state.dialogEliminarDocOrden
            print("   🗑️ DialogEliminarDocOrden (Elemento 2): icono=\"\(dlgElim.icono)\" titulo=\"\(dlgElim.titulo)\" descripcion=\"\(dlgElim.descripcion.prefix(60))\" btnAceptar=\"\(dlgElim.botonAceptar.texto)\" btnCancelar=\"\(dlgElim.botonCancelar.texto)\"")
            loadDialogEliminarMiArchivo(from: custom2, into: &state)
            let dlgArch = state.dialogEliminarMiArchivo
            print("   🗑️ DialogEliminarMiArchivo (Elemento 3): titulo=\"\(dlgArch.titulo)\" descripcion=\"\(dlgArch.descripcion.prefix(60))\" btnAceptar=\"\(dlgArch.botonAceptar.texto)\" btnCancelar=\"\(dlgArch.botonCancelar.texto)\"")
        } else {
            print("⚠️ [ExamenesAutomatizados] Record 'ExamenesAutomatizadosCustom2' NO encontrado")
        }

        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔬 [ExamenesAutomatizados] FIN - loadAutomatedExamsConfig()")
        print("   Resumen: \(state.bannersHub.count) bannersHub, \(state.secciones.count) secciones, \(state.categorias.count) categorias")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")

        return state
    }
}

// MARK: - Custom Record Parsers

private func loadBannersHub(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 1: Banners pantalla principal
    // Solo agregar como banner si el atributo es una URL (los campos restantes del Elemento 1
    // pueden contener nombres de atributos de otras configs, no URLs de banners)
    for i in 1...16 {
        guard let imageURL = record.getAtributo(section: 1, field: i)?.trimmingCharacters(in: .whitespacesAndNewlines),
              imageURL.lowercased().hasPrefix("http") else { continue }
        let linkURL = record.getValor(section: 1, field: i) ?? ""
        let isNull = linkURL.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "null"
        state.bannersHub.append(BannerExamItem(
            imageURL: imageURL,
            linkURL: isNull ? "" : linkURL
        ))
    }
}

private func loadHeaderConfig(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 2: Header pantalla principal (Archivo de Salud / hub)
    for i in 1...16 {
        let atributo = record.getAtributo(section: 2, field: i)
        let valor = record.getValor(section: 2, field: i) ?? ""
        guard let atributo = atributo else { continue }
        let attrLower = atributo.lowercased()

        // 2.8 BackArrow(Color) — debe ir ANTES del check genérico de "titulo"
        // porque no contiene esas palabras pero matchea otros patrones.
        if attrLower.hasPrefix("backarrow") {
            state.header.backArrowColor = valor.trimmingCharacters(in: .whitespaces)
        } else if attrLower.contains("titulo") && !attrLower.contains("atributo") {
            state.header.titulo = valor
        } else if attrLower.hasPrefix("atributos") && attrLower.contains("titulo") {
            state.header.tituloAttr = parseTextAttributes(valor)
        } else if attrLower.contains("descripcion") && !attrLower.contains("atributo") {
            state.header.descripcion = valor
        } else if attrLower.hasPrefix("atributos") && attrLower.contains("descripcion") {
            state.header.descripcionAttr = parseTextAttributes(valor)
        } else if attrLower == "block" {
            state.header.blockPosition = valor
        } else if attrLower.contains("botonvolver") {
            state.header.botonVolver = parseButton4(valor)
        } else if attrLower == "colorcirculobannerseleccionado" {
            state.header.colorCirculoBannerSeleccionado = valor
        }
    }
}

private func loadSeccionesIniciales(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 3: Secciones iniciales + atributos de títulos
    // 3.1-3.3: Secciones (Nombre;Icono) — Si valor == "No"/"NO", la sección se oculta
    // 3.4-3.6: Atributos títulos de cada sección (TipoFuente;Size;ColorTexto;Posicion)

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [SeccionesIniciales] Cargando secciones del Elemento 3")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 3, field: i),
              !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 3, field: i) ?? ""
        let attrLower = atributo.lowercased()

        // Campos de atributos de título (3.4, 3.5, 3.6) — no aplica lógica de "No"
        if attrLower.contains("atributostituloprescripciones") {
            if let idx = state.secciones.firstIndex(where: { $0.numero == 1 }) {
                state.secciones[idx].tituloAttr = parseTextAttributes(valor)
                print("      [3.\(i)] ✅ tituloAttr sección 1 = font:\(state.secciones[idx].tituloAttr.font) size:\(state.secciones[idx].tituloAttr.size) color:\(state.secciones[idx].tituloAttr.color)")
            }
            continue
        } else if attrLower.contains("atributostituloMisarchivos") || attrLower.contains("atributostituloMisarchivos".lowercased()) {
            if let idx = state.secciones.firstIndex(where: { $0.numero == 2 }) {
                state.secciones[idx].tituloAttr = parseTextAttributes(valor)
                print("      [3.\(i)] ✅ tituloAttr sección 2 = font:\(state.secciones[idx].tituloAttr.font) size:\(state.secciones[idx].tituloAttr.size) color:\(state.secciones[idx].tituloAttr.color)")
            }
            continue
        } else if attrLower.contains("atributostituloexamenesautomatizados") {
            if let idx = state.secciones.firstIndex(where: { $0.numero == 3 }) {
                state.secciones[idx].tituloAttr = parseTextAttributes(valor)
                print("      [3.\(i)] ✅ tituloAttr sección 3 = font:\(state.secciones[idx].tituloAttr.font) size:\(state.secciones[idx].tituloAttr.size) color:\(state.secciones[idx].tituloAttr.color)")
            }
            continue
        }

        // Campos de sección (3.1, 3.2, 3.3)
        var numero = i
        if let range = atributo.range(of: "Seccion", options: .caseInsensitive) {
            let afterSeccion = atributo[range.upperBound...]
            let digits = afterSeccion.prefix(while: { $0.isNumber })
            if let n = Int(digits) { numero = n }
        }

        // Si el valor es "No" o "NO", NO agregar la sección (se oculta dinámicamente)
        if valor.lowercased() == "no" {
            print("      [3.\(i)] 🚫 Sección \(numero) OCULTA (valor=\"\(valor)\")")
            continue
        }

        let parts = valor.components(separatedBy: ";")
        let nombre = parts.count >= 1 ? parts[0].trimmingCharacters(in: .whitespaces) : ""
        let iconURL = parts.count >= 2 ? parts[1].trimmingCharacters(in: .whitespaces) : ""

        state.secciones.append(SeccionInicialExam(
            numero: numero,
            nombre: nombre,
            iconURL: iconURL,
            visible: true
        ))
        print("      [3.\(i)] ✅ Sección \(numero) VISIBLE → nombre:\"\(nombre)\"")
    }

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [SeccionesIniciales] RESULTADO: \(state.secciones.count) secciones visibles de las configuradas")
    for sec in state.secciones {
        print("   • Sección \(sec.numero): \"\(sec.nombre)\"")
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

private func loadCategoriasListaConfig(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 4: CustomListaCategoriasExamenes
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 4, field: i) else { continue }
        let valor = record.getValor(section: 4, field: i) ?? ""
        let attrLower = atributo.lowercased()

        if attrLower.contains("titulo") && !attrLower.contains("atributo") && !attrLower.contains("subtitulo") {
            state.categoriasListaConfig.titulo = valor
        } else if attrLower.hasPrefix("atributos") && attrLower.contains("titulo") && !attrLower.contains("subtitulo") {
            state.categoriasListaConfig.tituloAttr = parseTextAttributes(valor)
        } else if attrLower.contains("subtitulo") && !attrLower.contains("atributo") {
            state.categoriasListaConfig.subtitulo = valor
        } else if attrLower.hasPrefix("atributos") && attrLower.contains("subtitulo") {
            state.categoriasListaConfig.subtituloAttr = parseTextAttributes(valor)
        } else if attrLower.contains("block") {
            state.categoriasListaConfig.blockPosition = valor
        }
    }
}

private func loadCarritoConfig(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 5: CustomCarritoExamenes
    print("   🔍 [loadCarritoConfig] Sección 5 — leyendo campos 1-16")
    for i in 1...16 {
        let atributo = record.getAtributo(section: 5, field: i)
        let valor = record.getValor(section: 5, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        print("      [5.\(i)] atributo=\"\(atributo ?? "(nil)")\" valor=\"\(valor.prefix(80))\"")

        if let atributo = atributo {
            // Extraer nombre base sin paréntesis para comparación exacta
            let attrBase = (atributo.components(separatedBy: "(").first ?? "").lowercased()

            switch attrBase {
            case "titulocustomcarritoexamenes":
                state.carrito.titulo = valor
                print("         ✅ titulo = \"\(valor)\"")
            case "atributostitulocustomcarritoexamenes":
                state.carrito.tituloAttr = parseTextAttributes(valor)
                print("         ✅ tituloAttr = font:\(state.carrito.tituloAttr.font) size:\(state.carrito.tituloAttr.size) color:\(state.carrito.tituloAttr.color)")
            case "colorcarritoexamenes":
                state.carrito.carritoColor = valor
                print("         ✅ carritoColor = \(valor)")
            case "titulosinexamenesagregadoscustomcarritoexamenes":
                state.carrito.sinExamenesTexto = valor
                print("         ✅ sinExamenesTexto = \"\(valor)\"")
            case "atributostitulosinexamenesagregadoscustomcarritoexamenes":
                state.carrito.sinExamenesAttr = parseTextAttributes(valor)
                print("         ✅ sinExamenesAttr = font:\(state.carrito.sinExamenesAttr.font) size:\(state.carrito.sinExamenesAttr.size)")
            case "titulototalexamenescustomcarritoexamenes":
                state.carrito.totalExamenesTexto = valor
                print("         ✅ totalExamenesTexto = \"\(valor)\"")
            case "atributotitulototalexamenescustomcarritoexamenes":
                state.carrito.totalExamenesAttr = parseTextAttributes(valor)
                print("         ✅ totalExamenesAttr")
            case "atributotitulocategoriaagregadacustomcarritoexamenes":
                state.carrito.categoriaAttr = parseTextAttributes5(valor)
                print("         ✅ categoriaAttr (colorFondo=\(state.carrito.categoriaAttr.colorFondo))")
            case "atributostitulonombresexamenescustomcarritoexamenes":
                state.carrito.nombresExamenesAttr = parseTextAttributes(valor)
                print("         ✅ nombresExamenesAttr")
            case "atributocantidadexamenagregadocustomcarritoexamenes":
                state.carrito.cantidadAttr = parseTextAttributes(valor)
                print("         ✅ cantidadAttr")
            case "colortachobasuracustomcarritoexamenes":
                state.carrito.basureroColor = valor
                print("         ✅ basureroColor = \(valor)")
            case "botonverresumencustomcarritoexamenes":
                state.carrito.btnVerResumen = parseButton6(valor)
                print("         ✅ btnVerResumen = \"\(state.carrito.btnVerResumen.texto)\"")
            case "botonlimpiarexamenes":
                state.carrito.btnLimpiar = parseButtonWithFont(valor)
                print("         ✅ btnLimpiar = \"\(state.carrito.btnLimpiar.texto)\"")
            default:
                print("         ⚠️ atributo no reconocido: \"\(atributo)\" → base: \"\(attrBase)\"")
            }
        } else {
            // Atributo nil — limitación Realm: atributo5_7+ no existen en el schema
            switch i {
            case 7: // AtributoTituloTotalExamenesCustomCarritoExamenes
                state.carrito.totalExamenesAttr = parseTextAttributes(valor)
                print("         ✅ [pos.7] totalExamenesAttr")
            case 8: // AtributoTituloCategoriaAgregadaCustomCarritoExamenes
                state.carrito.categoriaAttr = parseTextAttributes5(valor)
                print("         ✅ [pos.8] categoriaAttr (colorFondo=\(state.carrito.categoriaAttr.colorFondo))")
            case 9: // AtributosTituloNombresExamenesCustomCarritoExamenes
                state.carrito.nombresExamenesAttr = parseTextAttributes(valor)
                print("         ✅ [pos.9] nombresExamenesAttr")
            case 10: // AtributoCantidadExamenAgregadoCustomCarritoExamenes
                state.carrito.cantidadAttr = parseTextAttributes(valor)
                print("         ✅ [pos.10] cantidadAttr")
            case 11: // ColorTachoBasuraCustomCarritoExamenes
                state.carrito.basureroColor = valor
                print("         ✅ [pos.11] basureroColor = \(valor)")
            case 12: // BotonVerResumenCustomCarritoExamenes
                state.carrito.btnVerResumen = parseButton6(valor)
                print("         ✅ [pos.12] btnVerResumen = \"\(state.carrito.btnVerResumen.texto)\"")
            case 13: // BotonLimpiarExamenes
                state.carrito.btnLimpiar = parseButtonWithFont(valor)
                print("         ✅ [pos.13] btnLimpiar = \"\(state.carrito.btnLimpiar.texto)\"")
            default:
                print("         ⚠️ [pos.\(i)] atributo nil, valor no asignado: \"\(valor.prefix(60))\"")
            }
        }
    }
}

private func loadModalSeleccionConfig(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 6: ModalSeleccionExamenes
    print("   🔍 [loadModalSeleccionConfig] Sección 6 — leyendo campos 1-16")
    for i in 1...16 {
        let atributo = record.getAtributo(section: 6, field: i)
        let valor = record.getValor(section: 6, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        print("      [6.\(i)] atributo=\"\(atributo ?? "(nil)")\" valor=\"\(valor.prefix(80))\"")

        if let atributo = atributo {
            let attrLower = atributo.lowercased()

            if attrLower.contains("titulocategoria") {
                state.seleccionExamenes.tituloCategoriaAttr = parseTextAttributes(valor)
                print("         ✅ tituloCategoriaAttr = font:\(state.seleccionExamenes.tituloCategoriaAttr.font) size:\(state.seleccionExamenes.tituloCategoriaAttr.size)")
            } else if attrLower.contains("textoseleccionartodos") && !attrLower.contains("atributo") {
                state.seleccionExamenes.seleccionarTodosTexto = valor
                print("         ✅ seleccionarTodosTexto = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("seleccionartodos") {
                state.seleccionExamenes.seleccionarTodosAttr = parseTextAttributes(valor)
                print("         ✅ seleccionarTodosAttr")
            } else if attrLower.contains("examenesseleccion") && !attrLower.contains("textoexamenes") {
                let attr = parseTextAttributes5(valor)
                state.seleccionExamenes.textoListaAttr = attr
                if !attr.colorFondo.isEmpty {
                    state.seleccionExamenes.colorFondoSeleccionado = attr.colorFondo
                }
                print("         ✅ textoListaAttr (colorFondo=\(attr.colorFondo))")
            } else if attrLower.contains("colorcheckbox") {
                state.seleccionExamenes.checkboxColorSeleccionado = valor
                print("         ✅ checkboxColor = \(valor)")
            } else if attrLower.contains("textoexamenesseleccionados") && !attrLower.contains("atributo") {
                state.seleccionExamenes.contadorTexto = valor
                print("         ✅ contadorTexto = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("examenesseleccionados") {
                state.seleccionExamenes.contadorAttr = parseTextAttributes(valor)
                print("         ✅ contadorAttr")
            } else if attrLower.contains("sinexamenesparaseleccionar") && !attrLower.contains("atributo") {
                state.seleccionExamenes.sinExamenesTexto = valor
                print("         ✅ sinExamenesTexto = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("sinexamenesparaseleccionar") {
                state.seleccionExamenes.sinExamenesAttr = parseTextAttributes(valor)
                print("         ✅ sinExamenesAttr = font:\(state.seleccionExamenes.sinExamenesAttr.font) size:\(state.seleccionExamenes.sinExamenesAttr.size)")
            } else if attrLower.contains("botonaceptar") {
                state.seleccionExamenes.btnAgregar = parseButton5Inverted(valor)
                print("         ✅ btnAgregar = \"\(state.seleccionExamenes.btnAgregar.texto)\"")
            } else if attrLower.contains("botoncancelar") {
                state.seleccionExamenes.btnCancelar = parseButton3(valor)
                print("         ✅ btnCancelar = \"\(state.seleccionExamenes.btnCancelar.texto)\"")
            } else if attrLower.contains("colorbarrascroll") {
                state.seleccionExamenes.colorBarraScroll = valor
                print("         ✅ colorBarraScroll = \(valor)")
            } else if attrLower.contains("colorspinner") {
                state.seleccionExamenes.colorSpinner = valor
                print("         ✅ colorSpinner = \(valor)")
            } else {
                print("         ⚠️ atributo no reconocido: \"\(atributo)\"")
            }
        } else {
            // Atributo nil — limitación Realm: atributo6_7+ no existen en el schema
            // Parseo por posición conocida según estructura Salesforce
            switch i {
            case 7: // AtributosTextoExamenesSeleccionadosModalSeleccionExamenes
                state.seleccionExamenes.contadorAttr = parseTextAttributes(valor)
                print("         ✅ [pos.7] contadorAttr = font:\(state.seleccionExamenes.contadorAttr.font) size:\(state.seleccionExamenes.contadorAttr.size)")
            case 8: // TextoSinExamenesParaSeleccionarModalSeleccionExamenes
                state.seleccionExamenes.sinExamenesTexto = valor
                print("         ✅ [pos.8] sinExamenesTexto = \"\(valor)\"")
            case 9: // AtributosTextoSinExamenesParaSeleccionarModalSeleccionExamenes
                state.seleccionExamenes.sinExamenesAttr = parseTextAttributes(valor)
                print("         ✅ [pos.9] sinExamenesAttr = font:\(state.seleccionExamenes.sinExamenesAttr.font) size:\(state.seleccionExamenes.sinExamenesAttr.size) color:\(state.seleccionExamenes.sinExamenesAttr.color)")
            case 10: // BotonAceptarModalSeleccionExamenes
                state.seleccionExamenes.btnAgregar = parseButton5Inverted(valor)
                print("         ✅ [pos.10] btnAgregar = \"\(state.seleccionExamenes.btnAgregar.texto)\"")
            case 11: // BotonCancelarModalSeleccionExamenes
                state.seleccionExamenes.btnCancelar = parseButton3(valor)
                print("         ✅ [pos.11] btnCancelar = \"\(state.seleccionExamenes.btnCancelar.texto)\"")
            case 12: // ColorBarraScrollModalSeleccionExamenes
                state.seleccionExamenes.colorBarraScroll = valor
                print("         ✅ [pos.12] colorBarraScroll = \(valor)")
            case 13: // ColorSpinnerModalSeleccionExamenes
                state.seleccionExamenes.colorSpinner = valor
                print("         ✅ [pos.13] colorSpinner = \(valor)")
            default:
                print("         ⚠️ [pos.\(i)] atributo nil, valor no asignado: \"\(valor.prefix(60))\"")
            }
        }
    }
}

private func loadPopupDetalleCarrito(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 7: PopUpVerDetalleCarrito
    print("   🔍 [loadPopupDetalleCarrito] Sección 7 — leyendo campos 1-16")
    for i in 1...16 {
        let atributo = record.getAtributo(section: 7, field: i)
        let valor = record.getValor(section: 7, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        print("      [7.\(i)] atributo=\"\(atributo ?? "(nil)")\" valor=\"\(valor.prefix(80))\"")

        if let atributo = atributo {
            let attrLower = atributo.lowercased()

            if attrLower.contains("icono") && !attrLower.contains("atributo") {
                state.popupDetalleCarrito.iconURL = valor
                print("         ✅ iconURL")
            } else if attrLower.contains("titulo") && !attrLower.contains("atributo") && !attrLower.contains("subtitulo") && !attrLower.contains("nombres") && !attrLower.contains("categoria") && !attrLower.contains("cantidad") {
                state.popupDetalleCarrito.titulo = valor
                print("         ✅ titulo = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("titulo") && !attrLower.contains("subtitulo") && !attrLower.contains("nombres") && !attrLower.contains("categoria") && !attrLower.contains("cantidad") {
                state.popupDetalleCarrito.tituloAttr = parseTextAttributes(valor)
                print("         ✅ tituloAttr")
            } else if attrLower.contains("subtitulo") && !attrLower.contains("atributo") {
                state.popupDetalleCarrito.subtitulo = valor
                print("         ✅ subtitulo = \"\(valor.prefix(60))\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("subtitulo") {
                state.popupDetalleCarrito.subtituloAttr = parseTextAttributes(valor)
                print("         ✅ subtituloAttr")
            } else if attrLower.contains("categoriaagregada") {
                state.popupDetalleCarrito.categoriaAttr = parseTextAttributes5(valor)
                print("         ✅ categoriaAttr")
            } else if attrLower.contains("nombresexamenes") {
                state.popupDetalleCarrito.nombresExamenesAttr = parseTextAttributes(valor)
                print("         ✅ nombresExamenesAttr")
            } else if attrLower.contains("cantidadexamen") {
                state.popupDetalleCarrito.cantidadAttr = parseTextAttributes(valor)
                print("         ✅ cantidadAttr")
            } else if attrLower.contains("colortachobasura") {
                state.popupDetalleCarrito.basureroColor = valor
                print("         ✅ basureroColor = \(valor)")
            } else if attrLower.contains("botonaceptar") || attrLower.contains("botoncontinuar") {
                state.popupDetalleCarrito.btnAceptar = parseButton3(valor)
                print("         ✅ btnAceptar = \"\(state.popupDetalleCarrito.btnAceptar.texto)\"")
            } else if attrLower.contains("botoncerrar") {
                state.popupDetalleCarrito.btnCerrar = parseButton3(valor)
                print("         ✅ btnCerrar = \"\(state.popupDetalleCarrito.btnCerrar.texto)\"")
            } else if attrLower.contains("colorbarrascroll") {
                state.popupDetalleCarrito.colorBarraScroll = valor
                print("         ✅ colorBarraScroll = \(valor)")
            } else {
                print("         ⚠️ atributo no reconocido: \"\(atributo)\"")
            }
        } else {
            // Atributo nil — limitación Realm: atributo7_7+ no existen en el schema
            switch i {
            case 7: // AtributosTituloNombresExamenesPopUpVerDetalleCarrito
                state.popupDetalleCarrito.nombresExamenesAttr = parseTextAttributes(valor)
                print("         ✅ [pos.7] nombresExamenesAttr")
            case 8: // AtributoCantidadExamenAgregadoPopUpVerDetalleCarrito
                state.popupDetalleCarrito.cantidadAttr = parseTextAttributes(valor)
                print("         ✅ [pos.8] cantidadAttr")
            case 9: // ColorTachoBasuraPopUpVerDetalleCarrito
                state.popupDetalleCarrito.basureroColor = valor
                print("         ✅ [pos.9] basureroColor = \(valor)")
            case 10: // BotonAceptarPopUpVerDetalleCarrito
                state.popupDetalleCarrito.btnAceptar = parseButton3(valor)
                print("         ✅ [pos.10] btnAceptar = \"\(state.popupDetalleCarrito.btnAceptar.texto)\"")
            case 11: // BotonCerrarPopUpVerDetalleCarrito
                state.popupDetalleCarrito.btnCerrar = parseButton3(valor)
                print("         ✅ [pos.11] btnCerrar = \"\(state.popupDetalleCarrito.btnCerrar.texto)\"")
            case 12: // ColorBarraScrollPopUpVerDetalleCarrito
                state.popupDetalleCarrito.colorBarraScroll = valor
                print("         ✅ [pos.12] colorBarraScroll = \(valor)")
            default:
                print("         ⚠️ [pos.\(i)] atributo nil, valor no asignado: \"\(valor.prefix(60))\"")
            }
        }
    }
}

// MARK: - Elemento 9 (Custom): VistaDetallePrescripcionesMedicas
// Parser de la config completa del DETALLE de una prescripción médica
// (cuando el usuario hace click sobre una card y navega al detail view).
// Reemplaza al viejo loadSeleccionarTodosConfig — la config de "Seleccionar
// Todos" se movió al Elemento 13.5 (VistaPrincipalPrescripcionesMedicas).
private func loadVistaDetallePrescripcionesMedicas(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [VistaDetallePrescripciones] Buscando Elemento 9")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    var matched = false
    for elemIdx in 1...16 {
        let raw = record.getNombreElemento(elemIdx)
        print("   [\(elemIdx)] nombreElemento = \(raw.map { "\"\($0)\"" } ?? "nil")")
        guard let nombreElemento = raw else { continue }
        let normalized = nombreElemento.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.caseInsensitiveCompare("VistaDetallePrescripcionesMedicas") == .orderedSame else { continue }
        print("   ✅ [\(elemIdx)] MATCH — parseando atributos del Elemento 9")
        matched = true

        for i in 1...16 {
            guard let atributo = record.getAtributo(section: elemIdx, field: i), !atributo.isEmpty else { continue }
            let valor = record.getValor(section: elemIdx, field: i) ?? ""
            let parts = valor.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }

            switch atributo {
            // 9.1 BackArrow(Color)
            case "BackArrow(Color)":
                state.vistaDetallePrescripciones.backArrowColor = valor.trimmingCharacters(in: .whitespaces)

            // 9.2 TituloGeneralDetallePrescripcionesMedicas(Fuente;Texto;ColorTexto;Size)
            case "TituloGeneralDetallePrescripcionesMedicas(Fuente;Texto;ColorTexto;Size)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.tituloAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaDetallePrescripciones.tituloTexto = parts[1] }
                if parts.count >= 3 { state.vistaDetallePrescripciones.tituloAttr.color = parts[2] }
                if parts.count >= 4 { state.vistaDetallePrescripciones.tituloAttr.size = parts[3] }

            // 9.3 IconoEstrella(Size;Color)
            case "IconoEstrella(Size;Color)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.iconoEstrellaSize = parts[0] }
                if parts.count >= 2 { state.vistaDetallePrescripciones.iconoEstrellaColor = parts[1] }

            // 9.4 AtributosTituloCardDetalle(Fuente;ColorTexto;Size)
            case "AtributosTituloCardDetalle(Fuente;ColorTexto;Size)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.tituloCardAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaDetallePrescripciones.tituloCardAttr.color = parts[1] }
                if parts.count >= 3 { state.vistaDetallePrescripciones.tituloCardAttr.size = parts[2] }

            // 9.5 BadgeDetalleTipoPrescripcionesMedicas(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
            case "BadgeDetalleTipoPrescripcionesMedicas(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)":
                state.vistaDetallePrescripciones.badgeCreadoPaciente = parseDetalleBadge(parts: parts)

            // 9.6 FechaDetallePrescripcion(Fuente;Size;Color;Formato;Icono;ColorIcono)
            case "FechaDetallePrescripcion(Fuente;Size;Color;Formato;Icono;ColorIcono)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.fechaAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaDetallePrescripciones.fechaAttr.size = parts[1] }
                if parts.count >= 3 { state.vistaDetallePrescripciones.fechaAttr.color = parts[2] }
                if parts.count >= 4 { state.vistaDetallePrescripciones.fechaFormato = mapSalesforceDateFormatToIOS(parts[3]) }
                if parts.count >= 5 { state.vistaDetallePrescripciones.fechaIcono = parseIconName(parts[4]) }
                if parts.count >= 6 { state.vistaDetallePrescripciones.fechaIconoColor = parts[5] }

            // 9.7 DetalleIndicaciones(TextoTitulo;Fuente;Size;ColorTexto;Posicion)
            case "DetalleIndicaciones(TextoTitulo;Fuente;Size;ColorTexto;Posicion)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.indicacionesTitulo = parts[0] }
                if parts.count >= 2 { state.vistaDetallePrescripciones.indicacionesTituloAttr.font = parseFontName(parts[1]) }
                if parts.count >= 3 { state.vistaDetallePrescripciones.indicacionesTituloAttr.size = parts[2] }
                if parts.count >= 4 { state.vistaDetallePrescripciones.indicacionesTituloAttr.color = parts[3] }
                if parts.count >= 5 { state.vistaDetallePrescripciones.indicacionesTituloAttr.alignment = parts[4] }

            // 9.8 AtributosDetalleIndicaciones(Fuente;Size;Color)
            case "AtributosDetalleIndicaciones(Fuente;Size;Color)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.indicacionesTextoAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaDetallePrescripciones.indicacionesTextoAttr.size = parts[1] }
                if parts.count >= 3 { state.vistaDetallePrescripciones.indicacionesTextoAttr.color = parts[2] }

            // 9.9 DetalleExamenAdjunto(TextoTitulo;Fuente;Size;ColorTexto;Posicion)
            case "DetalleExamenAdjunto(TextoTitulo;Fuente;Size;ColorTexto;Posicion)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.examenAdjuntoTitulo = parts[0] }
                if parts.count >= 2 { state.vistaDetallePrescripciones.examenAdjuntoTituloAttr.font = parseFontName(parts[1]) }
                if parts.count >= 3 { state.vistaDetallePrescripciones.examenAdjuntoTituloAttr.size = parts[2] }
                if parts.count >= 4 { state.vistaDetallePrescripciones.examenAdjuntoTituloAttr.color = parts[3] }
                if parts.count >= 5 { state.vistaDetallePrescripciones.examenAdjuntoTituloAttr.alignment = parts[4] }

            // 9.10 ColorIconoExamenAdjunto(Color;Size)
            case "ColorIconoExamenAdjunto(Color;Size)":
                if parts.count >= 1 { state.vistaDetallePrescripciones.examenAdjuntoIconoColor = parts[0] }
                if parts.count >= 2 { state.vistaDetallePrescripciones.examenAdjuntoIconoSize = parts[1] }

            // 9.11 BotonDescargarDetalle(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)
            case "BotonDescargarDetalle(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)":
                state.vistaDetallePrescripciones.botonDescargar = parseBotonAccionDetalle(parts: parts)

            // 9.12 BotonCompartirDetalle(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)
            case "BotonCompartirDetalle(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)":
                state.vistaDetallePrescripciones.botonCompartir = parseBotonAccionDetalle(parts: parts)

            // 9.13 BotonSubirExamen(Texto;ColorTexto;ColorFondo;TipoFuente;Size)
            case "BotonSubirExamen(Texto;ColorTexto;ColorFondo;TipoFuente;Size)":
                var btn = ButtonExamConfig()
                if parts.count >= 1 { btn.texto = parts[0] }
                if parts.count >= 2 { btn.colorTexto = parts[1] }
                if parts.count >= 3 { btn.colorFondo = parts[2] }
                if parts.count >= 4 { btn.font = parseFontName(parts[3]) }
                if parts.count >= 5 { btn.size = parts[4] }
                state.vistaDetallePrescripciones.botonSubirExamen = btn

            // 9.14 BadgeDetalleTipoRecetaMedica(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
            case "BadgeDetalleTipoRecetaMedica(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)":
                state.vistaDetallePrescripciones.badgeRecetaMedica = parseDetalleBadge(parts: parts)

            // 9.15 BadgeDetalleTipoExamenMedico(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
            case "BadgeDetalleTipoExamenMedico(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)":
                state.vistaDetallePrescripciones.badgeExamenMedico = parseDetalleBadge(parts: parts)

            // 9.16 BotonVerDocumentoEnviado(Texto;Size;ColorTexto;ColorFondo;TipoFuente)
            // Botón que reemplaza a `BotonSubirExamen` cuando la prescripción
            // ya tiene un documento adjunto. Formato distinto al 9.13:
            // aquí Size va en la 2ª posición, no en la última.
            case "BotonVerDocumentoEnviado(Texto;Size;ColorTexto;ColorFondo;TipoFuente)":
                var btn = ButtonExamConfig()
                if parts.count >= 1 { btn.texto = parts[0] }
                if parts.count >= 2 { btn.size = parts[1] }
                if parts.count >= 3 { btn.colorTexto = parts[2] }
                if parts.count >= 4 { btn.colorFondo = parts[3] }
                if parts.count >= 5 { btn.font = parseFontName(parts[4]) }
                state.vistaDetallePrescripciones.botonVerDocumentoEnviado = btn

            default:
                print("      ⚠️ [VistaDetallePrescripciones] Atributo no reconocido: \"\(atributo)\" valor=\"\(valor.prefix(60))\"")
            }
        }
        break
    }
    if !matched {
        print("   ⚠️ [VistaDetallePrescripciones] NO se encontró ningún Elemento con nombre \"VistaDetallePrescripcionesMedicas\". Config quedó vacía.")
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

/// Parser de un BadgeDetalleConfig con formato común:
/// `Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono` (6 partes).
/// Usado por 9.5, 9.14, 9.15 y 9.16.
private func parseDetalleBadge(parts: [String]) -> BadgeDetalleConfig {
    var badge = BadgeDetalleConfig()
    if parts.count >= 1 { badge.texto = parts[0] }
    if parts.count >= 2 { badge.colorTexto = parts[1] }
    if parts.count >= 3 { badge.colorFondo = parts[2] }
    if parts.count >= 4 { badge.font = parseFontName(parts[3]) }
    if parts.count >= 5 { badge.size = parts[4] }
    if parts.count >= 6 { badge.icono = parseIconName(parts[5]) }
    return badge
}

/// Parser de un ButtonExamConfig con formato:
/// `TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde` (8 partes).
/// Usado por 9.11 (Descargar) y 9.12 (Compartir).
private func parseBotonAccionDetalle(parts: [String]) -> ButtonExamConfig {
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.font = parseFontName(parts[0]) }
    if parts.count >= 2 { btn.texto = parts[1] }
    if parts.count >= 3 { btn.colorTexto = parts[2] }
    if parts.count >= 4 { btn.size = parts[3] }
    if parts.count >= 5 { btn.colorFondo = parts[4] }
    if parts.count >= 6 { btn.icono = parseIconName(parts[5]) }
    if parts.count >= 7 { btn.colorIcono = parts[6] }
    if parts.count >= 8 { btn.colorBorde = parts[7] }
    return btn
}

// MARK: - Elemento 10 (Custom): VistaSubirExamenDetallePrescripcionesMedicasMisArchivosDeSalud
// Parser de la config completa de la pantalla "Subir Examen" (flujo compartido
// entre Prescripciones Médicas y Mis Archivos de Salud).
// Reemplaza al viejo loadSeccionMisArchivosDeSalud — los badges del detail
// view se movieron al Elemento 9.
private func loadVistaSubirExamenDetalle(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [VistaSubirExamen] Buscando Elemento 10")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    var matched = false
    for elemIdx in 1...16 {
        let raw = record.getNombreElemento(elemIdx)
        print("   [\(elemIdx)] nombreElemento = \(raw.map { "\"\($0)\"" } ?? "nil")")
        guard let nombreElemento = raw else { continue }
        let normalized = nombreElemento.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.caseInsensitiveCompare("VistaSubirExamenDetallePrescripcionesMedicasMisArchivosDeSalud") == .orderedSame else { continue }
        print("   ✅ [\(elemIdx)] MATCH — parseando atributos del Elemento 10")
        matched = true

        for i in 1...16 {
            guard let atributo = record.getAtributo(section: elemIdx, field: i), !atributo.isEmpty else { continue }
            let valor = record.getValor(section: elemIdx, field: i) ?? ""
            let parts = valor.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }

            switch atributo {
            // 10.1 BackArrow(Color)
            case "BackArrow(Color)":
                state.vistaSubirExamen.backArrowColor = valor.trimmingCharacters(in: .whitespaces)

            // 10.2 TituloGeneralSubirExamenDetallePrescripcionesMedicas(Fuente;Texto;ColorTexto;Size)
            case "TituloGeneralSubirExamenDetallePrescripcionesMedicas(Fuente;Texto;ColorTexto;Size)":
                if parts.count >= 1 { state.vistaSubirExamen.tituloAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaSubirExamen.tituloTexto = parts[1] }
                if parts.count >= 3 { state.vistaSubirExamen.tituloAttr.color = parts[2] }
                if parts.count >= 4 { state.vistaSubirExamen.tituloAttr.size = parts[3] }

            // 10.3 TextoListaTipoDocumentoASubir(Fuente;Texto;ColorTexto;Size;Position)
            case "TextoListaTipoDocumentoASubir(Fuente;Texto;ColorTexto;Size;Position)":
                if parts.count >= 1 { state.vistaSubirExamen.tipoDocumentoAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaSubirExamen.tipoDocumentoTexto = parts[1] }
                if parts.count >= 3 { state.vistaSubirExamen.tipoDocumentoAttr.color = parts[2] }
                if parts.count >= 4 { state.vistaSubirExamen.tipoDocumentoAttr.size = parts[3] }
                if parts.count >= 5 { state.vistaSubirExamen.tipoDocumentoAttr.alignment = parts[4] }

            // 10.4 BadgeCargadoPorElPacienteVerDocumentoEnviado
            //      (Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
            case "BadgeCargadoPorElPacienteVerDocumentoEnviado(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)":
                state.vistaSubirExamen.badgeCargadoPorPaciente = parseDetalleBadge(parts: parts)

            // 10.5 TextoAdjuntarArchivo(Fuente;Texto;ColorTexto;Size;Position)
            case "TextoAdjuntarArchivo(Fuente;Texto;ColorTexto;Size;Position)":
                if parts.count >= 1 { state.vistaSubirExamen.adjuntarArchivoAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaSubirExamen.adjuntarArchivoTexto = parts[1] }
                if parts.count >= 3 { state.vistaSubirExamen.adjuntarArchivoAttr.color = parts[2] }
                if parts.count >= 4 { state.vistaSubirExamen.adjuntarArchivoAttr.size = parts[3] }
                if parts.count >= 5 { state.vistaSubirExamen.adjuntarArchivoAttr.alignment = parts[4] }

            // 10.6 DescripcionAdjuntarArchivo(Fuente;Texto;ColorTexto;Size;Position)
            case "DescripcionAdjuntarArchivo(Fuente;Texto;ColorTexto;Size;Position)":
                if parts.count >= 1 { state.vistaSubirExamen.descripcionAdjuntarAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaSubirExamen.descripcionAdjuntarTexto = parts[1] }
                if parts.count >= 3 { state.vistaSubirExamen.descripcionAdjuntarAttr.color = parts[2] }
                if parts.count >= 4 { state.vistaSubirExamen.descripcionAdjuntarAttr.size = parts[3] }
                if parts.count >= 5 { state.vistaSubirExamen.descripcionAdjuntarAttr.alignment = parts[4] }

            // 10.7 AtributoContainerSinArchivoAdjunto
            //      (ColorBorde;Icono;ColorIcono;SizeIcono;ColorFondoContainer)
            // Tolerante: si Salesforce envía solo 4 partes (omite SizeIcono),
            // detectamos por el formato de la 4ta — si arranca con "#" es color
            // de fondo del container; si es numérico es el size.
            case "AtributoContainerSinArchivoAdjunto(ColorBorde;Icono;ColorIcono;SizeIcono;ColorFondoContainer)":
                if parts.count >= 1 { state.vistaSubirExamen.containerSinArchivo.colorBorde = parts[0] }
                if parts.count >= 2 { state.vistaSubirExamen.containerSinArchivo.icono = parseIconName(parts[1]) }
                if parts.count >= 3 { state.vistaSubirExamen.containerSinArchivo.colorIcono = parts[2] }
                if parts.count == 5 {
                    state.vistaSubirExamen.containerSinArchivo.sizeIcono = parts[3]
                    state.vistaSubirExamen.containerSinArchivo.colorFondoContainer = parts[4]
                } else if parts.count == 4 {
                    if parts[3].hasPrefix("#") {
                        state.vistaSubirExamen.containerSinArchivo.colorFondoContainer = parts[3]
                    } else {
                        state.vistaSubirExamen.containerSinArchivo.sizeIcono = parts[3]
                    }
                }

            // 10.8 AtributoContainerConArchivoAdjunto
            //      (ColorBorde;Icono;ColorIcono;SizeIcono;ColorTextoFormato;
            //       IconoCancelar;ColorFondo;ColorCruz;ColorFondoContainer)
            case "AtributoContainerConArchivoAdjunto(ColorBorde;Icono;ColorIcono;SizeIcono;ColorTextoFormato;IconoCancelar;ColorFondo;ColorCruz;ColorFondoContainer)":
                if parts.count >= 1 { state.vistaSubirExamen.containerConArchivo.colorBorde = parts[0] }
                if parts.count >= 2 { state.vistaSubirExamen.containerConArchivo.icono = parseIconName(parts[1]) }
                if parts.count >= 3 { state.vistaSubirExamen.containerConArchivo.colorIcono = parts[2] }
                if parts.count >= 4 { state.vistaSubirExamen.containerConArchivo.sizeIcono = parts[3] }
                if parts.count >= 5 { state.vistaSubirExamen.containerConArchivo.colorTextoFormato = parts[4] }
                if parts.count >= 6 { state.vistaSubirExamen.containerConArchivo.iconoCancelar = parseIconName(parts[5]) }
                if parts.count >= 7 { state.vistaSubirExamen.containerConArchivo.colorFondoBotonCancelar = normalizeHex(parts[6]) }
                if parts.count >= 8 { state.vistaSubirExamen.containerConArchivo.colorCruz = parts[7] }
                if parts.count >= 9 { state.vistaSubirExamen.containerConArchivo.colorFondoContainer = parts[8] }

            // 10.9 TextoNota(Fuente;Texto;ColorTexto;Size;Position)
            // Parsing tolerante: si Salesforce envía solo 4 partes y la 4ta
            // parece una posición ("Left"/"Center"/"Right"), la tratamos como
            // alignment y dejamos size con default.
            case "TextoNota(Fuente;Texto;ColorTexto;Size;Position)":
                if parts.count >= 1 { state.vistaSubirExamen.notaAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaSubirExamen.notaTexto = parts[1] }
                if parts.count >= 3 { state.vistaSubirExamen.notaAttr.color = parts[2] }
                if parts.count == 5 {
                    state.vistaSubirExamen.notaAttr.size = parts[3]
                    state.vistaSubirExamen.notaAttr.alignment = parts[4]
                } else if parts.count == 4 {
                    let v = parts[3].lowercased()
                    if ["left", "center", "right"].contains(v) {
                        state.vistaSubirExamen.notaAttr.alignment = parts[3]
                    } else {
                        state.vistaSubirExamen.notaAttr.size = parts[3]
                    }
                }

            // 10.10 BotonEnviar(Texto;Size;ColorTexto;ColorFondo;TipoFuente)
            case "BotonEnviar(Texto;Size;ColorTexto;ColorFondo;TipoFuente)":
                var btn = ButtonExamConfig()
                if parts.count >= 1 { btn.texto = parts[0] }
                if parts.count >= 2 { btn.size = parts[1] }
                if parts.count >= 3 { btn.colorTexto = parts[2] }
                if parts.count >= 4 { btn.colorFondo = parts[3] }
                if parts.count >= 5 { btn.font = parseFontName(parts[4]) }
                state.vistaSubirExamen.botonEnviar = btn

            default:
                print("      ⚠️ [VistaSubirExamen] Atributo no reconocido: \"\(atributo)\" valor=\"\(valor.prefix(60))\"")
            }
        }
        break
    }
    if !matched {
        print("   ⚠️ [VistaSubirExamen] NO se encontró ningún Elemento con nombre \"VistaSubirExamenDetallePrescripcionesMedicasMisArchivosDeSalud\". Config quedó vacía → containers usarán fallback verde.")
    } else {
        let csa = state.vistaSubirExamen.containerSinArchivo
        let cca = state.vistaSubirExamen.containerConArchivo
        print("   📊 RESULTADO containers:")
        print("      [10.7] sinArchivo: borde=\(csa.colorBorde) icono=\(csa.icono) colorIcono=\(csa.colorIcono) sizeIcono=\(csa.sizeIcono) fondo=\(csa.colorFondoContainer)")
        print("      [10.8] conArchivo: borde=\(cca.colorBorde) icono=\(cca.icono) colorIcono=\(cca.colorIcono) sizeIcono=\(cca.sizeIcono) textoFormato=\(cca.colorTextoFormato) iconoX=\(cca.iconoCancelar) fondoX=\(cca.colorFondoBotonCancelar) cruz=\(cca.colorCruz) fondoContainer=\(cca.colorFondoContainer)")
        print("      [10.9] nota: \"\(state.vistaSubirExamen.notaTexto)\" font=\(state.vistaSubirExamen.notaAttr.font) color=\(state.vistaSubirExamen.notaAttr.color)")
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

/// Asegura que un string que parece un color hex tenga "#" al inicio.
/// Algunos valores en Salesforce vienen sin el `#` (ej: "E06100") — esto
/// los normaliza para que `Color(hex:)` los interprete correctamente.
private func normalizeHex(_ raw: String) -> String {
    let trimmed = raw.trimmingCharacters(in: .whitespaces)
    if trimmed.isEmpty { return trimmed }
    if trimmed.hasPrefix("#") { return trimmed }
    // Si parece un hex válido (3, 6 u 8 chars alfanuméricos), le agregamos #.
    let hexChars = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    let allHex = trimmed.unicodeScalars.allSatisfy { hexChars.contains($0) }
    if allHex && [3, 6, 8].contains(trimmed.count) {
        return "#" + trimmed
    }
    return trimmed
}

// MARK: - Elemento 8: VistaDetalleMisArchivosDeSalud
// Config completa del detalle de un archivo de salud (cuando el usuario toca
// una card de Mis Archivos de Salud). Reemplaza al viejo uso del Elemento 8
// (ColorBackArrowSeccionCompleta) — el back arrow global ya no es dinámico.

private func loadVistaDetalleMisArchivos(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [VistaDetalleMisArchivos] Cargando Elemento 8")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 8, field: i),
              !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 8, field: i) ?? ""
        let parts = valor.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }

        switch atributo {
        // 8.1 BackArrow(Color)
        case "BackArrow(Color)":
            state.vistaDetalleMisArchivos.backArrowColor = valor.trimmingCharacters(in: .whitespaces)

        // 8.2 TituloGeneralDetalleMisArchivosDeSalud(Fuente;Texto;ColorTexto;Size)
        case "TituloGeneralDetalleMisArchivosDeSalud(Fuente;Texto;ColorTexto;Size)":
            if parts.count >= 1 { state.vistaDetalleMisArchivos.tituloAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaDetalleMisArchivos.tituloTexto = parts[1] }
            if parts.count >= 3 { state.vistaDetalleMisArchivos.tituloAttr.color = parts[2] }
            if parts.count >= 4 { state.vistaDetalleMisArchivos.tituloAttr.size = parts[3] }

        // 8.3 AtributosTituloCardDetalle(Fuente;ColorTexto;Size)
        case "AtributosTituloCardDetalle(Fuente;ColorTexto;Size)":
            if parts.count >= 1 { state.vistaDetalleMisArchivos.tituloCardAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaDetalleMisArchivos.tituloCardAttr.color = parts[1] }
            if parts.count >= 3 { state.vistaDetalleMisArchivos.tituloCardAttr.size = parts[2] }

        // 8.4 BadgeCargadoPorElPacienteVerDocumentoEnviado(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
        case "BadgeCargadoPorElPacienteVerDocumentoEnviado(Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)":
            state.vistaDetalleMisArchivos.badgeCargadoPorPaciente = parseDetalleBadge(parts: parts)

        // 8.5 FechaDetalleMisArchivosDeSalud(Fuente;Size;Color;Formato;Icono;ColorIcono)
        case "FechaDetalleMisArchivosDeSalud(Fuente;Size;Color;Formato;Icono;ColorIcono)":
            if parts.count >= 1 { state.vistaDetalleMisArchivos.fechaAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaDetalleMisArchivos.fechaAttr.size = parts[1] }
            if parts.count >= 3 { state.vistaDetalleMisArchivos.fechaAttr.color = parts[2] }
            if parts.count >= 4 { state.vistaDetalleMisArchivos.fechaFormato = mapSalesforceDateFormatToIOS(parts[3]) }
            if parts.count >= 5 { state.vistaDetalleMisArchivos.fechaIcono = parseIconName(parts[4]) }
            if parts.count >= 6 { state.vistaDetalleMisArchivos.fechaIconoColor = parts[5] }

        // 8.6 DetalleArchivosAdjuntos(TextoTitulo;Fuente;Size;ColorTexto;Posicion)
        case "DetalleArchivosAdjuntos(TextoTitulo;Fuente;Size;ColorTexto;Posicion)":
            if parts.count >= 1 { state.vistaDetalleMisArchivos.detalleArchivosTitulo = parts[0] }
            if parts.count >= 2 { state.vistaDetalleMisArchivos.detalleArchivosAttr.font = parseFontName(parts[1]) }
            if parts.count >= 3 { state.vistaDetalleMisArchivos.detalleArchivosAttr.size = parts[2] }
            if parts.count >= 4 { state.vistaDetalleMisArchivos.detalleArchivosAttr.color = parts[3] }
            if parts.count >= 5 { state.vistaDetalleMisArchivos.detalleArchivosAttr.alignment = parts[4] }

        // 8.7 ContainerArchivoAdjunto(ColorBorde;Icono;ColorIcono;SizeIcono;ColorTextoFormato;ColorFondoContainer)
        case "ContainerArchivoAdjunto(ColorBorde;Icono;ColorIcono;SizeIcono;ColorTextoFormato;ColorFondoContainer)":
            if parts.count >= 1 { state.vistaDetalleMisArchivos.containerArchivo.colorBorde = parts[0] }
            if parts.count >= 2 { state.vistaDetalleMisArchivos.containerArchivo.icono = parseIconName(parts[1]) }
            if parts.count >= 3 { state.vistaDetalleMisArchivos.containerArchivo.colorIcono = parts[2] }
            if parts.count >= 4 { state.vistaDetalleMisArchivos.containerArchivo.sizeIcono = parts[3] }
            if parts.count >= 5 { state.vistaDetalleMisArchivos.containerArchivo.colorTextoFormato = parts[4] }
            if parts.count >= 6 { state.vistaDetalleMisArchivos.containerArchivo.colorFondoContainer = parts[5] }

        // 8.8 BotonDescargarDetalleMisArchivosDeSalud(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)
        case "BotonDescargarDetalleMisArchivosDeSalud(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)":
            state.vistaDetalleMisArchivos.botonDescargar = parseBotonAccionDetalle(parts: parts)

        // 8.9 BotonCompartirDetalleMisArchivosDeSalud (mismo formato que 8.8)
        case "BotonCompartirDetalleMisArchivosDeSalud(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)":
            state.vistaDetalleMisArchivos.botonCompartir = parseBotonAccionDetalle(parts: parts)

        // 8.10 BotonEliminarDetalleMiArchivoDeSalud
        //      (Texto;ColorTexto;ColorFondo;TipoFuente;Size;SizeIcono;ColorIcono)
        // El icono es siempre el tacho de basura (SF "trash") — Salesforce
        // controla su tamaño y color pero no el símbolo. Soporta 5 partes
        // (formato viejo, sin ícono) o 7 partes (nuevo, con ícono).
        case "BotonEliminarDetalleMiArchivoDeSalud(Texto;ColorTexto;ColorFondo;TipoFuente;Size;SizeIcono;ColorIcono)",
             "BotonEliminarDetalleMiArchivoDeSalud(Texto;ColorTexto;ColorFondo;TipoFuente;Size)":
            var btn = ButtonExamConfig()
            if parts.count >= 1 { btn.texto = parts[0] }
            if parts.count >= 2 { btn.colorTexto = parts[1] }
            if parts.count >= 3 { btn.colorFondo = parts[2] }
            if parts.count >= 4 { btn.font = parseFontName(parts[3]) }
            if parts.count >= 5 { btn.size = parts[4] }
            if parts.count >= 6 { btn.iconoSize = parts[5] }
            if parts.count >= 7 { btn.colorIcono = parts[6] }
            // El símbolo del tacho viene hardcoded — Salesforce no envía nombre.
            btn.icono = "trash"
            state.vistaDetalleMisArchivos.botonEliminar = btn

        default:
            print("      [8.\(i)] ⚠️ Atributo no reconocido: \"\(atributo)\" valor=\"\(valor)\"")
        }
    }
    let v = state.vistaDetalleMisArchivos
    print("   📊 RESULTADO Elemento 8:")
    print("      [8.1] backArrow: \(v.backArrowColor)")
    print("      [8.2] titulo: \"\(v.tituloTexto)\" font=\(v.tituloAttr.font) size=\(v.tituloAttr.size) color=\(v.tituloAttr.color)")
    print("      [8.3] tituloCard: font=\(v.tituloCardAttr.font) size=\(v.tituloCardAttr.size) color=\(v.tituloCardAttr.color)")
    print("      [8.4] badge: \"\(v.badgeCargadoPorPaciente.texto)\" icono=\(v.badgeCargadoPorPaciente.icono)")
    print("      [8.5] fecha: font=\(v.fechaAttr.font) color=\(v.fechaAttr.color) formato=\(v.fechaFormato) icono=\(v.fechaIcono)")
    print("      [8.6] archivosAdjuntos: \"\(v.detalleArchivosTitulo)\" color=\(v.detalleArchivosAttr.color)")
    print("      [8.7] container: borde=\(v.containerArchivo.colorBorde) icono=\(v.containerArchivo.icono) fondo=\(v.containerArchivo.colorFondoContainer)")
    print("      [8.8] btnDescargar: \"\(v.botonDescargar.texto)\" colorTexto=\(v.botonDescargar.colorTexto)")
    print("      [8.9] btnCompartir: \"\(v.botonCompartir.texto)\" colorTexto=\(v.botonCompartir.colorTexto)")
    print("      [8.10] btnEliminar: \"\(v.botonEliminar.texto)\" colorTexto=\(v.botonEliminar.colorTexto) colorFondo=\(v.botonEliminar.colorFondo)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

// MARK: - Elemento 9: "Seleccionar Todos" en Prescripciones Médicas

private func loadSeleccionarTodosConfig(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 9: SeleccionarTodosPrescripcionesMedicas
    // 9.1: TextoSeleccionarTodasLasOrdenes → texto del checkbox
    // 9.2: AtributosTextoSeleccionarTodasLasOrdenes → font;size;color;posicion
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [SeleccionarTodos] Cargando Elemento 9")
    print("   Record Name: \(record.Name ?? "nil")")
    print("   nombreElemento9C: \(record.nombreElemento9C ?? "nil")")
    print("   atributo91C directo: \(record.atributo91C ?? "nil")")
    print("   valor91C directo: \(record.valor91C ?? "nil")")
    print("   atributo92C directo: \(record.atributo92C ?? "nil")")
    print("   valor92C directo: \(record.valor92C ?? "nil")")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    for i in 1...16 {
        let rawAtributo = record.getAtributo(section: 9, field: i)
        print("      [9.\(i)] raw getAtributo → \(rawAtributo ?? "nil")")
        guard let atributo = rawAtributo, !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 9, field: i) ?? ""
        print("      [9.\(i)] atributo=\"\(atributo)\" valor=\"\(valor.prefix(80))\"")

        switch atributo {
        case "TextoSeleccionarTodasLasOrdenes":
            if !valor.isEmpty {
                state.seleccionarTodosTexto = valor
                print("      [9.\(i)] ✅ texto = \"\(valor)\"")
            }
        case let attr where attr.contains("AtributosTextoSeleccionarTodasLasOrdenes"):
            state.seleccionarTodosAttr = parseTextAttributes(valor)
            print("      [9.\(i)] ✅ atributos = font:\(state.seleccionarTodosAttr.font) size:\(state.seleccionarTodosAttr.size) color:\(state.seleccionarTodosAttr.color)")

        // Badges
        case "BadgePrescricionesMedicasExamenAutomatizado":
            state.badgeExamenAutomatizado.texto = valor
            print("      [9.\(i)] ✅ badgeExamenAutomatizado.texto = \"\(valor)\"")
        case let attr where attr.contains("AtributosBadgePrescricionesMedicasExamenAutomatizado"):
            let parts = valor.replacingOccurrences(of: ",", with: ";").components(separatedBy: ";")
            if parts.count >= 1 { state.badgeExamenAutomatizado.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.badgeExamenAutomatizado.size = parts[1].trimmingCharacters(in: .whitespaces) }
            if parts.count >= 3 { state.badgeExamenAutomatizado.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
            if parts.count >= 4 { state.badgeExamenAutomatizado.colorFondo = parts[3].trimmingCharacters(in: .whitespaces) }
            print("      [9.\(i)] ✅ badgeExamenAutomatizado.attr → font:\(state.badgeExamenAutomatizado.font) size:\(state.badgeExamenAutomatizado.size) color:\(state.badgeExamenAutomatizado.colorTexto) fondo:\(state.badgeExamenAutomatizado.colorFondo)")

        case "BadgePrescricionesMedicasOrdenMedica":
            state.badgeOrdenMedica.texto = valor
            print("      [9.\(i)] ✅ badgeOrdenMedica.texto = \"\(valor)\"")
        case let attr where attr.contains("AtributosBadgePrescricionesMedicasOrdenMedica"):
            let parts = valor.replacingOccurrences(of: ",", with: ";").components(separatedBy: ";")
            if parts.count >= 1 { state.badgeOrdenMedica.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.badgeOrdenMedica.size = parts[1].trimmingCharacters(in: .whitespaces) }
            if parts.count >= 3 { state.badgeOrdenMedica.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
            if parts.count >= 4 { state.badgeOrdenMedica.colorFondo = parts[3].trimmingCharacters(in: .whitespaces) }
            print("      [9.\(i)] ✅ badgeOrdenMedica.attr → font:\(state.badgeOrdenMedica.font) size:\(state.badgeOrdenMedica.size) color:\(state.badgeOrdenMedica.colorTexto) fondo:\(state.badgeOrdenMedica.colorFondo)")

        case "BadgePrescricionesMedicasRecetaMedica":
            state.badgeRecetaMedica.texto = valor
            print("      [9.\(i)] ✅ badgeRecetaMedica.texto = \"\(valor)\"")
        case let attr where attr.contains("AtributosBadgePrescricionesMedicasRecetaMedica"):
            let parts = valor.replacingOccurrences(of: ",", with: ";").components(separatedBy: ";")
            if parts.count >= 1 { state.badgeRecetaMedica.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.badgeRecetaMedica.size = parts[1].trimmingCharacters(in: .whitespaces) }
            if parts.count >= 3 { state.badgeRecetaMedica.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
            if parts.count >= 4 { state.badgeRecetaMedica.colorFondo = parts[3].trimmingCharacters(in: .whitespaces) }
            print("      [9.\(i)] ✅ badgeRecetaMedica.attr → font:\(state.badgeRecetaMedica.font) size:\(state.badgeRecetaMedica.size) color:\(state.badgeRecetaMedica.colorTexto) fondo:\(state.badgeRecetaMedica.colorFondo)")

        default:
            print("      [9.\(i)] ⚠️ Atributo no reconocido: \"\(atributo)\" valor=\"\(valor)\"")
        }
    }
    print("   📊 RESULTADO FINAL: texto=\"\(state.seleccionarTodosTexto)\" font=\(state.seleccionarTodosAttr.font) size=\(state.seleccionarTodosAttr.size) color=\(state.seleccionarTodosAttr.color)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

// MARK: - Elemento 11: DialogEliminarExamenSubido

private func loadDialogEliminarExamen(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 11, field: i), !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 11, field: i) ?? ""

        switch atributo {
        case "TituloDialogEliminarMiExamen":
            state.dialogEliminarExamen.titulo = valor

        case "AtributosTituloDialogEliminarMiExamen(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogEliminarExamen.tituloAttr = parseTextAttributes(valor)

        case "DescripcionDialogEliminarMiExamen":
            state.dialogEliminarExamen.descripcion = valor

        case "AtributosDescripcionDialogEliminarMiExamen(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogEliminarExamen.descripcionAttr = parseTextAttributes(valor)

        case "BotonAceptarDialogEliminarMiExamen(Texto;ColorTexto;ColorFondo)":
            state.dialogEliminarExamen.botonAceptar = parseButton3(valor)

        case "BotonCancelarDialogEliminarMiExamen(Texto;ColorTexto;ColorFondo)":
            state.dialogEliminarExamen.botonCancelar = parseButton3(valor)

        default:
            break
        }
    }
}

// MARK: - Elemento 12: BadgesTipoExamenSubidoEnMisExamenes

/// Parsea formato: TipoFuente;Texto;ColorTexto;Size;ColorFondo
private func parseBadge(_ valor: String) -> BadgeConfig {
    let parts = valor.components(separatedBy: ";")
    var badge = BadgeConfig()
    if parts.count >= 1 { badge.font = parseFontName(parts[0].trimmingCharacters(in: .whitespaces)) }
    if parts.count >= 2 { badge.texto = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { badge.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { badge.size = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { badge.colorFondo = parts[4].trimmingCharacters(in: .whitespaces) }
    return badge
}

private func loadBadgesMisExamenes(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [VistaMisArchivos] Cargando Elemento 12")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 12, field: i), !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 12, field: i) ?? ""
        let parts = valor.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }

        switch atributo {
        // 12.1–12.6 Badges por tipo
        case "BadgeTipoExamenImagen(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
            state.vistaMisArchivos.badgeExamenImagen = parseBadge(valor)
        case "BadgeTipoRecetaMedica(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
            state.vistaMisArchivos.badgeRecetaMedica = parseBadge(valor)
        case "BadgeTipoExamenLaboratorio(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
            state.vistaMisArchivos.badgeExamenLaboratorio = parseBadge(valor)
        case "BadgeTipoOrdenExamen(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
            state.vistaMisArchivos.badgeOrdenExamen = parseBadge(valor)
        case "BadgeTipoInformeMedico(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
            state.vistaMisArchivos.badgeInformeMedico = parseBadge(valor)
        case "BadgeTipoOtros(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
            state.vistaMisArchivos.badgeOtros = parseBadge(valor)

        // 12.7 IconoBasuraEliminarMiArchivoSalud(Size;Color)
        case "IconoBasuraEliminarMiArchivoSalud(Size;Color)":
            if parts.count >= 1 { state.vistaMisArchivos.iconoBasuraSize = parts[0] }
            if parts.count >= 2 { state.vistaMisArchivos.iconoBasuraColor = parts[1] }

        // 12.8 BackArrow(Color)
        case "BackArrow(Color)":
            state.vistaMisArchivos.backArrowColor = valor.trimmingCharacters(in: .whitespaces)

        // 12.9 TituloGeneralMisArchivosDeSalud(Fuente;Texto;ColorTexto;Size)
        case "TituloGeneralMisArchivosDeSalud(Fuente;Texto;ColorTexto;Size)":
            if parts.count >= 1 { state.vistaMisArchivos.tituloAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaMisArchivos.tituloTexto = parts[1] }
            if parts.count >= 3 { state.vistaMisArchivos.tituloAttr.color = parts[2] }
            if parts.count >= 4 { state.vistaMisArchivos.tituloAttr.size = parts[3] }

        // 12.10 AtributosTituloCardDetalle(Fuente;ColorTexto;Size)
        case "AtributosTituloCardDetalle(Fuente;ColorTexto;Size)":
            if parts.count >= 1 { state.vistaMisArchivos.tituloCardAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaMisArchivos.tituloCardAttr.color = parts[1] }
            if parts.count >= 3 { state.vistaMisArchivos.tituloCardAttr.size = parts[2] }

        // 12.11 TextoPlaceholderFiltro(Fuente;Texto;Size;Color)
        case "TextoPlaceholderFiltro(Fuente;Texto;Size;Color)":
            if parts.count >= 1 { state.vistaMisArchivos.placeholderAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaMisArchivos.placeholderTexto = parts[1] }
            if parts.count >= 3 { state.vistaMisArchivos.placeholderAttr.size = parts[2] }
            if parts.count >= 4 { state.vistaMisArchivos.placeholderAttr.color = parts[3] }

        // 12.12 IconoFiltro(Icono;Size;Color)
        case "IconoFiltro(Icono;Size;Color)":
            if parts.count >= 1 { state.vistaMisArchivos.iconoFiltro = parseIconName(parts[0]) }
            if parts.count >= 2 { state.vistaMisArchivos.iconoFiltroSize = parts[1] }
            if parts.count >= 3 { state.vistaMisArchivos.iconoFiltroColor = parts[2] }

        // 12.13 FechaExamenCard(Fuente;Size;Color;Formato;Icono;ColorIcono)
        case "FechaExamenCard(Fuente;Size;Color;Formato;Icono;ColorIcono)":
            if parts.count >= 1 { state.vistaMisArchivos.fechaAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaMisArchivos.fechaAttr.size = parts[1] }
            if parts.count >= 3 { state.vistaMisArchivos.fechaAttr.color = parts[2] }
            if parts.count >= 4 { state.vistaMisArchivos.fechaFormato = mapSalesforceDateFormatToIOS(parts[3]) }
            if parts.count >= 5 { state.vistaMisArchivos.fechaIcono = parseIconName(parts[4]) }
            if parts.count >= 6 { state.vistaMisArchivos.fechaIconoColor = parts[5] }

        // 12.14 TextoEmptyState(Fuente;Texto;Size;Color)
        case "TextoEmptyState(Fuente;Texto;Size;Color)":
            if parts.count >= 1 { state.vistaMisArchivos.emptyStateAttr.font = parseFontName(parts[0]) }
            if parts.count >= 2 { state.vistaMisArchivos.emptyStateTexto = parts[1] }
            if parts.count >= 3 { state.vistaMisArchivos.emptyStateAttr.size = parts[2] }
            if parts.count >= 4 { state.vistaMisArchivos.emptyStateAttr.color = parts[3] }

        // 12.15 BarraVerticalCardMisArchivosDeSalud(Color)
        case "BarraVerticalCardMisArchivosDeSalud(Color)":
            state.vistaMisArchivos.barraVerticalColor = valor.trimmingCharacters(in: .whitespaces)

        // 12.16 BotonSubirExamen(Texto;ColorTexto;ColorFondo;TipoFuente;Size)
        case "BotonSubirExamen(Texto;ColorTexto;ColorFondo;TipoFuente;Size)":
            var btn = ButtonExamConfig()
            if parts.count >= 1 { btn.texto = parts[0] }
            if parts.count >= 2 { btn.colorTexto = parts[1] }
            if parts.count >= 3 { btn.colorFondo = parts[2] }
            if parts.count >= 4 { btn.font = parseFontName(parts[3]) }
            if parts.count >= 5 { btn.size = parts[4] }
            state.vistaMisArchivos.botonSubirExamen = btn

        default:
            print("      ⚠️ [VistaMisArchivos] Atributo no reconocido: \"\(atributo)\" valor=\"\(valor.prefix(60))\"")
        }
    }
    let v = state.vistaMisArchivos
    print("   📊 RESULTADO Elemento 12:")
    print("      titulo: \"\(v.tituloTexto)\" font=\(v.tituloAttr.font) size=\(v.tituloAttr.size) color=\(v.tituloAttr.color)")
    print("      backArrow: \(v.backArrowColor)  barraVertical: \(v.barraVerticalColor)")
    print("      placeholder: \"\(v.placeholderTexto)\" font=\(v.placeholderAttr.font) color=\(v.placeholderAttr.color)")
    print("      iconoFiltro: \(v.iconoFiltro) size=\(v.iconoFiltroSize) color=\(v.iconoFiltroColor)")
    print("      fecha: font=\(v.fechaAttr.font) size=\(v.fechaAttr.size) color=\(v.fechaAttr.color) formato=\(v.fechaFormato) icono=\(v.fechaIcono)")
    print("      emptyState: \"\(v.emptyStateTexto)\" color=\(v.emptyStateAttr.color)")
    print("      botonSubir: \"\(v.botonSubirExamen.texto)\" colorTexto=\(v.botonSubirExamen.colorTexto) colorFondo=\(v.botonSubirExamen.colorFondo)")
    print("      iconoBasura: size=\(v.iconoBasuraSize) color=\(v.iconoBasuraColor)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

// MARK: - Elemento 13: BotonesVistaDetalleExamenSubidoMisExamenes

private func parseButton5Fields(_ valor: String) -> ButtonExamConfig {
    let parts = valor.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.colorTexto = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { btn.colorFondo = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.font = parseFontName(parts[3].trimmingCharacters(in: .whitespaces)) }
    if parts.count >= 5 { btn.size = parts[4].trimmingCharacters(in: .whitespaces) }
    return btn
}

/// Parsea formato: TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon (7 campos)
/// o formato extendido: TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde (8 campos)
private func parseButton7Fields(_ valor: String) -> ButtonExamConfig {
    let parts = valor.components(separatedBy: ";")
    var btn = ButtonExamConfig()
    if parts.count >= 1 { btn.font = parseFontName(parts[0].trimmingCharacters(in: .whitespaces)) }
    if parts.count >= 2 { btn.texto = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { btn.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.size = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { btn.colorFondo = parts[4].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 6 { btn.icono = parseIconName(parts[5].trimmingCharacters(in: .whitespaces)) }
    if parts.count >= 7 { btn.colorIcono = parts[6].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 8 { btn.colorBorde = parts[7].trimmingCharacters(in: .whitespaces) }
    return btn
}

private func loadBotonesDetalleExamen(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🔍 [loadBotonesDetalleExamen] DUMP Elemento 13 del record '\(record.Name)'")
    print("   nombreElemento13: \"\(record.getNombreElemento(13) ?? "nil")\"")
    for j in 1...16 {
        let atr = record.getAtributo(section: 13, field: j)
        let val = record.getValor(section: 13, field: j)
        if atr != nil || val != nil {
            print("   [13.\(j)] atributo=\"\(atr ?? "nil")\" valor=\"\(val ?? "nil")\"")
        }
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 13, field: i), !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 13, field: i) ?? ""

        switch atributo {
        // Formato antiguo (Texto;ColorTexto;ColorFondo;TipoFuente;Size)
        case "BotonEliminar(Texto;ColorTexto;ColorFondo;TipoFuente;Size)":
            state.botonesDetalleExamen.botonEliminar = parseButton5Fields(valor)
        case "BotonDescargar(Texto;ColorTexto;ColorFondo;TipoFuente;Size)":
            state.botonesDetalleExamen.botonDescargar = parseButton5Fields(valor)

        // Formato 7 campos (TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon)
        case "BotonDescargar(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon)":
            state.botonesDetalleExamen.botonDescargar = parseButton7Fields(valor)
            print("      [13.\(i)] ✅ botonDescargar = \"\(state.botonesDetalleExamen.botonDescargar.texto)\" icono=\(state.botonesDetalleExamen.botonDescargar.icono)")

        case "BotonEliminar(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon)":
            state.botonesDetalleExamen.botonEliminar = parseButton7Fields(valor)
            print("      [13.\(i)] ✅ botonEliminar = \"\(state.botonesDetalleExamen.botonEliminar.texto)\" icono=\(state.botonesDetalleExamen.botonEliminar.icono)")

        case "BotonCompartir(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon)":
            state.botonesDetalleExamen.botonCompartir = parseButton7Fields(valor)
            print("      [13.\(i)] ✅ botonCompartir = \"\(state.botonesDetalleExamen.botonCompartir.texto)\" icono=\(state.botonesDetalleExamen.botonCompartir.icono)")

        // Formato 8 campos con ColorBorde (TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)
        case "BotonDescargar(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)":
            state.botonesDetalleExamen.botonDescargar = parseButton7Fields(valor)
            print("      [13.\(i)] ✅ botonDescargar = \"\(state.botonesDetalleExamen.botonDescargar.texto)\" icono=\(state.botonesDetalleExamen.botonDescargar.icono) colorBorde=\(state.botonesDetalleExamen.botonDescargar.colorBorde)")

        case "BotonEliminar(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)":
            state.botonesDetalleExamen.botonEliminar = parseButton7Fields(valor)
            print("      [13.\(i)] ✅ botonEliminar = \"\(state.botonesDetalleExamen.botonEliminar.texto)\" icono=\(state.botonesDetalleExamen.botonEliminar.icono) colorBorde=\(state.botonesDetalleExamen.botonEliminar.colorBorde)")

        case "BotonCompartir(TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)":
            state.botonesDetalleExamen.botonCompartir = parseButton7Fields(valor)
            print("      [13.\(i)] ✅ botonCompartir = \"\(state.botonesDetalleExamen.botonCompartir.texto)\" icono=\(state.botonesDetalleExamen.botonCompartir.icono) colorBorde=\(state.botonesDetalleExamen.botonCompartir.colorBorde)")

        case "TituloArchivosAdjuntos":
            state.botonesDetalleExamen.tituloArchivosAdjuntos = valor.trimmingCharacters(in: .whitespaces)
            print("      [13.\(i)] ✅ tituloArchivosAdjuntos = \"\(state.botonesDetalleExamen.tituloArchivosAdjuntos)\"")

        case "AtributosTituloArchivosAdjuntos(TipoFuente;Size;ColorTexto;Posicion)":
            state.botonesDetalleExamen.tituloArchivosAdjuntosAttr = parseTextAttributes(valor)
            print("      [13.\(i)] ✅ tituloArchivosAdjuntosAttr = font=\(state.botonesDetalleExamen.tituloArchivosAdjuntosAttr.font) size=\(state.botonesDetalleExamen.tituloArchivosAdjuntosAttr.size) color=\(state.botonesDetalleExamen.tituloArchivosAdjuntosAttr.color)")

        default:
            break
        }
    }
}

// MARK: - Custom2 Record Parsers

// MARK: - Elemento 1 (Custom2): DialogExamenesEnviadosCorrectamente

private func loadDialogExamenesEnviados(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 1, field: i), !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 1, field: i) ?? ""

        switch atributo {
        case "IconoSuperiorDialog":
            state.dialogExamenesEnviados.icono = parseIconoDialog(valor)

        case "TituloDialogExamenesEnviadosCorrectamente":
            state.dialogExamenesEnviados.titulo = valor

        case "AtributosTituloDialogExamenesEnviadosCorrectamente(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogExamenesEnviados.tituloAttr = parseTextAttributes(valor)

        case "DescripcionDialogExamenesEnviadosCorrectamente":
            state.dialogExamenesEnviados.descripcion = valor

        case "AtributosDescripcionDialogExamenesEnviadosCorrectamente(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogExamenesEnviados.descripcionAttr = parseTextAttributes(valor)

        case "BotonAceptarDialogExamenesEnviadosCorrectamente(Texto;ColorTexto;ColorFondo)":
            state.dialogExamenesEnviados.botonAceptar = parseButton3(valor)

        default:
            break
        }
    }
}

/// Mapea nombres de ícono de Salesforce para dialogs a SF Symbols
private func parseIconoDialog(_ raw: String) -> String {
    switch raw.trimmingCharacters(in: .whitespaces) {
    case "Check":      return "checkmark"
    case "Error":      return "xmark"
    case "Warning":    return "exclamationmark.triangle"
    case "Alert":      return "exclamationmark.triangle.fill"
    case "Info":       return "info.circle"
    default:           return raw
    }
}

// MARK: - Elemento 2 (Custom2): DialogConfirmarEliminarDocumentoSubidoAOrdenExamen

private func loadDialogEliminarDocOrden(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 2, field: i), !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 2, field: i) ?? ""

        switch atributo {
        case "IconoSuperiorDialog":
            state.dialogEliminarDocOrden.icono = parseIconoDialog(valor)

        case "TituloDialogConfirmarEliminarDocumentoSubidoAOrdenExamen":
            state.dialogEliminarDocOrden.titulo = valor

        case "AtributosTituloDialogConfirmarEliminarDocumentoSubidoAOrdenExamen(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogEliminarDocOrden.tituloAttr = parseTextAttributes(valor)

        case "DescripcionDialogConfirmarEliminarDocumentoSubidoAOrdenExamen":
            state.dialogEliminarDocOrden.descripcion = valor

        case "AtributosDescripcionDialogConfirmarEliminarDocumentoSubidoAOrdenExamen(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogEliminarDocOrden.descripcionAttr = parseTextAttributes(valor)

        case "BotonAceptarDialogConfirmarEliminarDocumentoSubidoAOrdenExamen(Texto;ColorTexto;ColorFondo)":
            state.dialogEliminarDocOrden.botonAceptar = parseButton3(valor)

        case "BotonCancelarDialogConfirmarEliminarDocumentoSubidoAOrdenExamen(Texto;ColorTexto;ColorFondo)":
            state.dialogEliminarDocOrden.botonCancelar = parseButton3(valor)

        default:
            break
        }
    }
}

// MARK: - Elemento 3 (Custom2): DialogConfirmarEliminarMiArchivoDeSalud

private func loadDialogEliminarMiArchivo(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 3, field: i), !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 3, field: i) ?? ""

        switch atributo {
        case "TituloDialogConfirmarEliminarMiArchivoDeSalud":
            state.dialogEliminarMiArchivo.titulo = valor

        case "AtributosTituloDialogConfirmarEliminarMiArchivoDeSalud(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogEliminarMiArchivo.tituloAttr = parseTextAttributes(valor)

        case "DescripcionDialogConfirmarEliminarMiArchivoDeSalud":
            state.dialogEliminarMiArchivo.descripcion = valor

        case "AtributosDescripcionDialogConfirmarEliminarMiArchivoDeSalud(TipoFuente;Size;ColorTexto;Posicion)":
            state.dialogEliminarMiArchivo.descripcionAttr = parseTextAttributes(valor)

        case "BotonAceptarDialogConfirmarEliminarMiArchivoDeSalud(Texto;ColorTexto;ColorFondo)":
            state.dialogEliminarMiArchivo.botonAceptar = parseButton3(valor)

        case "BotonCancelarDialogConfirmarEliminarMiArchivoDeSalud(Texto;ColorTexto;ColorFondo)":
            state.dialogEliminarMiArchivo.botonCancelar = parseButton3(valor)

        default:
            break
        }
    }
}

// MARK: - Main Record Parsers

private func loadCategorias(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elementos 1 y 2: ListadoCategorias1 y ListadoCategorias2
    for section in 1...2 {
        let offset = (section - 1) * 16
        for field in 1...16 {
            let atributo = record.getAtributo(section: section, field: field)
            let valor = record.getValor(section: section, field: field) ?? ""

            // Necesitamos al menos un valor con contenido para crear la categoría
            guard !valor.isEmpty, valor.lowercased() != "no" else { continue }

            let parts = valor.components(separatedBy: ";")
            let nombre = parts.count >= 1 ? parts[0].trimmingCharacters(in: .whitespaces) : ""
            let tituloTip = parts.count >= 2 ? parts[1].trimmingCharacters(in: .whitespaces) : ""
            let descripcionTip = parts.count >= 3 ? parts[2].trimmingCharacters(in: .whitespaces) : ""
            let iconURL = parts.count >= 4 ? parts[3].trimmingCharacters(in: .whitespaces) : ""

            // Extraer numero de categoria del atributo si existe, sino usar offset+field
            var categoriaNum = offset + field
            if let attr = atributo, let range = attr.range(of: "Categoria", options: .caseInsensitive) {
                let afterCat = attr[range.upperBound...]
                let digits = afterCat.prefix(while: { $0.isNumber })
                if let n = Int(digits) { categoriaNum = n }
            }

            state.categorias.append(CategoriaExamen(
                nombre: nombre,
                tituloTip: tituloTip,
                descripcionTip: descripcionTip,
                iconURL: iconURL,
                claveApi: "Categoria_\(categoriaNum)__c"
            ))
        }
    }
}

private func loadValidacion(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 3: CamposValidacionExamenes
    for i in 1...16 {
        let atributo = record.getAtributo(section: 3, field: i)
        let valor = record.getValor(section: 3, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        if let atributo = atributo {
            let atributoLower = atributo.lowercased()
            if atributoLower.contains("pais") && atributoLower.contains("examen") {
                state.validacion.paisExamen = valor
            } else if atributoLower.contains("tipo") && atributoLower.contains("examen") {
                state.validacion.tipoExamen = valor
            } else if atributoLower.contains("color") && atributoLower.contains("spinner") {
                state.validacion.colorSpinner = valor
            }
        }
        // Para validacion no hay parseo posicional — solo 3 campos conocidos con atributo
    }
}

private func loadSeleccionExamenesFromMain(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Main Record - Buscar elemento "SeleccionarExamenesDeCategoria" para campos complementarios (subtítulo)
    for elemIdx in 1...13 {
        guard let nombre = record.getNombreElemento(elemIdx),
              nombre == "SeleccionarExamenesDeCategoria" else { continue }

        print("   🔍 [loadSeleccionExamenesFromMain] Elemento \(elemIdx) = \"\(nombre)\" ENCONTRADO")

        for i in 1...16 {
            let atributo = record.getAtributo(section: elemIdx, field: i)
            let valor = record.getValor(section: elemIdx, field: i) ?? ""

            guard atributo != nil || !valor.isEmpty else { continue }

            if let atributo = atributo {
                let attrName = atributo.components(separatedBy: "(").first ?? ""

                switch attrName {
                case "SubtituloModalSeleccionarExamenes":
                    state.seleccionExamenes.subtituloTexto = valor
                    print("      [\(elemIdx).\(i)] ✅ subtituloTexto = \"\(valor)\"")

                case "AtributosSubtituloModalSeleccionarExamenes":
                    state.seleccionExamenes.subtituloAttr = parseTextAttributes(valor)
                    print("      [\(elemIdx).\(i)] ✅ subtituloAttr = font:\(state.seleccionExamenes.subtituloAttr.font) size:\(state.seleccionExamenes.subtituloAttr.size) color:\(state.seleccionExamenes.subtituloAttr.color)")

                default:
                    break
                }
            }
        }
        break // Ya encontramos el elemento
    }
}

private func loadCarritoFromMain(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Main Record - Buscar elemento "CustomDetalleCarrito" (Elem 12) para campos complementarios
    for elemIdx in 1...13 {
        guard let nombre = record.getNombreElemento(elemIdx),
              nombre.lowercased().contains("customdetallecarrito") else { continue }

        print("   🔍 [loadCarritoFromMain] Elemento \(elemIdx) = \"\(nombre)\" ENCONTRADO")

        for i in 1...16 {
            let atributo = record.getAtributo(section: elemIdx, field: i)
            let valor = record.getValor(section: elemIdx, field: i) ?? ""

            guard atributo != nil || !valor.isEmpty else { continue }

            if let atributo = atributo {
                let attrName = atributo.components(separatedBy: "(").first ?? ""

                switch attrName {
                case "TextoAntesDeContinuar":
                    let parts = valor.components(separatedBy: ";")
                    if parts.count >= 1 { state.carrito.antesDeContinuarTexto = parts[0].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 5 {
                        state.carrito.antesDeContinuarAttr = TextExamAttributes(
                            font: parseFontName(parts[1]),
                            size: parts[2].trimmingCharacters(in: .whitespaces),
                            color: parts[3].trimmingCharacters(in: .whitespaces),
                            alignment: parts[4].trimmingCharacters(in: .whitespaces)
                        )
                    }
                    print("      [\(elemIdx).\(i)] ✅ antesDeContinuar = \"\(state.carrito.antesDeContinuarTexto)\"")

                case "SubTextoAntesDeContinuar":
                    let parts = valor.components(separatedBy: ";")
                    if parts.count >= 1 { state.carrito.subAntesDeContinuarTexto = parts[0].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 5 {
                        state.carrito.subAntesDeContinuarAttr = TextExamAttributes(
                            font: parseFontName(parts[1]),
                            size: parts[2].trimmingCharacters(in: .whitespaces),
                            color: parts[3].trimmingCharacters(in: .whitespaces),
                            alignment: parts[4].trimmingCharacters(in: .whitespaces)
                        )
                    }
                    print("      [\(elemIdx).\(i)] ✅ subAntesDeContinuar = \"\(state.carrito.subAntesDeContinuarTexto)\"")

                default:
                    break
                }
            } else {
                // Atributo nil — parseo por posición para Elem 12
                let parts = valor.components(separatedBy: ";")
                if parts.count >= 5 && state.carrito.antesDeContinuarTexto.isEmpty {
                    state.carrito.antesDeContinuarTexto = parts[0].trimmingCharacters(in: .whitespaces)
                    state.carrito.antesDeContinuarAttr = TextExamAttributes(
                        font: parseFontName(parts[1]),
                        size: parts[2].trimmingCharacters(in: .whitespaces),
                        color: parts[3].trimmingCharacters(in: .whitespaces),
                        alignment: parts[4].trimmingCharacters(in: .whitespaces)
                    )
                    print("      [\(elemIdx).\(i)] ✅ [nil→pos] antesDeContinuar = \"\(state.carrito.antesDeContinuarTexto)\"")
                } else if parts.count >= 5 && state.carrito.subAntesDeContinuarTexto.isEmpty {
                    state.carrito.subAntesDeContinuarTexto = parts[0].trimmingCharacters(in: .whitespaces)
                    state.carrito.subAntesDeContinuarAttr = TextExamAttributes(
                        font: parseFontName(parts[1]),
                        size: parts[2].trimmingCharacters(in: .whitespaces),
                        color: parts[3].trimmingCharacters(in: .whitespaces),
                        alignment: parts[4].trimmingCharacters(in: .whitespaces)
                    )
                    print("      [\(elemIdx).\(i)] ✅ [nil→pos] subAntesDeContinuar = \"\(state.carrito.subAntesDeContinuarTexto)\"")
                }
            }
        }
        break
    }
}

// MARK: - Main Record Elemento 13: BadgesPrescripcionesMedicas

// MARK: - VistaPrincipalPrescripcionesMedicas (Main Record - Elemento 13)
// Parser de la config completa de la pantalla "Prescripciones Médicas".
// Reemplaza por completo la lectura de SecMas para esa vista — ahora todo
// (titulo, buscador, botones, atributos de card, etc.) viene de aquí.
private func loadVistaPrincipalPrescripcionesMedicas(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    for elemIdx in 1...13 {
        guard let nombreElemento = record.getNombreElemento(elemIdx) else { continue }
        guard nombreElemento == "VistaPrincipalPrescripcionesMedicas" else { continue }

        for i in 1...16 {
            guard let atributo = record.getAtributo(section: elemIdx, field: i), !atributo.isEmpty else { continue }
            let valor = record.getValor(section: elemIdx, field: i) ?? ""
            let parts = valor.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }

            switch atributo {
            // 13.1 BackArrow(Color)
            case "BackArrow(Color)":
                state.vistaPrincipalPrescripciones.backArrowColor = valor.trimmingCharacters(in: .whitespaces)

            // 13.2 TituloPrescripcionesMedicas(Fuente;Texto;Size;Color)
            case "TituloPrescripcionesMedicas(Fuente;Texto;Size;Color)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.tituloAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.tituloTexto = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.tituloAttr.size = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.tituloAttr.color = parts[3] }

            // 13.3 TextoPlaceholderFiltro(Fuente;Texto;Size;Color)
            case "TextoPlaceholderFiltro(Fuente;Texto;Size;Color)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.placeholderAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.placeholderTexto = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.placeholderAttr.size = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.placeholderAttr.color = parts[3] }

            // 13.4 IconoFiltro(Icono;Size;Color)
            case "IconoFiltro(Icono;Size;Color)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.iconoFiltro.nombre = parts[0] }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.iconoFiltro.size = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.iconoFiltro.color = parts[2] }

            // 13.5 TextoSeleccionarTodos(Fuente;Texto;Size;Color;ColorCheckboxActivo)
            case "TextoSeleccionarTodos(Fuente;Texto;Size;Color;ColorCheckboxActivo)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.seleccionarTodosAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.seleccionarTodosTexto = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.seleccionarTodosAttr.size = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.seleccionarTodosAttr.color = parts[3] }
                if parts.count >= 5 { state.vistaPrincipalPrescripciones.seleccionarTodosCheckboxColor = parts[4] }

            // 13.6 TextoContadorExamenesSeleccionados(Fuente;Size;Color)
            case "TextoContadorExamenesSeleccionados(Fuente;Size;Color)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.contadorAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.contadorAttr.size = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.contadorAttr.color = parts[2] }

            // 13.7 BotonDescargar(Texto;ColorTexto;ColorBoton;Icono)
            case "BotonDescargar(Texto;ColorTexto;ColorBoton;Icono)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.botonDescargar.texto = parts[0] }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.botonDescargar.colorTexto = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.botonDescargar.colorFondo = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.botonDescargar.icono = parts[3] }

            // 13.8 BotonCompartir(Texto;ColorTexto;ColorBoton;Icono)
            case "BotonCompartir(Texto;ColorTexto;ColorBoton;Icono)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.botonCompartir.texto = parts[0] }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.botonCompartir.colorTexto = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.botonCompartir.colorFondo = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.botonCompartir.icono = parts[3] }

            // 13.9 AtributosCard(ColorBarraVertical;ColorCheckboxActivo;ColorBordeActivo;ColorEstrella)
            case "AtributosCard(ColorBarraVertical;ColorCheckboxActivo;ColorBordeActivo;ColorEstrella)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.cardColorBarraVertical = parts[0] }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.cardColorCheckboxActivo = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.cardColorBordeActivo = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.cardColorEstrella = parts[3] }

            // 13.10 TituloNombreCardExamen(Fuente;Size;Color)
            case "TituloNombreCardExamen(Fuente;Size;Color)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.tituloCardAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.tituloCardAttr.size = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.tituloCardAttr.color = parts[2] }

            // 13.11 BadgeTipoExamenAutomatizado(TipoFuente;Texto;ColorTexto;Size;ColorFondo)
            case "BadgeTipoExamenAutomatizado(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
                if parts.count >= 1 { state.badgeExamenAutomatizado.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.badgeExamenAutomatizado.texto = parts[1] }
                if parts.count >= 3 { state.badgeExamenAutomatizado.colorTexto = parts[2] }
                if parts.count >= 4 { state.badgeExamenAutomatizado.size = parts[3] }
                if parts.count >= 5 { state.badgeExamenAutomatizado.colorFondo = parts[4] }

            // 13.12 BadgeTipoExamenMedico(TipoFuente;Texto;ColorTexto;Size;ColorFondo)
            case "BadgeTipoExamenMedico(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
                if parts.count >= 1 { state.badgeOrdenMedica.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.badgeOrdenMedica.texto = parts[1] }
                if parts.count >= 3 { state.badgeOrdenMedica.colorTexto = parts[2] }
                if parts.count >= 4 { state.badgeOrdenMedica.size = parts[3] }
                if parts.count >= 5 { state.badgeOrdenMedica.colorFondo = parts[4] }

            // 13.13 BadgeTipoRecetaMedica(TipoFuente;Texto;ColorTexto;Size;ColorFondo)
            case "BadgeTipoRecetaMedica(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
                if parts.count >= 1 { state.badgeRecetaMedica.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.badgeRecetaMedica.texto = parts[1] }
                if parts.count >= 3 { state.badgeRecetaMedica.colorTexto = parts[2] }
                if parts.count >= 4 { state.badgeRecetaMedica.size = parts[3] }
                if parts.count >= 5 { state.badgeRecetaMedica.colorFondo = parts[4] }

            // 13.14 FechaExamenCard(Fuente;Size;Color;Formato;Icono;ColorIcono)
            case "FechaExamenCard(Fuente;Size;Color;Formato;Icono;ColorIcono)",
                 "FechaExamenCard(Fuente;Size;Color;Formato)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.fechaCardAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.fechaCardAttr.size = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.fechaCardAttr.color = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.fechaCardFormato = mapSalesforceDateFormatToIOS(parts[3]) }
                if parts.count >= 5 { state.vistaPrincipalPrescripciones.fechaCardIcono = parseIconName(parts[4]) }
                if parts.count >= 6 { state.vistaPrincipalPrescripciones.fechaCardIconoColor = parts[5] }

            // 13.15 TextoEmptyState(Fuente;Texto;Size;Color)
            case "TextoEmptyState(Fuente;Texto;Size;Color)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.emptyStateAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.emptyStateTexto = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.emptyStateAttr.size = parts[2] }
                if parts.count >= 4 { state.vistaPrincipalPrescripciones.emptyStateAttr.color = parts[3] }

            // 13.16 AtributosDescripcionExamenCard(Fuente;Size;Color)
            case "AtributosDescripcionExamenCard(Fuente;Size;Color)":
                if parts.count >= 1 { state.vistaPrincipalPrescripciones.descripcionCardAttr.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.vistaPrincipalPrescripciones.descripcionCardAttr.size = parts[1] }
                if parts.count >= 3 { state.vistaPrincipalPrescripciones.descripcionCardAttr.color = parts[2] }

            default:
                print("      ⚠️ [VistaPrincipalPrescripciones] Atributo no reconocido: \"\(atributo)\" valor=\"\(valor.prefix(60))\"")
            }
        }
        break
    }
}

/// Convierte un formato de fecha en notación Salesforce ("DD/MM/AAAA",
/// "DD/MM/YYYY", "AAAA-MM-DD", etc.) al formato de iOS DateFormatter ("dd/MM/yyyy").
/// Convención Salesforce: DD=día, MM=mes, AAAA o YYYY=año (4 dígitos), AA o YY=año (2 dígitos).
/// Convención iOS: dd, MM (igual), yyyy, yy. Importante: usar `yyyy` (calendar year),
/// no `YYYY` (week-of-year year) — son distintos en iOS DateFormatter.
private func mapSalesforceDateFormatToIOS(_ sfFormat: String) -> String {
    return sfFormat
        .replacingOccurrences(of: "AAAA", with: "yyyy")
        .replacingOccurrences(of: "YYYY", with: "yyyy")
        .replacingOccurrences(of: "AA", with: "yy")
        .replacingOccurrences(of: "YY", with: "yy")
        .replacingOccurrences(of: "DD", with: "dd")
}

private func loadBadgesPrescripcionesMedicas(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    for elemIdx in 1...13 {
        guard let nombreElemento = record.getNombreElemento(elemIdx) else { continue }
        guard nombreElemento == "BadgesPrescripcionesMedicas" else { continue }

        for i in 1...16 {
            guard let atributo = record.getAtributo(section: elemIdx, field: i), !atributo.isEmpty else { continue }
            let valor = record.getValor(section: elemIdx, field: i) ?? ""
            // Formato: TipoFuente;Texto;ColorTexto;Size;ColorFondo
            let parts = valor.components(separatedBy: ";")

            switch atributo {
            case "BadgeTipoExamenAutomatizado(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
                if parts.count >= 1 { state.badgeExamenAutomatizado.font = parseFontName(parts[0].trimmingCharacters(in: .whitespaces)) }
                if parts.count >= 2 { state.badgeExamenAutomatizado.texto = parts[1].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 3 { state.badgeExamenAutomatizado.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 4 { state.badgeExamenAutomatizado.size = parts[3].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 5 { state.badgeExamenAutomatizado.colorFondo = parts[4].trimmingCharacters(in: .whitespaces) }
            case "BadgeTipoExamenMedico(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
                if parts.count >= 1 { state.badgeOrdenMedica.font = parseFontName(parts[0].trimmingCharacters(in: .whitespaces)) }
                if parts.count >= 2 { state.badgeOrdenMedica.texto = parts[1].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 3 { state.badgeOrdenMedica.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 4 { state.badgeOrdenMedica.size = parts[3].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 5 { state.badgeOrdenMedica.colorFondo = parts[4].trimmingCharacters(in: .whitespaces) }
            case "BadgeTipoRecetaMedica(TipoFuente;Texto;ColorTexto;Size;ColorFondo)":
                if parts.count >= 1 { state.badgeRecetaMedica.font = parseFontName(parts[0].trimmingCharacters(in: .whitespaces)) }
                if parts.count >= 2 { state.badgeRecetaMedica.texto = parts[1].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 3 { state.badgeRecetaMedica.colorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 4 { state.badgeRecetaMedica.size = parts[3].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 5 { state.badgeRecetaMedica.colorFondo = parts[4].trimmingCharacters(in: .whitespaces) }
            default:
                break
            }
        }
        break
    }
}

private func loadPopups(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    for elemIdx in 1...13 {
        guard let nombreElemento = record.getNombreElemento(elemIdx) else { continue }
        let nombre = nombreElemento.lowercased()

        if nombre.contains("popupcategorias") {
            state.popupCategorias = parsePopupGenerico(from: record, section: elemIdx)
        } else if nombre.contains("popupsugerencias") {
            state.popupCategorias = parsePopupGenerico(from: record, section: elemIdx)
        } else if nombre.contains("popupconfirmaciondatos") {
            state.popupConfirmDatos = parsePopupGenerico(from: record, section: elemIdx)
        } else if nombre.contains("popupconsentimientoinformado") {
            state.popupConsentimiento = parsePopupConsentimiento(from: record, section: elemIdx)
        } else if nombre.contains("popupenviarexamenemail") {
            state.popupEnviarEmail = parsePopupEmail(from: record, section: elemIdx)
        } else if nombre.contains("popupexamensincosto") {
            state.popupExamenSinCosto = parsePopupGenerico(from: record, section: elemIdx)
        } else if nombre.contains("popupcargacreacionexamen") {
            state.popupCarga = parsePopupCarga(from: record, section: elemIdx)
        } else if nombre.contains("popupexamenrealizado") {
            state.popupExamenRealizado = parsePopupGenerico(from: record, section: elemIdx)
        } else if nombre.contains("popupsugerencia") {
            state.popupSugerencia = parsePopupGenerico(from: record, section: elemIdx)
        }
    }
}

private func parsePopupGenerico(from record: BrandAccount, section: Int) -> PopupExamConfig {
    var popup = PopupExamConfig()

    print("   🔍 [parsePopupGenerico] Sección \(section) — leyendo campos 1-16")

    for i in 1...16 {
        let atributo = record.getAtributo(section: section, field: i)
        let valor = record.getValor(section: section, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        print("      [\(section).\(i)] atributo=\"\(atributo ?? "(nil)")\" valor=\"\(valor.prefix(60))\"")

        if let atributo = atributo {
            let attrLower = atributo.lowercased()

            if attrLower.contains("icono") && !attrLower.contains("atributo") {
                popup.iconURL = valor
                print("         ✅ iconURL = \"\(valor.prefix(50))\"")
            } else if attrLower.contains("titulo") && !attrLower.contains("atributo") {
                popup.titulo = valor
                print("         ✅ titulo = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("titulo") {
                popup.tituloAttr = parseTextAttributes(valor)
                print("         ✅ tituloAttr = font:\(popup.tituloAttr.font) size:\(popup.tituloAttr.size) color:\(popup.tituloAttr.color)")
            } else if attrLower.contains("descripcion") && !attrLower.contains("atributo") {
                popup.descripcion = valor
                print("         ✅ descripcion = \"\(valor.prefix(60))\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("descripcion") {
                popup.descripcionAttr = parseTextAttributes(valor)
                print("         ✅ descripcionAttr = font:\(popup.descripcionAttr.font) size:\(popup.descripcionAttr.size) color:\(popup.descripcionAttr.color)")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("nombres") && attrLower.contains("campos") {
                popup.labelAttr = parseTextAttributes(valor)
                print("         ✅ labelAttr = font:\(popup.labelAttr.font) size:\(popup.labelAttr.size) color:\(popup.labelAttr.color)")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("respuesta") {
                popup.respuestaAttr = parseTextAttributes(valor)
                print("         ✅ respuestaAttr = font:\(popup.respuestaAttr.font) size:\(popup.respuestaAttr.size) color:\(popup.respuestaAttr.color)")
            } else if attrLower.contains("labels") && attrLower.contains("campos") {
                // LabelsCamposPopUpConfirmacionDatos / LabelsCampoCorreoPopUpEnviarExamenEmail
                // Estos campos contienen labels de formulario — se ignoran en el parser genérico
                print("         ℹ️ labels de campos (no parseado en genérico): \"\(valor.prefix(50))\"")
            } else if attrLower.contains("botonaceptar") || attrLower.contains("botoncontinuar") || attrLower.contains("botondescargar") || attrLower.contains("botongenerar") {
                let parts = valor.components(separatedBy: ";")
                if parts.count >= 5 {
                    popup.btnAceptar = parseButton5(valor)
                } else {
                    popup.btnAceptar = parseButton3(valor)
                }
                print("         ✅ btnAceptar = texto:\"\(popup.btnAceptar.texto)\" fondoActivo:\(popup.btnAceptar.colorFondoActivo) fondoInactivo:\(popup.btnAceptar.colorFondoInactivo)")
            } else if attrLower.contains("botoncerrar") || attrLower.contains("botoncancelar") || attrLower.contains("botonvolver") {
                popup.btnCerrar = parseButton3(valor)
                print("         ✅ btnCerrar = texto:\"\(popup.btnCerrar.texto)\" colorTexto:\(popup.btnCerrar.colorTexto) colorFondo:\(popup.btnCerrar.colorFondo)")
            } else if attrLower.contains("colorbordecampos") && attrLower.contains("contexto") {
                popup.colorBordeConTexto = valor
                print("         ✅ colorBordeConTexto = \(valor)")
            } else if attrLower.contains("colorbordecampos") && attrLower.contains("sintexto") {
                popup.colorBordeSinTexto = valor
                print("         ✅ colorBordeSinTexto = \(valor)")
            } else if attrLower.contains("colorbarrascroll") {
                popup.colorBarraScroll = valor
                print("         ✅ colorBarraScroll = \(valor)")
            } else if attrLower.contains("colocirculos") || attrLower.contains("colorcirculos") || attrLower.contains("colocirculo") {
                popup.colorCirculoCalendario = valor
                print("         ✅ colorCirculoCalendario = \(valor)")
            } else {
                print("         ⚠️ atributo no reconocido: \"\(atributo)\"")
            }
        } else {
            // Atributo nil — limitación Realm: atributo6_7+ no existen en el schema
            let parts = valor.components(separatedBy: ";")
            if !popup.btnAceptar.texto.isEmpty && parts.count == 3 {
                popup.btnCerrar = parseButton3(valor)
                print("         ✅ [pos.\(i)] btnCerrar (detectado por formato) = texto:\"\(popup.btnCerrar.texto)\" colorTexto:\(popup.btnCerrar.colorTexto) colorFondo:\(popup.btnCerrar.colorFondo)")
            } else {
                switch i {
                case 7:
                    popup.respuestaAttr = parseTextAttributes(valor)
                    print("         ✅ [pos.7] respuestaAttr = font:\(popup.respuestaAttr.font) size:\(popup.respuestaAttr.size) color:\(popup.respuestaAttr.color)")
                case 8:
                    if parts.count >= 5 {
                        popup.btnAceptar = parseButton5(valor)
                    } else {
                        popup.btnAceptar = parseButton3(valor)
                    }
                    print("         ✅ [pos.8] btnAceptar = texto:\"\(popup.btnAceptar.texto)\" fondoActivo:\(popup.btnAceptar.colorFondoActivo) fondoInactivo:\(popup.btnAceptar.colorFondoInactivo)")
                case 9:
                    popup.btnCerrar = parseButton3(valor)
                    print("         ✅ [pos.9] btnCerrar = texto:\"\(popup.btnCerrar.texto)\" colorTexto:\(popup.btnCerrar.colorTexto) colorFondo:\(popup.btnCerrar.colorFondo)")
                default:
                    print("         ⚠️ [pos.\(i)] atributo nil, valor no asignado: \"\(valor.prefix(60))\"")
                }
            }
        }
    }

    return popup
}

private func parsePopupEmail(from record: BrandAccount, section: Int) -> PopupExamConfig {
    var popup = PopupExamConfig()

    print("   🔍 [parsePopupEmail] Sección \(section) — leyendo campos 1-16")

    for i in 1...16 {
        let atributo = record.getAtributo(section: section, field: i)
        let valor = record.getValor(section: section, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        print("      [\(section).\(i)] atributo=\"\(atributo ?? "(nil)")\" valor=\"\(valor.prefix(60))\"")

        if let atributo = atributo {
            let attrLower = atributo.lowercased()

            if attrLower.contains("icono") && !attrLower.contains("atributo") {
                popup.iconURL = valor
                print("         ✅ iconURL")
            } else if attrLower.contains("titulo") && !attrLower.contains("atributo") {
                popup.titulo = valor
                print("         ✅ titulo = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("titulo") {
                popup.tituloAttr = parseTextAttributes(valor)
                print("         ✅ tituloAttr = font:\(popup.tituloAttr.font) size:\(popup.tituloAttr.size) color:\(popup.tituloAttr.color)")
            } else if attrLower.contains("descripcion") && !attrLower.contains("atributo") {
                popup.descripcion = valor
                print("         ✅ descripcion = \"\(valor.prefix(60))\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("descripcion") {
                popup.descripcionAttr = parseTextAttributes(valor)
                print("         ✅ descripcionAttr")
            } else if attrLower.contains("labels") && attrLower.contains("campo") {
                // 7.6: LabelsCampoCorreoPopUpEnviarExamenEmail(Correo) → texto del label
                let parts = valor.components(separatedBy: ";")
                popup.labelTexto = parts.first?.trimmingCharacters(in: .whitespaces) ?? valor
                print("         ✅ labelTexto = \"\(popup.labelTexto)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("nombres") && attrLower.contains("campos") {
                popup.labelAttr = parseTextAttributes(valor)
                print("         ✅ labelAttr = font:\(popup.labelAttr.font) size:\(popup.labelAttr.size) color:\(popup.labelAttr.color)")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("respuesta") {
                popup.respuestaAttr = parseTextAttributes(valor)
                print("         ✅ respuestaAttr = font:\(popup.respuestaAttr.font) size:\(popup.respuestaAttr.size) color:\(popup.respuestaAttr.color)")
            } else if attrLower.contains("colorbordecampos") && attrLower.contains("contexto") {
                popup.colorBordeConTexto = valor
                print("         ✅ colorBordeConTexto = \(valor)")
            } else if attrLower.contains("colorbordecampos") && attrLower.contains("sintexto") {
                popup.colorBordeSinTexto = valor
                print("         ✅ colorBordeSinTexto = \(valor)")
            } else if attrLower.contains("botoncontinuar") || attrLower.contains("botonaceptar") {
                popup.btnAceptar = parseButton5(valor)
                print("         ✅ btnAceptar = texto:\"\(popup.btnAceptar.texto)\" fondoActivo:\(popup.btnAceptar.colorFondoActivo) fondoInactivo:\(popup.btnAceptar.colorFondoInactivo)")
            } else if attrLower.contains("botonvolver") || attrLower.contains("botoncerrar") {
                popup.btnCerrar = parseButton3(valor)
                print("         ✅ btnCerrar = texto:\"\(popup.btnCerrar.texto)\" colorTexto:\(popup.btnCerrar.colorTexto) colorFondo:\(popup.btnCerrar.colorFondo)")
            } else {
                print("         ⚠️ atributo no reconocido: \"\(atributo)\"")
            }
        } else {
            // Atributo nil — parseo posicional para PopUpEnviarExamenEmail
            switch i {
            case 7: // AtributosNombresCamposPopUpEnviarExamenEmail
                popup.labelAttr = parseTextAttributes(valor)
                print("         ✅ [pos.7] labelAttr = font:\(popup.labelAttr.font) size:\(popup.labelAttr.size) color:\(popup.labelAttr.color)")
            case 8: // AtributosRespuestaNombresCamposPopUpEnviarExamenEmail
                popup.respuestaAttr = parseTextAttributes(valor)
                print("         ✅ [pos.8] respuestaAttr = font:\(popup.respuestaAttr.font) size:\(popup.respuestaAttr.size) color:\(popup.respuestaAttr.color)")
            case 9: // ColorBordeCamposHoverConTextoPopUpEnviarExamenEmail
                popup.colorBordeConTexto = valor
                print("         ✅ [pos.9] colorBordeConTexto = \(valor)")
            case 10: // ColorBordeCamposHoverSinTextoPopUpEnviarExamenEmail
                popup.colorBordeSinTexto = valor
                print("         ✅ [pos.10] colorBordeSinTexto = \(valor)")
            case 11: // BotonContinuarPopUpEnviarExamenEmail (5 partes)
                popup.btnAceptar = parseButton5(valor)
                print("         ✅ [pos.11] btnAceptar = texto:\"\(popup.btnAceptar.texto)\" fondoActivo:\(popup.btnAceptar.colorFondoActivo)")
            case 12: // BotonVolverPopUpEnviarExamenEmail (3 partes)
                popup.btnCerrar = parseButton3(valor)
                print("         ✅ [pos.12] btnCerrar = texto:\"\(popup.btnCerrar.texto)\" colorTexto:\(popup.btnCerrar.colorTexto)")
            default:
                print("         ⚠️ [pos.\(i)] atributo nil, valor no asignado: \"\(valor.prefix(60))\"")
            }
        }
    }

    return popup
}

private func parsePopupCarga(from record: BrandAccount, section: Int) -> PopupCargaConfig {
    var popup = PopupCargaConfig()

    print("   🔍 [parsePopupCarga] Sección \(section) — leyendo campos 1-16")

    for i in 1...16 {
        let atributo = record.getAtributo(section: section, field: i)
        let valor = record.getValor(section: section, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        print("      [\(section).\(i)] atributo=\"\(atributo ?? "(nil)")\" valor=\"\(valor.prefix(60))\"")

        if let atributo = atributo {
            let attrLower = atributo.lowercased()

            if attrLower.contains("icono") && !attrLower.contains("atributo") {
                popup.iconURL = valor
                print("         ✅ iconURL = \"\(valor.prefix(50))\"")
            } else if attrLower.contains("titulo") && !attrLower.contains("atributo") {
                popup.titulo = valor
                print("         ✅ titulo = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("titulo") {
                popup.tituloAttr = parseTextAttributes(valor)
                print("         ✅ tituloAttr = font:\(popup.tituloAttr.font) size:\(popup.tituloAttr.size) color:\(popup.tituloAttr.color)")
            } else if attrLower.contains("descripcion") && !attrLower.contains("atributo") {
                popup.descripcion = valor
                print("         ✅ descripcion = \"\(valor.prefix(60))\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("descripcion") {
                popup.descripcionAttr = parseTextAttributes(valor)
                print("         ✅ descripcionAttr = font:\(popup.descripcionAttr.font) size:\(popup.descripcionAttr.size) color:\(popup.descripcionAttr.color)")
            } else if attrLower.contains("colorspinner") {
                popup.colorSpinner = valor
                print("         ✅ colorSpinner = \(valor)")
            } else if attrLower.contains("cantidadsegundos") || attrLower.contains("segundosmostrar") {
                popup.segundosMostrar = Int(valor) ?? 6
                print("         ✅ segundosMostrar = \(popup.segundosMostrar)")
            } else {
                print("         ⚠️ atributo no reconocido: \"\(atributo)\"")
            }
        } else {
            // Atributo nil — parseo por posición para PopupCarga
            switch i {
            case 7: // CantidadSegundosMostrar (suele venir como "5" o "6")
                if let segundos = Int(valor) {
                    popup.segundosMostrar = segundos
                    print("         ✅ [pos.7] segundosMostrar = \(segundos)")
                } else {
                    print("         ⚠️ [pos.7] atributo nil, valor no es entero: \"\(valor)\"")
                }
            default:
                print("         ⚠️ [pos.\(i)] atributo nil, valor no asignado: \"\(valor.prefix(60))\"")
            }
        }
    }

    return popup
}

private func parsePopupConsentimiento(from record: BrandAccount, section: Int) -> PopupConsentimientoConfig {
    var popup = PopupConsentimientoConfig()

    print("   🔍 [parsePopupConsentimiento] Sección \(section) — leyendo campos 1-16")

    for i in 1...16 {
        let atributo = record.getAtributo(section: section, field: i)
        let valor = record.getValor(section: section, field: i) ?? ""

        guard atributo != nil || !valor.isEmpty else { continue }

        print("      [\(section).\(i)] atributo=\"\(atributo ?? "(nil)")\" valor=\"\(valor.prefix(60))\"")

        if let atributo = atributo {
            let attrLower = atributo.lowercased()

            if attrLower.contains("icono") && !attrLower.contains("atributo") {
                popup.iconURL = valor
                print("         ✅ iconURL = \"\(valor.prefix(50))\"")
            } else if attrLower.contains("titulo") && !attrLower.contains("atributo") {
                popup.titulo = valor
                print("         ✅ titulo = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("titulo") {
                popup.tituloAttr = parseTextAttributes(valor)
                print("         ✅ tituloAttr = font:\(popup.tituloAttr.font) size:\(popup.tituloAttr.size) color:\(popup.tituloAttr.color)")
            } else if attrLower.contains("descripcion") && !attrLower.contains("atributo") {
                popup.descripcion = valor
                print("         ✅ descripcion = \"\(valor.prefix(60))\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("descripcion") {
                popup.descripcionAttr = parseTextAttributes(valor)
                print("         ✅ descripcionAttr = font:\(popup.descripcionAttr.font) size:\(popup.descripcionAttr.size) color:\(popup.descripcionAttr.color)")
            } else if attrLower.contains("textocheckbox") && !attrLower.contains("atributo") {
                popup.checkboxTexto = valor
                print("         ✅ checkboxTexto = \"\(valor)\"")
            } else if attrLower.hasPrefix("atributos") && attrLower.contains("textocheckbox") {
                popup.checkboxTextoAttr = parseTextAttributes(valor)
                print("         ✅ checkboxTextoAttr = font:\(popup.checkboxTextoAttr.font) size:\(popup.checkboxTextoAttr.size) color:\(popup.checkboxTextoAttr.color)")
            } else if attrLower.contains("colorcheckbox") {
                popup.checkboxColor = valor
                print("         ✅ checkboxColor = \"\(valor)\"")
            } else if attrLower.contains("botonaceptar") {
                let parts = valor.components(separatedBy: ";")
                if parts.count >= 5 {
                    popup.btnAceptar = parseButton5(valor)
                } else {
                    popup.btnAceptar = parseButton3(valor)
                }
                print("         ✅ btnAceptar = texto:\"\(popup.btnAceptar.texto)\" fondoActivo:\(popup.btnAceptar.colorFondoActivo) fondoInactivo:\(popup.btnAceptar.colorFondoInactivo)")
            } else if attrLower.contains("botoncancelar") || attrLower.contains("botoncerrar") {
                popup.btnCancelar = parseButton3(valor)
                print("         ✅ btnCancelar = texto:\"\(popup.btnCancelar.texto)\" colorTexto:\(popup.btnCancelar.colorTexto) colorFondo:\(popup.btnCancelar.colorFondo)")
            } else if attrLower.contains("colorbarrascroll") {
                popup.colorBarraScroll = valor
                print("         ✅ colorBarraScroll = \(valor)")
            } else {
                print("         ⚠️ atributo no reconocido: \"\(atributo)\"")
            }
        } else {
            let parts = valor.components(separatedBy: ";")
            switch i {
            case 7:
                popup.checkboxTextoAttr = parseTextAttributes(valor)
                print("         ✅ [pos.7] checkboxTextoAttr = font:\(popup.checkboxTextoAttr.font) size:\(popup.checkboxTextoAttr.size) color:\(popup.checkboxTextoAttr.color)")
            case 8:
                popup.checkboxColor = valor
                print("         ✅ [pos.8] checkboxColor = \"\(valor)\"")
            case 9:
                if parts.count >= 5 {
                    popup.btnAceptar = parseButton5(valor)
                } else {
                    popup.btnAceptar = parseButton3(valor)
                }
                print("         ✅ [pos.9] btnAceptar = texto:\"\(popup.btnAceptar.texto)\" fondoActivo:\(popup.btnAceptar.colorFondoActivo) fondoInactivo:\(popup.btnAceptar.colorFondoInactivo)")
            case 10:
                popup.btnCancelar = parseButton3(valor)
                print("         ✅ [pos.10] btnCancelar = texto:\"\(popup.btnCancelar.texto)\" colorTexto:\(popup.btnCancelar.colorTexto) colorFondo:\(popup.btnCancelar.colorFondo)")
            default:
                print("         ⚠️ [pos.\(i)] atributo nil, valor no asignado: \"\(valor.prefix(60))\"")
            }
        }
    }

    return popup
}
