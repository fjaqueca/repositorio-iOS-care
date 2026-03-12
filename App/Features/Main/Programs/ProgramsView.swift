//
//  ProgramsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/04/2023.
//

import Foundation
import SwiftUI
import RealmSwift

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
    @State var programs: Programs? = nil
    @State private var showFilterView: Bool = false
    @State var isLoading: Bool = false

    var body: some View {
        NavigationViewCustom {
            ZStack {
                VStack(spacing: 0) {
                    Divider()
                    ScrollView {
                        VStack(spacing: 20) {
                            if let program = programs {
                                ForEach(program.records) { p in
                                    if ((p.estadoC == "En Curso" || p.estadoC == "Completo" || p.estadoC == "No Iniciado") && (p.ocultarListaProgramasC == false)){
                                        ProgramCard(program: p)
                                    }
                                }
                            }
                        }
                        .padding(.margin)
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

