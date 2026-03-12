//
//  SendS3Response.swift
//  CareAssistance
//
//  Created by The App Master on 05/10/2023.
//

import Foundation

// ⚠️ IMPORTANTE: Android envía un array "files", NO un objeto plano
// El backend espera: { "files": [{ "type": "ext", "file": "base64" }] }

struct SendS3FileItem: Codable, Hashable {
    let type: String  // extensión del archivo (ej: "pdf", "jpg", "png")
    let file: String  // contenido en base64
}

struct SendS3Request: Codable, Hashable {
    let files: [SendS3FileItem]  // ✅ Array como Android
}

struct SendS3Response: Codable, Hashable {
    let data: [String]  // Array de URLs de S3
}
