//
//  NewAppointmentSelectDetailsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 27/10/2022.
//

import SwiftUI
import RealmSwift
import Alamofire
import CachedAsyncImage
import Combine

struct NewAppointmentSelectDetailsView: View {
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @Environment(\.rootPresentation) private var rootPresentation
    @Environment(\.dismiss) var dismiss
    var id: String
    let clinic: ClinicDetail
    @State var name: String = ""
    @ObservedResults(Appointment.self) var previousAppointment
    @ObservedResults(ClinicInit.self) var clinicObjects
    var publisher = PassthroughSubject<Void, Never>()
    @State var clinicName = ""
    @State var isShowingPopupPerHour = false
    @State var isShowingPopupPerClinic = false
    @State var isShowConsentPopup = false
    private let isConsent = AppStatusManager.selectedEnterprise?.consentimientoInformadoC
    @State var popupConsent: [PopupConsent] = []
    @ObservedResults(BrandAccounts.self) var items
    @State var isCreateAppointment = false
    
    @State private var popup: Popup?
    @State private var error: AppError?
    
    @State private var isLoading: Bool = false
    
    // NUEVO: Estados para Ficha Clínica General
    @State private var brandAccountResponse: BrandAccounts?
    @State private var brandAccountFormularioGeneral: BrandAccount?
    @State private var mostrarFormularioGeneral: Bool = false
    @State private var formularioParsed: FormularioGeneral?
    
    // Professional
    @State private var professional: Professional?
    @State private var professionals: [Professional] = []
    @State private var showProfessionalsPicker: Bool = false
    
    // Date
    @State private var date: Date?
    @State private var showCalendar: Bool = false
    @State private var calendarMonthOffset: Int = 0
    
    // Slot
    @State private var slot: AppointmentSlot?
    @State private var slots: [AppointmentSlot] = []
    @State private var showSlotPicker: Bool = false
    
    @Binding var selectedTab: Tab
    var selectedDateSlots: [AppointmentSlot] {
        slots.filter {
            guard let date = date else {
                return false
            }
            return Calendar.current.isDate($0.startDate, inSameDayAs: date)
        }
    }
    
    var dateFormat: Date.FormatStyle {
        .init(
            date: .abbreviated,
            time: .omitted,
            locale: .init(identifier: "es_419"),
            calendar: .current,
            timeZone: .current,
            capitalizationContext: .beginningOfSentence
        )
    }
    
    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(UIStateAppoint.newAppointmentUIState.title.text)
                            .font(Font.custom(UIStateAppoint.newAppointmentUIState.title.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.title.color))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.template)
                            .font(Font.custom(UIStateAppoint.newAppointmentUIState.title.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.title.color))
                    }
                }
            }
            .task {
                getProfessionals()
                configPopupConsent()
                
                // 🆕 NUEVO: Verificar Ficha Clínica General al entrar a la vista
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🏥 [NewAppointmentSelectDetailsView] Vista cargada - Iniciando verificación de Ficha Clínica")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                await checkFichaClinicaGeneralInAgendamiento()
            }
            .tabBarHidden(true)
            .navigationBarBackButtonHidden()
            // NUEVO: Sheet para mostrar Ficha Clínica General
            .sheet(isPresented: $mostrarFormularioGeneral) {
                if let formulario = formularioParsed {
                    FormularioGeneralView(
                        formulario: formulario,
                        onComplete: { respuestas in
                            handleFormularioComplete(respuestas: respuestas, formulario: formulario)
                        },
                        onClose: {
                            // Esta función no se llamará porque isCloseable=false
                            mostrarFormularioGeneral = false
                        },
                        isCloseable: false // ❌ NewAppointmentSelectDetailsView: Modal OBLIGATORIO (no se puede cerrar)
                    )
                    .interactiveDismissDisabled(true) // 🔒 CRÍTICO: Bloquea el gesto swipe-down
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        if professionals.isEmpty {
            VStack {
                ProgressView()
            }
        } else {
            ZStack{
                form
                    .blur(radius: isShowingPopupPerHour || isShowingPopupPerClinic || isShowConsentPopup ? 3 : 0.00001)
                    .disabled(isShowingPopupPerHour || isShowingPopupPerClinic || isShowConsentPopup)
                if isShowConsentPopup {
                    if let popup = popupConsent.first(where: { $0.clinicId == id }) {
                        PopupConsentView(
                            popupData: popup, showConsentPopup: $isShowConsentPopup, isCreateAppointment: $isCreateAppointment
                        )
                    }
                }
                if isShowingPopupPerHour{
                    PopupView(showCustomPopup: $isShowingPopupPerHour, clinicName: $clinicName, popupData: UIStateAppoint.popupAllreadyHaveAppointmentPerHour)
                }
                if isShowingPopupPerClinic{
                    PopupView(showCustomPopup: $isShowingPopupPerClinic, clinicName: $clinicName, popupData: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic)
                }
                
            }
            
        }
    }
    
    var form: some View {
        VStack {
            Divider()
            ScrollView{
                
                
                clinicRow
                
                if professional == nil {
                    dateFirstAvailableButton
                    Text("O")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.appCallout)
                        .foregroundColor(Color.primaryText)
                        .padding(.margin / 2)
                }
                
                professionalRow
                
                if professional != nil {
                    dateRow
                }
                
                if date != nil {
                    slotRow
                }
                
                if slot != nil {
                    appointmentTypeButtons
                }
                
                
                
                
            }
            Spacer()
            PrimaryButton(title: "Agendar cita", UIStateBtn: UIStateAppoint.newAppointmentUIState.btnAgend) {
                validatePopupConsent()
            }
            .background{
                if slot?.appointmentType == nil{
                    Color(hex: UIStateAppoint.newAppointmentUIState.btnAgend.backgroundPressBtn != "" ? UIStateAppoint.newAppointmentUIState.btnAgend.backgroundPressBtn : "#E9E9EB")
                        .cornerRadius(5.0)
                }
            }
            .disabled(slot?.appointmentType == nil)
            .padding(.bottom, .margin)
            .isLoading(isLoading)
        }
        .padding(.horizontal, .margin)
        .overlayView(isLoading)
        .pickerPopup(
            title: "Seleccionar profesional",
            items: professionals,
            isPresented: $showProfessionalsPicker,
            selection: .init(
                get: {
                    professional
                }, set: { newValue in
                    guard newValue != professional else {
                        return
                    }
                    professional = newValue
                    date = nil
                    slots = []
                    calendarMonthOffset = 0
                    slot = nil
                    Task {
                        await getProfessionalAvailableDatesForCurrentMonth()
                    }
                }
            )
        )
        .popup(isPresented: $showCalendar) {
            CalendarView(
                markedDates: .constant(slots.map { $0.startDate }),
                selectedDate: .init(
                    get: {
                        date
                    },
                    set: { newValue in
                        guard newValue != date else {
                            return
                        }
                        date = newValue
                        slot = nil
                    }
                ),
                selectedMonthOffset: $calendarMonthOffset,
                autoselectDateWhenMonthChanges: false, UIStateAppoint: $UIStateAppoint
            )
        }
        .pickerPopup(title: "Horarios disponibles", items: selectedDateSlots, isPresented: $showSlotPicker, selection: $slot)
        .onChange(of: calendarMonthOffset) { newValue in
            Task {
                await getProfessionalAvailableDatesForCurrentMonth()
            }
        }
        .onChange(of: date) { newValue in
            showCalendar = false
        }
        .onChange(of: isCreateAppointment) { newValue in
            if newValue {
                createAppointment()
            }
            
        }
        .popup(item: $popup)
    }
    
    @ViewBuilder
    var clinicRow: some View {
        Text(UIStateAppoint.newAppointmentUIState.labelTxtClinic)
            .font(Font.custom(UIStateAppoint.newAppointmentUIState.labelsAtr.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.labelsAtr.size) ?? 18)))
            .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.labelsAtr.color))
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear{
                name = clinic.name
            }
        
        HStack {
            ClinicIconView(clinic: clinic)
            TextField("", text: $name)
                .font(Font.custom(UIStateAppoint.newAppointmentUIState.btns.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btns.size) ?? 18)))
                .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btns.textColor))
                .textFieldStyle(.plain)
                .disabled(true)
        }
        .background(Color(hex: UIStateAppoint.newAppointmentUIState.btns.backColor))
        .frame(height: 50.0)
        .cornerRadius(.cornerRadius)
        .padding(.bottom, .margin)
    }
    
    @ViewBuilder
    var professionalRow: some View {
        Text(UIStateAppoint.newAppointmentUIState.labelTxtProf)
            .font(Font.custom(UIStateAppoint.newAppointmentUIState.labelsAtr.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.labelsAtr.size) ?? 18)))
            .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.labelsAtr.color))
            .frame(maxWidth: .infinity, alignment: .leading)
        
        HStack {
            ClinicIconView(clinic: clinic)
            
            Button {
                showProfessionalsPicker = true
            } label: {
                Text(professional?.description ?? UIStateAppoint.newAppointmentUIState.hintTxtProf)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .font(Font.custom(UIStateAppoint.newAppointmentUIState.btns.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btns.size) ?? 18)))
                    .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btns.textColor))
            }
            .buttonStyle(.plain)
        }
        .frame(height: 50.0)
        .background(Color(hex: UIStateAppoint.newAppointmentUIState.btns.backColor))
        .cornerRadius(.cornerRadius)
        .padding(.bottom, .margin)
    }
    
    @ViewBuilder
    var dateRow: some View {
        Text(UIStateAppoint.newAppointmentUIState.labelTxtDate)
            .font(Font.custom(UIStateAppoint.newAppointmentUIState.labelsAtr.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.labelsAtr.size) ?? 18)))
            .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.labelsAtr.color))
            .frame(maxWidth: .infinity, alignment: .leading)
        datePickerButton
            .padding(.bottom, .margin)
    }
    
    @ViewBuilder
    var datePickerButton: some View {
        Button {
            showCalendar = true
        } label: {
            HStack {
                if date != nil {
                    ClinicIconView(clinic: clinic)
                }
                Text(date?.formatted(dateFormat) ?? UIStateAppoint.newAppointmentUIState.hintTxtDate)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .font(Font.custom(UIStateAppoint.newAppointmentUIState.btns.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btns.size) ?? 18)))
                    .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btns.textColor))
                    .padding(.leading, date == nil ? .margin : .zero)
                Spacer()
                Image("calendar-empty")
                    .renderingMode(.template)
                    .padding(.trailing, .margin)
                    .font(Font.custom(UIStateAppoint.newAppointmentUIState.btns.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btns.size) ?? 18)))
                    .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btns.textColor))
            }
        }
        .buttonStyle(.plain)
        .frame(height: 50.0)
        .background(Color(hex: UIStateAppoint.newAppointmentUIState.btns.backColor))
        .cornerRadius(.cornerRadius)
    }
    
    @ViewBuilder
    var dateFirstAvailableButton: some View {
        Button {
            selectAvailableSlot()
        } label: {
            Text(UIStateAppoint.newAppointmentUIState.btnTextFirst)
                .font(Font.custom(UIStateAppoint.newAppointmentUIState.btns.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btns.size) ?? 18)))
                .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btns.textColor))
                .padding(.leading, .margin)
                .frame(height: 50.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .fill(Color.white)
                        .shadow(color: .gray, radius: 2, x: 1, y: 1)
                )
        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.main.bounds.size.width * 0.9)
    }
    
    @ViewBuilder
    var slotRow: some View {
        Text(UIStateAppoint.newAppointmentUIState.labelTxtHour)
            .font(Font.custom(UIStateAppoint.newAppointmentUIState.labelsAtr.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.labelsAtr.size) ?? 18)))
            .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.labelsAtr.color))
            .frame(maxWidth: .infinity, alignment: .leading)
        
        HStack {
            if  date != nil {
                ClinicIconView(clinic: clinic)
            }
            Button {
                showSlotPicker = true
            } label: {
                Text(slot?.startDate.formatted(date: .omitted, time: .shortened) ?? UIStateAppoint.newAppointmentUIState.hintTxtHour)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .font(Font.custom(UIStateAppoint.newAppointmentUIState.btns.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btns.size) ?? 18)))
                    .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btns.textColor))
            }
            .buttonStyle(.plain)
        }
        .frame(height: 50.0)
        .background(Color(hex: UIStateAppoint.newAppointmentUIState.btns.backColor))
        .cornerRadius(.cornerRadius)
        .padding(.bottom, .margin)
    }
    
    @ViewBuilder
    var appointmentTypeButtons: some View {
        Text(UIStateAppoint.newAppointmentUIState.tipeOfAppointment)
            .font(Font.custom(UIStateAppoint.newAppointmentUIState.labelsAtr.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.labelsAtr.size) ?? 18)))
            .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.labelsAtr.color))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, .margin)
        
        HStack {
            if slot != nil {
                Spacer()
                if UIStateAppoint.newAppointmentUIState.isBtnPhoneHidden != "No"{
                    
                    
                    Button(action: {
                        slot?.appointmentType = "Phone"
                    }) {
                        VStack{
                            if slot?.appointmentType == "Phone"{
                                CachedAsyncImage(
                                    url: URL(string: UIStateAppoint.newAppointmentUIState.btnPhoneSelected),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    })
                            }else{
                                CachedAsyncImage(
                                    url: URL(string: UIStateAppoint.newAppointmentUIState.btnPhoneEnable),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    })
                            }
                            Text(UIStateAppoint.newAppointmentUIState.btnPhone.text)
                                .padding(.margin / 2)
                                .font(Font.custom(UIStateAppoint.newAppointmentUIState.btnPhone.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btnPhone.size) ?? 18)))
                                .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btnPhone.textColor))
                        }
                        
                    }
                }
                if UIStateAppoint.newAppointmentUIState.isBtnVideoHidden != "No" && UIStateAppoint.newAppointmentUIState.isBtnPhoneHidden != "No"{
                    Spacer()
                }
                
                if UIStateAppoint.newAppointmentUIState.isBtnVideoHidden != "No"{
                    Button(action: {
                        slot?.appointmentType = "Video"
                    }) {
                        VStack{
                            if slot?.appointmentType == "Video"{
                                CachedAsyncImage(
                                    url: URL(string: UIStateAppoint.newAppointmentUIState.btnVideoSelected),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    })
                            }else{
                                CachedAsyncImage(
                                    url: URL(string: UIStateAppoint.newAppointmentUIState.btnVideoEnable),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    })
                            }
                            Text(UIStateAppoint.newAppointmentUIState.btnVideo.text)
                                .padding(.margin / 2)
                                .font(Font.custom(UIStateAppoint.newAppointmentUIState.btnVideo.font, size: CGFloat(Int(UIStateAppoint.newAppointmentUIState.btnVideo.size) ?? 18)))
                                .foregroundColor(Color(hex: UIStateAppoint.newAppointmentUIState.btnVideo.textColor))
                        }
                        
                    }
                }
                Spacer()
                
            }
        }
    }
}

// MARK: Network Requests

extension NewAppointmentSelectDetailsView {
    func selectAvailableSlot() {
        Task {
            isLoading = true
            let result = await Network.shared.getFirstAvailableAppointment(clinic: clinic, professionals: professionals, monthOffset: calendarMonthOffset)
            switch result {
            case let .success(slots):
                print(slots)
                guard let firstSlot = slots.first else {
                    self.calendarMonthOffset += 1
                    selectAvailableSlot()
                    return
                }
                
                for professional in self.professionals {
                    if professional.serviceResourceId == firstSlot.resources.first?.id {
                        self.professional = professional
                    }
                }
                await getProfessionalAvailableDatesForCurrentMonth()
                await MainActor.run {
                    self.isLoading = false
                    self.date = firstSlot.startDate
                    self.slot = firstSlot
                }
            case let .failure(error):
                await MainActor.run {
                    AppStatusManager.error(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    func getProfessionals() {
        Task {
            // 🔥 FIREBASE LOGGING: Inicio de carga de profesionales
            FirebaseLogger.shared.log("🔄 Cargando profesionales para clínica: \(clinic.name)")
            
            let result = await Network.shared.getProfessionalsByClinic(id: clinic.id)
            switch result {
            case let .success(professionals):
                // 🔥 FIREBASE LOGGING: Éxito
                FirebaseLogger.shared.log("✅ Profesionales cargados: \(professionals.count)")
                self.professionals = professionals
                
            case let .failure(error):
                // 🔥 FIREBASE LOGGING: Error con contexto de red
                FirebaseLogger.shared.log("❌ Error al cargar profesionales: \(error.localizedDescription)")
                FirebaseLogger.shared.recordNetworkError(
                    error,
                    endpoint: "/api/professionals/clinic/\(clinic.id ?? "unknown")",
                    httpCode: (error as? AppError)?.httpCode,
                    method: "GET"
                )
                FirebaseLogger.shared.setCustomValues([
                    "clinic_id": clinic.id ?? "N/A",
                    "clinic_name": clinic.name,
                    "error_context": "load_professionals"
                ])
                
                AppStatusManager.error(error)
            }
        }
    }
    
    func getProfessionalAvailableDatesForCurrentMonth() async {
        guard let professional else {
            return
        }
        isLoading = true
        
        // 🔥 FIREBASE LOGGING: Inicio de carga de disponibilidad
        FirebaseLogger.shared.log("🔄 Cargando disponibilidad para: \(professional.name)")
        
        let result = await Network.shared.getProfessionalsAvailability(clinic: clinic, professional: professional, monthOffset: calendarMonthOffset)
        isLoading = false
        switch result {
        case let .success(slots):
            // 🔥 FIREBASE LOGGING: Éxito
            FirebaseLogger.shared.log("✅ Slots disponibles cargados: \(slots.count)")
            
            var updatedSlots = slots
                .filter { !self.slots.contains($0) }
            updatedSlots.append(contentsOf: self.slots)
            updatedSlots.sort()
            self.slots = updatedSlots
            
        case let .failure(error):
            // 🔥 FIREBASE LOGGING: Error con contexto de red
            FirebaseLogger.shared.log("❌ Error al cargar disponibilidad: \(error.localizedDescription)")
            FirebaseLogger.shared.recordNetworkError(
                error,
                endpoint: "/api/professionals/\(professional.id)/availability",
                httpCode: (error as? AppError)?.httpCode,
                method: "GET"
            )
            FirebaseLogger.shared.setCustomValues([
                "professional_id": professional.id,
                "professional_name": professional.name,
                "clinic_id": clinic.id ?? "N/A",
                "month_offset": calendarMonthOffset,
                "error_context": "load_availability"
            ])
            
            AppStatusManager.error(error)
        }
    }
    
    func createAppointment() {
        Task {
            guard let rut = AppStatusManager.rut, let professional, let slot else {
                return
            }
            popup = nil
            
            // 🔥 FIREBASE LOGGING: Validación de cita duplicada en clínica
            if checkPreviusAppoitnmentForConfirmedOrScheduledClinic(){
                FirebaseLogger.shared.log("⚠️ Validación fallida: Cita duplicada en clínica - \(clinic.name)")
                FirebaseLogger.shared.logAlert(
                    title: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.text,
                    message: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.text,
                    source: "NewAppointmentSelectDetailsView - checkClinicDuplicate"
                )
                FirebaseLogger.shared.setCustomValues([
                    "validation_type": "clinic_duplicate",
                    "clinic_id": id,
                    "clinic_name": clinic.name
                ])
                
                self.isShowingPopupPerClinic = true
                return
            }
            
            // 🔥 FIREBASE LOGGING: Validación de cita duplicada en horario
            if checkPreviusAppoitnmentForConfirmedOrScheduledHour(){
                FirebaseLogger.shared.log("⚠️ Validación fallida: Cita duplicada en horario")
                FirebaseLogger.shared.logAlert(
                    title: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.text,
                    message: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.text,
                    source: "NewAppointmentSelectDetailsView - checkHourDuplicate"
                )
                FirebaseLogger.shared.setCustomValues([
                    "validation_type": "hour_duplicate",
                    "slot_start": slot.startDate.ISO8601Format()
                ])
                
                self.isShowingPopupPerHour = true
                return
            }
            isLoading = true

            // 🔍 NUEVA VALIDACIÓN DESDE FUNCIÓN EXTERNA
            let isValid = await validateProfessionalAvailability()
            guard isValid else {
                isLoading = false
                
                // 🔥 FIREBASE LOGGING: Popup de disponibilidad no válida
                let title = UIStateAppoint.popupCantAgendAppointment.title.text
                let message = UIStateAppoint.popupCantAgendAppointment.msg.text
                
                FirebaseLogger.shared.log("❌ Validación fallida: Profesional no disponible")
                FirebaseLogger.shared.logErrorPopup(
                    title: title,
                    message: message,
                    source: "NewAppointmentSelectDetailsView - validateAvailability"
                )
                FirebaseLogger.shared.setCustomValues([
                    "validation_type": "professional_unavailable",
                    "professional_id": professional.id,
                    "professional_name": professional.name,
                    "clinic_id": clinic.id ?? "N/A",
                    "slot_start": slot.startDate.ISO8601Format()
                ])
                
                popup = .init(
                    image: UIStateAppoint.popupCantAgendAppointment.img,
                    title: title,
                    message: message,
                    actionTitle: UIStateAppoint.popupCantAgendAppointment.btn.text,
                    action: {
                        self.professional = nil
                        self.date = nil
                        self.slot = nil
                    },
                    UIStateTitle: UIStateAppoint.popupCantAgendAppointment.title,
                    UIStateMessage: UIStateAppoint.popupCantAgendAppointment.msg,
                    UIStateButton: UIStateAppoint.popupCantAgendAppointment.btn,
                    UIStateCancelButton: nil
                )
                return
            }
            var previousAppointment = checkPreviusAppoitnment()
            
            // 🔥 FIREBASE LOGGING: Inicio de creación de cita
            FirebaseLogger.shared.log("📅 Iniciando creación de cita")
            FirebaseLogger.shared.logEvent("appointment_create_started", attributes: [
                "clinic_id": clinic.id ?? "N/A",
                "clinic_name": clinic.name,
                "professional_id": professional.id,
                "professional_name": professional.name,
                "is_replacement": previousAppointment != nil ? "true" : "false"
            ])
            
            let result: Result<Alamofire.Empty, AppError>
            if let previousAppointment = previousAppointment {
                result = await Network.shared.replaceAppointment(
                    previousAppointment: previousAppointment,
                    rut: rut,
                    clinic: clinic,
                    professional: professional,
                    slot: slot
                )
            } else {
                result = await Network.shared.createAppointment(
                    rut: rut,
                    clinic: clinic,
                    professional: professional,
                    slot: slot
                )
            }
            isLoading = false
            switch result {
            case .success:
                // 🔥 FIREBASE LOGGING: Cita creada exitosamente
                FirebaseLogger.shared.log("✅ Cita creada exitosamente")
                FirebaseLogger.shared.logEvent("appointment_created_success", attributes: [
                    "clinic_id": clinic.id ?? "N/A",
                    "clinic_name": clinic.name,
                    "professional_id": professional.id,
                    "professional_name": professional.name,
                    "slot_start": slot.startDate.ISO8601Format(),
                    "was_replacement": previousAppointment != nil ? "true" : "false"
                ])
                
                popup = .init(
                    image: UIStateAppoint.popupAppointmentUIState.iconCheck,
                    title: previousAppointment == nil ? UIStateAppoint.popupAppointmentUIState.agend.text1 : UIStateAppoint.popupAppointmentUIState.modifier.text1,
                    message: previousAppointment == nil ? UIStateAppoint.popupAppointmentUIState.agend.text2 : "Usted ya tenia una cita agendada. La misma fue cancelada y se agendó una nueva cita. Recuerde que debe confirmar su turno 48hs previas para no perder la cita agendada.",
                    actionTitle: UIStateAppoint.popupAppointmentUIState.agend.btnOk,
                    action: {
                        
                        self.dismiss()
                        self.publisher.send()
                        if selectedTab == .appointments{
                            rootPresentation.dismiss()
                        }
                        
                        
                    },
                    UIStateTitle: UIStateAppoint.popupAppointmentUIState.titleTxt,
                    UIStateMessage: UIStateAppoint.popupAppointmentUIState.textAtr,
                    UIStateButton: UIStateAppoint.popupAppointmentUIState.btnConfirm,
                    UIStateCancelButton: UIStateAppoint.popupAppointmentUIState.btnCancel
                )
                
            case let .failure(error):
                // 🔥 FIREBASE LOGGING: Error al crear cita con contexto completo
                FirebaseLogger.shared.log("❌ Error al crear cita: \(error.localizedDescription)")
                FirebaseLogger.shared.logAppointmentError(
                    action: previousAppointment != nil ? "replace" : "create",
                    appointmentId: previousAppointment?.id,
                    error: error
                )
                FirebaseLogger.shared.setCustomValues([
                    "clinic_id": clinic.id ?? "N/A",
                    "clinic_name": clinic.name,
                    "professional_id": professional.id,
                    "professional_name": professional.name,
                    "slot_start": slot.startDate.ISO8601Format()
                ])
                
                AppStatusManager.error(error)
            }
        }
        func checkPreviusAppoitnment() -> Appointment? {
            for appoint in self.previousAppointment{
                if appoint.workTypeGroup == self.id {
                    // ✅ Solo consideramos como "cita existente" los 3 estados activos
                    // Los estados inactivos NO deben tratarse como reemplazo
                    if appoint.status.rawValue == "A Confirmar" || 
                       appoint.status.rawValue == "Programado" || 
                       appoint.status.rawValue == "Confirmado" {
                        return appoint
                    }
                }
            }
            return nil
        }
        func checkPreviusAppoitnmentForConfirmedOrScheduledClinic() -> Bool {
            for appoint in self.previousAppointment{
                if appoint.workTypeGroup == self.id {
                    // ✅ Solo estos 3 estados bloquean el agendamiento
                    if appoint.status.rawValue == "A Confirmar" || 
                       appoint.status.rawValue == "Programado" || 
                       appoint.status.rawValue == "Confirmado"{
                        return true
                    }
                }
            }
            return false
        }
        func checkPreviusAppoitnmentForConfirmedOrScheduledHour() -> Bool {
            for appoint in self.previousAppointment{
                if appoint.date == self.slot?.startDate {
                    // ✅ Solo estos 3 estados bloquean el agendamiento
                    if appoint.status.rawValue == "A Confirmar" || 
                       appoint.status.rawValue == "Programado" || 
                       appoint.status.rawValue == "Confirmado"{
                        if let matched = clinicObjects.first(where: { $0.id == appoint.workTypeGroup }) {
                            self.clinicName = matched.name
                            
                        }else{
                            self.clinicName = appoint.clinica
                        }
                        return true
                    }
                }
            }
            return false
        }

    }
    private func validateProfessionalAvailability() async -> Bool {
        guard let rut = AppStatusManager.rut, let professional, let slot else {
            return false
        }

        let validationResult = await Network.shared.getValidationProfessionalsAvailability(
            clinic: clinic,
            professional: professional,
            slot: slot
        )

        switch validationResult {
        case .success(let result):
            print("✅ Validación OK \(result)")
            if result.count == 0 {
                return false
            }else{
                return true
            }
        case .failure(let error):
            print("❌ Falló validación: \(error)")
            return false
        }
    }
    var appointmentClinicAllreadyExist: Popup {
        .init(
            title: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title.text,
            message: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg.text,
            actionTitle: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn.text,
            action: {
            },
            isCancellable: false,
            UIStateTitle: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.title,
            UIStateMessage: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.msg,
            UIStateButton: UIStateAppoint.popupAllreadyHaveAppointmentPerClinic.btn,
            UIStateCancelButton: nil
        )
    }
    var appointmentHourAllreadyExist: Popup {
        .init(
            title: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title.text,
            message: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg.text,
            actionTitle: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn.text,
            action: {
            },
            isCancellable: false,
            UIStateTitle: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.title,
            UIStateMessage: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.msg,
            UIStateButton: UIStateAppoint.popupAllreadyHaveAppointmentPerHour.btn,
            UIStateCancelButton: nil
        )
    }
    
    func validatePopupConsent(){
        if isConsent ?? false {
            for popups in popupConsent {
                if popups.clinicId == self.id{
                    isShowConsentPopup.toggle()
                    return
                }
            }
            createAppointment()
        }else{
            createAppointment()
        }
        
    }
    
    // MARK: - Ficha Clínica General
    
    /// Verifica si debe mostrar el formulario de Ficha Clínica General en esta vista
    /// NOTA: A diferencia de HomeView, aquí SIEMPRE consultamos el servidor (ignoramos el flag local)
    /// porque esta pantalla es la barrera obligatoria para agendar. Si el usuario borró la ficha
    /// desde Salesforce sin cerrar sesión, el flag quedaría stale y nunca mostraríamos el modal.
    private func checkFichaClinicaGeneralInAgendamiento() async {
        print("🔍 [NewAppointmentSelectDetailsView] Iniciando verificación de Ficha Clínica General")
        
        // 📝 IMPORTANTE: A diferencia de HomeView, NO usamos el flag como gate aquí
        let flagLocal = UserDefaults.standard.bool(forKey: "ficha_clinica_completada")
        print("ℹ️ [NewAppointmentSelectDetailsView] Flag local ficha_clinica_completada=\(flagLocal) (ignorado como gate)")
        
        // Paso 1: Leer BrandAccount de CACHÉ LOCAL (sin HTTP request)
        // El BrandAccount ya fue descargado en HomeView y está en memoria/Realm
        guard let brandAccountCached = items.first else {
            print("⚠️ [NewAppointmentSelectDetailsView] No hay BrandAccount en caché local (Realm)")
            return
        }
        
        print("✅ [NewAppointmentSelectDetailsView] BrandAccount leído de caché local (sin HTTP)")
        print("   • Total registros en caché: \(brandAccountCached.records.count)")
        
        // Buscar "FormularioGeneral" en caché
        var foundRecord: BrandAccount?
        for record in brandAccountCached.records {
            let name = record.Name ?? ""
            if name == "FormularioGeneral" {
                foundRecord = record
                break
            }
        }
        
        guard let formularioRecord = foundRecord else {
            print("⚠️ [NewAppointmentSelectDetailsView] No se encontró 'FormularioGeneral' en BrandAccount caché")
            return
        }
        
        print("✅ [NewAppointmentSelectDetailsView] FormularioGeneral encontrado en caché")
        print("   • Atributo_1_1__c: \(formularioRecord.atributo11C ?? "nil")")
        print("   • Valor_1_1__c: \(formularioRecord.valor11C ?? "nil")")
        
        // Verificar si MostrarFormularioGeneral == "Si"
        let atributo = formularioRecord.atributo11C ?? ""
        let valor = formularioRecord.valor11C ?? ""
        let debeVerificar = (atributo == "MostrarFormularioGeneral") && (valor.lowercased() == "si")
        
        guard debeVerificar else {
            print("ℹ️ [NewAppointmentSelectDetailsView] MostrarFormularioGeneral != 'Si' → No verificar ficha")
            return
        }
        
        print("✅ [NewAppointmentSelectDetailsView] MostrarFormularioGeneral='Si' → Continuar verificación")
        
        // Guardar el formulario parseado para usarlo después si es necesario
        self.brandAccountFormularioGeneral = formularioRecord
        if let formulario = FormularioGeneralParser.parse(from: formularioRecord) {
            self.formularioParsed = formulario
            print("✅ [NewAppointmentSelectDetailsView] Formulario parseado desde caché (\(formulario.preguntas.count) preguntas)")
        } else {
            print("⚠️ [NewAppointmentSelectDetailsView] No se pudo parsear formulario desde caché")
            return
        }
        
        // Paso 2: SIEMPRE consultar al servidor (ignorar flag local)
        guard let accountId = UserDefaults.standard.string(forKey: "account_id"), !accountId.isEmpty else {
            print("⚠️ [NewAppointmentSelectDetailsView] No hay account_id para consultar ficha clínica")
            return
        }
        
        print("📡 [NewAppointmentSelectDetailsView] 🌐 Consultando servidor SIEMPRE (flag=\(flagLocal), ignorado aquí)")
        print("   • Motivo: Esta pantalla es la barrera obligatoria para agendar")
        print("   • Si el usuario borró la ficha desde Salesforce, el flag quedaría stale")
        await checkFichaClinicaExistente(accountId: accountId)
    }
    
    /// Verifica si el usuario ya tiene una ficha clínica en el servidor
    private func checkFichaClinicaExistente(accountId: String) async {
        print("🔄 [NewAppointmentSelectDetailsView.FichaClinica] Consultando function_filter...")
        print("   • account_id: \(accountId)")
        
        let result = await Network.shared.fichaClinicaGeneralService(accountId: accountId)
        
        switch result {
        case .success(let response):
            let countBlocks = response.data.count
            print("✅ [NewAppointmentSelectDetailsView.FichaClinica] Respuesta OK. data.count=\(countBlocks)")
            
            if let first = response.data.first {
                let fichaArray = first["Ficha_Clinica_General__c"] ?? []
                let count = fichaArray.count
                print("📦 [NewAppointmentSelectDetailsView.FichaClinica] Ficha_Clinica_General__c count=\(count)")
                applyFinalDecisionAgendamiento(fichaArrayCount: count)
            } else {
                print("ℹ️ [NewAppointmentSelectDetailsView.FichaClinica] data.first es nil. Asumimos fichaArray vacío")
                applyFinalDecisionAgendamiento(fichaArrayCount: 0)
            }
            
        case .failure(let error):
            print("❌ [NewAppointmentSelectDetailsView.FichaClinica] Error en function_filter: \(error)")
            applyFinalDecisionAgendamiento(fichaArrayCount: 0)
        }
    }
    
    /// Aplica la lógica de decisión final para mostrar el formulario
    /// NOTA: Aquí SÍ actualizamos el flag local, pero solo DESPUÉS de consultar el servidor
    private func applyFinalDecisionAgendamiento(fichaArrayCount: Int?) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("⚖️ [NewAppointmentSelectDetailsView.Decision] Evaluando decisión basada en servidor")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        guard let count = fichaArrayCount else {
            print("⚠️ [NewAppointmentSelectDetailsView.Decision] fichaArrayCount es nil → No mostrar modal")
            self.mostrarFormularioGeneral = false
            return
        }
        
        print("📊 [NewAppointmentSelectDetailsView.Decision] fichaArrayCount=\(count) (del servidor)")
        
        if count > 0 {
            // Usuario YA tiene ficha clínica en el servidor
            print("✅ [NewAppointmentSelectDetailsView.Decision] Usuario tiene \(count) ficha(s) → Actualizar flag local")
            UserDefaults.standard.set(true, forKey: "ficha_clinica_completada")
            self.mostrarFormularioGeneral = false
            print("🟢 [NewAppointmentSelectDetailsView.Decision] mostrarFormularioGeneral=false (puede agendar sin modal)")
        } else {
            // Usuario NO tiene ficha clínica en el servidor → BLOQUEAR con modal OBLIGATORIO
            print("⚠️ [NewAppointmentSelectDetailsView.Decision] Usuario NO tiene ficha → Modal OBLIGATORIO")
            UserDefaults.standard.set(false, forKey: "ficha_clinica_completada")
            
            // Verificar que el formulario esté parseado
            guard self.formularioParsed != nil else {
                print("❌ [NewAppointmentSelectDetailsView.Decision] Formulario no parseado → No mostrar modal")
                self.mostrarFormularioGeneral = false
                return
            }
            
            self.mostrarFormularioGeneral = true
            print("🟢 [NewAppointmentSelectDetailsView.Decision] mostrarFormularioGeneral=true (MODAL OBLIGATORIO para agendar)")
        }
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    
    /// Handler cuando el usuario completa el formulario
    @MainActor
    private func handleFormularioComplete(respuestas: [String: Any], formulario: FormularioGeneral) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 [NewAppointmentSelectDetailsView.Formulario] Respuestas recibidas del formulario")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        guard let nombreFlujo = formulario.nombreFlujoServicio else {
            print("❌ [NewAppointmentSelectDetailsView.Formulario] No hay nombreFlujoServicio en el formulario")
            return
        }
        
        // Reconstruir el diccionario correcto desde el FormularioGeneralView
        // El formulario viene con estructura: ["pregunta_1": {...}, "pregunta_2": {...}]
        // Necesitamos convertirlo a [UUID: RespuestaPregunta]
        
        var respuestasTyped: [UUID: RespuestaPregunta] = [:]
        
        for (index, pregunta) in formulario.preguntas.enumerated() {
            let key = "pregunta_\(index + 1)"
            
            // Obtener el diccionario de la respuesta
            guard let respuestaDict = respuestas[key] as? [String: Any] else {
                print("⚠️ [NewAppointmentSelectDetailsView.Formulario] No se encontró respuesta para \(key)")
                continue
            }
            
            // Reconstruir RespuestaPregunta desde el diccionario
            // NOTA: opcionesSeleccionadas ahora viene como String (formato "Opcion1;Opcion2;Opcion3")
            let opcionesString = respuestaDict["opcionesSeleccionadas"] as? String ?? ""
            let opcionesArray = opcionesString.isEmpty ? [] : opcionesString.components(separatedBy: ";")
            
            let textoLibre = respuestaDict["textoLibre"] as? String ?? ""
            let campoCondicional = respuestaDict["campoCondicional"] as? String ?? ""
            
            let respuesta = RespuestaPregunta(
                opcionesSeleccionadas: opcionesArray,
                textoLibre: textoLibre,
                campoCondicional: campoCondicional
            )
            
            respuestasTyped[pregunta.id] = respuesta
            
            print("   ✓ Pregunta \(index + 1): \(pregunta.texto)")
            if !opcionesArray.isEmpty {
                print("     - Opciones: \(opcionesArray.joined(separator: ", "))")
            }
            if !textoLibre.isEmpty {
                print("     - Texto libre: \(textoLibre)")
            }
            if !campoCondicional.isEmpty {
                print("     - Campo condicional: \(campoCondicional)")
            }
        }
        
        print("📤 [NewAppointmentSelectDetailsView.Formulario] Enviando formulario al servidor...")
        print("   • Nombre del flujo: \(nombreFlujo)")
        print("   • Preguntas: \(formulario.preguntas.count)")
        print("   • Respuestas reconstruidas: \(respuestasTyped.count)")
        
        Task {
            self.isLoading = true
            
            let result = await Network.shared.postFichaClinicaGeneral(
                nombreFlujo: nombreFlujo,
                preguntas: formulario.preguntas,
                respuestas: respuestasTyped
            )
            
            await MainActor.run {
                self.isLoading = false
                
                switch result {
                case .success:
                    print("✅ [NewAppointmentSelectDetailsView.Formulario] Ficha clínica enviada exitosamente")
                    self.mostrarFormularioGeneral = false
                    print("💾 [NewAppointmentSelectDetailsView.Formulario] Modal cerrado y flag guardado")
                    
                case .failure(let error):
                    print("❌ [NewAppointmentSelectDetailsView.Formulario] Error al enviar ficha clínica: \(error)")
                    // Falla silenciosamente, el modal permanece abierto
                }
            }
        }
    }
    
    
    struct PopupView: View {
        @Binding var showCustomPopup: Bool
        @Binding var clinicName: String
        let popupData: PopupAllreadyHaveAppointment
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 10)
                VStack(spacing: 5){
                    Text(popupData.title.text.htmlToString())
                        .font(Font.custom(popupData.title.font, size: CGFloat(Int(popupData.title.size) ?? 18)))
                        .foregroundColor(Color(hex: popupData.title.color))
                        .multilineTextAlignment(popupData.title.alignment == "center" ? .center : .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    if popupData.msg2 != ""{
                        Text(.init("\(popupData.msg.text) **\(clinicName)** \(popupData.msg2.htmlToString())"))
                            .font(Font.custom(popupData.msg.font, size: CGFloat(Int(popupData.msg.size) ?? 18)))
                            .foregroundColor(Color(hex: popupData.msg.color))
                            .multilineTextAlignment(popupData.msg.alignment == "center" ? .center : .leading)
                        
                    }else{
                        Text(.init(popupData.msg.text.htmlToString()))
                            .font(Font.custom(popupData.msg.font, size: CGFloat(Int(popupData.msg.size) ?? 18)))
                            .foregroundColor(Color(hex: popupData.msg.color))
                            .multilineTextAlignment(popupData.msg.alignment == "center" ? .center : .leading)
                            
                    }
                    
                    Button {
                        self.showCustomPopup = false
                    } label: {
                        Text(popupData.btn.text)
                            .font(Font.custom(popupData.btn.font, size: CGFloat(Int(popupData.btn.size) ?? 18)))
                            .foregroundColor(Color(hex: popupData.btn.color))
                            .padding()
                    }
                }
                .padding()
            }
            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: 300)
        }
    }
    struct PopupConsentView: View {
        let popupData: PopupConsent
        @Binding var showConsentPopup: Bool
        @Binding var isCreateAppointment: Bool
        @State private var hasScrolledToBottom = false
        @State private var contentHeight: CGFloat = 0
        @State private var scrollViewHeight: CGFloat = 0

        var body: some View {
            ZStack {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    CachedAsyncImage(
                            url: URL(string: popupData.logo),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 60)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )

                    Text(popupData.title.text)
                        .font(Font.custom(popupData.title.font?.font ?? "", size: CGFloat(Int(popupData.title.size) ?? 18)))
                        .foregroundColor(Color(hex: popupData.title.color))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(.init(popupData.consentText.text))
                                .font(Font.custom(popupData.consentText.font?.font ?? "", size: CGFloat(Int(popupData.consentText.size) ?? 16)))
                                .foregroundColor(Color(hex: popupData.consentText.color))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            Color.clear
                                .frame(height: 1)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onChange(of: geo.frame(in: .global).minY) { minY in
                                                let screenHeight = UIScreen.main.bounds.height
                                                if minY < (screenHeight - 150) {
                                                    hasScrolledToBottom = true
                                                }
                                            }
                                    }
                                )
                        }
                        .padding()
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        contentHeight = geo.size.height
                                        isCreateAppointment = false
                                    }
                            }
                        )
                    }
                    .frame(
                        maxHeight: contentHeight < 300 ? contentHeight : 300
                    )

                    .onChange(of: contentHeight) { _ in
                        if contentHeight <= scrollViewHeight {
                            hasScrolledToBottom = true
                        }
                    }
                    .onChange(of: scrollViewHeight) { _ in
                        if contentHeight <= scrollViewHeight {
                            hasScrolledToBottom = true
                        }
                    }

                    HStack {
                        Button {
                            showConsentPopup.toggle()
                            isCreateAppointment = true
                        } label: {
                            Text(popupData.btnAcept.textBtn)
                                .foregroundColor(Color(hex: popupData.btnAcept.colorTextBtn))
                                .bold()
                                .padding(10)
                                .background(hasScrolledToBottom ? Color(hex: popupData.btnAcept.backgroundBtn) : Color.gray.opacity(0.5))
                                .cornerRadius(8)
                        }
                        .disabled(!hasScrolledToBottom)
                        
                        Spacer()
                        
                        Button {
                            showConsentPopup = false
                        } label: {
                            Text(popupData.btnCancel.textBtn)
                                .foregroundColor(Color(hex: popupData.btnCancel.colorTextBtn))
                                .bold()
                                .padding(10)
                                .background(Color(hex: popupData.btnCancel.backgroundBtn))
                                .cornerRadius(8)
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                .frame(maxWidth: 350)
                .frame(minHeight: 100, maxHeight: UIScreen.main.bounds.height * 0.7)
            }
        }
    }
}

