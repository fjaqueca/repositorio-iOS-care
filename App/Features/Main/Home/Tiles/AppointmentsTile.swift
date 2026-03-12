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
            selectedAppointment = (item, displayName)
        } label: {
            HStack {
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
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(UIState.nextAppointmentUIState.title.text)
                            .font(Font.custom(UIState.nextAppointmentUIState.title.font, size: CGFloat(Int(UIState.nextAppointmentUIState.title.size) ?? 16)))
                            .foregroundColor(Color(hex: UIState.nextAppointmentUIState.title.color))
                        Text(item?.status.description ?? "")
                            .font(.appCalloutSemibold)
                            .foregroundColor(statusColor)
                    }
                    .padding(.bottom, .margin / 1.5)

                    Text(displayName)
                        .textCase(.uppercase)
                        .font(Font.custom(UIState.nextAppointmentUIState.clinic.font, size: CGFloat(Int(UIState.nextAppointmentUIState.clinic.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.nextAppointmentUIState.clinic.color))
                        .padding(.bottom, .margin / 2)

                    Label(item?.date.formatted(dateFormat) ?? "", image: "calendar-blue")
                        .font(Font.custom(UIState.nextAppointmentUIState.date.font, size: CGFloat(Int(UIState.nextAppointmentUIState.date.size) ?? 14)))
                        .foregroundColor(Color(hex: UIState.nextAppointmentUIState.date.color))
                        .padding(.bottom, .margin / 2)

                    Label((item?.date.formatted(Date.FormatStyle.init(time: .shortened)) ?? "") + "hs.", image: "clock-blue")
                        .font(Font.custom(UIState.nextAppointmentUIState.hour.font, size: CGFloat(Int(UIState.nextAppointmentUIState.hour.size) ?? 14)))
                        .foregroundColor(Color(hex: UIState.nextAppointmentUIState.hour.color))
                        .padding(.leading, -3)
                }
                .padding(.horizontal, .margin / 2)
                .padding(.vertical, .margin)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: UIState.nextAppointmentUIState.backgrounOblea))
            .cornerRadius(.cornerRadius)
        }
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(Color.shadowLight.opacity(0.5), lineWidth: 1)
                .shadow(color: .shadowLight, radius: 4, x: 1,y: 1)
        )
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
