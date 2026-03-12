//
//  ClinicOnDemandVideoCall.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/02/2023.
//

import SwiftUI
import RealmSwift
import TwilioVideo
import CachedAsyncImage
import Introspect

struct ClinicOnDemandVideoCall: View {
    let id: String
    let clinic: ClinicDetail
    let waitingMsg: String?
    var firstWaitingTime: Int = 5
    var secondWaitingTime: Int = 5
    @Environment(\.presentationMode) var presentation
    @ObservedResults(User.self) private var users
    
    
    @State private var status: Status = .waiting
    @StateObject private var viewModel = VideoCallViewModel()
    
    @State private var callData: PostAgentWorkQueueR1?
    @State private var newCallDataToken: OnDemandNewR1.OnDemandNewData?
    @State private var positionInQueue: Int?
    @State private var membersInRoom: Int?
    @State private var pollingTask: Task<(), Error>?
    @State private var roomParticipant: Task<(), Error>?
    
    @State private var popup: Popup?
    @State var isLoading: Bool = false
    @State var showCustomExitPopup: Bool = false
    @State var showCustomWaitingPopup: Bool = false
    @State var exit: Bool = false
    @State var comment: String = ""
    @State var reConected: Bool = false
    let customPopups: PopupsTelemedicina
    @State var showNewAppointmentSelectDetails: Bool = false
    @Binding var showNewAppointment: Bool 
    @State var whatsappNumber: String = ""
    @State var popups = PopupsTelemedicina.PopupData()
    @Binding var selectedTab: Tab
    @Binding var UIStateAppoint: AppointmentUIStateModel
    private var circleLabel: String {
        guard let positionInQueue else {
            return " "
        }
        return String(positionInQueue)
    }
    
    enum Status {
        case waiting
        case call
    }
    
    var body: some View {
        content
            .popup(item: $popup)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Videollamada")
                            .font(.appTabTitleBold)
                            .foregroundColor(.primaryText)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        goBack()
                    } label: {
                        Image("back")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        
            .tabBarHidden(true)
            .task {
                enqueueForVideoCall()
            }
//            .task {
//                await startInactiveTimer()
//            }
            .navigationLink(isActive: $showNewAppointment) {
                NewAppointmentSelectDetailsView(UIStateAppoint: $UIStateAppoint, id: clinic.id, clinic: clinic, selectedTab: $selectedTab).rootPresentation {
                    showNewAppointmentSelectDetails = false
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch status {
        case .waiting:
            waitingRoomView
        case .call:
            callView
        }
    }
    
    @ViewBuilder
    var waitingRoomView: some View {
        
        ZStack {
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    CachedAsyncImage(
                        url: URL(string: clinic.fondoOndemand ?? "https://ca-backend-prd.s3.amazonaws.com/0016u00000PbDXfAAN/on_demand/fondo_on_demand.png"),
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        },
                        placeholder: {
                            Color.clear
                        })
                }
                .edgesIgnoringSafeArea(.horizontal)
                .edgesIgnoringSafeArea(.bottom)
            
            VStack(spacing: .margin * 2) {
                Spacer()
                
                Text("Sala de espera")
                    .font(.appLargeTitle)
                    .foregroundColor(.white)
                
                
                
                if let circleIntValue = Int(circleLabel) {
                    let updatedCircleValue = circleIntValue - 1
                    if updatedCircleValue == 0 {
                        Text("Usted será el próximo en ser atendido\nPor favor aguarde")
                            .font(.appSubheadRegular)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        
                    }else {
                        Text("Posición en la fila")
                            .font(.appSubheadRegular)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                        
                        Text(String(((positionInQueue ?? 1) - 1)))
                            .padding(.vertical, .margin * 2)
                            .background(
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 10)
                                    .aspectRatio(1, contentMode: .fill)
                            )
                            .font(.appHugeTitle)
                            .foregroundColor(.white)
                            .hidden(circleLabel == " ")
                    }
                }
                
                Button {
                    goBack()
                } label: {
                    Image("exit")
                }
                
                Spacer()
            }
            .blur(radius: showCustomExitPopup || showCustomWaitingPopup ? 3.0 : 0.00001)
            .onChange(of: exit) { newValue in
                if newValue == true{
                    dequeueVideoCall(status: reConected ? "Recuperar Cerrado" : "Cerrado" ,reason: comment)
                }
            }
            if self.showCustomWaitingPopup {
                CustomWaitingVideoCallPopupView(showNewAppointmentSelectDetails: $showNewAppointmentSelectDetails, showPopupPreviusVideoCall: $showCustomWaitingPopup, showOnDemandVideoCall: $showCustomExitPopup, exit: $exit, whatsappNumber: $whatsappNumber, popupData: popups)
            }
            if self.showCustomExitPopup {
                CustomExitPupUp(comment: $comment, reConected: $reConected, showCustomPopup: $showCustomExitPopup, exit: $exit, popupData: customPopups.leavePopup)
            }
            if self.isLoading{
                ProgressView()
            }
            
        }
        
    }
    
    @ViewBuilder var callView: some View {
        VStack {
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
        }
    }
    
    /// Add the user to the video call queue (waiting room).
    func enqueueForVideoCall() {
        Task {
            print("I'm enqueueing for video call")
            FirebaseLogger.shared.log("📹 Enqueueing for video call - Clinic: \(clinic.id)")
            
            let result = await Network.shared.getOnDemandVideoCall()
            switch result {
            case let .success(videoCallOnDemand):
                self.callData = videoCallOnDemand
                FirebaseLogger.shared.log("✅ Successfully enqueued for video call")
                pollQueue()
                await startInactiveTimer()
                
            case let .failure(error):
                // 📝 Registrar error en Firebase antes de mostrar al usuario
                FirebaseLogger.shared.logVideoCallError(
                    action: "enqueue_failed",
                    error: error,
                    clinicId: clinic.id
                )
                AppStatusManager.error(error)
            }
        }
    }
    
    /// Starts a timer that asks the user if he wants to leave in custom times, have 5 diferents popups.
    func startInactiveTimer() async {
        do {
            if customPopups.popup1.time != "No"{
                try await Task.sleep(nanoseconds: UInt64(stringToInt(customPopups.popup1.time) * 60) * NSEC_PER_SEC)
                await MainActor.run {
                    guard status == .waiting else {
                        return
                    }
                    popups = customPopups.popup1
                    self.showCustomWaitingPopup.toggle()
                }
            }
            if customPopups.popup2.time != "No"{
                try await Task.sleep(nanoseconds: UInt64((stringToInt(customPopups.popup2.time) - stringToInt(customPopups.popup1.time)) * 60) * NSEC_PER_SEC)
                await MainActor.run {
                    guard status == .waiting else {
                        return
                    }
                    popups = customPopups.popup2
                    self.showCustomWaitingPopup.toggle()
                }
            }
            if customPopups.popup3.time != "No"{
                try await Task.sleep(nanoseconds: UInt64((stringToInt(customPopups.popup3.time) - stringToInt(customPopups.popup2.time)) * 60) * NSEC_PER_SEC)
                await MainActor.run {
                    guard status == .waiting else {
                        return
                    }
                    popups = customPopups.popup3
                    self.showCustomWaitingPopup.toggle()
                }
            }
            if customPopups.popup4.time != "No"{
                try await Task.sleep(nanoseconds: UInt64((stringToInt(customPopups.popup4.time) - stringToInt(customPopups.popup3.time)) * 60) * NSEC_PER_SEC)
                await MainActor.run {
                    guard status == .waiting else {
                        return
                    }
                    popups = customPopups.popup4
                    self.showCustomWaitingPopup.toggle()
                }
            }
            if customPopups.popup5.time != "No"{
                try await Task.sleep(nanoseconds: UInt64((stringToInt(customPopups.popup5.time) - stringToInt(customPopups.popup4.time)) * 60) * NSEC_PER_SEC)
                await MainActor.run {
                    guard status == .waiting else {
                        return
                    }
                    popups = customPopups.popup5
                    self.showCustomWaitingPopup.toggle()
                }
            }
        } catch {
            /// Not displaying an error for this
        }
    }
    
    func stringToInt(_ str: String) -> Int{
        return Int(str) ?? 1
    }
    
    /// Removes the user from the video call waiting room.
    func dequeueVideoCall(shouldDismiss: Bool = true, status: String, reason: String) {
        Task {
            self.isLoading = true
            guard let taskId = callData?.task else {
                FirebaseLogger.shared.log("⚠️ No task ID available for dequeue")
                return
            }
            
            FirebaseLogger.shared.log("📹 Dequeuing from video call - Status: \(status), Reason: \(reason)")
            
            let result = await Network.shared.onDemandVideoCallDequeue(taskSid: taskId, status:status ,reason:reason)
            self.showCustomExitPopup = false
            self.isLoading = false
            switch result {
            case .success:
                FirebaseLogger.shared.log("✅ Successfully dequeued from video call")
                self.pollingTask?.cancel()
                if shouldDismiss == true {
                    self.presentation.wrappedValue.dismiss()
                    if showNewAppointmentSelectDetails{
                        showNewAppointment = true
                    }
                    if whatsappNumber != ""{
                        let cleanPhone = whatsappNumber.replacingOccurrences(of: "+", with: "")
                        if let url = URL(string: "whatsapp://send?phone=\(cleanPhone)") {
                            if UIApplication.shared.canOpenURL(url) {
                                await UIApplication.shared.open(url)
                            } else {
                                // Si no está instalada la app, abrimos la versión web
                                if let webUrl = URL(string: "https://api.whatsapp.com/send?phone=\(cleanPhone)") {
                                    await  UIApplication.shared.open(webUrl)
                                }
                            }
                        }
                    }
                   
                }
            case let .failure(error):
                // 📝 Registrar error en Firebase antes de mostrar al usuario
                FirebaseLogger.shared.logVideoCallError(
                    action: "dequeue_failed",
                    error: error,
                    clinicId: clinic.id
                )
                AppStatusManager.error(error)
                self.presentation.wrappedValue.dismiss()
                if showNewAppointmentSelectDetails{
                    showNewAppointment = true
                }
                if whatsappNumber != ""{
                    let cleanPhone = whatsappNumber.replacingOccurrences(of: "+", with: "")
                    if let url = URL(string: "whatsapp://send?phone=\(cleanPhone)") {
                        if UIApplication.shared.canOpenURL(url) {
                            await UIApplication.shared.open(url)
                        } else {
                            // Si no está instalada la app, abrimos la versión web
                            if let webUrl = URL(string: "https://api.whatsapp.com/send?phone=\(cleanPhone)") {
                                await  UIApplication.shared.open(webUrl)
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    /// Starts a timer that will fetch the state of the queue every 10 seconds and connects the user
    /// to the call if needed.
    private func pollQueue() {
        self.pollingTask = Task {
            guard let taskId = callData?.task else {
                FirebaseLogger.shared.log("⚠️ No task ID available for polling queue")
                return
            }
            let result = await Network.shared.getOnDemandVideoCallQueue(taskSid: taskId)
            switch result {
            case let .success(queueData):
                await MainActor.run {
                    positionInQueue = queueData.data.positionInQueue
                    FirebaseLogger.shared.log("📊 Queue position: \(queueData.data.positionInQueue)")
                }
            case let .failure(error):
                // 📝 Registrar error en Firebase
                FirebaseLogger.shared.logVideoCallError(
                    action: "poll_queue_failed",
                    error: error,
                    clinicId: clinic.id
                )
                AppStatusManager.error(error)
            }
            if positionInQueue ?? .max <= 1 {
                if UIApplication.shared.applicationState == .active {
                    requestRoomParticipants()
                } else {
                    handleInactiveUser()
                }
            } else {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 10)
                await MainActor.run {
                    pollQueue()
                }
            }
        }
    }
    
    private func requestRoomParticipants() {
        self.roomParticipant = Task {
            guard let taskId = callData?.task else {
                FirebaseLogger.shared.log("⚠️ No task ID available for room participants")
                return
            }
            let result = await Network.shared.getOnDemandVideoCallRoom(taskSid: taskId)
            switch result {
            case let .success(roomData):
                await MainActor.run {
                    membersInRoom = roomData.data.participantsInRoom.count
                    FirebaseLogger.shared.log("👥 Room participants: \(roomData.data.participantsInRoom.count)")
                }
            case let .failure(error):
                // 📝 Registrar error en Firebase
                FirebaseLogger.shared.logVideoCallError(
                    action: "get_room_participants_failed",
                    error: error,
                    clinicId: clinic.id
                )
                AppStatusManager.error(error)
            }
            if membersInRoom ?? .max >= 1{
                if UIApplication.shared.applicationState == .active {
                    requestForVideoCallToken()
                } else {
                    handleInactiveUser()
                }
            }else{
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 15)
                await MainActor.run {
                    requestRoomParticipants()
                }
            }
        }
    }
    
    /// request for token
    func requestForVideoCallToken() {
        Task {
            guard let taskId = callData?.task else {
                FirebaseLogger.shared.log("⚠️ No task ID available for token request")
                return
            }
            
            FirebaseLogger.shared.log("🎫 Requesting video call token")
            
            let result = await Network.shared.getOnDemandVideoCallToken(taskSid: taskId, phone: users.first?.records.first?.Phone ?? "", name: users.first?.records.first?.FirstName ?? "")
            switch result {
            case let .success(data):
                self.newCallDataToken = data.data
                FirebaseLogger.shared.log("✅ Video call token received")
                connectToRoom()
            case let .failure(error):
                // 📝 Registrar error en Firebase
                FirebaseLogger.shared.logVideoCallError(
                    action: "get_token_failed",
                    error: error,
                    clinicId: clinic.id
                )
                AppStatusManager.error(error)
            }
        }
    }
    
    private func connectToRoom() {
        FirebaseLogger.shared.log("📹 Connecting to video call room")
        self.status = .call
        self.roomParticipant?.cancel()
        let connectOptions = ConnectOptions(token: newCallDataToken?.token ?? "") { (builder) in
            builder.roomName = newCallDataToken?.task
        }
        self.viewModel.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self.viewModel)
    }
    
    private func handleInactiveUser() {
        popup = reconnectActiveUser
        self.showCustomExitPopup.toggle()
    }
    
    private func goBack() {
        switch status {
        case .waiting:
            self.showCustomExitPopup.toggle()
        case .call:
            popup = leavingCallRoomPopUp
        }
    }
}

extension ClinicOnDemandVideoCall {
    var leavingWaitingRoomPopUp: Popup {
        .init(
            image: "appointment-cancel",
            title: "¿Está seguro de salir de la sala de espera?",
            message: "Si sale perderá la posición en la fila.",
            actionTitle: "Aceptar",
            action: {
                self.roomParticipant?.cancel()
                self.showCustomExitPopup.toggle()
            },
            isCancellable: true,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
    
    var leavingCallRoomPopUp: Popup {
        .init(
            image: "appointment-cancel",
            title: "¿Está seguro de salir de la videollamada?",
            actionTitle: "Aceptar",
            action: {
                self.roomParticipant?.cancel()
                self.presentation.wrappedValue.dismiss()
            },
            isCancellable: true,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
    
    var reconnectActiveUser: Popup {
        .init(
            image: "appointment-cancel",
            title: "Su turno ya venció.",
            message: "¿Desea reingresar a la sala de espera?",
            actionTitle: "Aceptar",
            action: {
                enqueueForVideoCall()
            },
            isCancellable: true,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil,
            cancelAction: {
                self.presentation.wrappedValue.dismiss()
            }
        )
    }
    
    var firstTimeOutPopUp: Popup {
        .init(
            title: "¿Desea continuar aguardando en la sala de espera?",
            actionTitle: "No",
            action: {
                self.roomParticipant?.cancel()
                self.showCustomExitPopup.toggle()
            },
            isCancellable: true,
            cancelTitle: "Sí",
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
    
    var finalTimeOutPopUp: Popup {
        .init(
            title: waitingMsg ?? "Se ha superado el tiempo máximo de espera. Finalizaremos la llamada y nos comunicaremos con usted a la brevedad.",
            actionTitle: "Ok",
            action: {
                self.roomParticipant?.cancel()
                presentation.wrappedValue.dismiss()
            },
            isCancellable: false,
            UIStateTitle: nil,
            UIStateMessage: nil,
            UIStateButton: nil,
            UIStateCancelButton: nil
        )
    }
    struct CustomExitPupUp: View{
        @Binding var comment: String
        @Binding var reConected: Bool
        @Binding var showCustomPopup: Bool
        @Binding var exit: Bool
        let popupData: PopupsTelemedicina.LeavePopup
        var body: some View {
            ZStack{
                VStack(alignment: .center,spacing: 5){
                    Circle()
                        .frame(width: 50.0, height: 50.0)
                        .foregroundColor(Color(hex: popupData.iconColor))
                        .overlay {
                            CachedAsyncImage(
                                url: URL(string: popupData.iconUrl),
                                content: { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25.0, height: 25.0)
                                },
                                placeholder: {
                                    ProgressView()
                                })
                        }
                    
                    Text(popupData.text.text)
                        .font(Font.custom(popupData.text.font, size: CGFloat(Int(popupData.text.size) ?? 18)))
                        .foregroundColor(Color(hex: popupData.text.color))
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    Group {
                        ZStack(alignment: .topLeading) {
                            if comment.isEmpty {
                                Text(popupData.placeholderReason.text)
                                    .font(Font.custom(popupData.placeholderReason.font, size: CGFloat(Int(popupData.placeholderReason.size) ?? 18)))
                                    .foregroundColor(Color(hex: popupData.placeholderReason.color))
                                    .padding(.margin/2)
                                
                            }
                            TextEditor(text: $comment)
                                .foregroundColor(Color(hex: popupData.placeholderReason.color))
                                .colorMultiply(Color.textSecondary.opacity(0.3))
                                .cornerRadius(.cornerRadius)
                                .multilineTextAlignment(TextAlignment.leading)
                            
                        }
                        .font(Font.custom(popupData.placeholderReason.font, size: CGFloat(Int(popupData.placeholderReason.size) ?? 18)))
                        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .topLeading)
                        .padding(.margin)
                    }
                    .frame(height: 100)
                    .cornerRadius(.cornerRadius)
                    
                    HStack {
                        Toggle("", isOn: $reConected)
                            .toggleStyle(CheckToggleSquareStyle(foregroundColor: Color(hex: popupData.check.color)))
                        Text(popupData.check.text)
                            .font(Font.custom(popupData.check.font, size: CGFloat(Int(popupData.check.size) ?? 18)))
                            .foregroundColor(Color(hex: popupData.check.color))
                    }
                    .frame(maxWidth: .infinity)
                    HStack(spacing: 100){
                        
                        Button {
                            self.exit = true
                        } label: {
                            Text(popupData.btnConfirm.text)
                                .font(Font.custom(popupData.btnConfirm.font, size: CGFloat(Int(popupData.btnConfirm.size) ?? 18)))
                                .foregroundColor(Color(hex: popupData.btnConfirm.color))
                        }
                        Button {
                            self.exit = false
                            self.showCustomPopup = false
                        } label: {
                            Text(popupData.btnCancel.text)
                                .font(Font.custom(popupData.btnCancel.font, size: CGFloat(Int(popupData.btnCancel.size) ?? 18)))
                                .foregroundColor(Color(hex: popupData.btnCancel.color))
                        }
                        
                    }
                }
            }
            .padding()
            .background {
                Color.white
            }
            .cornerRadius(10)
        }
    }
}

struct CustomWaitingVideoCallPopupView: View {
    @Binding var showNewAppointmentSelectDetails: Bool
    @Binding var showPopupPreviusVideoCall: Bool
    @Binding var showOnDemandVideoCall : Bool
    @Binding var exit: Bool
    @Binding var whatsappNumber: String
    let popupData: PopupsTelemedicina.PopupData
    var body: some View {
        ZStack{
            VStack(spacing: 5){
                Text(popupData.text.text)
                    .font(Font.custom(popupData.text.font, size: CGFloat(Int(popupData.text.size) ?? 18)))
                    .foregroundColor(Color(hex: popupData.text.color))
                    .multilineTextAlignment(popupData.alignmentText == "Center" ? .center : .leading)
                    .padding(.bottom)
                HStack(spacing: 5){
                    if popupData.showAppointmentButton == "Si"{
                        ClinicPopupButton(title: popupData.btnAppointmentButton.text, image: popupData.btnAppointmentButton.icon, UIState: popupData.btnAppointmentButton) {
                            
                            exit = true
                            showNewAppointmentSelectDetails = true
                            showPopupPreviusVideoCall.toggle()
                            
                        }
                        .frame(width: 75)
                    }
                    if popupData.btnContinueVideoCall.text != "No"{
                        ClinicPopupButton(title: popupData.btnContinueVideoCall.text, image: popupData.btnContinueVideoCall.icon, UIState: popupData.btnContinueVideoCall) {
                            
                            showPopupPreviusVideoCall.toggle()
                            
                            
                            
                        }
                        .frame(width: 75)
                    }
                    if popupData.whatsAppNumber != "No"{
                        ClinicPopupButton(title: popupData.btnWhatsApp.text, image: popupData.btnWhatsApp.icon, UIState: popupData.btnWhatsApp) {
                            
                            exit = true
                            showPopupPreviusVideoCall.toggle()
                            whatsappNumber = popupData.whatsAppNumber
                            
                            
                            
                        }
                        .frame(width: 75)
                        
                    }
                    if popupData.btnGoOut.text != "No"{
                        ClinicPopupButton(title: popupData.btnGoOut.text, image: popupData.btnGoOut.icon, UIState: popupData.btnGoOut) {
                            
                            showOnDemandVideoCall.toggle()
                            showPopupPreviusVideoCall.toggle()
                            
                        }
                        .frame(width: 75)
                    }
                }
                
            }
            .padding()
        }
        .padding()
        .background {
            Color.white
        }
        .cornerRadius(10)
    }
}

