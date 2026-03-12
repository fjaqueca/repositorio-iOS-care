//
//  StagesTaskRowView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/04/2023.
//

import SwiftUI

struct TaskRowView: View {
    let task: Goals.Goal
    @State private var isPresentingDetails = false
    @State private var isOn = false
    @State var isFavorite: Bool = false
    @State var percentage: Int = 0
    @Binding var isLoadingFavorite: Bool
    @Binding var isLoadingTasks: Bool
    let programId: String
    let puntosActivos: Bool
    let puntosObtener: Float
    let puntosAcumulados: Float
    @State private var sized: Int = 9
    
    // ✅ NUEVO: Recibir estado de navegación del padre
    @EnvironmentObject var navigationState: NavigationState

    var body: some View {
        /*Button(action: {
            if (task.estadoC ?? "No Iniciado") == "Completo"{
                showPopup.toggle()
            }
            if let actividades = task.actividadesR {
                if (task.estadoC ?? "No Iniciado") == "En Curso"{
                    isPresentingDetails = true
                }
            }
        })*/
        
        Button(action: {
            if let _ = task.actividadesR {
                let estado = task.estadoC ?? "No Iniciado"

                // Permitir entrar tanto En Curso como Completo
                if estado == "En Curso" || estado == "Completo" {
                    isPresentingDetails = true
                }
            }
        }) {
            HStack {
                CircularProgressView(progress: (CGFloat(percentage) / 100.0), fontSize: sized)
                        .frame(width: 34, height: 34)
                        .padding()
                        .onAppear{
                            percentage = Int(task.cumplimientoDeLaTareaC ?? 0)
                            isFavorite = task.favoritoAppC ?? false
                        }
                VStack(alignment: .leading) {
                    Text(task.nombrePersonalizadoC ?? "")
                        .font(.appSmallMediumForTasks)
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    /*Text("\(Int(task.cantDeElementosPorTareaC ?? 0)) Elementos")
                        .font(.appCaption)
                        .foregroundColor(.secondaryText)*/
                }
                
                Spacer()
                
                VStack {
                    Text(task.estadoC ?? "-")
                        .font(.appCaptionMedium)
                        .foregroundColor(.primaryText)
                    //Spacer()
                    
                    if puntosActivos {
                        Text("\(Int(task.puntosAcumuladosC ?? 0.0))/\(Int(task.puntosAObtenerC ?? 0.0))pts")
                            .font(.appCaption)
                            .foregroundColor(.buttonPrimaryBackground)
                    }
                }
            
                /*if puntosActivos {
                    //Text("\(Int(task.puntosAObtenerC ?? 0))pts")
                    Text("\(Int(task.puntosAcumuladosC ?? 0.0))/\(Int(task.puntosAObtenerC ?? 0.0))pts")
                        .font(.appSmallMedium)
                        .foregroundColor(.primaryText)
                        .frame(width: 50)
                }*/
                
                Button(action: {
                    changeFavorite()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(.secondaryText)
                }

            }
            /*.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.margin)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.grayLight, lineWidth: 1)
                    .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
            )
            .cornerRadius(4)*/
            
            
            
             .padding(.margin)
             .frame(height: 90)
             .cornerRadius(.cornerRadius)
             .overlay(
                 RoundedRectangle(cornerRadius: .cornerRadius)
                     .stroke(Color.grayLight, lineWidth: 1)
                     .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
             )
            
            
            
            
            
            
            
            
        }
        .opacity((task.estadoC == "En Curso" || task.estadoC == "Completo") ? 1 : 0.5)
        .frame(height: 60)
        .padding(.vertical, .margin)
        .navigationLink(isActive: $isPresentingDetails) {
            if let activities = task.actividadesR {
                ElementsView(
                    totalActivities: Int(task.cantDeElementosPorTareaC ?? 0.0),
                    taskTitle: task.nombrePersonalizadoC ?? "",
                    taskId: task.Id ?? "",
                    taskData: task,
                    allActivities: activities,
                    progress: percentage,
                    isFavorite: $isFavorite,
                    isLoadingTasks: $isLoadingTasks,
                    programa_id: programId,
                    puntosActivos: puntosActivos,
                    puntosObtener: puntosObtener,
                    puntosAcumulados: puntosAcumulados
                )
                .environmentObject(navigationState)  // ✅ PASAR ESTADO
            }
        }
    }
    func changeFavorite(){
        let data = !isFavorite
        self.isLoadingFavorite = true
        Task {
            let result = await Network.shared.postFavorite(registerId: task.Id ?? "", objet: task.attributes?.type ?? "", data: data)
            switch result {
                case .success:
                self.isFavorite = data
                await AppStatusManager.loadFavoriteTask()
                case let .failure(error):
                    AppStatusManager.error(error)
            }
            self.isLoadingFavorite = false
            self.isLoadingTasks = true
        }
    }
}

