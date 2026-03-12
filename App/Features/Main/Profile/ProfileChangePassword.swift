//
//  ProfileChangePassword.swift
//  CareAssistance
//
//  Created by Lara Dubs on 18/10/2022.
//

import SwiftUI
import Introspect

struct ProfileChangePassword: View {
    @State private var status: Status = .input
    @State private var oldPasswordField: Field = .oldPassword
    @State private var newPasswordField: Field = .newPassword
    @State private var passwordConfirmField: Field = .passwordConfirm
    @State private var isLoading: Bool = false
    @State var tabBarController: UITabBarController?
    
    enum Status {
        case input
        case success
    }
    
    var body: some View {
        content
            .tabBarHidden(true)
    }
    
    
    @ViewBuilder
    private var content: some View {
        switch status {
            case .input:
                inputView
            case .success:
                successView
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 0.0) {
            Divider()
            Text("Crea una contraseña que contenga mínimo 8 dígitos, una mayúscula, un número y un carácter especial.")
                .font(.appCallout)
                .foregroundColor(.primaryText)
                .padding(.vertical, .margin * 1.5)

            VStack(spacing: .margin) {
                FieldView(field: $oldPasswordField)
                FieldView(field: $newPasswordField)
                FieldView(field: $passwordConfirmField)
            }
            
            Spacer()
            
            PrimaryButton(title: "Guardar") {
                changePassword()
            }
            .disabled(!passwordConfirmField.isValid)
            .isLoading(isLoading)
        }
        .padding(.margin)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Cambiar contraseña")
                    .font(.appTabTitleBold)
                    .foregroundColor(.primaryText)
            }
        }
    }
    
    private var successView: some View {
        VStack {
            Spacer()
            Image("checkmark")
            Text("Su contraseña ha sido actualizada.")
                .foregroundColor(.primaryText)
                .font(.appBody)
            Spacer()
        }
    }
    
    public func changePassword() {
        guard let oldPassword = oldPasswordField.value, let newPassword = passwordConfirmField.value else {
            return
        }
        isLoading = true
        Task {
            let result = await Network.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            switch result {
                case .success:
                    status = .success
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}

struct ProfileChangePassword_Previews: PreviewProvider {
    static var previews: some View {
        ProfileChangePassword()
    }
}
