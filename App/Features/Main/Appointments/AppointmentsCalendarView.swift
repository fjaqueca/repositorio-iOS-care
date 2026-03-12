//
//  AppointmentsCalendarView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 25/08/2022.
//

import SwiftUI
import RealmSwift

struct AppointmentsCalendarView: View {
    @ObservedResults(Appointment.self) var appointments
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @State private var selectedDate: Date? = Date()
    @State private var selectedMonthOffset: Int = 0

    var body: some View {
        VStack(spacing: 0.0) {
            CalendarView(markedDates: .constant(appointments.map(\.date)), selectedDate: $selectedDate, selectedMonthOffset: $selectedMonthOffset, isFirstCalendar: true, UIStateAppoint: $UIStateAppoint)
            appointmentsView
        }
    }

    var appointmentsView: some View {
        ScrollView {
            VStack(spacing: 0) {
                let currentDateAppointments = appointments(for: selectedDate).sorted {
                    $0.date < $1.date
                }
                if !currentDateAppointments.isEmpty {
                    ForEach(currentDateAppointments) { appointment in
                        AppointmentRowView(appointment, UIStateAppoint: $UIStateAppoint)
                    }
                    
                } else {
                    Text("No hay citas agendadas")
                        .font(.appCallout)
                        .foregroundColor(.textSecondary)
                        .frame(height: 60.0)
                }
            }
        }
    }
}

// MARK: // Helpers

extension AppointmentsCalendarView {
    private func appointments(for date: Date?) -> [Appointment] {
        guard let date else {
            return []
        }
        return appointments.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) })
    }
}
