//
//  ProfileView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 06/08/2022.
//

import SwiftUI
import RealmSwift
import Alamofire
import Introspect
import WebKit
import SDWebImageSwiftUI

struct ProfileView: View {
    @Binding var isConvenioLoading: Bool
    @ObservedResults(User.self) private var users
    @ObservedResults(BrandAccounts.self) var items
    @State private var showEmailPhone: Bool = false
    @State private var navigation: Item?
    @State private var showButtons = false
    @State private var showTermsAndConditions: Bool = false
    @State private var showPrivacyPolicies: Bool = false
    @State private var selectedEnterprise: CompanyAgreementR? = AppStatusManager.selectedEnterprise
    @State var alert: AlertConfirmation?
    @State private var avatarScale: CGFloat = 0.0
    @State private var avatarOpacity: Double = 0.0
    @State private var showCompanyDialog: Bool = false
    @State private var showLogoutDialog: Bool = false
    @State var profileState = ProfileUIState()

    public struct AlertConfirmation {
        let title: String
        let action: () -> Void
    }

    private var userFirstName: String {
        users.first?.records.first?.FirstName ?? ""
    }

    private var userLastName: String {
        users.first?.records.first?.LastName ?? ""
    }

    private var userEmail: String {
        users.first?.records.first?.PersonEmail ?? ""
    }

    private var userInitials: String {
        let first = userFirstName.prefix(1).uppercased()
        let last = userLastName.prefix(1).uppercased()
        return "\(first)\(last)"
    }

    var body: some View {
        NavigationViewCustom {
            mainContent
        }
        .accentColor(.blue)
    }

    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            scrollContent

            if showCompanyDialog {
                CompanySelectionDialog(isPresented: $showCompanyDialog)
                    .zIndex(50)
                    .transition(.opacity)
            }

            if showLogoutDialog {
                LogoutConfirmationDialog(
                    onConfirm: {
                        showLogoutDialog = false
                        asyncTask(AppStatusManager.logoutUser)
                    },
                    onCancel: {
                        showLogoutDialog = false
                    }
                )
                .zIndex(50)
                .transition(.opacity)
            }
        }
        .onChange(of: showCompanyDialog) { newValue in
            isConvenioLoading = newValue
        }
    }

    @ViewBuilder
    private var scrollContent: some View {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Header con avatar
                    profileHeader
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    Divider()
                        .padding(.horizontal, .margin)

                    // MARK: - Menu items
                    VStack(spacing: 0) {
                        if profileState.empresas.isVisible {
                            menuRowAction(
                                iconUrl: profileState.empresas.iconUrl,
                                fallbackIcon: "building.2",
                                title: profileState.empresas.label,
                                showChevron: true
                            ) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showCompanyDialog = true
                                }
                            }
                        }

                        if profileState.datosPersonales.isVisible {
                            menuRow(
                                iconUrl: profileState.datosPersonales.iconUrl,
                                fallbackIcon: "person.text.rectangle",
                                title: profileState.datosPersonales.label,
                                item: .data
                            )
                        }

                        // Grupo Familiar combina visibilidad dinámica + check de relación titular
                        if profileState.grupoFamiliar.isVisible && showGrupoFamiliarMenu() {
                            menuRow(
                                iconUrl: profileState.grupoFamiliar.iconUrl,
                                fallbackIcon: "person.2",
                                title: profileState.grupoFamiliar.label,
                                item: .family
                            )
                        }

                        if profileState.cambiarContrasena.isVisible {
                            menuRow(
                                iconUrl: profileState.cambiarContrasena.iconUrl,
                                fallbackIcon: "lock",
                                title: profileState.cambiarContrasena.label,
                                item: .password
                            )
                        }

                        // Información Legal (expandible)
                        if profileState.informacionLegal.isVisible {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showButtons.toggle()
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    menuIcon(url: profileState.informacionLegal.iconUrl, fallbackSFSymbol: "doc.text")
                                    Text(profileState.informacionLegal.label)
                                        .font(Font.custom(profileState.menuStyle.font, size: CGFloat(Double(profileState.menuStyle.size) ?? 15)))
                                        .foregroundColor(Color(hex: profileState.menuStyle.color))
                                    Spacer()
                                    Image(systemName: showButtons ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .padding(.horizontal, .margin)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)

                            if showButtons {
                                VStack(spacing: 0) {
                                    subMenuRow(title: "Términos y condiciones") {
                                        navigation = .termsAndConditions
                                    }
                                    subMenuRow(title: "Políticas de privacidad") {
                                        navigation = .privacyPolicies
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        if profileState.ayuda.isVisible {
                            menuRowAction(
                                iconUrl: profileState.ayuda.iconUrl,
                                fallbackIcon: "questionmark.circle",
                                title: profileState.ayuda.label
                            ) {
                                openWhatsApp()
                            }
                        }

                        Divider()
                            .padding(.horizontal, .margin)
                            .padding(.vertical, 6)

                        menuRowAction(
                            iconUrl: "",
                            fallbackIcon: "rectangle.portrait.and.arrow.right",
                            title: "Cerrar sesión",
                            isDestructive: true
                        ) {
                            showLogoutDialog = true
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationLink(item: $navigation) { item in
                switch item {
                    case .data:
                    ProfileUpdateInformation(isObligatori: $showEmailPhone)
                            .tabBarHidden(true)
                    case .family:
                    FamilyGroupView()
                        .tabBarHidden(true)
                    case .password:
                        ProfileChangePassword()
                    case .termsAndConditions:
                        LegalsView(.termsAndConditions)
                    case .privacyPolicies:
                        LegalsView(.privacyPolicies)
                    default:
                        EmptyView()
                }
            }
            .navigationLink(isActive: $showTermsAndConditions) {
                LegalsView(.termsAndConditions)
            }
            .navigationLink(isActive: $showPrivacyPolicies) {
                LegalsView(.privacyPolicies)
            }
            .onAppear {
                profileState = loadProfileUIState()
            }
            .foregroundColor(.primaryText)
            .toolbar {}
            .configureNavigation()
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 10) {
            // Avatar con iniciales + animación bounce in
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0095B3"), Color(hex: "#00BBDC"), Color(hex: "#33CFEA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: Color(hex: "#00BBDC").opacity(0.3), radius: 8, x: 0, y: 4)

                Text(userInitials)
                    .font(Font.custom("FiraSans-Bold", size: 26))
                    .foregroundColor(.white)
            }
            .scaleEffect(avatarScale)
            .opacity(avatarOpacity)
            .onAppear {
                // Reset para que se anime cada vez que la vista aparece
                avatarScale = 0.0
                avatarOpacity = 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.3)) {
                        avatarScale = 1.0
                        avatarOpacity = 1.0
                    }
                }
            }

            // Nombre
            Text("\(userFirstName) \(userLastName)")
                .font(Font.custom("FiraSans-Bold", size: 18))
                .foregroundColor(Color(hex: "#222222"))

            // Email
            if !userEmail.isEmpty {
                Text(userEmail)
                    .font(Font.custom("FiraSans-Regular", size: 14))
                    .foregroundColor(Color(hex: "#888888"))
            }

            // Badge convenio
            if let enterprise = selectedEnterprise?.identificadorC, !enterprise.isEmpty {
                Text(enterprise)
                    .font(Font.custom("FiraSans-Medium", size: 12))
                    .foregroundColor(Color(hex: "#00BBDC"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#E6F9FC"))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .onReceive(AppStatusManager.onSelectedEnterprise) { newValue in
            guard let newValue = newValue else { return }
            self.selectedEnterprise = newValue
        }
    }

    // MARK: - Menu Row Components

    @ViewBuilder
    private func menuIcon(url: String, fallbackSFSymbol: String, isDestructive: Bool = false) -> some View {
        if !url.isEmpty, let imageUrl = URL(string: url) {
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .frame(width: 28)
        } else {
            Image(systemName: fallbackSFSymbol)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(isDestructive ? Color(hex: "#FF4D4F") : Color(hex: "#00BBDC"))
                .frame(width: 28)
        }
    }

    private var menuFontSize: CGFloat {
        CGFloat(Double(profileState.menuStyle.size) ?? 15)
    }

    private func menuRow(iconUrl: String, fallbackIcon: String, title: String, item: Item) -> some View {
        Button {
            navigation = item
        } label: {
            HStack(spacing: 14) {
                menuIcon(url: iconUrl, fallbackSFSymbol: fallbackIcon)
                Text(title)
                    .font(Font.custom(profileState.menuStyle.font, size: menuFontSize))
                    .foregroundColor(Color(hex: profileState.menuStyle.color))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(.horizontal, .margin)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func menuRowAction(iconUrl: String, fallbackIcon: String, title: String, isDestructive: Bool = false, showChevron: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 14) {
                menuIcon(url: iconUrl, fallbackSFSymbol: fallbackIcon, isDestructive: isDestructive)
                Text(title)
                    .font(Font.custom(profileState.menuStyle.font, size: menuFontSize))
                    .foregroundColor(isDestructive ? Color(hex: "#FF4D4F") : Color(hex: profileState.menuStyle.color))
                Spacer()
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .padding(.horizontal, .margin)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func subMenuRow(title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 14) {
                Color.clear
                    .frame(width: 28)
                Text(title)
                    .font(Font.custom("FiraSans-Regular", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding(.horizontal, .margin)
            .padding(.leading, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - WhatsApp Helper

    private func openWhatsApp() {
        let phone = profileState.whatsappNumber
        guard !phone.isEmpty else { return }
        let cleanPhone = phone.replacingOccurrences(of: "+", with: "")
        if let url = URL(string: "whatsapp://send?phone=\(cleanPhone)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let webUrl = URL(string: "https://api.whatsapp.com/send?phone=\(cleanPhone)") {
                UIApplication.shared.open(webUrl)
            }
        }
    }

    // MARK: - Grupo Familiar Validation

    private func showGrupoFamiliarMenu() -> Bool {
        let relation = selectedEnterprise?.relaciNConAseguradoC ?? "(nil)"
        let grupoFamiliar = selectedEnterprise?.grupoFamiliarC
        let nombreFlujo = selectedEnterprise?.nombreFlujoC ?? ""
        let enterpriseId = selectedEnterprise?.Id ?? "(nil)"
        let enterpriseName = selectedEnterprise?.identificadorC ?? "(nil)"

        let isTitular = relation == "Titular"
        let showMenu = isTitular

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] VALIDACIÓN MENÚ")
        print("   Enterprise: \(enterpriseName) (Id: \(enterpriseId))")
        print("   relaciNConAseguradoC: \"\(relation)\"")
        print("   grupoFamiliarC: \(grupoFamiliar != nil ? String(describing: grupoFamiliar!) : "(nil)")")
        print("   nombreFlujoC: \"\(nombreFlujo)\"")
        print("   ───────────────────────────────────")
        print("   isTitular: \(isTitular)")
        print("   → DECISIÓN MENÚ: \(showMenu ? "✅ MOSTRAR" : "❌ OCULTAR")")
        if showMenu {
            let addEnabled = grupoFamiliar ?? false
            let sendEmpresa = addEnabled && !nombreFlujo.isEmpty
            print("   → Agregar cargas habilitado (grupoFamiliarC): \(addEnabled ? "✅ SÍ" : "❌ NO")")
            print("   → Enviar empresa_solicitada: \(sendEmpresa ? "✅ SÍ (flujo: \(nombreFlujo))" : "❌ NO")")
        } else {
            print("   → Motivo: relación es \"\(relation)\", se requiere \"Titular\"")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        return showMenu
    }

    // MARK: - Helpers

    private func asyncTask<T>(_ action: @escaping () async -> Result<T, AppError>) {
        Task {
            let result = await action()
            self.alert = nil
            if case let .failure(error) = result {
                print("There was an \(error)")
            }
        }
    }
}

struct Item: Hashable {
    var title: String
    var icon: String

    static var data: Self {
        .init(title: "Datos personales", icon: "userdata")
    }

    static var family: Self {
        .init(title: "Grupo familiar", icon: "family-group")
    }

    static var companies: Self {
        .init(title: "Convenios", icon: "companies")
    }

    static var password: Self {
        .init(title: "Cambiar contraseña", icon: "change-password")
    }

    static var legals: Self {
        .init(title: "Información legal", icon: "legals")
    }

    static var termsAndConditions: Self {
        .init(title: "Términos y condiciones", icon: "")
    }

    static var privacyPolicies: Self {
        .init(title: "Políticas de privacidad", icon: "")
    }

    static var help: Self {
        .init(title: "Ayuda", icon: "help")
    }

    static var delete: Self {
        .init(title: "Eliminar perfil", icon: "delete-account")
    }

    static var logout: Self {
        .init(title: "Cerrar sesión", icon: "logout")
    }
}

func row(item: Item, action: @escaping () -> Void) -> some View {
    Button {
        action()
    } label: {
        Label(item.title, image: item.icon)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
    }
    .buttonStyle(.plain)
}
