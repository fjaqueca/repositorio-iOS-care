//
//  ClinicsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 23/08/2022.
//

import SwiftUI
import RealmSwift

struct SeeAllView: View {
    @Binding var UIState: HomeUIState
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @Binding var totalSubHomes: [String]
    @Binding var currentSubHome: [String]
    @Binding var tipeSubHome: [Int]
    @Binding var subHomeName: String
    @Binding var selectedTab: Tab
    let isGrid: Bool = true
    @ObservedResults(BrandAccounts.self) var brandItems
    var body: some View {
            VStack {
                Divider()
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(brandItems) { brands in
                            ForEach(Array(brands.records.enumerated()), id: \.element.id) { index, brand in
                                if brand.Name == subHomeName{
                                    TileObjetcView(brand: brand, UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome,tipeSubHome: $tipeSubHome, isGrid: isGrid, selectedTab: $selectedTab)
                                        .pressable()
                                        .staggeredAppear(index: index)
                                }
                            }
                        }
                    }
                    .padding(.top, .margin)
                    .padding(.horizontal, .margin)
                }
                Spacer()
            }
            .slideInFromRight()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(UIState.labelSeeAllUIState.title.text)
                            .font(Font.custom(UIState.labelSeeAllUIState.title.font, size: CGFloat(Int(UIState.labelSeeAllUIState.title.sizeText) ?? 18)))
                            .foregroundColor(Color(hex: UIState.labelSeeAllUIState.title.colorText))
                    }
                }
            }
    }
}

struct SeeAllTaskView: View {
    @Binding var UIState: HomeUIState
    @Binding var totalSubHomes: [String]
    @Binding var currentSubHome: [String]
    @Binding var tipeSubHome: [Int]
    @Binding var subHomeName: String
    @ObservedResults(FavoriteTasksTotal.self) var favoriteTasks
    let gridItemLayout = [GridItem(.flexible()),
                          GridItem(.flexible()),
                          GridItem(.flexible()),]
    var body: some View {
            VStack {
                Divider()
                ScrollView{
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
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
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Tareas")
                            .font(.appTabTitleBold)
                            .foregroundColor(.primaryText)
                    }
                }
            }
    }
}
