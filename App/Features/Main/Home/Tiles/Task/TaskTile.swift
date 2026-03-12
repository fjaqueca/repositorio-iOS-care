//
//  TaskTile.swift
//  CareAssistance
//
//  Created by The App Master on 24/11/2023.
//

import SwiftUI
import RealmSwift

struct TaskTile: View {
    @State var showAll = false
    @State var showAllTasks = false
    @Binding var UIState: HomeUIState
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @Binding var totalSubHomes: [String]
    @Binding var currentSubHome: [String]
    @Binding var tipeSubHome: [Int]
    @State var subHomeName: String = ""
    @Binding var selectedTab: Tab
    @ObservedResults(FavoriteTasksTotal.self) var favoriteTasks
    @ObservedResults(BrandAccounts.self) var brandItems
    var body: some View {
        VStack {
            HStack {
                Text(UIState.labelTaskUIState.text)
                    .font(Font.custom(UIState.labelTaskUIState.font, size: CGFloat(Int(UIState.labelTaskUIState.size) ?? 18)))
                    .foregroundColor(Color(hex: UIState.labelTaskUIState.color))
                Spacer()
                if tipeSubHome.count == 0{
                    Button {
                        showAllTasks.toggle()
                    } label: {
                        Text(UIState.labelSeeAllUIState.text)
                            .font(Font.custom(UIState.labelSeeAllUIState.font, size: CGFloat(Int(UIState.labelSeeAllUIState.size) ?? 16)))
                            .foregroundColor(Color(hex: UIState.labelSeeAllUIState.color))
                    }
                    .padding(.trailing, .margin)
                }
            }
            
                HStack(alignment: .firstTextBaseline) {
                    if tipeSubHome.last == 3{
                        if currentSubHome.count == 3{
                            ForEach(brandItems) { brands in
                                ForEach(brands.records) { brand in
                                        if brand.Name == currentSubHome.last{
                                            TileObjetcView(brand: brand, UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome,tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                                                .onAppear{
                                                    self.subHomeName = currentSubHome.last ?? ""
                                                }
                                       }
                                    }
                                }
                        }
                    
                    }
                    if tipeSubHome.count == 0{
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .firstTextBaseline) {
                        // TODO: fav tasks
                        ForEach(favoriteTasks) { favTasks in
                            ForEach(favTasks.records) { favTaskRecord in
                                if let records = favTaskRecord.goalsR?.records{
                                    ForEach(records) { task in
                                        
                                            FavoriteTaskTile(favoriteTask: task)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    }
                }
            
        }
        .onAppear{
            configView()
        }
        .navigationLink(isActive: $showAll) {
            SeeAllView(UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome,tipeSubHome: $tipeSubHome, subHomeName: $subHomeName, selectedTab: $selectedTab)
        }
        .navigationLink(isActive: $showAllTasks) {
            SeeAllTaskView(UIState: $UIState, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome,tipeSubHome: $tipeSubHome, subHomeName: $subHomeName)
        }
    }
    func configView(){
        self.currentSubHome = []
        let currentStringSubHome = self.totalSubHomes.last ?? ""
        if currentStringSubHome.contains(";") {
            self.currentSubHome = self.totalSubHomes.last?.components(separatedBy: ";") ?? []
        } else {
            self.currentSubHome.append(currentStringSubHome)
        }
    }
}
