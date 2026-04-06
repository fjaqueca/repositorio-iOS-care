//
//  PrescriptionDownloadView.swift
//  CareAssistance
//
//  Created by The App Master on 05/09/2023.
//

import SwiftUI

struct PrescriptionDownloadView: View {
    @Binding var total: Double
    @Binding var count: Double

    var isComplete: Bool { count >= total && total > 0 }

    var body: some View {
        VStack(spacing: 16) {
            if !isComplete {
                ProgressView()
                    .scaleEffect(1.4)
                    .padding(.top, 8)

                Text("Descargando \(Int(count) + 1) de \(Int(total))")
                    .font(Font.custom("FiraSans-Medium", size: 16))
                    .foregroundColor(.primary)

                Text("Por favor espera...")
                    .font(Font.custom("FiraSans-Regular", size: 13))
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .padding(.top, 8)

                Text("Descarga completa")
                    .font(Font.custom("FiraSans-Medium", size: 16))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}
