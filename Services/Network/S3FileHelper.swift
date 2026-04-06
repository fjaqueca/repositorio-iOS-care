//
//  S3FileHelper.swift
//  CareAssistance
//
//  Created by CareAssistance on 30/03/2026.
//

import Foundation

/// Helper para manejo de archivos S3: extracción de keys, caché local, y descarga via URL pre-firmada.
/// Lógica equivalente a Android (ExamenPreview).
struct S3FileHelper {

    // MARK: - Extract object_key from S3 URL

    /// Extrae el object_key de una URL S3 completa.
    /// Input:  "https://carepositoriodocumentos.s3.amazonaws.com/examenes_automatizados/file.pdf"
    /// Output: "examenes_automatizados/file.pdf"
    static func extractObjectKeyFromUrl(_ urlString: String) -> String {
        print("📦 [S3Helper] extractObjectKeyFromUrl -> input (\(urlString.count) chars): \(urlString)")

        // Si ya es un path relativo (no empieza con http), retornar tal cual
        if !urlString.lowercased().hasPrefix("http") {
            print("📦 [S3Helper] extractObjectKeyFromUrl -> ya es path relativo: \(urlString)")
            return urlString
        }

        // Quitar el dominio S3 para obtener solo el path
        guard let url = URL(string: urlString) else {
            print("📦 [S3Helper] extractObjectKeyFromUrl -> URL inválida, retornando string original")
            return urlString
        }

        // url.path retorna "/examenes_automatizados/file.pdf", quitamos el "/" inicial
        var path = url.path
        if path.hasPrefix("/") {
            path = String(path.dropFirst())
        }

        print("📦 [S3Helper] extractObjectKeyFromUrl -> objectKey extraido: \(path)")
        return path
    }

    // MARK: - Extract fileName from URL

    /// Extrae el nombre del archivo de una URL.
    /// Input:  "https://bucket.s3.amazonaws.com/examenes_auto/file_123.pdf"
    /// Output: "file_123.pdf"
    static func extractFileNameFromUrl(_ urlString: String) -> String {
        let fileName = urlString.components(separatedBy: "/").last ?? "archivo.pdf"
        print("📦 [S3Helper] extractFileNameFromUrl -> fileName: \(fileName)")
        return fileName
    }

    // MARK: - Local Cache

    /// Directorio de documentos de la app para caché de archivos.
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }

    /// Verifica si un archivo existe en el caché local (Documents).
    /// Retorna la URL local si existe, nil si no.
    static func getCachedFileUrl(fileName: String) -> URL? {
        let safeFileName = sanitizeFileName(fileName)
        let fileURL = documentsDirectory.appendingPathComponent(safeFileName)
        let exists = FileManager.default.fileExists(atPath: fileURL.path)
        print("📦 [S3Helper] isFileInCache -> path: \(fileURL.path), exists: \(exists)")
        return exists ? fileURL : nil
    }

    // MARK: - Downloads directory (visible en app Archivos > En mi iPhone > CareAssistance > Descargas)

    /// Carpeta "Descargas" dentro de Documents, visible en la app Archivos del iPhone.
    static var downloadsDirectory: URL {
        let dir = documentsDirectory.appendingPathComponent("Descargas")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            print("📦 [S3Helper] Carpeta 'Descargas' creada en: \(dir.path)")
        }
        return dir
    }

    // MARK: - Download & Save

    /// Descarga un archivo desde una URL pre-firmada, lo guarda en cache (Documents)
    /// y ademas lo copia a la carpeta "Descargas" visible en la app Archivos del iPhone.
    /// Siempre re-descarga del servidor independientemente de si ya existe en Descargas.
    /// Retorna la URL local del archivo guardado en cache.
    static func downloadAndSave(from presignedUrl: String, fileName: String) async throws -> URL {
        guard let remoteURL = URL(string: presignedUrl) else {
            throw NSError(domain: "S3FileHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL pre-firmada inválida"])
        }

        print("📦 [S3Helper] downloadAndSave -> descargando desde URL pre-firmada...")

        let (data, response) = try await URLSession.shared.data(from: remoteURL)

        if let httpResponse = response as? HTTPURLResponse {
            print("📦 [S3Helper] downloadAndSave -> HTTP status: \(httpResponse.statusCode), bytes: \(data.count)")
        }

        // Guardar en cache interno (Documents)
        let safeFileName = sanitizeFileName(fileName)
        let fileURL = documentsDirectory.appendingPathComponent(safeFileName)
        try data.write(to: fileURL, options: .atomic)
        print("📦 [S3Helper] downloadAndSave -> archivo guardado en cache: \(fileURL.path)")

        // Guardar copia en carpeta Descargas (visible en app Archivos)
        let downloadsFileURL = downloadsDirectory.appendingPathComponent(safeFileName)
        try data.write(to: downloadsFileURL, options: .atomic)
        print("📦 [S3Helper] downloadAndSave -> archivo guardado en Descargas: \(downloadsFileURL.path)")

        return fileURL
    }

    // MARK: - Helpers

    /// Limpia el nombre de archivo para uso seguro en el filesystem.
    static func sanitizeFileName(_ fileName: String) -> String {
        fileName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }

    /// Detecta el MIME type basado en la extensión del archivo.
    static func getMimeType(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "application/pdf"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        default: return "application/octet-stream"
        }
    }
}
