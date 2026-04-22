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

/// Busca un atributo por prefijo y retorna (nombreAtributo, valor).
/// Útil cuando el nombre del atributo cambia dinámicamente (ej: claves entre paréntesis).
func findProfileAttributeByPrefix(_ prefix: String, in brand: BrandAccount) -> (attribute: String, value: String)? {
    for elementIdx in 1...13 {
        for attrIdx in 1...16 {
            let attrKeys = ["atributo\(elementIdx)\(attrIdx)C",
                            "Atributo_\(elementIdx)_\(attrIdx)__c"]
            for atrKey in attrKeys {
                guard brand.objectSchema[atrKey] != nil,
                      let atrValue = (brand as NSObject).value(forKey: atrKey) as? String,
                      atrValue.hasPrefix(prefix) else { continue }

                let valorKeys = ["valor\(elementIdx)\(attrIdx)C",
                                 "Valor_\(elementIdx)_\(attrIdx)__c"]
                for valorKey in valorKeys {
                    if brand.objectSchema[valorKey] != nil,
                       let valor = (brand as NSObject).value(forKey: valorKey) as? String {
                        return (atrValue, valor)
                    }
                }
            }
        }
    }
    return nil
}

/// Extrae las claves entre paréntesis de un nombre de atributo.
/// Ej: "LabelsNombreSeccionesPerfil(DP;GF;CC;II;AY)" → ["DP", "GF", "CC", "II", "AY"]
private func extractKeysFromAttribute(_ attr: String) -> [String] {
    guard let start = attr.firstIndex(of: "("),
          let end = attr.firstIndex(of: ")") else { return [] }
    let keysStr = attr[attr.index(after: start)..<end]
    return keysStr.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
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
            // ── 1. Labels + Visibilidad (dinámico por claves del atributo) ──
            if let result = findProfileAttributeByPrefix("LabelsNombreSeccionesPerfil", in: brand) {
                let keys = extractKeysFromAttribute(result.attribute)
                let values = result.value.components(separatedBy: ";")

                // Mapeo de clave corta → keyPath en el state
                let keyToPath: [(String, WritableKeyPath<ProfileUIState, ProfileMenuItemConfig>)] = [
                    ("EM", \.empresas),
                    ("DP", \.datosPersonales),
                    ("GF", \.grupoFamiliar),
                    ("CC", \.cambiarContrasena),
                    ("II", \.informacionLegal),
                    ("AY", \.ayuda)
                ]

                // Primero ocultar TODAS las secciones
                for (_, kp) in keyToPath {
                    state[keyPath: kp].isVisible = false
                }

                func isHidden(_ s: String) -> Bool {
                    s.trimmingCharacters(in: .whitespaces).lowercased() == "no"
                }

                // Luego habilitar solo las que vienen en las claves
                for (idx, key) in keys.enumerated() {
                    guard let match = keyToPath.first(where: { $0.0 == key }) else { continue }
                    let value = idx < values.count ? values[idx].trimmingCharacters(in: .whitespaces) : ""
                    if !isHidden(value) {
                        state[keyPath: match.1].isVisible = true
                        if !value.isEmpty { state[keyPath: match.1].label = value }
                    }
                }

                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [Perfil] LabelsNombreSeccionesPerfil")
                print("   atributo: \"\(result.attribute)\"")
                print("   claves: \(keys)")
                print("   raw value: \"\(result.value)\"")
                print("   → Empresas: \(state.empresas.isVisible ? "✅ \"\(state.empresas.label)\"" : "❌ oculto")")
                print("   → Datos Personales: \(state.datosPersonales.isVisible ? "✅ \"\(state.datosPersonales.label)\"" : "❌ oculto")")
                print("   → Grupo Familiar: \(state.grupoFamiliar.isVisible ? "✅ \"\(state.grupoFamiliar.label)\"" : "❌ oculto")")
                print("   → Cambiar Contraseña: \(state.cambiarContrasena.isVisible ? "✅ \"\(state.cambiarContrasena.label)\"" : "❌ oculto")")
                print("   → Información Legal: \(state.informacionLegal.isVisible ? "✅ \"\(state.informacionLegal.label)\"" : "❌ oculto")")
                print("   → Ayuda: \(state.ayuda.isVisible ? "✅ \"\(state.ayuda.label)\"" : "❌ oculto")")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            } else {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [Perfil] LabelsNombreSeccionesPerfil no definido → todo visible con defaults")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }

            // ── 2. Atributos de estilo (búsqueda por prefijo) ──
            let styleResult = findProfileAttributeByPrefix("AtributosNombreSeccionesPerfil", in: brand)
            if let styleValue = styleResult?.value {
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

            // ── 3. Iconos por sección (dinámico por prefijo) ──
            // Mapeo de clave corta → (prefijo del atributo de icono, keyPath)
            let iconKeyToPath: [(key: String, prefix: String, keyPath: WritableKeyPath<ProfileUIState, ProfileMenuItemConfig>)] = [
                ("EM", "IconoEmpresas", \.empresas),
                ("DP", "IconoDatosPersonales", \.datosPersonales),
                ("GF", "IconoGrupoFamiliar", \.grupoFamiliar),
                ("CC", "IconoCambiarContrasena", \.cambiarContrasena),
                ("II", "IconoInformacionLegal", \.informacionLegal),
                ("AY", "IconoAyuda", \.ayuda)
            ]

            // También buscar iconos con atributo genérico "IconosSeccionesPerfil(EM;DP;GF;...)"
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [Perfil] Iconos dinámicos")

            if let iconResult = findProfileAttributeByPrefix("IconosSeccionesPerfil", in: brand) {
                // Iconos vienen en formato agrupado: "url1;url2;url3" con claves entre paréntesis
                let iconKeys = extractKeysFromAttribute(iconResult.attribute)
                let iconValues = iconResult.value.components(separatedBy: ";")

                for (idx, key) in iconKeys.enumerated() {
                    guard let match = iconKeyToPath.first(where: { $0.key == key }) else { continue }
                    let url = idx < iconValues.count ? iconValues[idx].trimmingCharacters(in: .whitespaces) : ""
                    if !url.isEmpty {
                        state[keyPath: match.keyPath].iconUrl = url
                        print("   → \(key): \"\(url)\"")
                    } else {
                        print("   → \(key): (vacío, usará SF Symbol)")
                    }
                }
            } else {
                // Fallback: buscar cada icono individualmente por nombre de atributo exacto
                for mapping in iconKeyToPath {
                    if let iconUrl = findProfileValueForAttribute(mapping.prefix, in: brand) {
                        state[keyPath: mapping.keyPath].iconUrl = iconUrl
                        print("   → \(mapping.prefix): \"\(iconUrl)\"")
                    } else {
                        print("   → \(mapping.prefix): (no definido, usará SF Symbol)")
                    }
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
