//
//  MainTabView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import Alamofire


enum Tab: Int, Hashable {
    case home
    case programs
    case appointments
    case profile
    case more
}


struct MainTabView: View {
    @ObservedResults(User.self) private var users
    @State private var showEmailPhone: Bool = false
    @State var selectedTab: Tab = .home
    @State private var showMore: Bool = false
    @State private var update: String = ""
    @State private var showPrescriptionsView: Bool = false
    @State private var showMedicalExamsView: Bool = false
    @State private var showEducationalMaterialView: Bool = false
    @State var UIState: HomeUIState = HomeUIState()
    @State var UIStateAppoint: AppointmentUIStateModel = AppointmentUIStateModel()
    @State var selectedColor: String = "#387FC2"

    /// Binding que intercepta la selección de "Más" (lógica Android):
    /// - "Más" nunca cambia la vista, solo hace toggle del overlay
    /// - Los demás tabs funcionan normal
    private var tabSelection: Binding<Tab> {
        Binding<Tab>(
            get: { selectedTab },
            set: { newValue in
                if newValue == .more {
                    // Como Android: solo toggle del menú, no cambiar vista
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMore.toggle()
                    }
                } else {
                    selectedTab = newValue
                    withAnimation {
                        showMore = false
                    }
                }
            }
        )
    }

    var body: some View {
        ZStack{
            if showEmailPhone{
                NavigationViewCustom{
                    ProfileUpdateInformation(isObligatori: $showEmailPhone)
                }
            }else{
                TabView(selection: tabSelection) {
                    if UIState.navBar.sectionNameNavbar.home != "No"{
                        HomeView(UIStateAppoint: $UIStateAppoint, UIState: $UIState ,selectedColor: $selectedColor, selectedTab: $selectedTab)
                            .tag(Tab.home)
                            .tabItem {
                                if UIState.navBar.sectionNameNavbar.home != ""{
                                    CachedAsyncImage(
                                        url: URL(string: UIState.navBar.iconsNavBar.home),
                                        content: { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: 30, maxHeight: 30)
                                        },
                                        placeholder: {
                                            Image("home")
                                        })
                                    Text(UIState.navBar.sectionNameNavbar.home != "" ? UIState.navBar.sectionNameNavbar.home : "Home")
                                }
                            }
                    }
                    if UIState.navBar.sectionNameNavbar.program != "No" && UIState.navBar.sectionNameNavbar.program != ""{
                        ProgramsView()
                            .tag(Tab.programs)
                            .tabItem {
                                CachedAsyncImage(
                                    url: URL(string: UIState.navBar.iconsNavBar.program),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30, maxHeight: 30)
                                    },
                                    placeholder: {
                                        Image("programs")
                                    })

                                Text(UIState.navBar.sectionNameNavbar.program != "" ? UIState.navBar.sectionNameNavbar.program : "Programas")
                            }
                    }
                    if UIState.navBar.sectionNameNavbar.diary != "No" && UIState.navBar.sectionNameNavbar.diary != ""{
                        AppointmentsView(UIStateAppoint: $UIStateAppoint, selectedTab: $selectedTab)
                            .tag(Tab.appointments)
                            .tabItem {
                                CachedAsyncImage(
                                    url: URL(string: UIState.navBar.iconsNavBar.diary),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30, maxHeight: 30)
                                    },
                                    placeholder: {
                                        Image("agenda")
                                    })


                                Text(UIState.navBar.sectionNameNavbar.diary != "" ? UIState.navBar.sectionNameNavbar.diary : "Agenda")
                            }
                            .tabBarHidden(false)
                    }
                    if UIState.navBar.sectionNameNavbar.profile != "No" && UIState.navBar.sectionNameNavbar.profile != ""{
                        ProfileView()
                            .tag(Tab.profile)
                            .tabItem {
                                CachedAsyncImage(
                                    url: URL(string: UIState.navBar.iconsNavBar.profile),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30, maxHeight: 30)
                                    },
                                    placeholder: {
                                        Image("gray-profile")
                                    })

                                Text(UIState.navBar.sectionNameNavbar.profile != "" ? UIState.navBar.sectionNameNavbar.profile : "Perfil")
                            }
                    }
                    if UIState.navBar.sectionNameNavbar.more != "No" && UIState.navBar.sectionNameNavbar.more != ""{
                        Color.clear
                            .tag(Tab.more)
                            .tabItem {
                                CachedAsyncImage(
                                    url: URL(string: UIState.navBar.iconsNavBar.more),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30, maxHeight: 30)
                                    },
                                    placeholder: {
                                        Image("more")
                                    })

                                Text(UIState.navBar.sectionNameNavbar.more != "" ? UIState.navBar.sectionNameNavbar.more : "Más")
                            }
                    }
                }
                .enableHiding()
                .accentColor(Color(hex: selectedColor))
                .onAppear {
                    update = "ForcedUpdate"
                }
                .overlay {
                    if showMore {
                        moreTabView
                    }
                }
                .fullScreenCover(isPresented: $showMedicalExamsView, content: {
                    ExamsView()
                })
                .fullScreenCover(isPresented: $showPrescriptionsView, content: {
                    PrescriptionsView()

                })
                .fullScreenCover(isPresented: $showEducationalMaterialView, content: {
                    EducationalMaterialView()
                })
            }

        }
        .onChange(of: UIState.greetingUIState.text) { _ in
            if (users.first?.records.first?.PersonEmail == nil || users.first?.records.first?.PersonEmail == "") || (users.first?.records.first?.Phone == nil || users.first?.records.first?.Phone == ""){
                self.showEmailPhone = true
            }
        }
    }

    private var moreTabView: some View {
        Color.black.opacity(0.01)
            .onTapGesture {
                withAnimation {
                    showMore = false
                }
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: .margin){
                    if UIState.navBar.sectionNameNavbar.exam != "No" && UIState.navBar.sectionNameNavbar.exam != ""{
                        Button {
                            showMedicalExamsView = true
                            showMore = false
                        } label: {
                            VStack {
                                CachedAsyncImage(
                                    url: URL(string: UIState.navBar.iconsNavBar.exam),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30, maxHeight: 30)
                                    },
                                    placeholder: {
                                        Image("exams")
                                    })

                                Text(UIState.navBar.sectionNameNavbar.exam != "" ? UIState.navBar.sectionNameNavbar.exam : "Exámenes")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    if UIState.navBar.sectionNameNavbar.prescription != "No" && UIState.navBar.sectionNameNavbar.prescription != ""{
                        Button {
                            showPrescriptionsView = true
                            showMore = false
                        } label: {
                            VStack {
                                CachedAsyncImage(
                                    url: URL(string: UIState.navBar.iconsNavBar.prescription),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30, maxHeight: 30)
                                    },
                                    placeholder: {
                                        Image("prescriptions")
                                    })


                                Text(UIState.navBar.sectionNameNavbar.prescription != "" ? UIState.navBar.sectionNameNavbar.prescription : "Recetas")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    if UIState.navBar.sectionNameNavbar.material != "No" && UIState.navBar.sectionNameNavbar.material != ""{
                        Button {
                            showEducationalMaterialView = true
                            showMore = false
                        } label: {
                            VStack {
                                CachedAsyncImage(
                                    url: URL(string: UIState.navBar.iconsNavBar.material),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30, maxHeight: 30)
                                    },
                                    placeholder: {
                                        Image("educational-material")
                                    })

                                Text(UIState.navBar.sectionNameNavbar.material != "" ? UIState.navBar.sectionNameNavbar.material : "Material")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(width: 80.0)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.vertical)
                .background(Color.white)
            }
            .offset(x: 0, y: -59.0)
    }
}
