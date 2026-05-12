//
//  SecondTile.swift
//  CareAssistance
//
//  Created by The App Master on 10/01/2024.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage

struct SecondTile: View {
    @State var showAll = false
    @Binding var UIState: HomeUIState
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @Binding var totalSubHomes: [String]
    @Binding var currentSubHome: [String]
    @Binding var tipeSubHome: [Int]
    @State var subHomeName: String = ""
    @Binding var selectedTab: Tab
    @ObservedResults(BrandAccounts.self) var brandItems
    
    
    var body: some View {
        VStack {
            HStack {
                Text(UIState.secondLabelUIState.text)
                    .font(Font.custom(UIState.secondLabelUIState.font, size: CGFloat(Int(UIState.secondLabelUIState.size) ?? 18)))
                    .foregroundColor(Color(hex: UIState.secondLabelUIState.color))
                Spacer()
                if tipeSubHome.count == 0{
                    Button {
                        HapticManager.selection()
                        showAll = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(UIState.labelSeeAllUIState.text.isEmpty ? "Ver todo" : UIState.labelSeeAllUIState.text)
                                .font(Font.custom(UIState.labelSeeAllUIState.font, size: CGFloat(Int(UIState.labelSeeAllUIState.size) ?? 13)))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: UIState.labelSeeAllUIState.color))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color(hex: UIState.labelSeeAllUIState.color).opacity(0.1))
                        )
                    }
                    .bounceOnTap()
                    .padding(.trailing, .margin)
                }
            }
            
            
            HStack(alignment: .firstTextBaseline) {
                ForEach(brandItems) { brands in
                    ForEach(brands.records) { brand in
                        if currentSubHome.indices.contains(1), brand.Name == currentSubHome[1]{
                            if tipeSubHome.last != nil && tipeSubHome.last == 3{
                                TileObjectSecondView(brand: brand, UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome,tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                                    .onAppear{
                                        self.subHomeName = currentSubHome[1]
                                    }
                            }else{
                                TileObjetcView(brand: brand, UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome,tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                                
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

