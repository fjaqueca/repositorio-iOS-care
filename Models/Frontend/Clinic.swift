//
//  Clinic.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/10/2022.
//

import Foundation
import RealmSwift

class Clinic: Object, ObjectKeyIdentifiable, Decodable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var brandId: String
    @Persisted var brandIcon: String?
    @Persisted var isActive: Bool
}



class ClinicR1: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true)var totalSize: Int?
    @Persisted var done: Bool?
    @Persisted var records = List<RecordClinic>()
    
}
class RecordClinic: Object, ObjectKeyIdentifiable, Codable  {
    @Persisted(primaryKey: true) var Id: String?
    @Persisted var attributes: AttributeRealm?
    @Persisted var convenioR: ConvenioR?
    @Persisted var clinica1R: Clinica1R?
    @Persisted var clinica2R: Clinica2R?
    @Persisted var clinica3R: Clinica3R?
    @Persisted var clinica4R: Clinica4R?
    @Persisted var clinica5R: Clinica5R?
    @Persisted var clinica6R: Clinica6R?
    @Persisted var clinica7R: Clinica7R?
    @Persisted var clinica8R: Clinica8R?
    @Persisted var clinica9R: Clinica9R?
    @Persisted var clinica10R: Clinica10R?
    @Persisted var clinica11R: Clinica11R?
    @Persisted var clinica12R: Clinica12R?
    @Persisted var clinica13R: Clinica13R?
    @Persisted var clinica14R: Clinica14R?
    @Persisted var clinica15R: Clinica15R?
    @Persisted var Name: String?
    @Persisted var paisC: String?
    @Persisted var seccionFrontC: String?
    @Persisted var convenioC: String?
    
}
class ConvenioR: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var whatsappC: String?
    @Persisted var telefonoC: String?
}
class WorkTypeGroupR: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var Name: String?
    @Persisted var Id: String?
}
//MARK: - Clinicas
class Clinica1R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica2R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica3R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica4R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica5R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica6R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica7R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica8R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica9R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica10R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica11R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica12R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica13R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica14R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}
class Clinica15R: Object, Codable {
    @Persisted var attributes: AttributeRealm?
    @Persisted var workTypeGroupR: WorkTypeGroupR?
    @Persisted var twilioFlexIdC: String?
    @Persisted var mensajeInicialWebchatC: String?
}



class ClinicInit: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var iconURL: String
    @Persisted var attribute: String // Aquí guardamos el atributo original (opcional)
    
    convenience init(id: String, name: String, iconURL: String, attribute: String) {
        self.init()
        self.id = id
        self.name = name
        self.iconURL = iconURL
        self.attribute = attribute
    }
}


class ClinicManager {
    private let realm: Realm? = try? Realm()
    
    func generateClinics(from brand: BrandAccounts) {
        for records in brand.records {
            guard records.Name == "ClinicasIni" else { continue }
            
            var clinics: [ClinicInit] = []
            
            // Obtenemos los nombres de propiedades del schema (sin "_" ni backing vars)
            let schemaPropNames = records.objectSchema.properties.map { $0.name }
            
            for prop in records.objectSchema.properties {
                let propName = prop.name // ej "valor11C" o "Valor_1_10__c"
                // Detectamos campos que empiecen por "valor" (insensible a mayúsculas)
                guard propName.lowercased().hasPrefix("valor") else {
                    // opcional debug:
                    // print("⏭ no es campo valor: \(propName)")
                    continue
                }
                
                // Safely get the value (la propiedad existe en el schema porque venimos del schema)
                guard let rawValor = records.value(forKey: propName) as? String,
                      !rawValor.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                    //print("⏭ valor vacío o no-string para \(propName)")
                    continue
                }
                let valor = rawValor.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                //print("✅ valor real para \(propName): \(valor)")
                
                // Construimos candidatos para la propiedad atributo, preservando mayúscula inicial si corresponde
                // "valor11C" -> rest = "11C"  => "atributo11C" y "Atributo11C"
                // "Valor_1_10__c" -> rest = "_1_10__c" => "atributo_1_10__c" y "Atributo_1_10__c"
                let restIndex = propName.index(propName.startIndex, offsetBy: 5) // after "valor"
                let rest = propName[restIndex...] // Substring
                var candidates: [String] = []
                candidates.append("atributo" + rest)
                candidates.append("Atributo" + rest)
                
                // También añadimos la variante generada por reemplazo case-insensitive (por si hay formas raras)
                let replacedLower = propName.replacingOccurrences(of: "valor", with: "atributo", options: .caseInsensitive, range: nil)
                let replacedCap = replacedLower.replacingOccurrences(of: "atributo", with: "Atributo")
                if !candidates.contains(String(replacedLower)) { candidates.append(String(replacedLower)) }
                if !candidates.contains(String(replacedCap)) { candidates.append(String(replacedCap)) }
                
                // Intentamos obtener atributo probando candidatos (pero solo si existen en el schema)
                var atributoValue: String? = nil
                for cand in candidates {
                    if schemaPropNames.contains(cand) {
                        if let rawA = records.value(forKey: cand) as? String,
                           !rawA.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                            atributoValue = rawA
                            //print("✅ atributo encontrado con key \(cand): \(rawA)")
                            break
                        } else {
                            print("⚠ propiedad \(cand) existe pero está vacía o no es String")
                        }
                    } else {
                        // opcional debug:
                        // print("⚪ schema no contiene \(cand)")
                    }
                }
                
                // Fallback tolerante: buscar cualquier property que contenga "atributo" y tenga los mismos dígitos
                if atributoValue == nil {
                    // extraemos dígitos del propName para intentar hacer match (p.ej. "11" o "110")
                    let digitsInValor = propName.filter { $0.isNumber }
                    for possible in schemaPropNames where possible.lowercased().contains("atributo") {
                        // comparo si los dígitos coinciden (ayuda con nombres como atributo21C / atributo_1_10__c)
                        let digitsInPossible = possible.filter { $0.isNumber }
                        if digitsInPossible == digitsInValor {
                            if let rawA = records.value(forKey: possible) as? String,
                               !rawA.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                                atributoValue = rawA
                                print("🔎 atributo encontrado por fallback \(possible): \(rawA)")
                                break
                            }
                        }
                    }
                }
                
                guard let atributo = atributoValue?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                      !atributo.isEmpty else {
                    print("⏭ No se encontró atributo válido para \(propName) (candidatos: \(candidates))")
                    continue
                }
                
                let infoArray = atributo.components(separatedBy: ";")
                guard infoArray.count >= 2 else {
                    print("⏭ Atributo mal formado (sin ';') para \(propName): \(atributo)")
                    continue
                }
                
                guard let clinicName = infoArray.first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                      let clinicId = infoArray.last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                    continue
                }
                
                // Aplicar filtros adicionales (WTW, beneficYapp) aquí si corresponde
                
                let clinic = ClinicInit(id: clinicId, name: clinicName, iconURL: valor, attribute: atributo)
                clinics.append(clinic)
                //print("🏥 Agregada clinic -> \(clinicName) id:\(clinicId)")
            }
            
            // Guardamos en Realm (reemplazo simple)
            guard let realm = realm else {
                print("❌ [Realm] Error en ClinicManager.generateClinics: Realm no disponible")
                return
            }
            do {
                try realm.write {
                    let oldClinics = realm.objects(ClinicInit.self)
                    realm.delete(oldClinics)
                    realm.add(clinics)
                }
            } catch {
                print("❌ [Realm] Error en ClinicManager.generateClinics: \(error.localizedDescription)")
            }
            print("Clinics guardadas para records.Name=\(records.Name ?? "nil"): \(clinics.count)")
            
        }
    }
    
    // Helper para sacar String de Mirror child.value que puede ser Optional
    private func stringValue(from any: Any) -> String? {
        let m = Mirror(reflecting: any)
        if m.displayStyle == .optional {
            // optional -> su primer child es el valor envuelto (si existe)
            if let first = m.children.first?.value {
                return first as? String ?? String(describing: first)
            } else {
                return nil
            }
        } else {
            return any as? String
        }
    }
    
    // Busca exactamente la propiedad con la key solicitada en el `records`
    private func getAtributoValue(from records: BrandAccount /* reemplaza por el tipo real si hace falta */, key: String) -> String? {
        let mirror = Mirror(reflecting: records)
        for child in mirror.children {
            if child.label == key {
                return stringValue(from: child.value)
            }
        }
        return nil
    }
}
