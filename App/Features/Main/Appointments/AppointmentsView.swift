//
//  AppointmentsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 06/08/2022.
//

import SwiftUI
import RealmSwift

struct AppointmentsView: View {
    @ObservedResults(BrandAccounts.self) var items
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @State private var isPresentingNewAppointment = false
    @State private var displayMode: DisplayMode = .calendar
    @Binding var selectedTab: Tab

    enum DisplayMode {
        case list
        case calendar

        mutating func toggle() {
            switch self {
                case .list:
                    self = .calendar
                case .calendar:
                    self = .list
            }
        }

        var toggleIcon: String {
            switch self {
                case .list:
                    return "calendar-blue"
                case .calendar:
                    return "calendar-list"
            }
        }
    }

    var body: some View {
        NavigationViewCustom {
            VStack(spacing: 0.0) {
                    Divider()
                    
                    Group {
                        switch displayMode {
                        case .list:
                            AppointmentsListView(UIStateAppoint: $UIStateAppoint)
                        case .calendar:
                            AppointmentsCalendarView(UIStateAppoint: $UIStateAppoint)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: displayMode)
                    Spacer()
                    PrimaryButton(title: "Nueva cita",UIStateBtn: UIStateAppoint.appointmentUIState.btnNew) {
                        HapticManager.impact(style: .medium)
                        isPresentingNewAppointment = true
                    }
                    .bounceOnTap()
                    .padding(.horizontal, .margin)
                    .padding(.bottom, .margin)
                }
                .fadeSlideIn(delay: 0.05, from: .bottom)
                .navigationLink(isActive: $isPresentingNewAppointment) {
                        NewAppointmentSelectClinicView(UIStateAppoint: $UIStateAppoint, selectedTab: $selectedTab)
                            .rootPresentation {
                                isPresentingNewAppointment = false
                            }
                            .tabBarHidden(true)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(UIStateAppoint.appointmentUIState.title.text)
                            .font(Font.custom(UIStateAppoint.appointmentUIState.title.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.title.color))
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            HapticManager.selection()
                            displayMode.toggle()
                        } label: {
                            Image(displayMode.toggleIcon)
                                .renderingMode(.template)
                                .font(Font.custom(UIStateAppoint.appointmentUIState.title.font, size: CGFloat(Int(UIStateAppoint.appointmentUIState.title.size) ?? 18)))
                                .foregroundColor(Color(hex: UIStateAppoint.appointmentUIState.title.color))
                        }
                    }
                }
            .navigationBarTitleDisplayMode(.inline)
            .configureNavigation()
            .removeBackButtonText()

        }
            
        .accentColor(.blue)
    }
}
