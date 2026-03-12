//
//  ClinicsTile.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage

struct FirstComponentTile: View {
    @State var showAll = false
    @Binding var UIState: HomeUIState
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @Binding var totalSubHomes: [String]
    @Binding var currentSubHome: [String]
    @Binding var tipeSubHome: [Int]
    @Binding var selectedTab: Tab
    @State var subHomeName: String = ""
    @ObservedResults(BrandAccounts.self) var brandItems
    
    
    var body: some View {
        VStack {
            HStack {
                Text(UIState.firstLabelUIState.text)
                    .font(Font.custom(UIState.firstLabelUIState.font, size: CGFloat(Int(UIState.firstLabelUIState.size) ?? 18)))
                    .foregroundColor(Color(hex: UIState.firstLabelUIState.color))
                Spacer()
                if tipeSubHome.count == 0{
                    Button {
                        showAll = true
                    } label: {
                        Text(UIState.labelSeeAllUIState.text)
                            .font(Font.custom(UIState.labelSeeAllUIState.font, size: CGFloat(Int(UIState.labelSeeAllUIState.size) ?? 16)))
                            .foregroundColor(Color(hex: UIState.labelSeeAllUIState.color))
                    }
                    .padding(.trailing, .margin)
                }
            }
            
            
                HStack(alignment: .firstTextBaseline) {
                    ForEach(brandItems) { brands in
                        ForEach(brands.records) { brand in
                            if let subHome = currentSubHome.first {
                                if brand.Name == subHome{
                                    TileObjetcView(brand: brand, UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome,tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                                        .onAppear{
                                            self.subHomeName = currentSubHome.first ?? ""
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

