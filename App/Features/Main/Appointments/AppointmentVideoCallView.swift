//
//  AppointmentVideoCallView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/12/2022.
//

import SwiftUI
import RealmSwift
import TwilioVideo
import Combine

struct AppointmentVideoCallView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedRealmObject var appointment: Appointment
    @StateObject private var viewModel = VideoCallViewModel()
    @State private var shouldEndVideoCall = false
    
    var body: some View {
        VideoCallView(configuration: .constant(viewModel.mainVideoConfiguration))
            .overlay(
                VideoCallView(configuration: .constant(viewModel.secondaryVideoConfiguration))
                    .frame(width: 150, height: 150.0)
                    .onTapGesture {
                        viewModel.isDisplayingRemoteAsMainView.toggle()
                    },
                alignment: .bottomTrailing
            )
            .popup(item: $viewModel.waitingRemoteParticipantPopUp)
        
        VideoCallRoomToolbar(viewModel: viewModel)
            .task {
                startCall()
            }
    }
    
    func startCall() {
        Task {
            let result = await Network.shared.getAppointmentVideoCall(appointment: appointment)
            switch result {
                case let .success(videoCall):
                    let connectOptions = ConnectOptions(token: videoCall.token) { (builder) in
                        builder.roomName = videoCall.roomType
                    }
                    self.viewModel.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self.viewModel)
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}
