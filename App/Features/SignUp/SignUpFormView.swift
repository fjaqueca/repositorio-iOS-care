//
//  SignUpFormView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 04/08/2022.
//

import SwiftUI
import CachedAsyncImage

struct SignUpFormView: View {
    @State private var rut: String
    @State private var status: Status = .input
    @State private var selectedAffiliate: Affiliate?
    @State private var affiliates: [Affiliate] = []
    @State private var name: Field = .name
    @State private var lastName: Field = .lastName
    @State private var titularRut: Field = .rutAccountHolder
    @State private var enterprise: SignupFormEnterprise?
    @State private var enterprises: [SignupFormEnterprise] = []
    @State private var country: Country?
    @State private var countries: [Country] = []
    @State private var email: Field = .email
    @State private var phone: Field = .phone
    @State private var company: Field = .enterprise
    @State private var error: AppError?
    @Binding var navigation: Navigation?
    
    @State private var serverError: String?
    
    @Binding var UIState: PreLoginUIState
    enum Status {
        case input
        case success
    }
    
    var body: some View {
        content
            .onTapGesture {
                self.hideKeyboard()
            }
            .ignoresSafeArea(.keyboard)
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
        VStack(alignment: .leading) {
            titleView
            
            Group {
// TODO: Will be available in R1
// PickerButton(title: "País", items: countries, selection: $country)
                TextField("", text: $rut)
                    .font(.appCallout)
                    .foregroundColor(Color.primaryText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)
                    .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primaryText, lineWidth: 1))
                
#if !Premedic
                PickerButton(title: "Tipo de afiliado", items: affiliates, selection: $selectedAffiliate)
                FieldView(field: $name)
                FieldView(field: $lastName)
                
                if selectedAffiliate?.id == Affiliate.holder.id {
                    FieldView(field: $company)
                } else {
                    FieldView(field: $titularRut)
                }
                FieldView(field: $email)
                    .textInputAutocapitalization(.never)
                FieldView(field: $phone)
#endif
                
#if Premedic
                
                FieldView(field: $name)
                FieldView(field: $lastName)
                
               
                FieldView(field: $email)
                    .textInputAutocapitalization(.never)
                FieldView(field: $phone)
                    .onAppear{
                        selectedAffiliate = Affiliate.holder
                        company.value = "Premedic"
                    }
#endif
            }
            
            Spacer()
            PrimaryButton(title: "Enviar", UIStateBtn: UIState.singUpFormUIState.btnSend) {
                registerUser()
            }
            .disabled(!isValid)
            .padding(.bottom, .margin)
        }
        .padding(.horizontal, .margin)
        .background(
            Group {
                    if UIState.singUpFormUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.singUpFormUIState.imageBackground ),
                            content: { image in
                                image
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .aspectRatio(contentMode: .fill)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                        .eraseToAnyView()
                    }
                }
        )
        .onChange(of: selectedAffiliate) { newValue in
            titularRut.value = nil
            enterprise = nil
        }
//        .task {
//            getCountries()
//        }
        .task {
            getRoles()
        }
        .task {
            getEnterprises()
        }
    }
    
    var isValid: Bool {
        guard [name, lastName, email, phone].allSatisfy({ $0.isValid }) else {
            return false
        }
        switch selectedAffiliate {
            case .holder:
            return company.value != nil
            case .beneficiary:
                return titularRut.isValid
            default:
                return false
        }
    }
    
    func getCountries() {
        Task {
            let result = await Network.shared.getCountries()
            switch result {
                case let .success(value):
                    await MainActor.run {
                        self.countries = value
                    }
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
    
    func getEnterprises() {
        Task {
            let result = await Network.shared.getSignupFormEnterprises(countryId: "a1U8c000005dAtnEAE")
            switch result {
                case let .success(value):
                    await MainActor.run {
                        self.enterprises = value
                    }
                case let .failure(error):
                    AppStatusManager.error(error)
                    self.status = .input
            }
        }
    }
    
    func getRoles() {
        Task {
            let result = await Network.shared.getRoles()
            switch result {
                case let .success(beneficiaries):
                print(result)
                    var affiliates: [Affiliate] = [.holder]
                    affiliates.append(contentsOf: beneficiaries.data
                        .map { Affiliate.beneficiary($0) })
                affiliates.removeAll { affiliate in
                    if case let .beneficiary(beneficiary) = affiliate {
                        return beneficiary.id == "a1J8c00000PcJoeEAF" && beneficiary.name == "Titular"
                    }
                    return false
                }
                    self.affiliates = affiliates
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
    
    private var successView: some View {
        VStack {
            Spacer()
            if UIState.popupRegisterSuccessUIState.icon != "" {
                CachedAsyncImage(
                    url: URL(string: UIState.popupRegisterSuccessUIState.icon  ),
                    content: { image in
                        image
                            .resizable()
                            .frame(width: 155.0, height: 151.0)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                .eraseToAnyView()
            }else {
                Image("checkmark")
            }
            Text(UIState.popupRegisterSuccessUIState.msg.text != "" ? UIState.popupRegisterSuccessUIState.msg.text : "Muchas gracias, su solicitud será verificada por nuestro equipo y lo contactaremos a la brevedad.")
                .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.popupRegisterSuccessUIState.msg.sizeText) ?? 20)))
                .foregroundColor(UIState.popupRegisterSuccessUIState.msg.colorText != "" ? Color(hex: UIState.popupRegisterSuccessUIState.msg.colorText) : .primaryText)
                .multilineTextAlignment(.center)
                .padding(.vertical, .margin)
                .onAppear{
                    moveToLoginView()
                }
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .background(
            Group {
                    if UIState.popupRegisterSuccessUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.popupRegisterSuccessUIState.imageBackground ),
                            content: { image in
                                image
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .aspectRatio(contentMode: .fill)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                        .eraseToAnyView()
                    }
                }
        )
    }
    
    private var titleView: some View {
        Text(UIState.singUpFormUIState.title.text != "" ? UIState.singUpFormUIState.title.text : "Ayúdanos con tus datos")
            .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.singUpFormUIState.title.sizeText) ?? 18)))
            .foregroundColor(UIState.singUpFormUIState.title.colorText != "" ? Color(hex: UIState.singUpFormUIState.title.colorText) : .primaryText)
    }
    
    private var formValues: [String: String] {
        [
            "nomenclatura_id": "RUT",
            "cedula_id": rut.filter { $0.isLetter || $0.isNumber },
            name.id: name.value,
            lastName.id: lastName.value,
            "empresa_solicitada": company.value,
            "cedula_titular": titularRut.value,
            phone.id: phone.value,
            email.id: email.value,
            "relacion_titular": selectedAffiliate?.id
        ].compactMapValues({ $0 })
    }
    
    init(rut: String, UIState: Binding<PreLoginUIState>, navigation: Binding<Navigation?>) {
        self.rut = rut
        self._UIState = UIState
        self._navigation = navigation
    }
    private func moveToLoginView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.navigation = .login
        }
        
    }
    private func registerUser() {
        Task {
            AppStatusManager.setLoading(true)
            let result = await Network.shared.sendSignUpForm(formValues)
            AppStatusManager.setLoading(false)
            switch result {
                case .success:
                    status = .success
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}
