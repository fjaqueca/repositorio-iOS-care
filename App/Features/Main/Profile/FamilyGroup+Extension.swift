//
//  FamilyGroup+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 18/07/2024.
//

import Foundation
import RealmSwift

// MARK: - Parse Helpers (privados)

private func parseFGFontName(_ raw: String) -> String {
    switch raw.lowercased().trimmingCharacters(in: .whitespaces) {
    case "firasans_bold":   return "FiraSans-Bold"
    case "firasans_italic": return "FiraSans-Italic"
    case "firasans_medium": return "FiraSans-Medium"
    default:                return "FiraSans-Regular"
    }
}

/// Parse "font;size;color;alignment" → FGTextAttributes
private func parseFGTextAttributes(_ raw: String?) -> FGTextAttributes {
    guard let raw = raw, !raw.isEmpty else { return FGTextAttributes() }
    let parts = raw.components(separatedBy: ";")
    var attr = FGTextAttributes()
    if parts.count >= 1 { attr.font = parseFGFontName(parts[0]) }
    if parts.count >= 2 { attr.size = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { attr.color = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { attr.alignment = parts[3].trimmingCharacters(in: .whitespaces) }
    return attr
}

/// Parse "texto;colorTexto;colorFondo" → FGButtonConfig (3 partes)
private func parseFGButton3(_ raw: String?) -> FGButtonConfig {
    guard let raw = raw, !raw.isEmpty else { return FGButtonConfig() }
    let parts = raw.components(separatedBy: ";")
    var btn = FGButtonConfig()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.colorTexto = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { btn.colorFondo = parts[2].trimmingCharacters(in: .whitespaces) }
    return btn
}

/// Parse "texto;colorTextoActivo;colorTextoInactivo;colorFondoActivo;colorFondoInactivo" → FGButton5Config
private func parseFGButton5(_ raw: String?) -> FGButton5Config {
    guard let raw = raw, !raw.isEmpty else { return FGButton5Config() }
    let parts = raw.components(separatedBy: ";")
    var btn = FGButton5Config()
    if parts.count >= 1 { btn.texto = parts[0].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 2 { btn.colorTextoActivo = parts[1].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 3 { btn.colorTextoInactivo = parts[2].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 4 { btn.colorFondoActivo = parts[3].trimmingCharacters(in: .whitespaces) }
    if parts.count >= 5 { btn.colorFondoInactivo = parts[4].trimmingCharacters(in: .whitespaces) }
    return btn
}

// MARK: - KVC Helper

/// Lee un valor de BrandAccount vía KVC, intentando camelCase primero y Salesforce después.
private func fgGetValor(_ brand: BrandAccount, section: Int, field: Int) -> String? {
    let camelKey = "valor\(section)\(field)C"
    if brand.objectSchema[camelKey] != nil,
       let v = (brand as NSObject).value(forKey: camelKey) as? String, !v.isEmpty {
        return v
    }
    let sfKey = "Valor_\(section)_\(field)__c"
    if brand.objectSchema[sfKey] != nil,
       let v = (brand as NSObject).value(forKey: sfKey) as? String, !v.isEmpty {
        return v
    }
    return nil
}

private func fgGetAtributo(_ brand: BrandAccount, section: Int, field: Int) -> String? {
    let camelKey = "atributo\(section)\(field)C"
    if brand.objectSchema[camelKey] != nil,
       let v = (brand as NSObject).value(forKey: camelKey) as? String, !v.isEmpty {
        return v
    }
    let sfKey = "Atributo_\(section)_\(field)__c"
    if brand.objectSchema[sfKey] != nil,
       let v = (brand as NSObject).value(forKey: sfKey) as? String, !v.isEmpty {
        return v
    }
    return nil
}

// MARK: - Extension principal

extension FamilyGroupView {

    // ══════════════════════════════════════════════════════
    // MARK: - loadUIState (PreLogin — background)
    // ══════════════════════════════════════════════════════

    func loadUIState() {
        if let record = self.items.first?.records {
            for brandAccount in record {
                if brandAccount.Name == "PreLogin" {
                    // MARK: - SingUpUIState
                    self.preLoginState.singUpFormUIState.imageBackground = brandAccount.valor51C ?? ""

                    self.preLoginState.singUpFormUIState.title.text = brandAccount.valor52C ?? ""
                    if let valor53 = brandAccount.valor53C?.components(separatedBy: ";"), valor53.count >= 2 {
                        self.preLoginState.singUpFormUIState.title.colorText = valor53[0]
                        self.preLoginState.singUpFormUIState.title.sizeText = valor53[1]
                    }

                    self.preLoginState.singUpFormUIState.btnSend.textBtn = brandAccount.valor54C ?? ""
                    if let valor55 = brandAccount.valor55C?.components(separatedBy: ";"), valor55.count >= 3 {
                        self.preLoginState.singUpFormUIState.btnSend.colorTextBtn = valor55[0]
                        self.preLoginState.singUpFormUIState.btnSend.backgroundBtn = valor55[1]
                        self.preLoginState.singUpFormUIState.btnSend.backgroundPressBtn = valor55[2]

                        // MARK: - PopupRegisterSuccessUIState
                        self.preLoginState.popupRegisterSuccessUIState.imageBackground = brandAccount.Valor_11_1__c ?? ""
                        self.preLoginState.popupRegisterSuccessUIState.icon = brandAccount.Valor_11_2__c ?? ""
                        self.preLoginState.popupRegisterSuccessUIState.msg.text = brandAccount.Valor_11_3__c ?? ""
                        if let valor114 = brandAccount.Valor_11_4__c?.components(separatedBy: ";"), valor114.count >= 2 {
                            self.preLoginState.popupRegisterSuccessUIState.msg.colorText = valor114[0]
                            self.preLoginState.popupRegisterSuccessUIState.msg.sizeText = valor114[1]
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - loadFamilyGroupConfig (record "GrupoFamiliar")
    // ══════════════════════════════════════════════════════

    func loadFamilyGroupConfig() -> FamilyGroupUIState {
        var state = FamilyGroupUIState()

        guard let records = self.items.first?.records else {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("👨‍👩‍👧 [GrupoFamiliar] No se encontraron BrandAccount records")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return state
        }

        var grupoFamiliarRecord: BrandAccount?
        for brand in records where brand.Name == "GrupoFamiliar" {
            grupoFamiliarRecord = brand
            break
        }

        guard let brand = grupoFamiliarRecord else {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("👨‍👩‍👧 [GrupoFamiliar] Record \"GrupoFamiliar\" NO encontrado en BrandAccount")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return state
        }

        // ── Dump completo para debugging ──
        dumpGrupoFamiliarRecord(brand)

        // ── Elemento 1: SeccionPrincipal ──
        loadSeccionPrincipal(from: brand, into: &state)

        // ── Elemento 2: SeccionModificar ──
        loadSeccionModificar(from: brand, into: &state)

        // ── Elemento 3: SeccionAgregarCarga ──
        loadSeccionAgregar(from: brand, into: &state)

        // ── Elemento 4: SeccionEliminarCarga (Over-Limit) ──
        loadSeccionOverLimit(from: brand, into: &state)

        // ── Elemento 5: PopUpEliminarCarga ──
        loadPopupEliminar(from: brand, into: &state)

        // ── Elemento 6: BackArrowSeccionGrupoFamiliar ──
        loadBackArrow(from: brand, into: &state)

        // ── Elemento 7: FondoAvatarGrupoFamiliar ──
        loadFondoAvatar(from: brand, into: &state)

        return state
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Loaders por sección
    // ══════════════════════════════════════════════════════

    private func loadSeccionPrincipal(from brand: BrandAccount, into state: inout FamilyGroupUIState) {
        let s = 1 // Elemento 1

        for f in 1...16 {
            guard let attr = fgGetAtributo(brand, section: s, field: f) else { continue }
            let val = fgGetValor(brand, section: s, field: f)

            switch attr {
            case "TituloSeccionPrincipal":
                state.seccionPrincipal.titulo = val ?? ""

            case "AtributosTituloSeccionPrincipal(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionPrincipal.tituloAttr = parseFGTextAttributes(val)

            case "DescripcionSeccionPrincipal":
                state.seccionPrincipal.descripcion = val ?? ""

            case "AtributosDescripcionSeccionPrincipal(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionPrincipal.descripcionAttr = parseFGTextAttributes(val)

            case "LinkIconoUsuarios":
                state.seccionPrincipal.iconoUsuarios = val ?? ""

            case "AtributosNombresCargas(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionPrincipal.nombresAttr = parseFGTextAttributes(val)

            case "TextoBotonModificar":
                state.seccionPrincipal.textoBotonModificar = val ?? ""

            case "AtributosTextoBotonModificar(TipoFuente;Size;ColorTexto;ColorIcono;ColorBordeBoton)":
                if let raw = val {
                    let parts = raw.components(separatedBy: ";")
                    if parts.count >= 1 { state.seccionPrincipal.botonModificarFont = parseFGFontName(parts[0]) }
                    if parts.count >= 2 { state.seccionPrincipal.botonModificarSize = parts[1].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 3 { state.seccionPrincipal.botonModificarColorTexto = parts[2].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 4 { state.seccionPrincipal.colorIconoEditar = parts[3].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 5 { state.seccionPrincipal.colorBordeEditar = parts[4].trimmingCharacters(in: .whitespaces) }
                }

            case "ColorIconoEliminar(Activo;Hover)":
                if let raw = val {
                    let parts = raw.components(separatedBy: ";")
                    if parts.count >= 1 { state.seccionPrincipal.colorIconoEliminar = parts[0].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 2 { state.seccionPrincipal.colorIconoEliminarHover = parts[1].trimmingCharacters(in: .whitespaces) }
                }

            case "BotonAgregarCarga(Texto;ColorTexto;ColorBoton)":
                state.seccionPrincipal.botonAgregar = parseFGButton3(val)

            case "ColorSpinnerGrupoFamiliar":
                state.seccionPrincipal.colorSpinner = val ?? ""

            case "ColorBordeCampoEstaticoSeccionPrincipal":
                state.seccionPrincipal.colorBordeCampo = val ?? ""

            case "IconoSinCargasSeccionPrincipal":
                state.seccionPrincipal.iconoSinCargas = val ?? ""

            case "TextoSinCargasSeccionPrincipal":
                state.seccionPrincipal.textoSinCargas = val ?? ""

            case "AtributosTextoSinCargasSeccionPrincipal(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionPrincipal.textoSinCargasAttr = parseFGTextAttributes(val)

            default:
                break
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] SeccionPrincipal parseada")
        print("   titulo: \"\(state.seccionPrincipal.titulo)\"")
        print("   tituloAttr: font=\(state.seccionPrincipal.tituloAttr.font) size=\(state.seccionPrincipal.tituloAttr.size) color=\(state.seccionPrincipal.tituloAttr.color)")
        print("   descripcion: \"\(state.seccionPrincipal.descripcion)\"")
        print("   botonAgregar: texto=\"\(state.seccionPrincipal.botonAgregar.texto)\" color=\(state.seccionPrincipal.botonAgregar.colorTexto) fondo=\(state.seccionPrincipal.botonAgregar.colorFondo)")
        print("   colorSpinner: \(state.seccionPrincipal.colorSpinner)")
        print("   colorIconoEliminar: \(state.seccionPrincipal.colorIconoEliminar)")
        print("   colorIconoEditar: \(state.seccionPrincipal.colorIconoEditar)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    private func loadSeccionModificar(from brand: BrandAccount, into state: inout FamilyGroupUIState) {
        let s = 2

        for f in 1...16 {
            guard let attr = fgGetAtributo(brand, section: s, field: f) else { continue }
            let val = fgGetValor(brand, section: s, field: f)

            switch attr {
            case "TituloModalModificarSeccionModificar":
                state.seccionModificar.titulo = val ?? ""

            case "AtributosTituloModalModificarSeccionModificar(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionModificar.tituloAttr = parseFGTextAttributes(val)

            case "LabelTitulosCamposSeccionModificar(Identificacion;Nombre;Apellido;Direccion;FechaNacimiento;Sexo;Correo;Telefono)":
                state.seccionModificar.labels = (val ?? "").components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }

            case "AtributosLabelTitulosCamposSeccionModificar(Identificacion;Nombre;Apellido;Direccion;FechaNacimiento;Sexo;Correo;Telefono)(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionModificar.labelsAttr = parseFGTextAttributes(val)

            case "ColorAsteriscoObligatorioSeccionModificar":
                state.seccionModificar.colorAsterisco = val ?? ""

            case "ColorBordeCampoEstaticoSeccionModificar":
                state.seccionModificar.colorBordeCampo = val ?? ""

            case "ColorHoverBordeCampoSeleccionadoSeccionModificar":
                state.seccionModificar.colorBordeSeleccionado = val ?? ""

            case "ColorTextoSelecionadoSeccionModificar":
                state.seccionModificar.colorTextoSeleccionado = val ?? ""

            case "ColorListaSeleccionSeccionModificar(ColorTexto;Hover)":
                if let raw = val {
                    let parts = raw.components(separatedBy: ";")
                    if parts.count >= 1 { state.seccionModificar.colorListaTexto = parts[0].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 2 { state.seccionModificar.colorListaHover = parts[1].trimmingCharacters(in: .whitespaces) }
                }

            case "ColorIconoCalendarioSeccionModificar":
                state.seccionModificar.colorIconoCalendario = val ?? ""

            case "ColoresCalendarioSeccionModificar(ColorFlechas;ColorMes;ColorAño;ColorDiaSemana;ColorDiaMes;ColorHover;ColorTextoSeleccion;ColorFondoSeleccion)":
                if let raw = val {
                    let parts = raw.components(separatedBy: ";")
                    var cal = FGCalendarioConfig()
                    if parts.count >= 1 { cal.colorFlechas = parts[0].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 2 { cal.colorMes = parts[1].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 3 { cal.colorAnio = parts[2].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 4 { cal.colorDiaSemana = parts[3].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 5 { cal.colorDiaMes = parts[4].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 6 { cal.colorHover = parts[5].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 7 { cal.colorTextoSeleccion = parts[6].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 8 { cal.colorFondoSeleccion = parts[7].trimmingCharacters(in: .whitespaces) }
                    state.seccionModificar.coloresCalendario = cal
                }

            case "ColorScrollSeccionModificar":
                state.seccionModificar.colorScroll = val ?? ""

            case "BotonCancelarSeccionModificar(Texto;ColorTextoActivo;ColorTextoHover;ColorBotonActivo;ColorBotonHover)":
                state.seccionModificar.botonCancelar = parseFGButton5(val)

            case "BotonModificarSeccionModificar(Texto;ColorTextoActivo;ColorTextoInactivo;ColorBotonActivo;ColorBotonInactivo)":
                state.seccionModificar.botonModificar = parseFGButton5(val)

            case "TextoPreSeleccionSeccionModificar":
                state.seccionModificar.textoPreSeleccion = val ?? ""

            default:
                break
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] SeccionModificar parseada")
        print("   titulo: \"\(state.seccionModificar.titulo)\"")
        print("   labels: \(state.seccionModificar.labels)")
        print("   botonCancelar: texto=\"\(state.seccionModificar.botonCancelar.texto)\"")
        print("   botonModificar: texto=\"\(state.seccionModificar.botonModificar.texto)\"")
        print("   colorIconoCalendario: \(state.seccionModificar.colorIconoCalendario)")
        let cal = state.seccionModificar.coloresCalendario
        print("   coloresCalendario: flechas=\(cal.colorFlechas) mes=\(cal.colorMes) anio=\(cal.colorAnio) diaSemana=\(cal.colorDiaSemana) diaMes=\(cal.colorDiaMes) hover=\(cal.colorHover) textoSel=\(cal.colorTextoSeleccion) fondoSel=\(cal.colorFondoSeleccion)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    private func loadSeccionAgregar(from brand: BrandAccount, into state: inout FamilyGroupUIState) {
        let s = 3

        for f in 1...16 {
            guard let attr = fgGetAtributo(brand, section: s, field: f) else { continue }
            let val = fgGetValor(brand, section: s, field: f)

            switch attr {
            case "TituloModalEditarSeccionAgregarCarga":
                state.seccionAgregar.titulo = val ?? ""

            case "AtributosTituloModalEditarSeccionAgregarCarga(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionAgregar.tituloAttr = parseFGTextAttributes(val)

            case "LabelTitulosCamposSeccionAgregarCarga(Identificacion;TipoAfiliado;Nombre;Apellido;FechaNacimiento;Correo;Telefono)":
                state.seccionAgregar.labels = (val ?? "").components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }

            case "AtributosLabelTitulosCamposSeccionAgregarCarga(Identificacion;TipoAfiliado;Nombre;Apellido;FechaNacimiento;Correo;Telefono)(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionAgregar.labelsAttr = parseFGTextAttributes(val)

            case "ColorAsteriscoObligatorioSeccionAgregarCarga":
                state.seccionAgregar.colorAsterisco = val ?? ""

            case "ColorBordeCampoEstaticoSeccionAgregarCarga":
                state.seccionAgregar.colorBordeCampo = val ?? ""

            case "ColorHoverBordeCampoSeleccionadoSeccionAgregarCarga":
                state.seccionAgregar.colorBordeSeleccionado = val ?? ""

            case "ColorTextoSelecionadoSeccionAgregarCarga":
                state.seccionAgregar.colorTextoSeleccionado = val ?? ""

            case "ColorIconoCalendarioSeccionAgregarCarga":
                state.seccionAgregar.colorIconoCalendario = val ?? ""

            case "ColoresCalendarioSeccionAgregarCarga(ColorFlechas;ColorMes;ColorAño;ColorDiaSemana;ColorDiaMes;ColorHover;ColorTextoSeleccion;ColorFondoSeleccion)":
                if let raw = val {
                    let parts = raw.components(separatedBy: ";")
                    var cal = FGCalendarioConfig()
                    if parts.count >= 1 { cal.colorFlechas = parts[0].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 2 { cal.colorMes = parts[1].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 3 { cal.colorAnio = parts[2].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 4 { cal.colorDiaSemana = parts[3].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 5 { cal.colorDiaMes = parts[4].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 6 { cal.colorHover = parts[5].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 7 { cal.colorTextoSeleccion = parts[6].trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 8 { cal.colorFondoSeleccion = parts[7].trimmingCharacters(in: .whitespaces) }
                    state.seccionAgregar.coloresCalendario = cal
                }

            case "ColorScrollSeccionAgregarCarga":
                state.seccionAgregar.colorScroll = val ?? ""

            case "BotonCancelarSeccionAgregarCarga(Texto;ColorTextoActivo;ColorTextoHover;ColorBotonActivo;ColorBotonHover)":
                state.seccionAgregar.botonCancelar = parseFGButton5(val)

            case "BotonAgregarSeccionAgregarCarga(Texto;ColorTextoActivo;ColorTextoInactivo;ColorBotonActivo;ColorBotonInactivo)":
                state.seccionAgregar.botonAgregar = parseFGButton5(val)

            case "ColorSpinnerCargaTipoAfiliadoSeccionAgregarCarga":
                state.seccionAgregar.colorSpinner = val ?? ""

            default:
                break
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] SeccionAgregarCarga parseada")
        print("   titulo: \"\(state.seccionAgregar.titulo)\"")
        print("   labels: \(state.seccionAgregar.labels)")
        print("   botonCancelar: texto=\"\(state.seccionAgregar.botonCancelar.texto)\"")
        print("   botonAgregar: texto=\"\(state.seccionAgregar.botonAgregar.texto)\"")
        let calAdd = state.seccionAgregar.coloresCalendario
        print("   coloresCalendario: flechas=\(calAdd.colorFlechas) mes=\(calAdd.colorMes) anio=\(calAdd.colorAnio) diaSemana=\(calAdd.colorDiaSemana) diaMes=\(calAdd.colorDiaMes) hover=\(calAdd.colorHover) textoSel=\(calAdd.colorTextoSeleccion) fondoSel=\(calAdd.colorFondoSeleccion)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    private func loadSeccionOverLimit(from brand: BrandAccount, into state: inout FamilyGroupUIState) {
        let s = 4

        for f in 1...16 {
            guard let attr = fgGetAtributo(brand, section: s, field: f) else { continue }
            let val = fgGetValor(brand, section: s, field: f)

            switch attr {
            case "TituloModalSeccionEliminarCarga":
                state.seccionOverLimit.titulo = val ?? ""

            case "AtributosTituloModalSeccionEliminarCarga(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionOverLimit.tituloAttr = parseFGTextAttributes(val)

            case "TextoModalSeccionEliminarCarga":
                state.seccionOverLimit.texto = val ?? ""

            case "AtributosTextoModalSeccionEliminarCarga(TipoFuente;Size;ColorTexto;Posicion)":
                state.seccionOverLimit.textoAttr = parseFGTextAttributes(val)

            default:
                break
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] SeccionOverLimit parseada")
        print("   titulo: \"\(state.seccionOverLimit.titulo)\"")
        print("   texto: \"\(state.seccionOverLimit.texto)\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    private func loadPopupEliminar(from brand: BrandAccount, into state: inout FamilyGroupUIState) {
        let s = 5

        for f in 1...16 {
            guard let attr = fgGetAtributo(brand, section: s, field: f) else { continue }
            let val = fgGetValor(brand, section: s, field: f)

            switch attr {
            case "LogoPopUpEliminarCarga":
                state.popupEliminar.iconUrl = val ?? ""

            case "TituloPopUpEliminarCarga":
                state.popupEliminar.titulo = val ?? ""

            case "AtributosTituloPopUpEliminarCarga(TipoFuente;Size;ColorTexto;Posicion)":
                state.popupEliminar.tituloAttr = parseFGTextAttributes(val)

            case "TextoPopUpEliminarCarga":
                state.popupEliminar.texto = val ?? ""

            case "AtributosAtributosTituloPopUpEliminarCarga(TipoFuente;Size;ColorTexto;Posicion)":
                state.popupEliminar.textoAttr = parseFGTextAttributes(val)

            case "BotonSiPopUpEliminarCarga(Texto;ColorTexto;ColorBoton)":
                state.popupEliminar.botonSi = parseFGButton3(val)

            case "BotonNoPopUpEliminarCarga(Texto;ColorTexto;ColorBoton)":
                state.popupEliminar.botonNo = parseFGButton3(val)

            default:
                break
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] PopupEliminar parseada")
        print("   iconUrl: \"\(state.popupEliminar.iconUrl)\"")
        print("   titulo: \"\(state.popupEliminar.titulo)\"")
        print("   texto: \"\(state.popupEliminar.texto)\"")
        print("   botonSi: texto=\"\(state.popupEliminar.botonSi.texto)\" color=\(state.popupEliminar.botonSi.colorTexto) fondo=\(state.popupEliminar.botonSi.colorFondo)")
        print("   botonNo: texto=\"\(state.popupEliminar.botonNo.texto)\" color=\(state.popupEliminar.botonNo.colorTexto) fondo=\(state.popupEliminar.botonNo.colorFondo)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    private func loadBackArrow(from brand: BrandAccount, into state: inout FamilyGroupUIState) {
        let s = 6

        for f in 1...16 {
            guard let attr = fgGetAtributo(brand, section: s, field: f) else { continue }
            let val = fgGetValor(brand, section: s, field: f)

            switch attr {
            case "ColorBackArrow":
                state.backArrow.colorBackArrow = val ?? ""

            default:
                break
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] BackArrow parseado")
        print("   colorBackArrow: \"\(state.backArrow.colorBackArrow)\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    private func loadFondoAvatar(from brand: BrandAccount, into state: inout FamilyGroupUIState) {
        let s = 7

        for f in 1...16 {
            guard let attr = fgGetAtributo(brand, section: s, field: f) else { continue }
            let val = fgGetValor(brand, section: s, field: f)

            switch attr {
            case "ColorFondoAvatarGrupoFamiliarCarga":
                state.fondoAvatar.colorFondoAvatar = val ?? ""

            default:
                break
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] FondoAvatar parseado")
        print("   colorFondoAvatar: \"\(state.fondoAvatar.colorFondoAvatar)\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Dump para debugging
    // ══════════════════════════════════════════════════════

    private func dumpGrupoFamiliarRecord(_ brand: BrandAccount) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [BrandAccount] DUMP COMPLETO — record: \"GrupoFamiliar\"")
        print("   Id: \(brand.Id ?? "(nil)")")
        print("   brandGroupsC: \(brand.brandGroupsC ?? "(nil)")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        for elementIdx in 1...13 {
            let nombreKey = "nombreElemento\(elementIdx)C"
            let nombreVal: String? = {
                guard brand.objectSchema[nombreKey] != nil else { return nil }
                return (brand as NSObject).value(forKey: nombreKey) as? String
            }()

            var sectionHasData = !(nombreVal ?? "").isEmpty
            if !sectionHasData {
                for fieldIdx in 1...16 {
                    if fgGetAtributo(brand, section: elementIdx, field: fieldIdx) != nil {
                        sectionHasData = true
                        break
                    }
                }
            }
            guard sectionHasData else { continue }

            print("   ┌─── Elemento \(elementIdx): \"\(nombreVal ?? "(vacío)")\" ───")

            for fieldIdx in 1...16 {
                let attrVal = fgGetAtributo(brand, section: elementIdx, field: fieldIdx)
                let valVal = fgGetValor(brand, section: elementIdx, field: fieldIdx)

                if attrVal != nil || valVal != nil {
                    print("   │  [\(elementIdx)_\(fieldIdx)] atributo: \"\(attrVal ?? "(vacío)")\"")
                    print("   │           valor: \"\(valVal ?? "(vacío)")\"")
                }
            }
            print("   └────────────────────────────────────")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}
