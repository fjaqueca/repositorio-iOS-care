////
////  MediaSetupView.swift
////  CareAssistance
////
////  Created by Lara Dubs on 28/11/2022.
////
//
//import SwiftUI
//import Combine
//import TwilioVideo
//
//struct MediaSetupView: View {
//    @EnvironmentObject var viewModel: MediaSetupViewModel
//    @EnvironmentObject var localParticipant: LocalParticipantManager
//    @Environment(\.presentationMode) var presentationMode
//    let roomName: String
//    @Binding var isMediaSetup: Bool
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.background.ignoresSafeArea()
//
//                VStack {
//                    Text("Join " + roomName)
//                        .font(.title2)
//                    
//                    ParticipantView(viewModel: $viewModel.participant)
//                        .aspectRatio(1, contentMode: .fit)
//                        .padding(.horizontal, 70)
//                        .padding(.vertical)
//
//                    HStack {
//                        Spacer()
//                        MicToggleButton()
//                        CameraToggleButton()
//                        Spacer()
//                    }
//                    
//                    Spacer()
//                    Spacer()
//                    
//                    Button("Join Now") {
//                        isMediaSetup = true
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                    .buttonStyle(PrimaryButtonStyle())
//                    .padding(.horizontal, 40)
//
//                    Spacer()
//                    Spacer()
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }
//            }
//            .onAppear {
//                isMediaSetup = false
//                localParticipant.isMicOn = true
//                localParticipant.isCameraOn = true
//            }
//            .onDisappear {
//                // Is called for cancel button and swipe dismiss gesture
//                if !isMediaSetup {
//                    localParticipant.isMicOn = false
//                    localParticipant.isCameraOn = false
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
//        }
//    }
//}
//
//struct MediaSetupView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediaSetupView(roomName: "Demo", isMediaSetup: .constant(true))
//            .environmentObject(MediaSetupViewModel.stub())
//            .environmentObject(LocalParticipantManager.stub())
//    }
//}
//
//extension MediaSetupViewModel {
//    static func stub() -> MediaSetupViewModel {
//        let viewModel = MediaSetupViewModel()
//        viewModel.participant = ParticipantViewModel.stub(networkQualityLevel: .unknown)
//        return viewModel
//    }
//}
//
//class MediaSetupViewModel: ObservableObject {
//    @Published var participant = ParticipantViewModel()
//    private var localParticipant: LocalParticipantManager!
//    private var subscriptions = Set<AnyCancellable>()
//
//    func configure(localParticipant: LocalParticipantManager) {
//        self.localParticipant = localParticipant
//
//        localParticipant.changePublisher
//            .map { ParticipantViewModel(participant: $0, shouldHideYou: true) }
//            .sink { [weak self] participant in self?.participant = participant }
//            .store(in: &subscriptions)
//    }
//}
