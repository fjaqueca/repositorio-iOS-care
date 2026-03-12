//
//  SignUpContactInfoFormView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 27/06/2023.
//

import SwiftUI

struct SignUpContactInfoFormView: View {
    @State private var isPresentingOtpView = false
    @State private var rut: String
    @State private var email: Field = .email
    @State private var phone: Field = .phone
    @Binding var UIState: PreLoginUIState
    @Binding var navigation: Navigation?
    var body: some View {
        VStack(spacing: 10) {
            Text("Ayúdanos con tus datos")
                .font(.appSubtitleBold)
                .foregroundColor(.primaryText)
                .padding(.bottom, .margin)
            FieldView(field: $email)
                .textInputAutocapitalization(.never)
            FieldView(field: $phone)
            
            Spacer()
            PrimaryButton(title: "Enviar") {
                setEmailPhone()
            }
            .disabled(!isValid)
        }
        .padding(.horizontal, .margin)
        .onTapGesture {
            self.hideKeyboard()
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        .navigationLink(isActive: $isPresentingOtpView) {
            SignUpOtpView(rut: rut, recipient: email.value ?? "", navigation: $navigation, UIState: $UIState)
        }
    }
    
    private var formValues: [String: String] {
        [
            "cedula": rut.filter { $0.isLetter || $0.isNumber },
            phone.id: phone.value,
            email.id: email.value
        ].compactMapValues({ $0 })
    }
    
    var isValid: Bool {
        guard [email, phone].allSatisfy({ $0.isValid }) else {
            return false
        }
        return true
    }

    init(rut: String, UIState: Binding<PreLoginUIState>, navigation: Binding<Navigation?>) {
        self.rut = rut
        self._UIState = UIState
        self._navigation = navigation
    }
    
    private func setEmailPhone() {
        Task {
            let result = await Network.shared.setContactInfo(formValues)
            switch result {
                case .success:
                    sendOtp()
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
    
    public func sendOtp() {
        Task {
            let result = await Network.shared.sendValidationCode(rut: rut.filter { $0.isLetter || $0.isNumber })
            switch result {
                case .success:
                    isPresentingOtpView = true
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}


