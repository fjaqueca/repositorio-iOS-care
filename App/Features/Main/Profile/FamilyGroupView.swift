//
//  FamilyGroupView.swift
//  CareAssistance
//
//  Created by The App Master on 18/07/2024.
//

import SwiftUI
import CachedAsyncImage
import RealmSwift
struct FamilyGroupView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedResults(User.self) private var users
    @State private var rut: Field = .identificationNumber
    @State private var status: Status = .input
    @State private var selectedAffiliate: Affiliate?
    @State private var affiliates: [Affiliate] = []
    @State private var name: Field = .name
    @State private var lastName: Field = .lastName
    @State private var birthDate: String = ""
    @State private var date: Date = .now
    @State private var showCalendar: Bool = false
    @State private var titularRut: Field = .rutAccountHolder
    @State private var enterprise: SignupFormEnterprise?
    @State private var enterprises: [SignupFormEnterprise] = []
    @State private var country: Country?
    @State private var countries: [Country] = []
    @State private var email: Field = .email
    @State private var phone: Field = .phone
    @State private var company: Field = .enterprise
    @State private var error: AppError?
    @State private var serverError: String?
    @State private var stringDate: String = ""
    @ObservedResults(BrandAccounts.self) var items
    @State var UIState: PreLoginUIState = PreLoginUIState()
    @State var isLoading: Bool = false
    @State var isMinor: Bool = false
    @State private var selectedEnterprise: CompanyAgreementR? = AppStatusManager.selectedEnterprise
    enum Status {
        case input
        case success
    }
    var body: some View {
        if isLoading{
            ProgressView()
        }else{
            content
                .onAppear{
                    isLoading = true
                    titularRut.value = AppStatusManager.rut
                    company.value = selectedEnterprise?.nombreFlujoC ?? ""
                    loadUIState()
                }
                .onTapGesture {
                    self.hideKeyboard()
                }
                .ignoresSafeArea(.keyboard)
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
        }
        
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
                FieldView(field: $rut)
                
                PickerButton(title: "Tipo de afiliado", items: affiliates, selection: $selectedAffiliate)
                if selectedAffiliate?.id == Affiliate.holder.id {
                    FieldView(field: $company)
                } else {
                    FieldView(field: $titularRut)
                        .foregroundColor(.gray)
                        .disabled(true)
                }
                FieldView(field: $name)
                FieldView(field: $lastName)
                HStack{
                    Text(formattedDate(date))
                        .font(.appCallout)
                        .padding(.horizontal, 5)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 30, alignment: Alignment.leading)
                .textFieldStyle(.roundedBorder)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1))
                .onTapGesture {
                    self.showCalendar.toggle()
                }
                
                FieldView(field: $email)
                    .textInputAutocapitalization(.never)
                    .disabled(isMinor)
                FieldView(field: $phone)
                    .disabled(isMinor)
            }
            
            Spacer()
            PrimaryButton(title: "Enviar", UIStateBtn: UIState.singUpFormUIState.btnSend) {
                registerUser()
            }
            .disabled(!isValid)
            .padding(.bottom, .margin)
        }
        .padding(.horizontal, .margin)
        .popup(isPresented: $showCalendar){
            VStack{
                HStack{
                    Text("Fecha de nacimiento")
                        Spacer()
                        
                    Button(action: {
                        self.showCalendar.toggle()
                        stringDate = formattedDateToEndpoint(date)
                    }, label: {
                        Text("Aceptar")
                            .font(.appBodyBold)
                            .foregroundColor(.primaryText)
                    })
                }
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "es_ES"))
            }
            .padding()
            
        }
        .onChange(of: date){ newValue in
            let age = calculateAge(from: newValue)
            if age < 18 {
                email.value = users.first?.records.first?.PersonEmail ?? ""
                phone.value = users.first?.records.first?.Phone ?? ""
                isMinor = true
            }else{
                email.value = ""
                phone.value = ""
                isMinor = false
            }
        }
        
        .onChange(of: selectedAffiliate) { newValue in
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
                    var affiliates: [Affiliate] = []
                    affiliates.append(contentsOf: beneficiaries.data
                        .map { Affiliate.beneficiary($0) })
                affiliates.removeAll { affiliate in
                    if case let .beneficiary(beneficiary) = affiliate {
                        return (beneficiary.id == "a1J8c00000PcJoeEAF" && beneficiary.name == "Titular") ||
                               (beneficiary.id == "a1J8c00000PdhadEAB" && beneficiary.name == "Primary Care Provider (PCP)") ||
                               (beneficiary.id == "a1J8c00000PcJooEAF" && beneficiary.name == "Hijo/a")
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
            Text(UIState.popupRegisterSuccessUIState.msg.text != "" ? UIState.popupRegisterSuccessUIState.msg.text : "Registro exitoso")
                .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.popupRegisterSuccessUIState.msg.sizeText) ?? 20)))
                .foregroundColor(UIState.popupRegisterSuccessUIState.msg.colorText != "" ? Color(hex: UIState.popupRegisterSuccessUIState.msg.colorText) : .primaryText)
                .multilineTextAlignment(.center)
                .padding(.vertical, .margin)
            Button {
                self.presentation.wrappedValue.dismiss()

            } label: {
                Text("Aceptar")
                    .font(.appBodyBold)
                    .foregroundColor(.primaryText)
            }
            Spacer()
        }
    }
    
    private var titleView: some View {
        Text(UIState.singUpFormUIState.title.text != "" ? UIState.singUpFormUIState.title.text : "Ayúdanos con tus datos")
            .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.singUpFormUIState.title.sizeText) ?? 18)))
            .foregroundColor(UIState.singUpFormUIState.title.colorText != "" ? Color(hex: UIState.singUpFormUIState.title.colorText) : .primaryText)
    }
    
    private var formValues: [String: String] {
        [
            "nomenclatura_id": "RUT",
            "cedula_id": rut.value?.uppercased().filter { $0.isLetter || $0.isNumber },
            name.id: name.value,
            lastName.id: lastName.value,
            "empresa_solicitada": company.value,
            "cedula_titular": titularRut.value,
            phone.id: phone.value,
            email.id: email.value,
            "relacion_titular": selectedAffiliate?.id
        ].compactMapValues({ $0 })
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
                if error.httpCode == 400{
                    AppStatusManager.error(AppError(id: "api.error.AllReadyExist", name: "", message: "El Número de Identificación ingresado ya se encuentra registrado."))
                }else{
                    AppStatusManager.error(error)
                }
            }
        }
    }
    func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
    func calculateAge(from birthDate: Date) -> Int {
            let calendar = Calendar.current
            let now = Date()
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
            return ageComponents.year ?? 0
        }
    func formattedDateToEndpoint(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            return formatter.string(from: date)
        }
}
