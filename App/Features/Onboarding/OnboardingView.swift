//
//  OnboardingView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/08/2022.
//

import SwiftUI
import CachedAsyncImage
import RealmSwift
import Lottie
import SDWebImageSwiftUI

enum Navigation {
    case login
    case signUp
}

struct OnboardingView: View {
    init() {
#if CareAssistance
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(hex: "00BBDC"))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color(hex: "C8CDD2"))
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
    @State private var showCarousel: Bool = false
    @State private var showButton: Bool = false
    @State private var showVersion: Bool = false
    @State private var buttonScale: CGSize = CGSize(width: 1, height: 1)

    // Carrusel typewriter en bucle
    @State private var currentSlide: Int = 0
    @State private var slideTextReady: Bool = false
    @State private var autoAdvanceTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationViewCustom {
            ZStack{
                if isLoading {
                    ProgressView()
                        .frame(height: 200)
                        .onAppear{
                            // Delay mayor para que Lottie precargue sin presión de memoria
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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


                        TabView(selection: $currentSlide) {
                            // TEMPORAL: carousel Lottie deshabilitado, se restaura item() con URL dinámica desde Salesforce.
                            // Para reactivar los Lotties, comenta las 3 llamadas a item(...) y descomenta las llamadas a lottieItem(...).

                            // Slide 0
                            item(text: UIState.onboardingUIState.nav1.textNav.isEmpty ? "Atención virtual fácil e intuitiva con especialistas a tu disposición." : UIState.onboardingUIState.nav1.textNav, imageName: "onboarding-1", UIStateNav: UIState.onboardingUIState.nav1, slideIndex: 0)
                                .tag(0)

                            // Slide 1
                            item(text: UIState.onboardingUIState.nav2.textNav.isEmpty ? "Primer ecosistema de salud capaz de generar múltiples interacciones desde la comodidad de tu dispositivo móvil." : UIState.onboardingUIState.nav2.textNav, imageName: "onboarding-2", UIStateNav: UIState.onboardingUIState.nav2, slideIndex: 1)
                                .tag(1)

                            // Slide 2
                            item(text: UIState.onboardingUIState.nav3.textNav.isEmpty ? "Orientación, asesoría y seguimiento continuo con uno de nuestros profesionales." : UIState.onboardingUIState.nav3.textNav, imageName: "onboarding-3", UIStateNav: UIState.onboardingUIState.nav3, slideIndex: 2)
                                .tag(2)

                            // lottieItem(text: UIState.onboardingUIState.nav1.textNav.isEmpty ? "Atención virtual fácil e intuitiva con especialistas a tu disposición." : UIState.onboardingUIState.nav1.textNav, animationName: "onboarding_lottie_1", UIStateNav: UIState.onboardingUIState.nav1, slideIndex: 0)
                            //     .tag(0)
                            // lottieItem(text: UIState.onboardingUIState.nav2.textNav.isEmpty ? "Primer ecosistema de salud capaz de generar múltiples interacciones desde la comodidad de tu dispositivo móvil." : UIState.onboardingUIState.nav2.textNav, animationName: "Medical_App", UIStateNav: UIState.onboardingUIState.nav2, slideIndex: 1)
                            //     .tag(1)
                            // lottieItem(text: UIState.onboardingUIState.nav3.textNav.isEmpty ? "Orientación, asesoría y seguimiento continuo con uno de nuestros profesionales." : UIState.onboardingUIState.nav3.textNav, animationName: "Front_Line_Doctos", UIStateNav: UIState.onboardingUIState.nav3, slideIndex: 2)
                            //     .tag(2)
                        }
                        .tabViewStyle(.page)
                        .accentColor(Color.red)
                        .animation(.easeInOut(duration: 0.5), value: currentSlide)
                        .opacity(showCarousel ? 1 : 0)
                        .offset(y: showCarousel ? 0 : 30)
                        .onChange(of: currentSlide) { _ in
                            animateSlide()
                        }

                        // Botón "Iniciar sesión" con animación squeeze al tap
                        Button {
                            animateButtonAndNavigate()
                        } label: {
                            Text(UIState.onboardingUIState.btnLogin.textBtn != "" ? UIState.onboardingUIState.btnLogin.textBtn : "Iniciar sesión")
                                .font(Font.custom(UIState.onboardingUIState.btnLogin.font.isEmpty ? "FiraSans-Bold" : UIState.onboardingUIState.btnLogin.font, size: CGFloat(Int(UIState.onboardingUIState.btnLogin.size) ?? 18)))
                                .foregroundColor(UIState.onboardingUIState.btnLogin.colorTextBtn != "" ? Color(hex: UIState.onboardingUIState.btnLogin.colorTextBtn) : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: .buttonTitleHeight)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(UIState.onboardingUIState.btnLogin.backgroundBtn != "" ? Color(hex: UIState.onboardingUIState.btnLogin.backgroundBtn) : .secondary)
                        .scaleEffect(buttonScale)
                        .opacity(showButton ? 1 : 0)
                        .offset(y: showButton ? 0 : 30)

                        // Chip de versión
                        Text("V. \(appVersion())")
                            .font(Font.custom("FiraSans-Regular", size: 12))
                            .foregroundColor(UIState.onboardingUIState.nav1.colorTextNav != "" ? Color(hex: UIState.onboardingUIState.nav1.colorTextNav).opacity(0.7) : .white.opacity(0.7))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .opacity(showVersion ? 1 : 0)
                    }
                    .padding(.horizontal, .margin)
                    .padding(.bottom, .margin * 2)
                    .background(
                        Group {
                            // TEMPORAL: dotLottie deshabilitado, se restaura fondo dinámico desde Salesforce.
                            // Para reactivar el Lottie animado, comenta el bloque if/else y descomenta el LottieView.
                            if UIState.onboardingUIState.imageBackground != "" {
                                CachedAsyncImage(
                                    url: URL(string: UIState.onboardingUIState.imageBackground ),
                                    content: { image in
                                        image
                                            .resizable()
                                            .edgesIgnoringSafeArea(.all)
                                    },
                                    placeholder: { ProgressView() }
                                )
                                .eraseToAnyView()
                            } else {
                                Image("onboarding-background")
                                    .resizable()
                                    .edgesIgnoringSafeArea(.all)
                                    .aspectRatio(contentMode: .fill)
                                    .eraseToAnyView()
                            }
                            // LottieView(
                            //     animationName: "gradient_background",
                            //     loopMode: .loop,
                            //     contentMode: .scaleAspectFill
                            // )
                            // .edgesIgnoringSafeArea(.all)
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
                    .onAppear {
                        triggerEntryAnimations()
                    }
                }

            }

        }
        .onChange(of: items){ newValue in
            loadUIState()
        }
    }

    // MARK: - Entry Animations

    private func triggerEntryAnimations() {
        // Carousel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                showCarousel = true
            }
        }
        // Botón
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                showButton = true
            }
        }
        // Versión
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                showVersion = true
            }
        }
        // Arrancar typewriter del primer slide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animateSlide()
        }
    }

    // MARK: - Carousel Typewriter Loop

    /// Equivalente a animateSlide() de Android:
    /// Cancela auto-advance, resetea typewriter, arranca fresco.
    private func animateSlide() {
        autoAdvanceTask?.cancel()
        slideTextReady = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            slideTextReady = true
        }
    }

    /// Equivalente a scheduleNext() de Android:
    /// Espera 2s después del typewriter y avanza con slide animado.
    private func scheduleNextSlide() {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                currentSlide = (currentSlide + 1) % 3
            }
        }
    }

    // MARK: - Button Animation

    private func cleanupCarousel() {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil
        slideTextReady = false
    }

    private func animateButtonAndNavigate() {
        HapticManager.impact(style: .medium)
        // Squeeze
        withAnimation(.easeInOut(duration: 0.12)) {
            buttonScale = CGSize(width: 1.15, height: 0.85)
        }
        // Expand
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.1)) {
                buttonScale = CGSize(width: 0.95, height: 1.05)
            }
        }
        // Settle + navigate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.08)) {
                buttonScale = CGSize(width: 1, height: 1)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            cleanupCarousel()
            navigation = .login
        }
    }

    func item(text: String, imageName: String, UIStateNav: NavUIState, slideIndex: Int) -> some View {
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
            } else {
                Image(imageName)
                    .resizable()
                    .frame(width: 155.0, height: 151.0)
                    .padding(.top, 20)
            }

            if slideTextReady && currentSlide == slideIndex {
                TypewriterText(text,
                              font: "FiraSans-Regular",
                              size: CGFloat(Int(UIStateNav.sizeTextNav) ?? 14),
                              color: UIStateNav.colorTextNav != "" ? Color(hex: UIStateNav.colorTextNav) : .white,
                              speed: 0.05, showDots: false, delay: 0.3,
                              onComplete: { scheduleNextSlide() })
                    .frame(width: 325)
                    .padding(.top, 10)
            } else {
                Text("")
                    .frame(width: 325, height: 40)
                    .padding(.top, 10)
            }
            Spacer()
        }
    }

    // TEMPORAL: función lottieItem conservada como referencia, pero LottieView deshabilitado.
    // No se llama desde el carousel (el carousel usa item() con URL dinámica). Para reactivar,
    // descomenta el LottieView y reactiva las llamadas en TabView.
    func lottieItem(text: String, animationName: String, UIStateNav: NavUIState, slideIndex: Int) -> some View {
        VStack(spacing: .margin) {
            Spacer()
            // LottieView(animationName: animationName)
            //     .frame(width: 350, height: 350)
            //     .padding(.top, 60)
            Color.clear
                .frame(width: 350, height: 350)
                .padding(.top, 60)

            if slideTextReady && currentSlide == slideIndex {
                TypewriterText(text,
                              font: "FiraSans-Regular",
                              size: CGFloat(Int(UIStateNav.sizeTextNav) ?? 14),
                              color: UIStateNav.colorTextNav != "" ? Color(hex: UIStateNav.colorTextNav) : .white,
                              speed: 0.05, showDots: false, delay: 0.3,
                              onComplete: { scheduleNextSlide() })
                    .frame(width: 325)
                    .padding(.top, 10)
            } else {
                Text("")
                    .frame(width: 325, height: 40)
                    .padding(.top, 10)
            }
            Spacer()
        }
    }

    func gifItem(text: String, gifName: String, UIStateNav: NavUIState, slideIndex: Int) -> some View {
        VStack(spacing: .margin) {
            Spacer()
            AnimatedImage(name: gifName)
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .padding(.top, 60)

            if slideTextReady && currentSlide == slideIndex {
                TypewriterText(text,
                              font: "FiraSans-Regular",
                              size: CGFloat(Int(UIStateNav.sizeTextNav) ?? 14),
                              color: UIStateNav.colorTextNav != "" ? Color(hex: UIStateNav.colorTextNav) : .white,
                              speed: 0.05, showDots: false, delay: 0.3,
                              onComplete: { scheduleNextSlide() })
                    .frame(width: 325)
                    .padding(.top, 10)
            } else {
                Text("")
                    .frame(width: 325, height: 40)
                    .padding(.top, 10)
            }
            Spacer()
        }
    }

    func appVersion(in bundle: Bundle = .main) -> String {
            guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
                return "0.0.0"
            }
            return version
        }
}
