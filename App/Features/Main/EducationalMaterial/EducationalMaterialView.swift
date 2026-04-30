//
//  EducationalMaterialView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 08/04/2023.
//

import SwiftUI
import RealmSwift

struct EducationalMaterialView: View {
    @ObservedResults(BrandAccounts.self) var items
    @Environment(\.dismiss) var dismiss
    @State var filterMaterial: String = ""
    @State private var isLoading: Bool = true
    @State var material: [EducationalMaterial.EducationalMaterialRecords]? = []
    @State var isLoadingFav: Bool = false
    @State var UIState: EducationalMaterialUIState = EducationalMaterialUIState()
    var body: some View {
        NavigationViewCustom {
            ZStack {
                VStack (spacing: 0){
                    Divider()
                    VStack(spacing: 20){
                        Text(UIState.materialList.listText.text != "" ? UIState.materialList.listText.text : "Listado de materiales")
                            .font(Font.custom(UIState.materialList.listText.font, size: CGFloat(Int(UIState.materialList.listText.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.materialList.listText.color))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack{
                            Image("search")
                                .renderingMode(.template)
                                .foregroundColor(Color(hex: UIState.materialList.colorSearch.iconColor))
                            TextField(UIState.materialList.placeholderSearch.text, text: $filterMaterial)
                                .font(Font.custom(UIState.materialList.placeholderSearch.font, size: CGFloat(Int(UIState.materialList.placeholderSearch.size) ?? 18)))
                                .foregroundColor(Color(hex: UIState.materialList.placeholderSearch.color))
                            
                        }
                        .padding(.margin)
                        .background {
                            Color(hex: UIState.materialList.colorSearch.backgrountColor)
                        }
                        .cornerRadius(10)
                        if isLoading {
                            ScrollView {
                                ProgressView()
                                    .padding()
                                    .onAppear {
                                        getEducationalMaterial()
                                    }
                            }
                        } else if let searchMaterial = searchMaterial, !searchMaterial.isEmpty {
                            ScrollView {
                                VStack {
                                    ForEach(searchMaterial, id: \.self) { filterMaterial in
                                        EducationalMaterialRow(material: filterMaterial, isLoadingFavorite: $isLoadingFav, isLoadingMaterial: $isLoading, UIState: $UIState)
                                    }
                                }
                            }
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.margin)
                    
                }
                .blur(radius: isLoadingFav ? 3 : 0.000001)
                if isLoadingFav{
                    ProgressView()
                        .padding()
                }
            }
            .task{
                loadUIState()
            }
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(UIState.materialList.title.text != "" ? UIState.materialList.title.text : "Material Educativo")
                        .font(Font.custom(UIState.materialList.title.font, size: CGFloat(Int(UIState.materialList.title.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.materialList.title.color))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.template)
                            .tint(Color(hex: UIState.materialList.colorBackArrow))
                    }
                }
            }
            .configureNavigation()
        }
    }
    var searchMaterial: [EducationalMaterial.EducationalMaterialRecords]?{
        if filterMaterial.isEmpty{
            return material?
                .sorted{$0.favoritoAppC ?? false && !($1.favoritoAppC ?? false) }
        }else {
            return material?.filter{ $0.Name?.contains(filterMaterial) ?? false}
                .sorted{$0.favoritoAppC ?? false && !($1.favoritoAppC ?? false) }
        }
    }
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Spacer()

            Image(systemName: "folder")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(Color(.systemGray3))

            Text("Sin documentos cargados...")
                .font(Font.custom("FiraSans-Bold", size: 19))
                .foregroundColor(Color(hex: "#5B6770"))

            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func getEducationalMaterial() {
        Task{
            let agreementId = AppStatusManager.selectedEnterprise?.empresaC
            let result = await Network.shared.getEducationalMaterial(agreementId: agreementId ?? "")
            self.isLoading = false
            switch result {
                case let .success(listMaterial):
                if case let materialRecords = listMaterial.records{
                    self.material = materialRecords
                }
                case let .failure(error):
                    AppStatusManager.error(error)
                
            }

        }
    }
}
