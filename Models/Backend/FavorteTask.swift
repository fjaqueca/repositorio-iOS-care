//
//  FavorteTask.swift
//  CareAssistance
//
//  Created by The App Master on 15/01/2024.
//

import RealmSwift
import Foundation

class FavoriteTasksTotal: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true)var totalSize: Int?
    @Persisted var done: Bool?
    @Persisted var records = List<FavoriteTaskTotalRecords>()
    
}
class FavoriteTaskTotalRecords: Object, ObjectKeyIdentifiable, Codable  {
    @Persisted var attributes: AttributeRealm?
    @Persisted var Id: String?
    @Persisted var goalsR: FavoriteTasks?
}
class FavoriteTasks: Object, ObjectKeyIdentifiable, Codable  {
    @Persisted var totalSize: Int?
    @Persisted var done: Bool?
    @Persisted var records = List<FavoriteTaskRecords>()
}
class FavoriteTaskRecords: Object, ObjectKeyIdentifiable, Codable  {
    @Persisted var attributes: AttributeRealm?
    @Persisted var Id: String?
    @Persisted var etapaC: String?
    @Persisted var nombrePersonalizadoC: String?
    @Persisted var cumplimientoDeLaTareaC: Float?
    @Persisted var cantDeElementosPorTareaC: Float?
    @Persisted var responsableDeLaTareaC: String?
}
