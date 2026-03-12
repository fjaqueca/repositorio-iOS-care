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
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
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
    
    var body: some View {
        VStack(spacing: .margin) {
            Divider()
            
            Group {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Cita \(customName != "" ? customName : appointment.clinica)")
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.clinicsAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.clinicsAtr.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.clinicsAtr.color))
                        .padding(.top, .margin)
                    Text("\(appointment.date.formatted(dateFormat))hs.")
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.dateAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.dateAtr.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.dateAtr.color))
                    Text("\(appointment.appointmentType.description)")
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.tipeAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.tipeAtr.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.tipeAtr.color))
                }
                
                Text("\(UIStateAppoint.detaillAppointmentUIState.textVideo1) **\(users.first?.records.first?.FirstName ?? "")**,")
                    .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 18)))
                    .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                if !isConfirmed {
                    Text("Usted contará con una consulta con **\(appointment.professionalName)**, por favor confirmar la fecha y hora para mantener la vigencia del turno.")
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                } else {
                    Text(appointment.appointmentType == .video ? "\(UIStateAppoint.detaillAppointmentUIState.textVideo2) **\(appointment.professionalName)** \(UIStateAppoint.detaillAppointmentUIState.textVideo3)" : "\(UIStateAppoint.detaillAppointmentUIState.textPhone1)")
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                }
                if appointment.appointmentType == .phone && (users.first?.records.first?.Phone == nil || users.first?.records.first?.Phone == "") {
                    Text("Por favor ingrese su número telefónico. Para hacerlo debe ingresar a perfil, luego a [datos personales](http://user-profile.com). Ingresar su número telefónico y apretar enviar.")
                        .environment(\.openURL, .init(handler: { _ in
                            self.showProfileUpdateInformation = true
                            return .handled
                        }))
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                } else if appointment.appointmentType == .phone {
                    Text("\(UIStateAppoint.detaillAppointmentUIState.textPhone2) **\(users.first?.records.first?.Phone ?? "")**. \(UIStateAppoint.detaillAppointmentUIState.textPhone3) [\(UIStateAppoint.detaillAppointmentUIState.textPhone4)](http://user-profile.com) \(UIStateAppoint.detaillAppointmentUIState.textPhone5)")
                        .environment(\.openURL, .init(handler: { _ in
                            self.showProfileUpdateInformation = true
                            return .handled
                        }))
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.textAtr.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.textAtr.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.textAtr.color))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if isConfirmed {
                VStack {
                    Spacer()
                        .frame(height: .margin)
                    if appointment.appointmentType == .video {
                        PrimaryButton(title: "Comenzar la videollamada", backgroundColor: .primaryText, UIStateBtn: UIStateAppoint.detaillAppointmentUIState.btnVideo, haveImage: true, action: {
                            showVideoCall = true
                        })
                        .disabled(!isVideoCallButtonEnabled)
                        .background{
                            if !isVideoCallButtonEnabled{
                                Color(hex: UIStateAppoint.detaillAppointmentUIState.btnVideo.backgroundPressBtn != "" ? UIStateAppoint.detaillAppointmentUIState.btnVideo.backgroundPressBtn : "#E9E9EB")
                                    .cornerRadius(5.0)
                            }
                        }
                        .onReceive(timer) { _ in
                            now = Date()
                            updateVideoCallButtonStatus()
                        }
                    }
                }
                
                if appointment.appointmentType == .video {
                    Text(UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.text)
                        .font(Font.custom(UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.font, size: CGFloat(Int(UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.detaillAppointmentUIState.msgBtnVideo.color))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
            
            buttonsView
        }
        .onAppear {
            updateVideoCallButtonStatus()
        }
        .padding(.horizontal, .margin)
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
        .overlayView(isLoading)
    }
    
    @ViewBuilder
    private var buttonsView: some View {
        PrimaryButton(title: isConfirmed ? UIStateAppoint.detaillAppointmentUIState.btnConfirm2 : UIStateAppoint.detaillAppointmentUIState.btnConfirm1, UIStateBtn: UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier) {
            confirmAppointment()
        }
        .disabled(isConfirmed || isLoading || isCanceled)
        .background{
            if isConfirmed || isLoading || isCanceled{
                Color(hex: UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.backgroundPressBtn != "" ? UIStateAppoint.detaillAppointmentUIState.btnConfirmModifier.backgroundPressBtn : "#E9E9EB")
                    .cornerRadius(5.0)
            }
        }
        
        
//        Button {
//            showModifyAppointment = true
//        } label: {
//            Text("Modificar")
//                .font(.appBodyBold)
//                .foregroundColor(.primaryText)
//                .frame(maxWidth: .infinity)
//                .frame(height: .buttonHeight)
//                .background(
//                    RoundedRectangle(cornerRadius: .cornerRadius)
//                        .stroke(Color.primaryText, lineWidth: 1)
//                )
//        }
//        .buttonStyle(.plain)
//        .disabled(isCanceled || isLoading)
        
        TransparentButton(title: "Cancelar", UIStateBtn: UIStateAppoint.detaillAppointmentUIState.btnCancel) {
            popup = cancellationConfirmationPopup
        }
        .padding(.bottom, .margin)
        .disabled(isCanceled || isLoading)
    }
}

// MARK: - Actions

extension AppointmentDetailsView {
    func updateVideoCallButtonStatus() {
        let currentDate = Date()
        let tenMinutesBeforeTargetTime = Calendar.current.date(byAdding: .minute, value: -3, to: appointment.date)!
        let oneHourAfterTargetTime = Calendar.current.date(byAdding: .hour, value: 1, to: appointment.date)!
        
        if currentDate >= tenMinutesBeforeTargetTime && currentDate <= oneHourAfterTargetTime {
            isVideoCallButtonEnabled = true
        } else {
            isVideoCallButtonEnabled = false
        }
    }
}

extension AppointmentDetailsView {
    func confirmAppointment() {
        isLoading = true
        Task {
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
        Task {
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
