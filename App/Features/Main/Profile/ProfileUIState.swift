//
//  ProfileUIState.swift
//  CareAssistance
//

import Foundation

struct ProfileMenuItemConfig {
    var label: String
    var isVisible: Bool
    var iconUrl: String
}

struct ProfileMenuStyle {
    var font: String
    var size: String
    var color: String
    var alignment: String
}

struct ProfileUIState {
    var empresas: ProfileMenuItemConfig = .init(label: "Empresas", isVisible: true, iconUrl: "")
    var datosPersonales: ProfileMenuItemConfig = .init(label: "Datos Personales", isVisible: true, iconUrl: "")
    var grupoFamiliar: ProfileMenuItemConfig = .init(label: "Grupo Familiar", isVisible: true, iconUrl: "")
    var cambiarContrasena: ProfileMenuItemConfig = .init(label: "Cambiar Contraseña", isVisible: true, iconUrl: "")
    var informacionLegal: ProfileMenuItemConfig = .init(label: "Información Legal", isVisible: true, iconUrl: "")
    var ayuda: ProfileMenuItemConfig = .init(label: "Ayuda", isVisible: true, iconUrl: "")
    var menuStyle: ProfileMenuStyle = .init(font: "FiraSans-Regular", size: "15", color: "#333333", alignment: "left")
    var whatsappNumber: String = ""
}
