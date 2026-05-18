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
                Spacer().frame(height: 12)
                let currentDateAppointments = appointments(for: selectedDate).sorted {
                    $0.date < $1.date
                }
                if !currentDateAppointments.isEmpty {
                    ForEach(Array(currentDateAppointments.enumerated()), id: \.element.id) { index, appointment in
                        AppointmentRowView(appointment, UIStateAppoint: $UIStateAppoint)
                            .pressable()
                            .springOnAppear(delay: Double(index) * 0.05)
                    }

                } else {
                    VStack(spacing: 12) {
                        Spacer()

                        // TEMPORAL: Lottie no_citas_para_este_dia deshabilitado, se restaura icono SF Symbol.
                        // Para reactivar, comenta el Image y descomenta el LottieView.
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(Color(.systemGray3))
                        // LottieView(animationName: "no_citas_para_este_dia")
                        //     .frame(width: 180, height: 180)

                        Text("No hay citas para este día")
                            .font(Font.custom("FiraSans-Regular", size: 15))
                            .foregroundColor(Color(hex: "#C4C4C4"))
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .popIn()
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
