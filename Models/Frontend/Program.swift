//
//  Program.swift
//  CareAssistance
//
//  Created by The App Master on 19/07/2023.
//

import Foundation
import RealmSwift

class Programs: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true)var totalSize: Int?
    @Persisted var done: Bool?
    @Persisted var records = List<Program>()
    
}
class Program: Object, ObjectKeyIdentifiable, Codable  {
    @Persisted(primaryKey: true) var Id: String
    @Persisted var IsDeleted: Bool?
    @Persisted var healthcloudgaIsactiveC: Bool?
    @Persisted var Name: String?
    @Persisted var nombrePersonalizadoC: String?
    @Persisted var nombreDelResponsableC: String?
    @Persisted var imagenProgramaMobileC: String?
    @Persisted var puntosAcumuladosC: Float?
    @Persisted var puntosAObtenerC: Float?
    @Persisted var informeC: String?
    @Persisted var estadoC: String?
    @Persisted var cumplimientoDelProgramaC: Float?
    @Persisted var puntosactivosC: Bool?
    @Persisted var ocultarListaProgramasC: Bool?
    
}
