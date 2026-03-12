//
//  OnboardingView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/08/2022.
//

import SwiftUI
import CachedAsyncImage
import RealmSwift

enum Navigation {
    case login
    case signUp
}

struct OnboardingView: View {
    init() {
#if CareAssistance
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.secondary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white
#elseif Wellbeing
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.secondary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white
#elseif BCI
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(hex: "424242"))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color(hex: "9A9A9A"))
#elseif PharmaBenefits
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(hex: "A1C7FE"))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color(hex: "C1DAFE"))
#elseif VCContigo
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.secondary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white
#elseif CareAssistanceMX
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.secondary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white
#elseif Premedic
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(hex: "009B6F"))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color(hex: "007456"))
#elseif ContigoSalud
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(hex: "52BED1"))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color(hex: "CDEEDC"))
        
#endif
    }

    @State private var navigation: Navigation?
    @ObservedResults(BrandAccounts.self) var items
    @State var UIState: PreLoginUIState = PreLoginUIState()
    @State var isLoading = true
    
    var body: some View {
        NavigationViewCustom {
            ZStack{
                if isLoading {
                    ProgressView()
                        .frame(height: 200)
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isLoading = false
                            }
                        }
                }else{
                    VStack(spacing: .margin) {
                #if BCI
                        Image("logoBCI")
                            .resizable()
                            .frame(width: 200, height: 65)
                            .padding(.top, 20)
                #endif
                #if Premedic
                    
                        Text("")
                            .frame(height: 100)
                #endif
                
                        
                        TabView {
                            item(text: "Atención virtual inmediata por medio de nuestra Clínica Virtual.", imageName: "onboarding-1", UIStateNav: UIState.onboardingUIState.nav1)
                            item(text: "Primer ecosistema de salud capaz de generar múltiples interacciones desde la comodidad de tu dispositivo móvil.", imageName: "onboarding-2", UIStateNav: UIState.onboardingUIState.nav2)
                            item(text: "Orientación, asesoría y seguimiento continuo con uno de nuestros profesionales.", imageName: "onboarding-3", UIStateNav: UIState.onboardingUIState.nav3)
                        }
                        .tabViewStyle(.page)
                        .accentColor(Color.red)
                        
                        
                        PrimaryButton(title: "Iniciar sesión", UIStateBtn: UIState.onboardingUIState.btnLogin) {
                            navigation = .login
                        }
                        
//                        Button {
//                            navigation = .signUp
//                        } label: {
//                            Text(UIState.onboardingUIState.btnRegister.textBtn != "" ? UIState.onboardingUIState.btnRegister.textBtn : "Registrarme")
//                                .foregroundColor(UIState.onboardingUIState.btnRegister.colorTextBtn != "" ? Color(hex: UIState.onboardingUIState.btnRegister.colorTextBtn) : .white)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: .buttonTitleHeight)
//                                .font(.appBody)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .tint(UIState.onboardingUIState.btnRegister.backgroundBtn != "" ? Color(hex: UIState.onboardingUIState.btnRegister.backgroundBtn) : Color.white.opacity(0.25))
                        Text("V. \(appVersion())")
                            .foregroundColor(UIState.onboardingUIState.nav1.colorTextNav != "" ? Color(hex: UIState.onboardingUIState.nav1.colorTextNav) : .white)
                    }
                    .padding(.horizontal, .margin)
                    .padding(.bottom, .margin * 2)
                    .background(
                        Group {
                                if UIState.onboardingUIState.imageBackground != "" {
                                    CachedAsyncImage(
                                        url: URL(string: UIState.onboardingUIState.imageBackground ),
                                        content: { image in
                                            image
                                                .resizable()
                                                .edgesIgnoringSafeArea(.all)
                                        },
                                        placeholder: {
                                            ProgressView()
                                        }
                                    )
                                    .eraseToAnyView()
                                } else {
                                    Image("onboarding-background")
                                        .resizable()
                                        .edgesIgnoringSafeArea(.all)
                                        .aspectRatio(contentMode: .fill)
                                        .eraseToAnyView()
                                }
                        #if Premedic
                            Image("logoPremedic")
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .aspectRatio(contentMode: .fit)
                            Spacer()
                        #endif
                            }
                    )
                    .navigationLink(item: $navigation) { value in
                        switch value {
                            case .login:
                                    SignInView(UIState: $UIState, navigation: $navigation)
                            case .signUp:
                                    SignUpView(UIState: $UIState, navigation: $navigation)
                        }
                    }
                    .configureNavigation()
                }
            
            }
            
        }
        .onChange(of: items){ newValue in
            loadUIState()
        }
    }
    
    func item(text: String, imageName: String, UIStateNav: NavUIState) -> some View {
        VStack(spacing: .margin) {
            Spacer()
            if UIStateNav.imgNav != "" {
                CachedAsyncImage(
                    url: URL(string: UIStateNav.imgNav),
                    content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 190)
                            .padding(.top, 20)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
            }else{
                Image(imageName)
                    .resizable()
                    .frame(width: 155.0, height: 151.0)
                    .padding(.top, 20)
            }
            
            Text(UIStateNav.textNav != "" ? UIStateNav.textNav : text)
                .foregroundColor(UIStateNav.colorTextNav != "" ? Color(hex: UIStateNav.colorTextNav) : .white)
                .multilineTextAlignment(.center)
                .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIStateNav.sizeTextNav) ?? 14)))
                .frame(width: 325)
                .padding(.top, 10)
            Spacer()
        }
    }
    func appVersion(in bundle: Bundle = .main) -> String {
            guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
                fatalError("CFBundleShortVersionString should not be missing from info dictionary")
            }
            return version
        }
}

