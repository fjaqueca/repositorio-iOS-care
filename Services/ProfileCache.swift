//
//  ProfileCache.swift
//  CareAssistance
//
//  Created by Care Assistance on 31/03/2026.
//

import Foundation

/// Cache de datos del perfil del paciente usando UserDefaults
/// Equivalente a SharedPreferences en Android
struct ProfileCache {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let firstName = "profile_firstName"
        static let lastName = "profile_lastName"
        static let birthdate = "profile_birthdate"
        static let email = "profile_email"
        static let address = "profile_address"
        static let gender = "profile_gender"
        static let rut = "profile_rut"
    }

    // MARK: - Getters

    static var firstName: String { defaults.string(forKey: Keys.firstName) ?? "" }
    static var lastName: String { defaults.string(forKey: Keys.lastName) ?? "" }
    static var birthdate: String { defaults.string(forKey: Keys.birthdate) ?? "" }
    static var email: String { defaults.string(forKey: Keys.email) ?? "" }
    static var address: String { defaults.string(forKey: Keys.address) ?? "" }
    static var gender: String { defaults.string(forKey: Keys.gender) ?? "" }
    static var rut: String { defaults.string(forKey: Keys.rut) ?? "" }

    // MARK: - Save

    static func save(
        firstName: String,
        lastName: String,
        birthdate: String,
        email: String,
        address: String,
        gender: String,
        rut: String
    ) {
        defaults.set(firstName, forKey: Keys.firstName)
        defaults.set(lastName, forKey: Keys.lastName)
        defaults.set(birthdate, forKey: Keys.birthdate)
        defaults.set(email, forKey: Keys.email)
        defaults.set(address, forKey: Keys.address)
        defaults.set(gender, forKey: Keys.gender)
        defaults.set(rut, forKey: Keys.rut)

        print("💾 [ProfileCache] Datos guardados en cache:")
        print("   firstName: \"\(firstName)\"")
        print("   lastName: \"\(lastName)\"")
        print("   birthdate: \"\(birthdate)\"")
        print("   email: \"\(email)\"")
        print("   address: \"\(address)\"")
        print("   gender: \"\(gender)\"")
        print("   rut: \"\(rut)\"")
    }

    // MARK: - Clear

    static func clear() {
        [Keys.firstName, Keys.lastName, Keys.birthdate,
         Keys.email, Keys.address, Keys.gender, Keys.rut].forEach {
            defaults.removeObject(forKey: $0)
        }
        print("🗑️ [ProfileCache] Cache limpiado")
    }
}
