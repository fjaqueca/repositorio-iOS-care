//
//  NewAppointmentUpdateDetailsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 27/10/2022.
//

import SwiftUI
import RealmSwift
import Introspect
import AVFoundation
import TwilioVideo

struct AppointmentDetailsView: View {
    @Environment(\.rootPresentation) private var rootPresentation
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @ObservedRealmObject var appointment: Appointment
    @ObservedResults(User.self) var users
    @State var customName: String = ""
    @State private var showEmailPhone: Bool = false
    @State private var showModifyAppointment: Bool = false
    @State private var showVideoCall: Bool = false
    @State private var showProfileUpdateInformation: Bool = false
    @State private var isVideoCallButtonEnabled = false
    @State private var isLoading: Bool = false
    @State private var popup: Popup?
    @State var now = Date()
    
    // NUEVO: Estado para deshabilitar botón "Cancelar" según hora de la cita
    @State private var isCancelButtonEnabledByTime = true
    
    // Timer cada 5 segundos para revisar estado de botones (videollamada + cancelar)
    let timer = Timer.publish(every: 5, on: .current, in: .common).autoconnect()
    
    var isConfirmed: Bool {
        switch appointment.status{
        case .programado:
            return false
        case .confirmado:
            return true
        case .cancelado:
            return true
        case .noConfirmado:
            return true
        case .noRealizado:
            return true
        case .realizado:
            return true
        case .reagendado:
            return true
        case .aConfirmar:
            return false
        case .failure:
            return true
        }
    }
    
    var isCanceled: Bool {
        switch appointment.status{
        case .programado:
            return false
        case .confirmado:
            return false
        case .cancelado:
            return true
        case .noConfirmado:
            return true
        case .noRealizado:
            return true
        case .realizado:
            return true
        case .reagendado:
            return true
        case .aConfirmar:
            return false
        case .failure:
            return true
        }
    }
    
    /// NUEVO: Determina si el botón cancelar debe estar habilitado según el STATUS de la cita
    /// LÓGICA ANDROID (Paso 1): Estado inicial según status de la cita
    var isCancelButtonEnabledByStatus: Bool {
        switch appointment.status {
        case .programado, .aConfirmar, .confirmado:
            return true // ✅ Estados activos: botón habilitado
        case .cancelado, .reagendado, .realizado, .noRealizado, .failure, .noConfirmado:
            return false // ❌ Estados inactivos: botón deshabilitado
        }
    }
    
    var dateFormat: Date.FormatStyle {
        .init(
            date: .complete,
            time: .shortened,
            locale: .init(identifier: "es_419"),
            calendar: .current,
            timeZone: .current,
            capitalizationContext: .beginningOfSentence
        )
    }
    
    /// Ícono SF Symbol según tipo de cita
    private var detailTypeIcon: String {
        switch appointment.appointmentType {
        case .video: return "video.fill"
        case .phone: return "phone.fill"
        default: return "calendar"
        }
    }

    /// Color del status como en el row
    private var statusColor: Color {
        switch appointment.status {
        case .confirmado: return Color.darkGreen
        case .noConfirmado, .programado, .aConfirmar: return Color.orangeText
        case .cancelado: return Color.negativeSentiment
        case .realizado, .noRealizado, .reagendado, .failure: return Color.black
        }
    }

    var body: some View {
        VStack(spacing: 0) {
        ScrollView {
            VStack(spacing: 16) {
                // ══════════════════════════════════════
                // MARK: - Card principal de info
                // ══════════════════════════════════════
                VStack(alignment: .leading, spacing: 14) {
                    // Header: ícono + título + badge status
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#00BBDC").opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: detailTypeIcon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#00BBDC"))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cita \(customName != "" ? customName : appointment.clinica)")
                                .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.clinicsAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.clinicsAtr.size) ?? 18)))
                                .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.clinicsAtr.color))
                                .lineLimit(2)
                            Text("\(appointment.date.formatted(dateFormat))hs.")
                                .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.dateAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.dateAtr.size) ?? 14)))
                                .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.dateAtr.color))
                        }

                        Spacer()

                        // Badge status
                        Text(appointment.status.description)
                            .font(Font.custom("FiraSans-Medium", size: 11))
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(statusColor.opacity(0.12)))
                    }

                    Divider()

                    // Tipo de cita
                    HStack(spacing: 8) {
                        Image(systemName: detailTypeIcon)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.tipeAtr.color))
                        Text("\(appointment.appointmentType.description)")
                            .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.tipeAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.tipeAtr.size) ?? 14)))
                            .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.tipeAtr.color))
                    }

                    // Mensaje personalizado
                    Text("\(UIStateAppoint.detaillAppointmentUIState.textVideo1) **\(users.first?.records.first?.FirstName ?? "")**,")
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 15)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))

                    if !isConfirmed {
                        Text("Usted contará con una consulta con **\(appointment.professionalName)**, por favor confirmar la fecha y hora para mantener la vigencia del turno.")
                            .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 15)))
                            .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                    } else {
                        Text(appointment.appointmentType == .video ? "\(UIStateAppoint.detaillAppointmentUIState.textVideo2) **\(appointment.professionalName)** \(UIStateAppoint.detaillAppointmentUIState.textVideo3)" : "\(UIStateAppoint.detaillAppointmentUIState.textPhone1)")
                            .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 15)))
                            .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                    }

                    if appointment.appointmentType == .phone && (users.first?.records.first?.Phone == nil || users.first?.records.first?.Phone == "") {
                        Text("Por favor ingrese su número telefónico. Para hacerlo debe ingresar a perfil, luego a [datos personales](http://user-profile.com). Ingresar su número telefónico y apretar enviar.")
                            .environment(\.openURL, .init(handler: { _ in
                                self.showProfileUpdateInformation = true
                                return .handled
                            }))
                            .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 15)))
                            .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                    } else if appointment.appointmentType == .phone {
                        Text("\(UIStateAppoint.detaillAppointmentUIState.textPhone2) **\(users.first?.records.first?.Phone ?? "")**. \(UIStateAppoint.detaillAppointmentUIState.textPhone3) [\(UIStateAppoint.detaillAppointmentUIState.textPhone4)](http://user-profile.com) \(UIStateAppoint.detaillAppointmentUIState.textPhone5)")
                            .environment(\.openURL, .init(handler: { _ in
                                self.showProfileUpdateInformation = true
                                return .handled
                            }))
                            .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 15)))
                            .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                    }
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                .springOnAppear(delay: 0.05)

                // ══════════════════════════════════════
                // MARK: - Card videollamada (si aplica)
                // ══════════════════════════════════════
                Group {
                    if isConfirmed {
                        VStack(spacing: 12) {
                            if appointment.appointmentType == .video {
                                PrimaryButton(title: "Comenzar la videollamada", backgroundColor: .primaryText, UIStateBtn: UIStateAppoint.detaillAppointmentUIState.btnVideo, haveImage: true, action: {
                                    HapticManager.impact(style: .medium)
                                    showVideoCall = true
                                })
                                .bounceOnTap()
                                .disabled(!isVideoCallButtonEnabled)
                                .opacity(isVideoCallButtonEnabled ? 1.0 : 0.5)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onReceive(timer) { _ in
                                    now = Date()
                                    updateVideoCallButtonStatus()
                                    checkAndUpdateCancelButton()
                                }

                                Text(UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.text)
                                    .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.size) ?? 13)))
                                    .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.color.isEmpty ? "#999999" : UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.color))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray5), lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                }
                .springOnAppear(delay: 0.15)

            }
            .padding(.horizontal, .margin)
            .padding(.top, 12)
            .padding(.bottom, .margin)
        }

        // ══════════════════════════════════════
        // MARK: - Botones Confirmar / Cancelar (fijos abajo)
        // ══════════════════════════════════════
        VStack(spacing: 0) {
            Divider()
            buttonsView
                .padding(.horizontal, .margin)
                .padding(.top, 12)
                .springOnAppear(delay: 0.25)
        }
        .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            logAppointmentDetails()
            updateVideoCallButtonStatus()
            setupInitialCancelButtonState()
            checkAndUpdateCancelButton()
        }
        .slideInFromRight()
        .overlayView(isLoading)
        .navigationLink(isActive: $showModifyAppointment) {
//            NewAppointmentSelectDetailsView(previousAppointment: appointment)
        }
        .navigationLink(isActive: $showVideoCall) {
            AppointmentVideoCallView(appointment: appointment)
        }
        .navigationLink(isActive: $showProfileUpdateInformation) {
            ProfileUpdateInformation(isObligatori: $showEmailPhone)
        }
        .popup(item: $popup)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(UIStateAppoint.detaillAppointmentUIState.title.text)
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.title.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.title.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.title.color))
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    HapticManager.impact(style: .light)
                    rootPresentation.dismiss()
                } label: {
                    Image("back")
                        .renderingMode(.template)
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.title.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.title.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.title.color))
                }
            }
        }
        .navigationBarBackButtonHidden()
        .tabBarHidden(true)
    }
    
    @ViewBuilder
    private var buttonsView: some View {
        let cancelBtnState = UIStateAppoint.detaillAppointmentUIState.btnCancel
        let confirmBtnState = UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier
        let isCancelEnabled = !isCanceled && !isLoading && isCancelButtonEnabledByStatus && isCancelButtonEnabledByTime
        let isConfirmEnabled = !isConfirmed && !isLoading && !isCanceled

        HStack(spacing: 12) {
            // Cancelar (izquierda)
            Button {
                HapticManager.warning()
                if isCancelButtonEnabledByStatus && isCancelButtonEnabledByTime {
                    popup = cancellationConfirmationPopup
                }
            } label: {
                Text(cancelBtnState.textBtn.isEmpty ? "Cancelar cita" : cancelBtnState.textBtn)
                    .font(Font.custom(cancelBtnState.font.isEmpty ? "FiraSans-Bold" : cancelBtnState.font, size: 15))
                    .foregroundColor(Color(hex: cancelBtnState.colorTextBtn.isEmpty ? "#555555" : cancelBtnState.colorTextBtn))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#CCCCCC"), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .bounceOnTap()
            .disabled(!isCancelEnabled)
            .opacity(isCancelEnabled ? 1.0 : 0.5)

            // Confirmar (derecha)
            Button {
                HapticManager.success()
                confirmAppointment()
            } label: {
                Text(isConfirmed ? (UIStateAppoint.detaillAppointmentUIState.btnConfirm2.isEmpty ? "Confirmada" : UIStateAppoint.detaillAppointmentUIState.btnConfirm2) : (UIStateAppoint.detaillAppointmentUIState.btnConfirm1.isEmpty ? "Confirmar" : UIStateAppoint.detaillAppointmentUIState.btnConfirm1))
                    .font(Font.custom(confirmBtnState.font.isEmpty ? "FiraSans-Bold" : confirmBtnState.font, size: 15))
                    .foregroundColor(Color(hex: confirmBtnState.colorTextBtn.isEmpty ? "#FFFFFF" : confirmBtnState.colorTextBtn))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isConfirmEnabled
                                ? Color(hex: confirmBtnState.backgroundBtn.isEmpty ? "#00BBDC" : confirmBtnState.backgroundBtn)
                                : Color(hex: confirmBtnState.backgroundPressBtn.isEmpty ? "#E9E9EB" : confirmBtnState.backgroundPressBtn))
                    )
            }
            .buttonStyle(.plain)
            .bounceOnTap()
            .disabled(!isConfirmEnabled)
            .opacity(isConfirmEnabled ? 1.0 : 0.7)
        }
        .padding(.bottom, .margin)
    }
}

// MARK: - Actions

extension AppointmentDetailsView {
    /// 📝 NUEVO: Log detallado de la cita al abrir el detalle
    func logAppointmentDetails() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [AppointmentDetailsView] Datos de la cita")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   • id: \(appointment.id)")
        print("   • status: \(appointment.status.rawValue) (\(appointment.status.description))")
        print("   • schedStartTime: \(appointment.schedStartTime)")
        print("   • schedEndTime: \(appointment.schedEndTime)")
        print("   • professionalName: \(appointment.professionalName)")
        print("   • clinica: \(appointment.clinica)")
        print("   • workTypeGroup: \(appointment.workTypeGroup)")
        print("   • appointmentType: \(appointment.appointmentType.rawValue) (\(appointment.appointmentType.description))")
        print("   • serviceTerritoryId: \(appointment.serviceTerritoryId)")
        print("   • iconoAzul: \(appointment.iconoAzul)")
        print("")
        print("   📅 Fecha parseada (date property):")
        print("      • \(appointment.date)")
        print("")
        print("   🔍 Computed properties:")
        print("      • isConfirmed: \(isConfirmed)")
        print("      • isCanceled: \(isCanceled)")
        print("      • isCancelButtonEnabledByStatus: \(isCancelButtonEnabledByStatus)")
        print("")
        print("   📄 Representación completa del Appointment:")
        print("      {")
        print("        \"id\": \"\(appointment.id)\",")
        print("        \"status\": \"\(appointment.status.rawValue)\",")
        print("        \"schedStartTime\": \"\(appointment.schedStartTime)\",")
        print("        \"schedEndTime\": \"\(appointment.schedEndTime)\",")
        print("        \"professionalName\": \"\(appointment.professionalName)\",")
        print("        \"clinica\": \"\(appointment.clinica)\",")
        print("        \"workTypeGroup\": \"\(appointment.workTypeGroup)\",")
        print("        \"appointmentType\": \"\(appointment.appointmentType.rawValue)\",")
        print("        \"serviceTerritoryId\": \"\(appointment.serviceTerritoryId)\",")
        print("        \"iconoAzul\": \"\(appointment.iconoAzul)\"")
        print("      }")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
    
    func updateVideoCallButtonStatus() {
        let currentDate = Date()
        guard let tenMinutesBeforeTargetTime = Calendar.current.date(byAdding: .minute, value: -3, to: appointment.date),
              let oneHourAfterTargetTime = Calendar.current.date(byAdding: .hour, value: 1, to: appointment.date) else {
            return
        }

        if currentDate >= tenMinutesBeforeTargetTime && currentDate <= oneHourAfterTargetTime {
            isVideoCallButtonEnabled = true
        } else {
            isVideoCallButtonEnabled = false
        }
    }
    
    // MARK: - NUEVO: Lógica Android para deshabilitar botón "Cancelar"
    
    /// PASO 1 ANDROID: Estado inicial según status de la cita (onCreate)
    /// Se ejecuta en onAppear
    func setupInitialCancelButtonState() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔧 [CancelButton] Setup inicial")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   • Status: \(appointment.status.rawValue)")
        print("   • schedStartTime: \(appointment.schedStartTime)")
        
        // Estado inicial según status (equivalente a when en Kotlin)
        isCancelButtonEnabledByTime = isCancelButtonEnabledByStatus
        
        if isCancelButtonEnabledByStatus {
            print("   ✅ Status permite cancelación (Programado/A Confirmar/Confirmado)")
        } else {
            print("   ❌ Status NO permite cancelación (Cancelado/Reagendado/Realizado/etc)")
        }
        
        print("   • isCancelButtonEnabledByTime (inicial): \(isCancelButtonEnabledByTime)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
    
    /// PASO 4 & 5 ANDROID: Timer periódico + Comparación de hora (lógica central)
    /// Se ejecuta cada 5 segundos (equivalente a CountDownTimer en Android)
    func checkAndUpdateCancelButton() {
        // Solo revisar si el status permite cancelación
        guard isCancelButtonEnabledByStatus else {
            return
        }
        
        // PASO 2 & 3 ANDROID: Extracción de hora de la cita + offset
        guard let correctedApptDate = Date.fromSchedStartTime(appointment.schedStartTime) else {
            print("⚠️ [CancelButton] No se pudo parsear schedStartTime: \(appointment.schedStartTime)")
            return
        }
        
        // PASO 5 ANDROID: Comparación de hora (lógica central)
        let nowMillis = Date().timeIntervalSince1970
        let correctedApptMillis = correctedApptDate.timeIntervalSince1970
        
        print("⏰ [CancelButton] Check cada 5s:")
        print("   • Now (UTC): \(Date()) (\(nowMillis))")
        print("   • Appt corrected (UTC): \(correctedApptDate) (\(correctedApptMillis))")
        print("   • Diferencia: \(correctedApptMillis - nowMillis)s")
        
        // LÓGICA ANDROID: if (nowMillis >= correctedApptMillis) → deshabilitar
        if nowMillis >= correctedApptMillis {
            print("   ❌ La hora de la cita ya pasó → Deshabilitando botón")
            isCancelButtonEnabledByTime = false
        } else {
            print("   ✅ La cita aún no ha pasado → Botón habilitado")
            isCancelButtonEnabledByTime = true
        }
    }
}

extension AppointmentDetailsView {
    func confirmAppointment() {
        isLoading = true
        Task { @MainActor in
            let result = await Network.shared.confirmAppointment(appointment: appointment)
            isLoading = false

            switch result {
                case .success:
                    popup = confirmationSuccessPopup
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }

    func cancelAppointment() {
        isLoading = true
        Task { @MainActor in
            let result = await Network.shared.cancelAppointment(appointment: appointment)
            isLoading = false
            switch result {
                case .success:
                    popup = cancellationSuccesPopup
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}

// MARK: - Popups

extension AppointmentDetailsView {
    var cancellationConfirmationPopup: Popup {
        .init(
            image: UIStateAppoint.popupAppointmentUIState.iconCalendar,
            title: UIStateAppoint.popupAppointmentUIState.cancel.text1,
            actionTitle: UIStateAppoint.popupAppointmentUIState.cancel.btnOk,
            action: {
                cancelAppointment()
            },
            isCancellable: true,
            cancelTitle: UIStateAppoint.popupAppointmentUIState.cancel.btnCancel,
            UIStateTitle: UIStateAppoint.popupAppointmentUIState.titleTxt,
            UIStateMessage: UIStateAppoint.popupAppointmentUIState.textAtr,
            UIStateButton: UIStateAppoint.popupAppointmentUIState.btnConfirm,
            UIStateCancelButton: UIStateAppoint.popupAppointmentUIState.btnCancel
        )
    }
    
    var cancellationSuccesPopup: Popup {
        .init(
            image: UIStateAppoint.popupAppointmentUIState.iconCheck,
            title: UIStateAppoint.popupAppointmentUIState.cancel2.text1,
            actionTitle: UIStateAppoint.popupAppointmentUIState.cancel2.btnOk,
            action: {
                self.rootPresentation.dismiss()
            },
            isCancellable: false,
            UIStateTitle: UIStateAppoint.popupAppointmentUIState.titleTxt,
            UIStateMessage: UIStateAppoint.popupAppointmentUIState.textAtr,
            UIStateButton: UIStateAppoint.popupAppointmentUIState.btnConfirm,
            UIStateCancelButton: UIStateAppoint.popupAppointmentUIState.btnCancel
        )
    }
    
    var confirmationSuccessPopup: Popup {
        .init(
            image: UIStateAppoint.popupAppointmentUIState.iconCheck,
            title: UIStateAppoint.popupAppointmentUIState.confirm.text1,
            actionTitle: UIStateAppoint.popupAppointmentUIState.confirm.btnOk,
            action: {
                self.rootPresentation.dismiss()
            },
            isCancellable: false,
            UIStateTitle: UIStateAppoint.popupAppointmentUIState.titleTxt,
            UIStateMessage: UIStateAppoint.popupAppointmentUIState.textAtr,
            UIStateButton: UIStateAppoint.popupAppointmentUIState.btnConfirm,
            UIStateCancelButton: UIStateAppoint.popupAppointmentUIState.btnCancel
        )
    }
}
