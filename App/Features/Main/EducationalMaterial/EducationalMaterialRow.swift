//
//  EducationalMaterialRow.swift
//  CareAssistance
//
//  Created by The App Master on 09/02/2024.
//

import SwiftUI

struct EducationalMaterialRow: View {
    @State private var isPresentingDetails = false
    let material: EducationalMaterial.EducationalMaterialRecords
    @State var isFavorite: Bool = false
    @Binding var isLoadingFavorite: Bool
    @Binding var isLoadingMaterial: Bool
    @Binding var UIState: EducationalMaterialUIState
    var body: some View {
        Button(action: {
            isPresentingDetails = true
        }) {
            HStack{
                Text(material.Name ?? "")
                    .font(Font.custom(UIState.materialList.itemNames.font, size: CGFloat(Int(UIState.materialList.itemNames.size) ?? 18)))
                    .foregroundColor(Color(hex: UIState.materialList.itemNames.color))
                Spacer()
                Button(action: {
                    changeFavorite()
                }) {
                    
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor( isFavorite ? Color(hex: UIState.materialList.btnFavorite.active) : Color(hex: UIState.materialList.btnFavorite.inActive))
                    

                }
                .onAppear{
                    isFavorite = material.favoritoAppC ?? false
                }
            }
            .padding(.margin)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.margin / 2)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(hex: UIState.materialList.borderItem), lineWidth: 1)
                    .shadow(radius: 20)
            )
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.materialList.borderItem), lineWidth: 1)
                    .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
            )
            .padding(.margin / 2)
            .navigationLink(isActive: $isPresentingDetails) {
                EducationalMaterialDetailsView(material: material, isFavorite: $isFavorite, isLoadingMaterial: $isLoadingMaterial, UIState: $UIState)
            }
        }
        
        
    }
    func changeFavorite(){
        let data = !isFavorite
        self.isLoadingFavorite = true
        Task {
            let result = await Network.shared.postFavorite(registerId: material.Id ?? "", objet: material.attributes?.type ?? "", data: data)
            switch result {
                case .success:
                self.isFavorite = data
                print("success")
                case let .failure(error):
                    AppStatusManager.error(error)
            }
            self.isLoadingFavorite = false
            self.isLoadingMaterial = true
        }
    }
}
