//
//  VideoCallViewModel.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/02/2023.
//

import Foundation
import TwilioVideo

class VideoCallViewModel: NSObject, TwilioVideo.RoomDelegate, ObservableObject {
    @Published var room: Room?
    @Published var isDisplayingRemoteAsMainView: Bool = false
    @Published var isParticipantConnected: Bool = false {
        didSet {
            if !isParticipantConnected {
                waitingRemoteParticipantPopUp = .init(
                    image: "appointment-clock",
                    title: "Aguarde un momento.\nEl profesional se conectará en unos instantes.",
                    actionTitle: "Aceptar",
                    action: {},
                    UIStateTitle: nil,
                    UIStateMessage: nil,
                    UIStateButton: nil,
                    UIStateCancelButton: nil
                )
            } else {
                waitingRemoteParticipantPopUp = nil
            }
        }
    }

    var mainVideoConfiguration: VideoCallView.Configuration {
        isDisplayingRemoteAsMainView ? remoteVideoConfiguration : localVideoConfiguration
    }

    var secondaryVideoConfiguration: VideoCallView.Configuration {
        isDisplayingRemoteAsMainView ? localVideoConfiguration : remoteVideoConfiguration
    }

    @Published var remoteVideoConfiguration: VideoCallView.Configuration = .init()
    @Published var localVideoConfiguration: VideoCallView.Configuration = .init(shouldMirror: true)

    private var cameraManager: CameraManager? = CameraManager(position: .front)

    func toggleLocalCameraPosition() {
        cameraManager?.position = cameraManager?.position == .front ? .back : .front
        localVideoConfiguration.shouldMirror = cameraManager?.position == .back
    }

    var localVideoTrack: LocalVideoTrack? {
        cameraManager?.track
    }

    @Published var localAudioTrack: LocalAudioTrack? = LocalAudioTrack()
    
    @Published var isMicEnabled: Bool = false {
        didSet {
            guard isMicEnabled != oldValue else {
                return
            }
            
            if let audioTrack = localAudioTrack {
                if isMicEnabled {
                    room?.localParticipant?.publishAudioTrack(audioTrack)
                } else {
                    room?.localParticipant?.unpublishAudioTrack(audioTrack)
                }
            } else {
                isMicEnabled = false
            }
        }
    }
    
    @Published var isCamEnabled: Bool = false {
        didSet {
            guard isCamEnabled != oldValue else {
                return
            }
            
            if let videoTrack = localVideoTrack {
                if isCamEnabled {
                    room?.localParticipant?.publishVideoTrack(videoTrack)
                    videoTrack.isEnabled = true
                } else {
                    videoTrack.isEnabled = false
//                    room?.localParticipant?.localVideoTracks.first?.isTrackEnabled = false
//                    room?.localParticipant?.unpublishVideoTrack(videoTrack)
                }
            } else {
                isCamEnabled = false
            }
        }
    }

    @Published var waitingRemoteParticipantPopUp: Popup?

    override init() {
        super.init()
        self.localVideoConfiguration.videoTrack = cameraManager?.track
    }
    
    func roomDidConnect(room: Room) {
        isMicEnabled = true
        isCamEnabled = true
        
        room.remoteParticipants.forEach { $0.delegate = self }
        updateDisplayingRemote()
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        print("Failed room recording \(error.localizedDescription)")
        
        // 📝 Registrar error en Firebase (temporalmente comentado)
        // TODO: Agregar FirebaseLogger.swift al target de Xcode
        // FirebaseLogger.shared.logVideoCallError(
        //     action: "room_connection_failed",
        //     error: error,
        //     roomName: room.name
        // )
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        participant.delegate = self
        updateDisplayingRemote()
        isParticipantConnected = true
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func participantDidReconnect(room: Room, participant: RemoteParticipant) {
        updateDisplayingRemote()
        isParticipantConnected = true
    }

    func updateDisplayingRemote() {
        isDisplayingRemoteAsMainView = (room?.remoteParticipants.count ?? 0) > 0
        isParticipantConnected = false
    }
}

extension VideoCallViewModel: CameraSourceDelegate {
    func roomDidStartRecording(room: Room) {
        print("Room started recording")
    }
    
    func roomDidStopRecording(room: Room) {
        print("Room did stop recording")
    }
    
    func cameraSourceInterruptionEnded(source: CameraSource) {
        print("Camera source")
    }
    
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        print("Camera source")
    }
    
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        print("Camera source error: \(error.localizedDescription)")
        
        // 📝 Registrar error en Firebase (temporalmente comentado)
        // FirebaseLogger.shared.logCameraError(
        //     action: "camera_source_failed",
        //     error: error
        // )
    }
}

extension VideoCallViewModel: RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        remoteVideoConfiguration.videoTrack = videoTrack
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        print("Did unsubscribe to track")
    }
    
    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        print("Random")
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        print("Random")
    }
    
    func remoteParticipantSwitchedOnVideoTrack(participant: RemoteParticipant, track: RemoteVideoTrack) {
        print("Random")
    }
    
    func remoteParticipantSwitchedOffVideoTrack(participant: RemoteParticipant, track: RemoteVideoTrack) {
        print("Random")
    }
    
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        print("Random")
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        print("Random")
    }
    
    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        print("Random")
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        print("Random")
    }
    
    func remoteParticipantNetworkQualityLevelDidChange(
        participant: RemoteParticipant,
        networkQualityLevel: NetworkQualityLevel
    ) {
        print("Random")
    }
}
