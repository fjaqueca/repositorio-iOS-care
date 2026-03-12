//
//  Network+VideoCall.swift
//  CareAssistance
//
//  Created by Lara Dubs on 24/11/2022.
//

import Foundation
import TwilioVideo
import Alamofire

extension Network {
    func getAppointmentVideoCall(appointment: Appointment) async -> Result<VideoCall, AppError> {
        await request(method: .post, endpoint: .videoCallToken, parameters: [
            "create_room": true,
            "create_conversation": true,
            "user_identity": AppStatusManager.rut,
            "room_name": appointment.id
        ])
    }
    
    func getOnDemandVideoCall() async -> Result<PostAgentWorkQueueR1, AppError> {
        await request(method: .post, endpoint: .videoCallnOnDemandTokenR1, parameters: [
            "rut": AppStatusManager.rut,
            "id_convenio": AppStatusManager.selectedEnterprise?.empresaC
        ])
    }
    
    func getOnDemandVideoCallQueue(taskSid: String) async -> Result<VideoCallOnDemand.Queue, AppError> {
        await request(method: .get, endpoint: .videoCallnOnDemandQueuR1, parameters: [
            "task_sid": taskSid
        ])
    }
    
    func onDemandVideoCallDequeue(taskSid: String, status: String, reason: String) async -> Result<Empty, AppError> {
        await request(method: .post, endpoint: .videoCallnOnDemandDequeueR1, parameters: [
            "id": taskSid,
            "estado": status,
            "motivo": reason
        ])
    }
    
    func getOnDemandVideoCallRoom(taskSid: String) async -> Result<VideoCallOnDemand.Room, AppError> {
        await request(method: .get, endpoint: .videoCallOnDemandRoomR1, parameters: [
            "room_unique_name": taskSid
        ])
    }
    
    func getOnDemandVideoCallToken(taskSid: String, phone: String, name: String) async -> Result<OnDemandNewR1, AppError> {
        await request(method: .post, endpoint: .videoCallnOnDemandTokenNewR1, parameters: [
            "username": name,
            "phone": phone,
            "id_convenio":AppStatusManager.selectedEnterprise?.empresaC,
            "id_task": taskSid
        ])
    }
}
