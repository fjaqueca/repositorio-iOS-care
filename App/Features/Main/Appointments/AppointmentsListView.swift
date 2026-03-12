//
//  AppointmentCalendarListView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 07/11/2022.
//

import SwiftUI
import RealmSwift

struct AppointmentsListView: View {
    // ✅ Solo mostramos citas con estados activos: A Confirmar, Programado, Confirmado
    // Excluimos: Cancelado, Fallido, Reagendado, Realizado, No realizado, No Confirmado
    @ObservedResults(
        Appointment.self,
        filter: NSPredicate(format: "status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@ AND status != %@",
                            "No realizado", "Reagendado", "No Confirmado", "Realizado", "Cancelado", "Fallido"),
        sortDescriptor: .init(keyPath: \Appointment.date, ascending: true)
    ) var appointments
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @State private var sections: [ListSection] = []

    private struct ListSection: Identifiable, Hashable {
        let date: Date
        var appointments: [Appointment]

        var id: Date {
            date
        }

        init(appointment: Appointment) {
            self.date = appointment.date
            self.appointments = [appointment]
        }
    
        mutating func append(_ appointment: Appointment) {
            self.appointments.append(appointment)
        }
    }
    
    var dateFormat: Date.FormatStyle {
        .init(
            locale: .init(identifier: "es_419"),
            calendar: .current,
            timeZone: .current,
            capitalizationContext: .beginningOfSentence
            )
        .weekday(.wide)
        .day(.defaultDigits)
        .month(.wide)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                if !sections.isEmpty {
                    ForEach(sections) { section in
                        Section {
                            ForEach(section.appointments) { appointment in
                                AppointmentRowView(appointment, UIStateAppoint: $UIStateAppoint)
                            }
                        } header: {
                            Text(section.date.formatted(dateFormat).uppercased())
                                .font(Font.custom(UIStateAppoint.appointmentUIState.separatorLineDate.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.separatorLineDate.size) ?? 18)))
                                .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.separatorLineDate.textColor))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, .margin)
                                .padding(.leading, .appointmentRowMarkerWidth + .margin)
                                .padding(.vertical, .margin / 2)
                                .background(Color(hex: UIStateAppoint.appointmentUIState.separatorLineDate.backColor))
                        }
                    }
                    
                } else {
                    Text("No hay citas agendadas")
                        .font(.appCallout)
                        .foregroundColor(.textSecondary)
                        .frame(height: 60.0)
                }
            }
        }
        .onChange(of: appointments) { newValue in
            updateSections()
        }
    }

    func updateSections() {
        let sortedAppointments = appointments.sorted(by: \.date, ascending: true)
        var sections = [ListSection]()
        var currentSection: ListSection?
        for appointment in sortedAppointments {
            // First section is created with the first appointment
            if currentSection == nil {
                currentSection = .init(appointment: appointment)
            } else if let section = currentSection {
                // In case we already have a section, we decide if we add a new element to it (same day)
                // or if we create a new section
                if Calendar.current.isDate(appointment.date, inSameDayAs: section.date) {
                    currentSection?.append(appointment)
                } else {
                    sections.append(section)
                    currentSection = .init(appointment: appointment)
                }
            }
        }
        if let currentSection {
            sections.append(currentSection)
        }
        if sections != self.sections {
            self.sections = sections
        }
    }
}
