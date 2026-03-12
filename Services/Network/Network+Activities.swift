//
//  Network+Activities.swift
//  CareAssistance
//
//  Created by The App Master on 08/08/2023.
//

import Foundation

extension Network {
    func getActivities(taskId: String) async -> Result<Activities, AppError> {
        await request(endpoint: .activities, parameters: ["goal_id": taskId])
    }
    func getActivityCompletion(activityId: String) async -> Result<ActivityCompletion, AppError> {
        await request(endpoint: .activityCompletion, parameters: ["actividad_id": activityId])
    }
}
