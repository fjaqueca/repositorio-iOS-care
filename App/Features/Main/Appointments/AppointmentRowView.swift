//
//  AppointmentRowView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 26/08/2022.
//

import SwiftUI
import RealmSwift

struct AppointmentRowView<Content: View>: View {
    @ObservedRealmObject var appointment: Appointment
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @ObservedResults(ClinicInit.self) var clinicObjects
    let content: (Appointment, String) -> Content
    
    @State private var isPresentingDetails = false
    
    var color: Color {
        switch appointment.status {
            case .confirmado:
                return Color.darkGreen
            case .noConfirmado, .programado, .aConfirmar:
                return Color.orangeText
            case .cancelado:
                return Color.negativeSentiment
            case .realizado, .noRealizado, .reagendado, .failure:
                return Color.black
        }
    }
    
    var customName: String {
        if let matched = clinicObjects.first(where: { $0.id == appointment.workTypeGroup }) {
            return matched.name
        }
        return appointment.clinica
    }
    
    var body: some View {
        Button {
            isPresentingDetails = true
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(customName) // ✅ Mostramos el nombre custom
                            .font(Font.custom(UIStateAppoint.appointmentUIState.titleList.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.titleList.size) ?? 18)))
                            .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.titleList.color))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(appointment.status.description)
                            .font(.appSmallMedium)
                            .foregroundColor(color)
                    }
                    
                    HStack {
                        Text("\(appointment.professionalName)")
                            .font(Font.custom(UIStateAppoint.appointmentUIState.profesionalList.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.profesionalList.size) ?? 18)))
                            .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.profesionalList.color))
                        
                        Spacer()
                        
                        Text(appointment.date.formatted(Date.FormatStyle.init(time: .shortened)) + "hs.")
                            .font(Font.custom(UIStateAppoint.appointmentUIState.hour.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.hour.size) ?? 18)))
                            .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.hour.color))
                    }
                }
                .padding(.leading, .appointmentRowMarkerWidth + .margin)
                .overlay(alignment: .leading) {
                    Color(hex: UIStateAppoint.appointmentUIState.colorLineCite)
                        .frame(width: .appointmentRowMarkerWidth)
                        .cornerRadius(3)
                }
                .padding(.horizontal, .margin)
                .padding(.vertical, .margin / 2)
                .frame(maxWidth: .infinity)
                Divider()
            }
        }
        .navigationLink(isActive: $isPresentingDetails) {
            content(appointment, customName) // ✅ Le pasamos el nombre custom
                .rootPresentation {
                    isPresentingDetails = false
                }
        }
    }
    
    init(_ appointment: Appointment, UIStateAppoint: Binding<AppointmentUIStateModel>, @ViewBuilder content: @escaping (Appointment, String) -> Content) {
        self.appointment = appointment
        self.content = content
        self._UIStateAppoint = UIStateAppoint
    }
}

// MARK: - Extensión para compatibilidad con AppointmentDetailsView
extension AppointmentRowView where Content == AppointmentDetailsView {
    init(_ appointment: Appointment, UIStateAppoint: Binding<AppointmentUIStateModel>) {
        self.init(appointment, UIStateAppoint: UIStateAppoint) { appointment, customName in
            AppointmentDetailsView(UIStateAppoint: UIStateAppoint, appointment: appointment, customName: customName)
        }
    }
}

