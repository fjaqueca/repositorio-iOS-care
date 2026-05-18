//
//  AppointmentsTile.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage

struct AppointmentsTile: View {
    @Binding var UIState: HomeUIState
    @Binding var UIStateAppoint: AppointmentUIStateModel

    // Sigue el ObservedResults original para appointments (mismo filtro y orden)
    @ObservedResults(
        Appointment.self,
        filter: NSPredicate(format: "status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@",
                            "No realizado", "Reagendado", "No Confirmado", "Realizado", "Cancelado", "Fallido"),
        sortDescriptor: .init(keyPath: \Appointment.date, ascending: true)
    ) var appointments

    // 🔹 Observamos las clínicas persistidas en Realm
    @ObservedResults(ClinicInit.self) var clinicObjects

    @State private var selectedAppointment: (Appointment?, String)?

    var dateFormat: Date.FormatStyle {
        .init(
            date: .complete,
            time: .omitted,
            locale: .init(identifier: "es_419"),
            calendar: .current,
            timeZone: .current,
            capitalizationContext: .beginningOfSentence
        )
    }

    var body: some View {
        if appointments.isEmpty {
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .foregroundColor(Color(hex: UIState.placerholderAppointment.background))
                CachedAsyncImage(
                    url: URL(string: UIState.placerholderAppointment.URLimg),
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: .infinity)
                    },
                    placeholder: {
                        ProgressView()
                    })
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120.0)
            .padding(.horizontal, .margin / 2)

        } else {
            HorizontalTileView(items: appointments, height: 120.0) { appointment in
                itemView(item: appointment)
                    .padding(.leading, .margin / 2)
            }
            .navigationLink(item: $selectedAppointment) { data in
                AppointmentDetailsView(UIStateAppoint: $UIStateAppoint, appointment: data.0 ?? Appointment(), customName: data.1)
                    .rootPresentation {
                        selectedAppointment = nil
                    }
            }
        }
    }

    // ------------------------------------------------------------
    // NOTA: quitamos @ViewBuilder y retornamos directamente una View.
    // Calculamos displayIcon y displayName antes de construir la vista.
    // ------------------------------------------------------------
    func itemView(item: Appointment?) -> some View {
        // valores por defecto (lo que ya tenías)
        var displayIcon = item?.iconoAzul ?? ""
        var displayName = item?.clinica ?? ""

        // BUSCAMOS UNA CLINICA QUE COINCIDA (heurísticas para ser tolerante)
        if let item = item {
            if let matched = findClinic(for: item) {
                // matched.iconURL puede contener 1 o más URLs separadas por ';'
                let icons = matched.iconURL.components(separatedBy: ";")
                    .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                // Si hay segundo icono, lo usamos; sino usamos el primero si existe
                if icons.count > 1 {
                    displayIcon = icons[1]
                } else if let first = icons.first {
                    // Aquí decidimos: si no hay segundo icono, mantenemos el que YA mostrabas (item.iconoAzul)
                    // o usamos el primero en clinic. En tu petición dijiste: en esta vista usar primero icon.
                    // Para no romper, usaré:
                    // - si item.iconoAzul está vacío, fallback al first
                    displayIcon = item.iconoAzul.isEmpty ? first : item.iconoAzul
                }

                // Reemplazamos el nombre por el guardado en ClinicInit (según lo pediste)
                if !matched.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    displayName = matched.name
                }
            } else {
                // no matched clinic -> mantenemos los valores actuales (ya asignados)
            }
        }

        // color por estado (mismo comportamiento)
        let statusColor: Color = {
            switch item?.status {
                case .confirmado:
                    return Color.darkGreen
                case .noConfirmado, .programado, .aConfirmar:
                    return Color.orangeText
                case .cancelado:
                    return Color.negativeSentiment
                case .none:
                    return Color.backgroundSecondary
                case .realizado, .noRealizado, .reagendado, .failure:
                    return Color.black
            }
        }()

        // Construimos la vista exactamente igual a la anterior (sin cambios visuales)
        return Button {
            HapticManager.selection()
            selectedAppointment = (item, displayName)
        } label: {
            HStack(spacing: 0) {
                // Panel lateral imagen (esquinas solo izquierda, paridad Android)
                // TEMPORAL: Lottie squat_proxima_cita deshabilitado, se restaura CachedAsyncImage dinámico.
                // Para reactivar el Lottie, comenta el CachedAsyncImage y descomenta el LottieView.
                CachedAsyncImage(
                    url: URL(string: displayIcon),
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: .infinity)
                            .frame(width: 50.0)
                            .background(Color(hex: UIState.nextAppointmentUIState.headerOblea))
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                // LottieView(
                //     animationName: "squat_proxima_cita",
                //     loopMode: .loop,
                //     contentMode: .scaleAspectFill
                // )
                // .frame(width: 75)
                // .frame(maxHeight: .infinity)
                // .clipShape(LeftRoundedShape(radius: 18))

                // Contenido texto
                VStack(alignment: .leading, spacing: 5) {
                    // Header: título + badge status
                    HStack(spacing: 8) {
                        Text(UIState.nextAppointmentUIState.title.text)
                            .font(Font.custom(UIState.nextAppointmentUIState.title.font, size: CGFloat(Int(UIState.nextAppointmentUIState.title.size) ?? 14)))
                            .foregroundColor(Color(hex: UIState.nextAppointmentUIState.title.color))

                        Text(item?.status.description ?? "")
                            .font(Font.custom("FiraSans-Medium", size: 11))
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(statusColor.opacity(0.12)))
                    }

                    // Nombre clínica
                    Text(displayName)
                        .font(Font.custom(UIState.nextAppointmentUIState.clinic.font, size: CGFloat(Int(UIState.nextAppointmentUIState.clinic.size) ?? 15)))
                        .foregroundColor(Color(hex: UIState.nextAppointmentUIState.clinic.color))
                        .lineLimit(1)

                    // Fecha
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: UIState.nextAppointmentUIState.date.color))
                        Text(item?.date.formatted(dateFormat) ?? "")
                            .font(Font.custom(UIState.nextAppointmentUIState.date.font, size: CGFloat(Int(UIState.nextAppointmentUIState.date.size) ?? 13)))
                            .foregroundColor(Color(hex: UIState.nextAppointmentUIState.date.color))
                    }

                    // Hora
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: UIState.nextAppointmentUIState.hour.color))
                        Text((item?.date.formatted(Date.FormatStyle.init(time: .shortened)) ?? "") + "hs.")
                            .font(Font.custom(UIState.nextAppointmentUIState.hour.font, size: CGFloat(Int(UIState.nextAppointmentUIState.hour.size) ?? 13)))
                            .foregroundColor(Color(hex: UIState.nextAppointmentUIState.hour.color))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

                Spacer(minLength: 0)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: UIState.nextAppointmentUIState.backgrounOblea.isEmpty ? "#FFFFFF" : UIState.nextAppointmentUIState.backgrounOblea))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .pressable()
        .springOnAppear(delay: 0.1)
    }

    // MARK: - Heurística para encontrar ClinicInit correspondiente a un Appointment
    // Trata  posibles para emparejar (id == clinica)
    private func findClinic(for appointment: Appointment) -> ClinicInit? {
        // 1) Match exacto por ID en appointment.clinica
        if !appointment.clinica.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let exactById = clinicObjects.first(where: { $0.id == appointment.workTypeGroup }) {
                return exactById
            }
        }
        // Si no se encuentra, devolvemos nil -> se usan los datos originales del appointment
        return nil
    }
}

// MARK: - Shape con esquinas redondeadas solo en el lado izquierdo
private struct LeftRoundedShape: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}
