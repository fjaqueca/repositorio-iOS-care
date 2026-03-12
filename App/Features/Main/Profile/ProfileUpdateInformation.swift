//
//  ProfileUpdateInformation.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/02/2023.
//

import SwiftUI
import RealmSwift

struct ProfileUpdateInformation: View {
    @Environment(\.presentationMode) var presentation
    @ObservedResults(User.self) private var users
    @State private var rut: String = ""
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var email: Field = .email
    @State private var phone: Field = .phone
    @State private var popup: Popup?
    @State private var isLoading: Bool = false
    @Binding var isObligatori: Bool
    
    var body: some View {
        VStack(spacing: 0.0) {
            Divider()
            Text("Solicitud de modificación")
                .font(.appCalloutBold)
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, .margin * 1.5)
            VStack(spacing: .margin) {
                TextField(AppStatusManager.rut ?? "", text: $rut)
                    .font(.appCallout)
                    .foregroundColor(Color.primaryText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)
                    .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.textSecondary, lineWidth: 1))
                TextField(users.first?.records.first?.FirstName ?? "Nombre", text: $name)
                    .font(.appCallout)
                    .textFieldStyle(.roundedBorder)
                    .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.textSecondary, lineWidth: 1))
                TextField(users.first?.records.first?.LastName ?? "Apellido", text: $lastName)
                    .font(.appCallout)
                    .textFieldStyle(.roundedBorder)
                    .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.textSecondary, lineWidth: 1))
                
                FieldView(field: $email)
                    .textInputAutocapitalization(.never)
                FieldView(field: $phone)
//                TextField(users.first?.records.first?.PersonEmail ?? "Email", text: $email)
//                    .font(.appCallout)
//                    .foregroundColor(Color.primaryText)
//                    .textFieldStyle(.roundedBorder)
//                    .overlay(RoundedRectangle(cornerRadius: 5)
//                        .stroke(Color.primaryText, lineWidth: 1))
//                TextField(users.first?.records.first?.Phone ?? "Teléfono", text: $phone)
//                    .font(.appCallout)
//                    .foregroundColor(Color.primaryText)
//                    .textFieldStyle(.roundedBorder)
//                    .overlay(RoundedRectangle(cornerRadius: 5)
//                        .stroke(Color.primaryText, lineWidth: 1))
            }
            .onAppear{
                email.value = users.first?.records.first?.PersonEmail ?? ""
                phone.value = users.first?.records.first?.Phone ?? ""
                name = users.first?.records.first?.FirstName ?? ""
                lastName = users.first?.records.first?.LastName ?? ""
            }
            
            Spacer()
            
            PrimaryButton(title: "Enviar") {
                updateProfile()
            }
            .disabled(isLoading || (!phone.isValid && ((users.first?.records.first?.Phone?.isEmpty) == nil)) || (!email.isValid && ((users.first?.records.first?.PersonEmail) == nil)))
        }
        .padding(.margin)
        .popup(item: $popup)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Datos personales")
                    .font(.appTabTitleBold)
                    .foregroundColor(.primaryText)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if isObligatori{
                        exit(0)
                    }else{
                        self.presentation.wrappedValue.dismiss()
                    }
                } label: {
                    Image("back")
                        .renderingMode(.template)
                }
            }
        }
            .tabBarHidden(true)
    }
    public func updateProfile() {
        Task {
            
            isLoading = true
            let result = await Network.shared.updateProfile(
                rut: AppStatusManager.rut ?? "",
                lastName: lastName,
                firstName: name,
                email: email.value,
                phone: phone.value
            )
            isLoading = false
            switch result {
                case .success:
                if isObligatori{
                    self.presentation.wrappedValue.dismiss()
                    self.isObligatori = false
                }else{
                    popup = confirmationPopup
                }
                    
                    await AppStatusManager.loadUser()
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}

extension ProfileUpdateInformation {
    var confirmationPopup: Popup {
        .init(
            image: "checkmark",
            title: "Solicitud enviada con éxito.",
            message: "Su solicitud será verificada por nuestro equipo y lo contactaremos a la brevedad.",
            actionTitle: "Aceptar",
            action: {
                self.presentation.wrappedValue.dismiss()
                self.isObligatori = false
            },
            isCancellable: false,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
}
