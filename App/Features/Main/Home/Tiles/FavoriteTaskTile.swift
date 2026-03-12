//
//  FavoriteTaskTile.swift
//  CareAssistance
//
//  Created by The App Master on 15/01/2024.
//

import SwiftUI

struct FavoriteTaskTile: View {
    let favoriteTask: FavoriteTaskRecords
    @State private var showElementsView: Bool = false
    @State private var goal: Goals.Goal? // Inicializadas en el inicializador
    @State private var isFavorite: Bool = true
    @State private var isLoadingTasks: Bool = false  // Inicializadas en el inicializador

    init(favoriteTask: FavoriteTaskRecords) {
        self.favoriteTask = favoriteTask
    }

    var body: some View {
        Button {
            getStageInfo()
        } label: {
            VStack(alignment: .leading){
                HStack{
                    Circle()
                        .fill(Color(hex: "#70AEF4"))
                        .frame(width: 25, height: 25)
                        .overlay(content: {
                            Text("\(Int(favoriteTask.cumplimientoDeLaTareaC ?? 0))%")
                                    .foregroundColor(Color.white)
                                    .font(Font.appMiniCaption)
                        })
                    Spacer()
                }
                
                Text("")
                    .foregroundColor(Color.white)
                    .font(Font.appMiniCaption)
                Text(favoriteTask.nombrePersonalizadoC ?? "")
                    .lineLimit(1)
                    .foregroundColor(Color.white)
                    .font(Font.appMiniCaptionSemibold)
                Text("\(Int(favoriteTask.cantDeElementosPorTareaC ?? 0)) Elementos")
                    .foregroundColor(Color.white)
                    .font(Font.appMiniCaption)
                Text("")
                    .foregroundColor(Color.white)
                    .font(Font.appMiniCaption)
                
            }
            .padding(.margin / 2)
            
        }
        .frame(width: 100, height: 100)
        .background{
            Color.buttonPrimaryBackground
                .cornerRadius(.cornerRadius)
        }
        .padding(.margin / 2)
        .onChange(of: goal){ newValue in
            if newValue != nil{
                self.showElementsView.toggle()
            }
        }
        .navigationLink(isActive: $showElementsView){
            if let g = goal{
                if let activities = g.actividadesR{
                    /*ElementsView(
                        totalActivities: Int(favoriteTask.cantDeElementosPorTareaC ?? 0.0),
                        taskTitle: favoriteTask.nombrePersonalizadoC ?? "",
                        taskId: favoriteTask.Id ?? "",
                        taskData: g,
                        allActivities: activities,
                        progress: Int(g.cumplimientoDeLaTareaC ?? 0),
                        isFavorite: $isFavorite,
                        isLoadingTasks: $isLoadingTasks
                    )*/
                }
            }
            
        }
    }
    func getStageInfo() {
        AppStatusManager.setLoading(true)
        self.goal = nil
        Task{
            let result = await Network.shared.getTasks(stageId: favoriteTask.etapaC ?? "")
            switch result {
                case let .success(listTask):
                for tasks in listTask{
                    for task in tasks.records{
                        for t in task.goalsR.records {
                            if t.Id ?? "" == favoriteTask.Id ?? ""{
                                self.goal = t
                            }
                        }
                    }
                }
                    
                case let .failure(error):
                    AppStatusManager.error(error)
            }
            AppStatusManager.setLoading(false)
        }
    }
}
