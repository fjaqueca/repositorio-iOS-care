//
//  AppointmentSlot.swift
//  CareAssistance
//
//  Created by Lara Dubs on 25/10/2022.
//

import Foundation

struct AppointmentSlot: Codable, Identifiable, Hashable, CustomStringConvertible, Comparable {
    var id: String {
        startTime
    }

    private let startTime: String
    private let endTime: String
    var WorkTypeId: String
    var resources: [ProfessionalReference]
    // Optional because the appointment type doesn't come from get_professionals_availability, but you have to send it on post_appointment
    var appointmentType: String?

    var startDate: Date {
        .init(isoString: startTime)
    }

    var endDate: Date {
        .init(isoString: endTime)
    }

    var description: String {
        startDate.timeString
    }

    static func < (lhs: AppointmentSlot, rhs: AppointmentSlot) -> Bool {
        lhs.startDate < rhs.startDate
    }
    
    struct ProfessionalReference: Codable, Hashable, Identifiable {
        let id: String
        let name: String
    }
}
