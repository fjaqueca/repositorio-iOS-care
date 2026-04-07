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

        for record in records {
            if record.Name == "ExamenesAutomatizadosCustom" {
                customRecord = record
            }
            if record.Name == "ExamenesAutomatizados" {
                mainRecord = record
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
            for elemIdx in 1...10 {
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
            loadBackArrowColorSeccion(from: custom, into: &state)
            print("   🔙 BackArrowColorSeccion (Elemento 8): \(state.backArrowColorSeccion)")
            loadSeleccionarTodosConfig(from: custom, into: &state)
            print("   ✅ SeleccionarTodos (Elemento 9): texto=\"\(state.seleccionarTodosTexto)\" font=\(state.seleccionarTodosAttr.font) size=\(state.seleccionarTodosAttr.size) color=\(state.seleccionarTodosAttr.color)")
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
        } else {
            print("⚠️ [ExamenesAutomatizados] Record 'ExamenesAutomatizados' NO encontrado")
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
    for i in 1...16 {
        guard let imageURL = record.getAtributo(section: 1, field: i),
              !imageURL.isEmpty else { continue }
        let linkURL = record.getValor(section: 1, field: i) ?? ""
        let isNull = linkURL.lowercased() == "null"
        state.bannersHub.append(BannerExamItem(
            imageURL: imageURL,
            linkURL: isNull ? "" : linkURL
        ))
    }
}

private func loadHeaderConfig(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 2: Header pantalla principal
    for i in 1...16 {
        let atributo = record.getAtributo(section: 2, field: i)
        let valor = record.getValor(section: 2, field: i) ?? ""
        guard let atributo = atributo else { continue }
        let attrLower = atributo.lowercased()

        if attrLower.contains("titulo") && !attrLower.contains("atributo") {
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

// MARK: - Elemento 8: Color Back Arrow de toda la sección exámenes

private func loadBackArrowColorSeccion(from record: BrandAccount, into state: inout AutomatedExamsUIState) {
    // Elemento 8: ColorBackArrowSeccionCompleta
    // 8.1: BackArrowColor → color hex del back arrow para toda la sección de exámenes
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📋 [BackArrowColorSeccion] Cargando Elemento 8")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    for i in 1...16 {
        guard let atributo = record.getAtributo(section: 8, field: i),
              !atributo.isEmpty else { continue }
        let valor = record.getValor(section: 8, field: i) ?? ""

        switch atributo {
        case "BackArrowColor":
            if !valor.isEmpty {
                state.backArrowColorSeccion = valor
                print("      [8.\(i)] ✅ backArrowColorSeccion = \"\(valor)\"")
            }
        default:
            print("      [8.\(i)] ⚠️ Atributo no reconocido: \"\(atributo)\" valor=\"\(valor)\"")
        }
    }
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
        default:
            print("      [9.\(i)] ⚠️ Atributo no reconocido: \"\(atributo)\" valor=\"\(valor)\"")
        }
    }
    print("   📊 RESULTADO FINAL: texto=\"\(state.seleccionarTodosTexto)\" font=\(state.seleccionarTodosAttr.font) size=\(state.seleccionarTodosAttr.size) color=\(state.seleccionarTodosAttr.color)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
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
