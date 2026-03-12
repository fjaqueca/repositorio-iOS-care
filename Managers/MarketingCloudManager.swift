/*struct ContactData {
      let personContactId: String
      let rut: String
      let nombre: String
      let apellido: String
      let email: String
      let telefono: String
      let accountId: String
      let empresaId: String?
      let convenioId: String?
  }
 
  class MarketingCloudManager {
 
      static func sendContactToMarketingCloud(contactData: ContactData) {
          // Contact Key = personContactId (igual que Android)
          MarketingCloudSDK.sharedInstance().sfmc_setContactKey(contactData.personContactId)
 
          // Mismos atributos que Android
          MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("RUT",        value: contactData.rut)
          MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("FirstName",  value: contactData.nombre)
          MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("LastName",   value: contactData.apellido)
          MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("EmailAddress", value: contactData.email)
          MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("PhoneNumber", value: contactData.telefono)
          MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("AccountId",  value: contactData.accountId)
          MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("PersonContactId", value: contactData.personContactId)
 
          if let empresaId = contactData.empresaId {
              MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("EmpresaId", value: empresaId)
          }
          if let convenioId = contactData.convenioId {
              MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed("ConvenioId", value: convenioId)
          }
      }
 
      static func clearContact() {
          MarketingCloudSDK.sharedInstance().sfmc_setContactKey("")
      }
  }
 
  Llamarlo al hacer login, igual que Android:
  // Al autenticar al usuario:
  MarketingCloudManager.sendContactToMarketingCloud(contactData: contact)
 
  // Al hacer logout:
  MarketingCloudManager.clearContact()*/

import Foundation
import SFMCSDK

struct MarketingCloudManager {

    // MARK: - Contact Data Model
    struct ContactData {
        let rut: String
        let nombre: String
        let apellido: String
        let email: String
        let telefono: String
        let accountId: String
        let personContactId: String
        let empresaId: String?
        let convenioId: String?
    }

    // MARK: - Send Contact to Salesforce Marketing Cloud
    static func sendContactToMarketingCloud(
        contactData: ContactData,
        onSuccess: @escaping () -> Void,
        onError: @escaping (String) -> Void
    ) {

        // =====================================================
        // 🔍 DEBUG – Objeto recibido desde la app
        // =====================================================
        print("📤 [SFMC] ContactData recibido:")
        print("• rut:", contactData.rut)
        print("• nombre:", contactData.nombre)
        print("• apellido:", contactData.apellido)
        print("• email:", contactData.email)
        print("• telefono:", contactData.telefono)
        print("• accountId:", contactData.accountId)
        print("• personContactId:", contactData.personContactId)
        print("• empresaId:", contactData.empresaId ?? "nil")
        print("• convenioId:", contactData.convenioId ?? "nil")

        // =====================================================
        // 🔑 Contact Key (Profile ID) — equivalente Android
        // =====================================================
        SFMCSdk.identity.setProfileId(contactData.personContactId)

        // =====================================================
        // 🧾 Construcción del payload de atributos
        // =====================================================
        var attributes: [String: String] = [
            "RUT": contactData.rut,
            "FirstName": contactData.nombre,
            "LastName": contactData.apellido,
            "EmailAddress": contactData.email,
            "PhoneNumber": contactData.telefono,
            "AccountId": contactData.accountId,
            "PersonContactId": contactData.personContactId
        ]

        if let empresaId = contactData.empresaId {
            attributes["EmpresaId"] = empresaId
        }

        if let convenioId = contactData.convenioId {
            attributes["ConvenioId"] = convenioId
        }

        // =====================================================
        // 🔍 DEBUG – Payload final enviado a SFMC
        // =====================================================
        print("📦 [SFMC] Payload de atributos:")
        attributes.forEach { key, value in
            print("• \(key): \(value)")
        }

        // (Opcional) JSON bonito para comparar con Android
        if let jsonData = try? JSONSerialization.data(
            withJSONObject: attributes,
            options: .prettyPrinted
        ),
        let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🧾 [SFMC] Payload JSON:\n\(jsonString)")
        }

        // =====================================================
        // 🚀 Envío a Salesforce Marketing Cloud
        // =====================================================
        SFMCSdk.identity.setProfileAttributes(attributes)

        print("✅ [SFMC] Identity actualizada correctamente para RUT: \(contactData.rut)")
        onSuccess()
    }

    // MARK: - Clear Contact (Logout)
    static func clearContact() {
        print("🧹 [SFMC] Clearing contact / profileId")
        SFMCSdk.identity.setProfileId("")
    }
}
