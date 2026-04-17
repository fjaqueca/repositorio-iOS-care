//
//  Profile+Extension.swift
//  CareAssistance
//

import Foundation
import RealmSwift

// MARK: - Font Parser

private func parseFontName(_ raw: String) -> String {
    switch raw.lowercased().trimmingCharacters(in: .whitespaces) {
    case "firasans_bold":   return "FiraSans-Bold"
    case "firasans_italic": return "FiraSans-Italic"
    case "firasans_medium": return "FiraSans-Medium"
    default:                return "FiraSans-Regular"
    }
}

// MARK: - BrandAccount Attribute Finder

/// Busca dinámicamente un atributo dentro de un BrandAccount usando KVC.
/// Itera todos los elementos (1..13) y posiciones (1..16) hasta encontrar
/// `atributoXY == targetAttr`, y retorna el `valorXY` correspondiente.
func findProfileValueForAttribute(_ targetAttr: String, in brand: BrandAccount) -> String? {
    for elementIdx in 1...13 {
        for attrIdx in 1...16 {
            let attrKeys = ["atributo\(elementIdx)\(attrIdx)C",
                            "Atributo_\(elementIdx)_\(attrIdx)__c"]
            for atrKey in attrKeys {
                guard brand.objectSchema[atrKey] != nil,
                      let atrValue = (brand as NSObject).value(forKey: atrKey) as? String,
                      atrValue == targetAttr else { continue }

                let valorKeys = ["valor\(elementIdx)\(attrIdx)C",
                                 "Valor_\(elementIdx)_\(attrIdx)__c"]
                for valorKey in valorKeys {
                    if brand.objectSchema[valorKey] != nil,
                       let valor = (brand as NSObject).value(forKey: valorKey) as? String {
                        return valor
                    }
                }
            }
        }
    }
    return nil
}

// MARK: - Profile UIState Loader

extension ProfileView {

    /// Carga toda la configuración dinámica del perfil desde el record "Perfil" del BrandAccount.
    func loadProfileUIState() -> ProfileUIState {
        var state = ProfileUIState()
        guard let brandRecords = items.first?.records else {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [Perfil] No se encontraron BrandAccount records")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return state
        }

        for brand in brandRecords where brand.Name == "Perfil" {
            // ── 1. Labels + Visibilidad ──
            if let labelsValue = findProfileValueForAttribute(
                "LabelsNombreSeccionesPerfil(EM;DP;GF;CC;AY)", in: brand
            ) {
                let parts = labelsValue.components(separatedBy: ";")
                func isHidden(_ s: String) -> Bool {
                    s.trimmingCharacters(in: .whitespaces).lowercased() == "no"
                }
                if parts.count >= 1 {
                    state.empresas.isVisible = !isHidden(parts[0])
                    if !isHidden(parts[0]) { state.empresas.label = parts[0].trimmingCharacters(in: .whitespaces) }
                }
                if parts.count >= 2 {
                    state.datosPersonales.isVisible = !isHidden(parts[1])
                    if !isHidden(parts[1]) { state.datosPersonales.label = parts[1].trimmingCharacters(in: .whitespaces) }
                }
                if parts.count >= 3 {
                    state.grupoFamiliar.isVisible = !isHidden(parts[2])
                    if !isHidden(parts[2]) { state.grupoFamiliar.label = parts[2].trimmingCharacters(in: .whitespaces) }
                }
                if parts.count >= 4 {
                    state.cambiarContrasena.isVisible = !isHidden(parts[3])
                    if !isHidden(parts[3]) { state.cambiarContrasena.label = parts[3].trimmingCharacters(in: .whitespaces) }
                }
                if parts.count >= 5 {
                    state.ayuda.isVisible = !isHidden(parts[4])
                    if !isHidden(parts[4]) { state.ayuda.label = parts[4].trimmingCharacters(in: .whitespaces) }
                }

                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [Perfil] LabelsNombreSeccionesPerfil")
                print("   raw value: \"\(labelsValue)\"")
                print("   → Empresas: \(state.empresas.isVisible ? "✅ \"\(state.empresas.label)\"" : "❌ oculto")")
                print("   → Datos Personales: \(state.datosPersonales.isVisible ? "✅ \"\(state.datosPersonales.label)\"" : "❌ oculto")")
                print("   → Grupo Familiar: \(state.grupoFamiliar.isVisible ? "✅ \"\(state.grupoFamiliar.label)\"" : "❌ oculto")")
                print("   → Cambiar Contraseña: \(state.cambiarContrasena.isVisible ? "✅ \"\(state.cambiarContrasena.label)\"" : "❌ oculto")")
                print("   → Ayuda: \(state.ayuda.isVisible ? "✅ \"\(state.ayuda.label)\"" : "❌ oculto")")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            } else {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [Perfil] LabelsNombreSeccionesPerfil no definido → todo visible con defaults")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }

            // ── 2. Atributos de estilo ──
            if let styleValue = findProfileValueForAttribute(
                "AtributosNombreSeccionesPerfil(TipoFuente;Size;ColorTexto;Posicion)", in: brand
            ) {
                let parts = styleValue.components(separatedBy: ";")
                if parts.count >= 1 { state.menuStyle.font = parseFontName(parts[0]) }
                if parts.count >= 2 { state.menuStyle.size = parts[1].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 3 { state.menuStyle.color = parts[2].trimmingCharacters(in: .whitespaces) }
                if parts.count >= 4 { state.menuStyle.alignment = parts[3].trimmingCharacters(in: .whitespaces) }

                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [Perfil] AtributosNombreSeccionesPerfil")
                print("   raw value: \"\(styleValue)\"")
                print("   → font: \"\(state.menuStyle.font)\"")
                print("   → size: \"\(state.menuStyle.size)\"")
                print("   → color: \"\(state.menuStyle.color)\"")
                print("   → alignment: \"\(state.menuStyle.alignment)\"")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }

            // ── 3. Iconos por sección ──
            let iconMapping: [(attr: String, keyPath: WritableKeyPath<ProfileUIState, ProfileMenuItemConfig>)] = [
                ("IconoEmpresas", \.empresas),
                ("IconoDatosPersonales", \.datosPersonales),
                ("IconoGrupoFamiliar", \.grupoFamiliar),
                ("IconoCambiarContrasena", \.cambiarContrasena),
                ("IconoAyuda", \.ayuda)
            ]

            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [Perfil] Iconos dinámicos")
            for mapping in iconMapping {
                if let iconUrl = findProfileValueForAttribute(mapping.attr, in: brand) {
                    state[keyPath: mapping.keyPath].iconUrl = iconUrl
                    print("   → \(mapping.attr): \"\(iconUrl)\"")
                } else {
                    print("   → \(mapping.attr): (no definido, usará SF Symbol)")
                }
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

            // ── 4. WhatsApp ──
            if let whatsapp = findProfileValueForAttribute("NumeroWhatsApp", in: brand) {
                state.whatsappNumber = whatsapp
            } else if let whatsapp = brand.valor85C {
                state.whatsappNumber = whatsapp
            }

            break
        }

        return state
    }
}
