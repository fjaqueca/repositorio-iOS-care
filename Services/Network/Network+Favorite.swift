//
//  Netwwork+Favorite.swift
//  CareAssistance
//
//  Created by The App Master on 20/10/2023.
//

import Foundation

import Alamofire

extension Network {
    func postFavorite(registerId: String, objet: String, data: Bool) async -> Result<Empty, AppError> {
        return await request(
            method: .post,
            endpoint: .postFavorite,
            parameters: [
                        "registro_id": registerId,
                        "SObject": objet,
                        "marcar_favorito": data
                    ])
    }
}
