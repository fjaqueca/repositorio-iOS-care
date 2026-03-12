//
//  ClinicIconView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 03/11/2022.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct ClinicIconView: View {
    @State var clinic: ClinicDetail
    var body: some View {
        Circle()
            .frame(width: 35.0, height: 35.0)
            .foregroundColor(.white)
            .overlay {
                CachedAsyncImage(
                    url: URL(string: clinic.icon ?? ""),
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25.0, height: 25.0)
                    },
                    placeholder: {
                        if clinic.brandBanner == nil {
                            Image("orientacion-medica")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25.0, height: 25.0)
                        } else {
                            ProgressView()
                        }
                    }
                )
            }
            .padding(.horizontal, .margin / 2)
            .padding(.vertical, .margin)
    }
}
