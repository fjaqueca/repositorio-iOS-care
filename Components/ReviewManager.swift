//
//  ReviewManager.swift
//  CareAssistance
//
//  Created on 11/05/2026.
//
//  Gestiona el prompt de calificación en el App Store.
//  Usa SKStoreReviewController (dialog oficial de Apple) — el review
//  queda registrado directamente en la Store.
//
//  100% dinámico: usa el bundleId del target actual para resolver
//  el App Store ID via iTunes Lookup API. Funciona para todos los
//  targets (CareAssistance, Wellbeing, BCI, etc.) sin hardcodear nada.
//
//  Uso en hitos de éxito:
//    ReviewManager.shared.requestReviewIfNeeded()
//
//  Uso desde Perfil (link directo al App Store):
//    ReviewManager.shared.openAppStoreForReview()
//

import StoreKit
import UIKit

final class ReviewManager {
    static let shared = ReviewManager()

    // MARK: - Keys
    private let hasReviewedKey = "hasCompletedAppReview"
    private let lastRequestDateKey = "lastReviewRequestDate"
    private let cachedAppStoreIdKey = "cachedAppStoreId"

    private init() {}

    // MARK: - Public API

    /// Indica si ya se solicitó review (asumimos que calificó o declinó)
    var hasReviewed: Bool {
        UserDefaults.standard.bool(forKey: hasReviewedKey)
    }

    /// Solicita review después de un hito de éxito.
    /// Solo muestra si: no ha calificado + no se pidió recientemente.
    /// Incluye delay de 2.5s para que el usuario vea el confetti/éxito primero.
    func requestReviewIfNeeded() {
        guard !hasReviewed else {
            print("⭐ [ReviewManager] Ya calificó — no se muestra prompt")
            return
        }
        guard !wasRequestedRecently() else {
            print("⭐ [ReviewManager] Solicitado recientemente — no se muestra prompt")
            return
        }

        print("⭐ [ReviewManager] Programando prompt de review en 2.5s...")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                print("⭐ [ReviewManager] Mostrando dialog oficial de Apple")
                SKStoreReviewController.requestReview(in: scene)
                self.markAsRequested()
            }
        }
    }

    /// Abre la página del App Store para escribir un review.
    /// Resuelve el App Store ID dinámicamente usando el bundleId del target.
    /// Funciona para todos los targets sin hardcodear IDs.
    func openAppStoreForReview() {
        // Si tenemos el ID cacheado, abrir directo
        if let cachedId = UserDefaults.standard.string(forKey: cachedAppStoreIdKey), !cachedId.isEmpty {
            openStoreReviewPage(appId: cachedId)
            return
        }

        // Si no, resolver via iTunes Lookup API
        guard let bundleId = Bundle.main.bundleIdentifier else {
            print("⭐ [ReviewManager] No se pudo obtener bundleIdentifier")
            return
        }

        print("⭐ [ReviewManager] Buscando App Store ID para bundleId: \(bundleId)")

        guard let lookupUrl = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else { return }

        URLSession.shared.dataTask(with: lookupUrl) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                print("⭐ [ReviewManager] Error en iTunes Lookup: \(error?.localizedDescription ?? "unknown")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let first = results.first,
                   let trackId = first["trackId"] as? Int {
                    let appId = String(trackId)
                    print("⭐ [ReviewManager] App Store ID encontrado: \(appId)")

                    // Cachear para futuras llamadas
                    UserDefaults.standard.set(appId, forKey: self.cachedAppStoreIdKey)

                    DispatchQueue.main.async {
                        self.openStoreReviewPage(appId: appId)
                    }
                } else {
                    print("⭐ [ReviewManager] App no encontrada en iTunes Lookup — puede no estar publicada aún")
                }
            } catch {
                print("⭐ [ReviewManager] Error parseando iTunes Lookup: \(error)")
            }
        }.resume()
    }

    // MARK: - Private

    private func openStoreReviewPage(appId: String) {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review") else { return }
        print("⭐ [ReviewManager] Abriendo App Store para review (appId: \(appId))")
        UIApplication.shared.open(url)
    }

    private func markAsRequested() {
        UserDefaults.standard.set(Date(), forKey: lastRequestDateKey)
        UserDefaults.standard.set(true, forKey: hasReviewedKey)
        print("⭐ [ReviewManager] Marcado como revisado — no se volverá a pedir")
    }

    private func wasRequestedRecently() -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: lastRequestDateKey) as? Date else {
            return false
        }
        let daysSinceLastRequest = Date().timeIntervalSince(lastDate) / (24 * 60 * 60)
        return daysSinceLastRequest < 30
    }
}
