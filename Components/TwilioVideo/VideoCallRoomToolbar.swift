//
//  VideoCallRoomToolbar.swift
//  CareAssistance
//
//  Created by Lara Dubs on 07/03/2023.
//

import Foundation
import SwiftUI

struct VideoCallRoomToolbar: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel: VideoCallViewModel
    
    var body: some View {
        HStack(alignment: .bottom) {
            Button {
                viewModel.toggleLocalCameraPosition()
            } label: {
                Circle()
                    .frame(width: 50.0, height: 50.0)
                    .accentColor(.gray)
                    .overlay {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .tint(Color.white)
                    }
            }
            
            Button {
                viewModel.isCamEnabled.toggle()
            } label: {
                Circle()
                    .frame(width: 50.0, height: 50.0)
                    .accentColor(.gray)
                    .overlay {
                        Image(systemName: viewModel.isCamEnabled ? "video.fill" : "video.slash.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .tint(Color.white)
                    }
            }
            
            Button {
                viewModel.isMicEnabled.toggle()
            } label: {
                Circle()
                    .frame(width: 50.0, height: 50.0)
                    .accentColor(.gray)
                    .overlay {
                        Image(systemName: viewModel.isMicEnabled ? "mic.fill" : "mic.slash.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .tint(Color.white)
                    }
            }
            
            Button {
                presentation.wrappedValue.dismiss()
            } label: {
                Circle()
                    .frame(width: 50.0, height: 50.0)
                    .accentColor(.gray)
                    .overlay {
                        Image(systemName: "phone.down.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .tint(Color.white)
                    }
            }
        }
    }
}
