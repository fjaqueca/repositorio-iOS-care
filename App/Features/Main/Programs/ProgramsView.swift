//
//  ProgramsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/04/2023.
//

import Foundation
import SwiftUI
import RealmSwift
import CachedAsyncImage

// MARK: - Loading View Helper
/*private struct CenteredLoadingView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ProgressView()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}*/

struct ProgramsView: View {
    var programIconUrl: String = ""
    @State var programs: Programs? = nil
    @State private var showFilterView: Bool = false
    @State var isLoading: Bool = false

    var body: some View {
        NavigationViewCustom {
            ZStack {
                VStack(spacing: 0) {
                    Divider()
                    let hasPrograms: Bool = {
                        guard let program = programs else { return false }
                        return !Array(program.records.filter {
                            ($0.estadoC == "En Curso" || $0.estadoC == "Completo" || $0.estadoC == "No Iniciado") && $0.ocultarListaProgramasC == false
                        }).isEmpty
                    }()

                    Group {
                        if !isLoading && !hasPrograms {
                            emptyStateView
                        } else {
                            ScrollView {
                                VStack(spacing: 20) {
                                    if let program = programs {
                                        let visiblePrograms = Array(program.records.filter {
                                            ($0.estadoC == "En Curso" || $0.estadoC == "Completo" || $0.estadoC == "No Iniciado") && $0.ocultarListaProgramasC == false
                                        })
                                        ForEach(visiblePrograms) { p in
                                            ProgramCard(program: p)
                                        }
                                    }
                                }
                                .padding(.margin)
                            }
                        }
                    }
                    .padding(.top, .margin)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Mis Programas")
                                .font(.appTabTitleBold)
                                .foregroundColor(.primaryText)
                            /*Text("Prueba Felipe")
                                .font(.appTabTitleBold)
                                .foregroundColor(.primaryText)*/
                        }
                    }
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            Button {
//                                showFilterView.toggle()
//                            } label: {
//                                Image("filter")
//                            }
//                        }
//                    }
                }
                .blur(radius: isLoading ? 3 : 0.000001)
                
                if isLoading {
                    CenteredLoadingView()
                        .onAppear {
                            getPrograms()
                        }
                }
            }
            .onAppear{
                isLoading = true
            }
            .configureNavigation()

        }
        .accentColor(.blue)
    }
    // MARK: - Empty State (paridad con Web/Android)
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Spacer()

            CachedAsyncImage(
                url: URL(string: programIconUrl),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .opacity(0.4)
                },
                placeholder: {
                    Image("programs")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .opacity(0.4)
                })

            Text("Sin programas asociados")
                .font(Font.custom("FiraSans-Bold", size: 19))
                .foregroundColor(Color(hex: "#5B6770"))

            Text("Aún no has hecho uso de tus programas disponibles")
                .font(Font.custom("FiraSans-Regular", size: 15))
                .foregroundColor(Color(hex: "#C4C4C4"))
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func getPrograms(){
        Task {
            let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
            let programResult = await Network.shared.getPrograms(accountId: accountId)
            
            print("programResult:", programResult)
            
            switch programResult {
                case let .success(program):
                self.programs = program
                print("programs:", programs ?? "nill")
                
                
                case let .failure(error):
                    AppStatusManager.error(error)
                    
            }
            self.isLoading = false
        }
    }
}

