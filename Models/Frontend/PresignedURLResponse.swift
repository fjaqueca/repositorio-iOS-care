//
//  PresignedURLResponse.swift
//  CareAssistance
//
//  Created by CareAssistance on 30/03/2026.
//

import Foundation

struct PresignedURLResponse: Codable {
    let url: String?
    let error: Bool
    let message: String?

    enum CodingKeys: String, CodingKey {
        case url
        case error
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        error = (try? container.decode(Bool.self, forKey: .error)) ?? false
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}
