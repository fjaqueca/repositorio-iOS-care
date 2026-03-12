//
//  PrescriptionDownloadView.swift
//  CareAssistance
//
//  Created by The App Master on 05/09/2023.
//

import SwiftUI

struct PrescriptionDownloadView: View {
    @Binding var isLoadingAction: Bool
    @Binding var total: Double
    @Binding var count: Double
    @Binding var progress: Double
    @Binding var actionButton: ActionAuthPresAndExam?
    @Binding var showSheetView: Bool
    var body: some View {
        VStack{
            if count < total {
                Text("Descargando \(Int(count)) de \(Int(total)) recetas")
                ProgressView(value: progress)
                .padding()
                Button("Cerrar") {
                    isLoadingAction = false
                }
            }else{
                Text("Descarga completa (\(Int(count))/\(Int(total)))")
                ProgressView(value: progress)
                .padding()
                Button("Cerrar") {
                    isLoadingAction = false
                    if actionButton == .isShare {
                        showSheetView.toggle()
                    }
                }
            }
        }
        .padding(.margin)
    }
}
