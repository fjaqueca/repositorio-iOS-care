//
//  Network+S3.swift
//  CareAssistance
//
//  Created by Assistant on 16/02/2026.
//

import Foundation
import Alamofire

extension Network {
    /// Sube un archivo a S3
    /// - Parameters:
    ///   - base64: Contenido del archivo en base64 (puede incluir metadatos: "base64|||extension:ext|||filename:name")
    ///   - archivExtension: Extensión por defecto si no se puede extraer del base64
    /// - Returns: Respuesta con las URLs de S3
    func postSendS3(base64: String, archivExtension: String) async -> Result<SendS3Response, AppError> {
        
        // ✅ Extraer información del formato: "base64|||extension:ext|||filename:name"
        var actualBase64 = base64
        var fileExtension = archivExtension
        var fileName = "archivo.\(archivExtension)"
        
        if base64.contains("|||extension:") {
            let components = base64.components(separatedBy: "|||")
            if components.count >= 2 {
                actualBase64 = components[0]
                
                // Extraer extensión
                if let extComponent = components.first(where: { $0.hasPrefix("extension:") }) {
                    fileExtension = extComponent.replacingOccurrences(of: "extension:", with: "")
                }
                
                // Extraer nombre de archivo
                if let nameComponent = components.first(where: { $0.hasPrefix("filename:") }) {
                    fileName = nameComponent.replacingOccurrences(of: "filename:", with: "")
                }
            }
        }
        
        print("📤 [S3] Preparando archivo para subir:")
        print("   • Nombre: \(fileName)")
        print("   • Extensión: \(fileExtension)")
        print("   • Base64: \(actualBase64.count) caracteres")
        
        // ✅ FORMATO CORRECTO: Array de files (igual que Android)
        let fileItem = SendS3FileItem(type: fileExtension, file: actualBase64)
        let requestBody = SendS3Request(files: [fileItem])
        
        // Log del request body (solo metadatos, no el base64 completo)
        print("📦 [S3] Request body:")
        print("   {")
        print("     \"files\": [")
        print("       {")
        print("         \"type\": \"\(fileExtension)\",")
        print("         \"file\": \"<base64 con \(actualBase64.count) caracteres>\"")
        print("       }")
        print("     ]")
        print("   }")
        
        return await request(
            method: .post,
            endpoint: .sendS3,
            parameters: requestBody
        )
    }
}
