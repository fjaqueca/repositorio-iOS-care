//
//  VideoCall.swift
//  CareAssistance
//
//  Created by Lara Dubs on 13/02/2023.
//

import Foundation

struct VideoCall: Codable {
    let token: String
    let roomType: String
}

struct VideoCallOnDemand: Codable {
    let data: Data
    
    struct Data: Codable {
        let task: String
        let taskQueueSid: String
        let token: String
        let roomSid: String
        let roomType: String
        let message: String
    }
    
    struct Queue: Codable {
        let data: QueueData
        
        struct QueueData: Codable {
            let totalTasksInQueue: Int
            let positionInQueue: Int
            let remainingTasks: Int
        }
    }
    struct Room: Codable {
        let data: RoomData
        struct RoomData: Codable{
            let participantsInRoom: [String]
        }
    }
}

struct PostAgentWorkQueueR1: Codable {
    let statusCode: Int
    let message: String
    let task: String
}

struct OnDemandNewR1: Codable {
    let data: OnDemandNewData
    struct OnDemandNewData: Codable{
        let task: String
        let token: String
        let conferenceUrl: String
        let message: String
    }
}
