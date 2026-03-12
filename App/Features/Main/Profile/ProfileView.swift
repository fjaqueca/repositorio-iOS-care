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

struct ProfileView: View {
    @ObservedResults(User.self) private var users
    @ObservedResults(BrandAccounts.self) var items
    @State private var showEmailPhone: Bool = false
    @State private var navigation: Item?
    @State private var showButtons = false
    @State private var showTermsAndConditions: Bool = false
    @State private var showPrivacyPolicies: Bool = false
    @State private var selectedEnterprise: CompanyAgreementR? = AppStatusManager.selectedEnterprise
    @State var alert: AlertConfirmation?
    
    public struct AlertConfirmation {
        let title: String
        let action: () -> Void
    }
    
    var body: some View {
        NavigationViewCustom {
            VStack(spacing: 0.0) {
                Divider()
                headerView
                
                Section {
                    row(item: .data) {
                        navigation = .data
                    }
                    if let relation = selectedEnterprise?.relaciNConAseguradoC, relation == "Titular"{
                        if let showFamilyGroup = selectedEnterprise?.grupoFamiliarC, showFamilyGroup{
                            row(item: .family) {
                                navigation = .family
                            }
                        }
                    }

                    row(item: .companies) {
                        navigation = .companies
                    }
                    
                    row(item: .password) {
                        navigation = .password
                    }
                    
                    row(item: .legals) {
                        showButtons.toggle()
                    }
                    
                    if showButtons {
                        Button(action: {
                            navigation = .termsAndConditions
                        }) {
                            Text(Item.termsAndConditions.title)
                                .foregroundColor(.secondaryText)
                                .font(.appCallout)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 30)
                        .padding(.leading, .margin)
                        
                        
                        Button(action: {
                            navigation = .privacyPolicies
                        }) {
                            Text(Item.privacyPolicies.title)
                                .foregroundColor(.secondaryText)
                                .font(.appCallout)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 30)
                        .padding(.leading, .margin)
                    }
                    row(item: .help) {
                        if let brandRecords = items.first?.records{
                            for brands in brandRecords{
                                if brands.Name == "Perfil" {
                                    if let whatsapp = brands.valor85C {
                                        let cleanPhone = whatsapp.replacingOccurrences(of: "+", with: "")
                                        if let url = URL(string: "whatsapp://send?phone=\(cleanPhone)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                // Si no está instalada la app, abrimos la versión web
                                                if let webUrl = URL(string: "https://api.whatsapp.com/send?phone=\(cleanPhone)") {
                                                    UIApplication.shared.open(webUrl)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    row(item: .delete) {
                        alert = .init(title: "¿Está seguro de eliminar su perfil?") {
                            asyncTask(AppStatusManager.deleteUser)
                        }
                    }
                    row(item: Item.logout) {
                        alert = .init(title: "¿Está seguro de cerrar su sesión?") {
                            asyncTask(AppStatusManager.logoutUser)
                        }
                    }
                }
                Spacer()
            }
            .navigationLink(item: $navigation) { item in
                switch item {
                    case .data:
                    ProfileUpdateInformation(isObligatori: $showEmailPhone)
                            .tabBarHidden(true)
                    case .family:
                    FamilyGroupView()
                        .tabBarHidden(true)
                    case .companies:
                        CompanySelectionView(style: .profile)
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
            .padding(.horizontal, .margin)
            .foregroundColor(.primaryText)
            .font(.appBody)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Perfil")
                        .font(.appTabTitleBold)
                        .foregroundColor(.primaryText)
                }
            }
            .configureNavigation()
        }
        .accentColor(.blue)
        .alert("", isPresented: .init(get: { alert != nil }, set: { if !$0 { alert = nil }}), presenting: alert) { value in
            Button("Cancelar") {
                self.alert = nil
            }
            Button("Confirmar") {
                value.action()
            }
        } message: { value in
            Text(value.title)
        }
    }
    
    private var headerView: some View {
        VStack {
            Text(users.first?.records.first?.FirstName ?? "")
                .font(.appBodyBold)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .labelStyle(.inverted)
            Text(selectedEnterprise?.identificadorC ?? "")
                .font(.appCallout)
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.margin * 1.5)
        .onReceive(AppStatusManager.onSelectedEnterprise) { newValue in
            guard let newValue = newValue else { return }
            self.selectedEnterprise = newValue
        }
    }
    
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
