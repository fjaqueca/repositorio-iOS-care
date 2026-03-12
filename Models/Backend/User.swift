//
//  User.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import UIKit
import RealmSwift


class User: Object,Identifiable, Codable {
    @Persisted(primaryKey: true) var totalSize: Int?
    @Persisted var done: Bool?
    @Persisted var records = List<UserR>()
}

class UserR: Object, Identifiable, Codable {
    @Persisted(primaryKey: true) var Id: String
    @Persisted var FirstName: String?
    @Persisted var LastName: String?
    @Persisted var PersonEmail: String?
    @Persisted var Phone: String?
    @Persisted var BillingAddress: BillingAddress?
    @Persisted var BillingCity: String?
    @Persisted var BillingCountry: String?
    @Persisted var BillingState: String?
    @Persisted var empresacontactoconveniosR: CompanyAgreement?
    @Persisted var RUT: String?
    @Persisted var PersonContactId: String?

    var id: String {
        Id
    }
}
class CompanyAgreement: Object, Codable {
    @Persisted var totalSize: Int?
    @Persisted var done: Bool?
    @Persisted var records = List<CompanyAgreementR>()
}
class BillingAddress: Object, Codable {
    @Persisted var city: String?
    @Persisted var country: String?
    @Persisted var geocodeAccuracy: String?
    @Persisted var latitude: String?
    @Persisted var longitude: String?
    @Persisted var postalCode: String?
    @Persisted var state: String?
    @Persisted var street: String?
}
class CompanyAgreementR: Object, Codable {
    @Persisted var empresaC: String?
    @Persisted var datosMostrarC: String?
    @Persisted var empresaR: Company?
    @Persisted var disenoDeIconoC: String?
    @Persisted var identificadorC: String?
    @Persisted var campaAC: String?
    @Persisted var Id: String?
    @Persisted var consentimientoInformadoC: Bool?
    @Persisted var appMobileC: Bool?
    @Persisted var relaciNConAseguradoC: String?
    @Persisted var grupoFamiliarC: Bool?
    @Persisted var nombreFlujoC: String? 
    
}
class Company: Object, Codable {
    @Persisted var nombreDeEmpresaC: String?
}
