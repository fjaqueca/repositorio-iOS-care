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
    @State private var isConvenioLoading: Bool = false

    // Drawer "Más opciones"

    var body: some View {
        ZStack {
            if showEmailPhone {
                NavigationViewCustom {
                    ProfileUpdateInformation(isObligatori: $showEmailPhone)
                }
            } else {
                VStack(spacing: 0) {
                    // MARK: - Contenido principal
                    ZStack {
                        if UIState.navBar.sectionNameNavbar.home != "No" {
                            HomeView(UIStateAppoint: $UIStateAppoint, UIState: $UIState, selectedColor: $selectedColor, selectedTab: $selectedTab)
                                .opacity(selectedTab == .home ? 1 : 0)
                                .zIndex(selectedTab == .home ? 1 : 0)
                        }
                        if UIState.navBar.sectionNameNavbar.program != "No" && UIState.navBar.sectionNameNavbar.program != "" {
                            ProgramsView(programIconUrl: UIState.navBar.iconsNavBar.program)
                                .opacity(selectedTab == .programs ? 1 : 0)
                                .zIndex(selectedTab == .programs ? 1 : 0)
                        }
                        if UIState.navBar.sectionNameNavbar.diary != "No" && UIState.navBar.sectionNameNavbar.diary != "" {
                            AppointmentsView(UIStateAppoint: $UIStateAppoint, selectedTab: $selectedTab)
                                .opacity(selectedTab == .appointments ? 1 : 0)
                                .zIndex(selectedTab == .appointments ? 1 : 0)
                        }
                        if UIState.navBar.sectionNameNavbar.profile != "No" && UIState.navBar.sectionNameNavbar.profile != "" {
                            ProfileView(isConvenioLoading: $isConvenioLoading)
                                .opacity(selectedTab == .profile ? 1 : 0)
                                .zIndex(selectedTab == .profile ? 1 : 0)
                        }
                    }
                    .overlay {
                        if showMore {
                            moreTabView
                        }
                    }

                    Divider()

                    // MARK: - Tab Bar Custom
                    customTabBar
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
        .onAppear {
            update = "ForcedUpdate"
        }
        .onChange(of: UIState.greetingUIState.text) { _ in
            guard let user = users.first, !user.isInvalidated,
                  let record = user.records.first, !record.isInvalidated else { return }
            if (record.PersonEmail == nil || record.PersonEmail == "") ||
               (record.Phone == nil || record.Phone == "") {
                self.showEmailPhone = true
            }
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            if UIState.navBar.sectionNameNavbar.home != "No" && UIState.navBar.sectionNameNavbar.home != "" {
                tabBarItem(
                    tab: .home,
                    label: UIState.navBar.sectionNameNavbar.home.isEmpty ? "Home" : UIState.navBar.sectionNameNavbar.home,
                    iconUrl: UIState.navBar.iconsNavBar.home,
                    fallbackImage: "home"
                )
            }
            if UIState.navBar.sectionNameNavbar.program != "No" && UIState.navBar.sectionNameNavbar.program != "" {
                tabBarItem(
                    tab: .programs,
                    label: UIState.navBar.sectionNameNavbar.program.isEmpty ? "Programas" : UIState.navBar.sectionNameNavbar.program,
                    iconUrl: UIState.navBar.iconsNavBar.program,
                    fallbackImage: "programs"
                )
            }
            if UIState.navBar.sectionNameNavbar.diary != "No" && UIState.navBar.sectionNameNavbar.diary != "" {
                tabBarItem(
                    tab: .appointments,
                    label: UIState.navBar.sectionNameNavbar.diary.isEmpty ? "Agenda" : UIState.navBar.sectionNameNavbar.diary,
                    iconUrl: UIState.navBar.iconsNavBar.diary,
                    fallbackImage: "agenda"
                )
            }
            if UIState.navBar.sectionNameNavbar.profile != "No" && UIState.navBar.sectionNameNavbar.profile != "" {
                tabBarItem(
                    tab: .profile,
                    label: UIState.navBar.sectionNameNavbar.profile.isEmpty ? "Perfil" : UIState.navBar.sectionNameNavbar.profile,
                    iconUrl: UIState.navBar.iconsNavBar.profile,
                    fallbackImage: "gray-profile"
                )
            }
            if UIState.navBar.sectionNameNavbar.more != "No" && UIState.navBar.sectionNameNavbar.more != "" {
                moreTabBarItem
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: -2)
        )
        .allowsHitTesting(!isConvenioLoading)
        .opacity(isConvenioLoading ? 0.5 : 1.0)
    }

    /// Tab item estándar (Home, Programas, Agenda, Perfil)
    private func tabBarItem(tab: Tab, label: String, iconUrl: String, fallbackImage: String) -> some View {
        Button {
            selectedTab = tab
            if showMore {
                closeMoreDrawer()
            }
        } label: {
            let isActive = selectedTab == tab
            let tintColor = isActive ? Color(hex: "#333333") : Color(hex: "#C4C4C4")
            VStack(spacing: 3) {
                // Barra horizontal indicadora encima del icono (como Android)
                RoundedRectangle(cornerRadius: 1)
                    .fill(isActive ? Color(hex: "#333333") : Color.clear)
                    .frame(width: 28, height: 2)
                CachedAsyncImage(
                    url: URL(string: iconUrl),
                    content: { image in
                        image
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 24, maxHeight: 24)
                    },
                    placeholder: {
                        Image(fallbackImage)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 24, maxHeight: 24)
                    })
                Text(label)
                    .font(.system(size: 10, weight: isActive ? .bold : .regular))
            }
            .foregroundColor(tintColor)
            .opacity(isActive ? 1.0 : 0.6)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    /// Tab item especial "Más" — estilo activo independiente controlado por showMore
    private var moreTabBarItem: some View {
        let isActive = showMore
        let tintColor = isActive ? Color(hex: "#333333") : Color(hex: "#C4C4C4")
        return Button {
            if showMore {
                closeMoreDrawer()
            } else {
                openMoreDrawer()
            }
        } label: {
            VStack(spacing: 3) {
                // Barra horizontal indicadora encima del icono (como Android)
                RoundedRectangle(cornerRadius: 1)
                    .fill(isActive ? Color(hex: "#333333") : Color.clear)
                    .frame(width: 28, height: 2)
                CachedAsyncImage(
                    url: URL(string: UIState.navBar.iconsNavBar.more),
                    content: { image in
                        image
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 24, maxHeight: 24)
                    },
                    placeholder: {
                        Image("more")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 24, maxHeight: 24)
                    })
                Text(UIState.navBar.sectionNameNavbar.more.isEmpty ? "Más" : UIState.navBar.sectionNameNavbar.more)
                    .font(.system(size: 10, weight: isActive ? .bold : .regular))
            }
            .foregroundColor(tintColor)
            .opacity(isActive ? 1.0 : 0.6)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                showMore
                    ? RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .padding(.horizontal, 6)
                    : nil
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - More Menu Overlay (Mini-Drawer — paridad Android)

    private var moreMenuItems: [(label: String, iconUrl: String, fallback: String, action: () -> Void)] {
        var items: [(label: String, iconUrl: String, fallback: String, action: () -> Void)] = []
        let nav = UIState.navBar.sectionNameNavbar
        let icons = UIState.navBar.iconsNavBar

        if nav.exam != "No" && nav.exam != "" {
            items.append((
                label: nav.exam.isEmpty ? "Exámenes" : nav.exam,
                iconUrl: icons.exam,
                fallback: "exams",
                action: { [self] in closeMoreDrawer { showMedicalExamsView = true } }
            ))
        }
        if nav.prescription != "No" && nav.prescription != "" {
            items.append((
                label: nav.prescription.isEmpty ? "Recetas" : nav.prescription,
                iconUrl: icons.prescription,
                fallback: "prescriptions",
                action: { [self] in closeMoreDrawer { showPrescriptionsView = true } }
            ))
        }
        if nav.material != "No" && nav.material != "" {
            items.append((
                label: nav.material.isEmpty ? "Material Educativo" : nav.material,
                iconUrl: icons.material,
                fallback: "educational-material",
                action: { [self] in closeMoreDrawer { showEducationalMaterialView = true } }
            ))
        }
        return items
    }

    // MARK: Abrir/cerrar drawer
    private func openMoreDrawer() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            showMore = true
        }
    }

    private func closeMoreDrawer(then action: (() -> Void)? = nil) {
        withAnimation(.easeIn(duration: 0.2)) {
            showMore = false
        }
        if let action = action {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                action()
            }
        }
    }

    private var moreTabView: some View {
        ZStack(alignment: .bottomTrailing) {
            // Backdrop (20% negro)
            Color.black.opacity(0.20)
                .ignoresSafeArea()
                .onTapGesture {
                    closeMoreDrawer()
                }

            // Card drawer
            VStack(spacing: 0) {
                // Header — barra azul + título "Más opciones"
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color(hex: "#00BBDC"))
                        .frame(width: 3, height: 13)
                    Text("Más opciones")
                        .font(Font.custom("FiraSans-Bold", size: 12))
                        .foregroundColor(Color(hex: "#5B6770"))
                        .tracking(0.3)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 11)
                .padding(.bottom, 7)

                // Items dinámicos
                ForEach(Array(moreMenuItems.enumerated()), id: \.offset) { index, item in
                    // Divider sutil entre items
                    Rectangle()
                        .fill(Color(hex: "#EEEEEE"))
                        .frame(height: 0.5)
                        .padding(.horizontal, 8)

                    Button {
                        HapticManager.selection()
                        item.action()
                    } label: {
                        HStack(spacing: 9) {
                            CachedAsyncImage(
                                url: URL(string: item.iconUrl),
                                content: { image in
                                    image
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                },
                                placeholder: {
                                    Image(item.fallback)
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                })
                                .foregroundColor(Color(hex: "#333F48"))

                            Text(item.label)
                                .font(Font.custom("FiraSans-Regular", size: 13))
                                .foregroundColor(Color(hex: "#333F48"))
                                .lineLimit(1)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "#BDBDBD"))
                        }
                        .padding(.leading, 12)
                        .padding(.trailing, 10)
                        .padding(.vertical, 11)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 196)
            .background(
                RoundedRectangle(cornerRadius: 17)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: -4)
            .padding(.trailing, 10)
            .padding(.bottom, 8)
            .transition(.scale(scale: 0.85, anchor: .bottomTrailing).combined(with: .opacity))
        }
    }
}
