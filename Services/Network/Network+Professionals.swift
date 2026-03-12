//
//  Network+Professionals.swift
//  CareAssistance
//
//  Created by Lara Dubs on 28/10/2022.
//

import Foundation

extension Network {
    func getProfessionalsByClinic(id: String) async -> Result<[Professional], AppError> {
        await request(endpoint: .professionals, parameters: ["work_type_group": id])
    }
    
    func getProfessionalsAvailability(clinic: ClinicDetail, professional: Professional, monthOffset: Int) async -> Result<[AppointmentSlot], AppError> {
        let startOfMonth = Date().startOfMonth().adding(months: monthOffset)
        let endOfMonth = startOfMonth.endOfMonth().endOfDay()

        return await request(method: .post, endpoint: .professionalsAvailability, parameters: [
            "work_type_group_id": clinic.id,
            "service_territory": [professional.serviceTerritoryId],
            "service_resource": [
                [
                    "id": professional.serviceResourceId,
                    "name": professional.name
                ]
            ],
            "sched_start_time": startOfMonth.isoString,
            "sched_end_time": endOfMonth.isoString,
        ])
    }
    
    func getFirstAvailableAppointment(clinic: ClinicDetail, professionals: [Professional], monthOffset: Int) async -> Result<[AppointmentSlot], AppError> {
        let startOfMonth = Date().startOfMonth().adding(months: monthOffset)
        let endOfMonth = startOfMonth.endOfMonth().endOfDay()
        
        var serviceResources = [[String: Any]]()

        for professional in professionals {
            serviceResources.append([
                "id": professional.serviceResourceId,
                "name": professional.name
            ])
        }

        return await request(method: .post, endpoint: .professionalsAvailability, parameters: [
            "work_type_group_id": clinic.id,
            "service_territory": [professionals[0].serviceTerritoryId],
            "service_resource": serviceResources,
            "sched_start_time": startOfMonth.isoString,
            "sched_end_time": endOfMonth.isoString,
        ])
    }
    func getValidationProfessionalsAvailability(clinic: ClinicDetail, professional: Professional, slot: AppointmentSlot) async -> Result<[AppointmentSlot], AppError> {

        return await request(method: .post, endpoint: .professionalsAvailability, parameters: [
            "work_type_group_id": clinic.id,
            "service_territory": [professional.serviceTerritoryId],
            "service_resource": [
                [
                    "id": professional.serviceResourceId,
                    "name": professional.name
                ]
            ],
            "sched_start_time": slot.startDate.isoString,
            "sched_end_time": slot.endDate.isoString,
        ])
    }
}
