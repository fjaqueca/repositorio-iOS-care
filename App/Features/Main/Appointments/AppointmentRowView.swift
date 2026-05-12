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
    
    /// Color de fondo sutil del badge de status
    private var statusBadgeBackground: Color {
        color.opacity(0.12)
    }

    /// Ícono SF Symbol según el tipo de cita
    private var appointmentTypeIcon: String {
        switch appointment.appointmentType {
        case .video: return "video.fill"
        case .phone: return "phone.fill"
        default: return "calendar"
        }
    }

    var body: some View {
        Button {
            HapticManager.impact(style: .light)
            isPresentingDetails = true
        } label: {
            HStack(spacing: 14) {
                // Barra lateral de color (más gruesa y redondeada)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: UIStateAppoint.appointmentUIState.colorLineCite))
                    .frame(width: 4)

                // Ícono de tipo de cita
                ZStack {
                    Circle()
                        .fill(Color(hex: UIStateAppoint.appointmentUIState.colorLineCite).opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: appointmentTypeIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.colorLineCite))
                }

                // Contenido texto
                VStack(alignment: .leading, spacing: 4) {
                    Text(customName)
                        .font(Font.custom(UIStateAppoint.appointmentUIState.titleList.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.titleList.size) ?? 16)))
                        .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.titleList.color))
                        .lineLimit(1)

                    Text(appointment.professionalName)
                        .font(Font.custom(UIStateAppoint.appointmentUIState.profesionalList.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.profesionalList.size) ?? 14)))
                        .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.profesionalList.color.isEmpty ? "#888888" : UIStateAppoint.appointmentUIState.profesionalList.color))
                        .lineLimit(1)
                }

                Spacer()

                // Columna derecha: hora + badge status
                VStack(alignment: .trailing, spacing: 6) {
                    Text(appointment.date.formatted(Date.FormatStyle.init(time: .shortened)) + "hs.")
                        .font(Font.custom(UIStateAppoint.appointmentUIState.hour.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.hour.size) ?? 13)))
                        .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.hour.color))

                    Text(appointment.status.description)
                        .font(Font.custom("FiraSans-Medium", size: 11))
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(statusBadgeBackground)
                        )
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .padding(.horizontal, .margin)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .heroSendEffect(isActive: $isPresentingDetails)
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

