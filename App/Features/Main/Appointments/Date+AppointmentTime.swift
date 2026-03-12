//
//  Date+AppointmentTime.swift
//  CareAssistance
//
//  Created by Assistant on 12/03/2026.
//

import Foundation

extension Date {
    /// Parsea schedStartTime desde Salesforce y devuelve Date corregido para comparación UTC
    /// Ejemplo: "2026-03-12T13:13:00.000-0300" → Date en UTC real (16:13 UTC = 13:13 Chile)
    ///
    /// PROBLEMA SALESFORCE:
    /// - Salesforce guarda "13:13 Chile" como "13:13 UTC" en el timestamp (INCORRECTO)
    /// - El string trae el offset correcto ("-0300"), pero los dígitos de hora están mal interpretados
    ///
    /// LÓGICA ANDROID (CitaDetalleActivity.kt):
    /// - calendar.timeInMillis - offsetMs
    /// - 13:13 UTC (mal) - (-10800000 ms) = 16:13 UTC = 13:13 Chile ✓
    static func fromSchedStartTime(_ schedStartTime: String) -> Date? {
        // PASO 1: Parsear IGNORANDO el timezone (tratarlo como UTC puro)
        // Removemos el offset del string temporalmente
        guard let timezonelessString = removeTimezone(from: schedStartTime) else {
            print("⚠️ [Date+AppointmentTime] No se pudo procesar schedStartTime: \(schedStartTime)")
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Forzar UTC
        
        guard let baseDate = formatter.date(from: timezonelessString) else {
            print("⚠️ [Date+AppointmentTime] No se pudo parsear: \(timezonelessString)")
            return nil
        }
        
        // PASO 2: Extraer el offset del string ORIGINAL
        guard let offsetSeconds = extractTimezoneOffsetInSeconds(from: schedStartTime) else {
            print("⚠️ [Date+AppointmentTime] No se pudo extraer offset de: \(schedStartTime)")
            return baseDate
        }
        
        // PASO 3: Aplicar corrección ANDROID
        // calendar.timeInMillis - offsetMs
        // baseDate (13:13 UTC) - (-10800s) = 16:13 UTC = 13:13 Chile ✓
        let correctedDate = baseDate.addingTimeInterval(-offsetSeconds)
        
        print("📅 [Date+AppointmentTime] Corrección de timezone:")
        print("   • schedStartTime original: \(schedStartTime)")
        print("   • Sin timezone (UTC puro): \(timezonelessString)")
        print("   • Base date parseado: \(baseDate)")
        print("   • Offset extraído: \(offsetSeconds)s (\(offsetSeconds/3600)h)")
        print("   • Corrected date (UTC real): \(correctedDate)")
        print("   • Fórmula: \(baseDate) - (\(offsetSeconds)s) = \(correctedDate)")
        
        return correctedDate
    }
    
    /// Remueve el timezone del string ISO8601 para parsearlo como UTC puro
    /// "2026-03-12T13:13:00.000-0300" → "2026-03-12T13:13:00.000Z"
    private static func removeTimezone(from isoString: String) -> String? {
        guard isoString.count >= 28 else {
            return nil
        }
        
        // Tomar todo excepto los últimos 5 caracteres (el offset)
        let withoutOffset = String(isoString.dropLast(5))
        
        // Agregar "Z" para indicar UTC
        return withoutOffset + "Z"
    }
    
    /// Extrae el offset de zona horaria en segundos desde el string ISO8601
    /// Ejemplo: "2026-03-12T13:13:00.000-0300" → -10800 segundos (−3 horas)
    /// Ejemplo: "2026-03-12T15:50:00.000+0530" → +19800 segundos (+5.5 horas)
    ///
    /// LÓGICA ANDROID (getSchedOffsetMs):
    /// val offsetStr = s.substring(23, 28)  // "-0300"
    /// return sign * (hours * 60L + minutes) * 60L * 1000L
    private static func extractTimezoneOffsetInSeconds(from isoString: String) -> TimeInterval? {
        // Verificar longitud mínima (debe tener al menos 28 caracteres)
        guard isoString.count >= 28 else {
            print("⚠️ String muy corto: \(isoString)")
            return nil
        }
        
        // Extraer últimos 5 caracteres: "-0300" o "+0530"
        let offsetString = String(isoString.suffix(5))
        
        // Verificar formato válido
        guard offsetString.count == 5,
              (offsetString.hasPrefix("-") || offsetString.hasPrefix("+")),
              let hoursString = offsetString.dropFirst().prefix(2) as? Substring,
              let minutesString = offsetString.dropFirst(3) as? Substring else {
            print("⚠️ Formato de offset inválido: \(offsetString)")
            return nil
        }
        
        // Parsear horas y minutos
        guard let hours = Int(hoursString),
              let minutes = Int(minutesString) else {
            print("⚠️ No se pudieron parsear horas/minutos de: \(offsetString)")
            return nil
        }
        
        // Calcular signo (- o +)
        let sign: TimeInterval = offsetString.hasPrefix("-") ? -1.0 : 1.0
        
        // LÓGICA ANDROID: sign * (hours * 60L + minutes) * 60L * 1000L (en millis)
        // En Swift: sign * (hours * 3600 + minutes * 60) (en segundos)
        let offsetSeconds = sign * TimeInterval(hours * 3600 + minutes * 60)
        
        return offsetSeconds
    }
}
