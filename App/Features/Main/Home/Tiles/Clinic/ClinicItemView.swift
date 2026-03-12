//
//  HealthProgramItemView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 23/08/2022.
//

import SwiftUI
import CachedAsyncImage

struct ClinicItemView: View {
    let name: String?
    let id: String?
    let brandIcon: String?

    @State private var showDetails = false

    var body: some View {
        Button {
            showDetails = true
        } label: {
            VStack {
                Circle()
                    .frame(width: 80.0, height: 80.0)
                    .foregroundColor(.white)
                    .shadow(color: .shadowLight, radius: 4, x: 1,y: 1)
                    .overlay {
                        CachedAsyncImage(
                            url: URL(string: brandIcon ?? "https://ca-backend-prd.s3.amazonaws.com/0016u00000PbDXfAAN/Iconos-azul/orientacion.png"),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30.0, height: 30.0)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                    }
                    .padding(.horizontal, .margin / 2)
                    .padding(.vertical, .margin / 2)
                Text(name ?? "Sin nombre")
                    .font(.appCaptionSemibold)
                    .minimumScaleFactor(0.5)
                Spacer()
            }
        }
        .frame(width: 100, height: 150)
        .navigationLink(isActive: $showDetails) {
//            content(clinic)
        }
    }
}
