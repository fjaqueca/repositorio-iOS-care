//
//  HapticManager.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Manager centralizado de feedback háptico.
//  100% nativo, no requiere librería externa.
//
//  Uso:
//    HapticManager.impact(.medium)       // tap en botón importante
//    HapticManager.success()             // acción completada (cita agendada, examen enviado)
//    HapticManager.error()               // algo salió mal
//    HapticManager.warning()             // acción destructiva o confirmación
//    HapticManager.selection()           // cambio de selección (picker, toggle, tab)
//

import UIKit

enum HapticManager {

    // MARK: - Impact (toques con peso)

    /// Feedback de impacto para interacciones con botones y elementos.
    /// - `.light`: toques sutiles (toggles, chips)
    /// - `.medium`: toques normales (botones principales)
    /// - `.heavy`: toques fuertes (confirmar acción importante)
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification (resultados)

    /// Feedback de éxito — cita agendada, tarea completada, examen enviado.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Feedback de error — fallo de red, validación incorrecta.
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    /// Feedback de advertencia — antes de eliminar, acción destructiva.
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    // MARK: - Selection (cambios de estado)

    /// Feedback de selección — cambiar tab, elegir opción en picker, toggle.
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
