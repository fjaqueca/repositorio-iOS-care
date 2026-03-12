//
//  Network+Appointments.swift
//  CareAssistance
//
//  Created by Lara Dubs on 25/10/2022.
//

import Foundation
import Alamofire
import RealmSwift

extension Network {
    func getNextAppointments(rut: String) async -> Result<[Appointment], AppError> {
        await request(endpoint: .appointments, parameters: ["rut": rut])
    }

    func createAppointment(rut: String, clinic: ClinicDetail, professional: Professional, slot: AppointmentSlot) async -> Result<Empty, AppError> {
        await executeAndUpdate {
            await newAppointment(rut: rut, clinic: clinic, professional: professional, slot: slot)
        }
    }

    func cancelAppointment(appointment: Appointment) async -> Result<Empty, AppError> {
        await executeAndUpdate {
            await updateAppointment(appointment: appointment, status: .cancelado)
        }
    }

    func confirmAppointment(appointment: Appointment) async -> Result<Empty, AppError> {
        await executeAndUpdate {
            await updateAppointment(appointment: appointment, status: .confirmado)
        }
    }

    func replaceAppointment(previousAppointment: Appointment, rut: String, clinic: ClinicDetail, professional: Professional, slot: AppointmentSlot) async -> Result<Empty, AppError> {
        await executeAndUpdate {
            let result = await Network.shared.newAppointment(rut: rut, clinic: clinic, professional: professional, slot: slot)
            if case .success = result {
                _ = await updateAppointment(appointment: previousAppointment, status: .cancelado)
            }
            return result
        }
    }

    // MARK: - Server Calls

    private func newAppointment(rut: String, clinic: ClinicDetail, professional: Professional, slot: AppointmentSlot) async -> Result<Empty, AppError> {
        await request(method: .post, endpoint: .appointmentCreate, parameters: [
            "sched_start_time": slot.startDate.isoString,
            "sched_end_time": slot.endDate.isoString,
            "rut": rut,
            "service_territory_id": professional.serviceTerritoryId,
            "work_type_id": slot.WorkTypeId,
            "work_type_group_id": clinic.id,
            "appointment_type": slot.appointmentType,
            "service_resource_id": professional.serviceResourceId
        ])
    }

    private func updateAppointment(appointment: Appointment, status: Appointment.Status) async -> Result<Empty, AppError> {
        await request(method: .post, endpoint: .appointmentUpdate, parameters: [
            "appointment_id": appointment.id,
            "status": status.rawValue
        ])
    }

    // MARK: - Helpers

    /// Executes the function and reloads the appointments in case of success.
    private func executeAndUpdate<Success,Failure>(_ block: () async -> Result<Success, Failure>) async -> Result<Success, Failure> {
        let result = await block()
        if case .success = result {
            await AppStatusManager.loadAppointments()
        }
        return result
    }
}
