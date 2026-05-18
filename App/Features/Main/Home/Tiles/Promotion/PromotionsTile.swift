//
//  PromotionsTile.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import WebKit

struct PromotionsTile: View {
    @Binding var UIState: HomeUIState
    @State private var showWebView = false
    @State var urlWebView: String = ""
    @State var bannerSelected: Int = 0

    var body: some View {
        TabView {
            // TEMPORAL: Lottie Banner_Dot deshabilitado, se restaura comportamiento original
            // que itera todos los banners remotos (1 a 6) con itemView.
            // Para reactivar el Lottie en slide 1, descomenta la línea lottieItemView y cambia el rango a 2...6.
            // lottieItemView(urlValor: UIState.bannersUIState.URLValor1)

            ForEach(1...6, id: \.self) { number in
                if let urlBanner = urlBanner(for: number),
                   let urlValor = urlValor(for: number),
                   !urlBanner.isEmpty {
                    itemView(urlBanner: urlBanner, urlValor: urlValor, numberBanner: number)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Use page tab style without page indicators
        .frame(height: 125) // Set a frame height to control the height of the TabView
        .sheet(isPresented: $showWebView) {
            if let _ = urlWebView.getCleanedURL() {
                SafariWebView(url: urlWebView)
            }
        }
    }

    func urlBanner(for number: Int) -> String? {
        switch number {
        case 1: return UIState.bannersUIState.URLBanner1
        case 2: return UIState.bannersUIState.URLBanner2
        case 3: return UIState.bannersUIState.URLBanner3
        case 4: return UIState.bannersUIState.URLBanner4
        case 5: return UIState.bannersUIState.URLBanner5
        case 6: return UIState.bannersUIState.URLBanner6
        default: return nil
        }
    }

    func urlValor(for number: Int) -> String? {
        switch number {
        case 1: return UIState.bannersUIState.URLValor1
        case 2: return UIState.bannersUIState.URLValor2
        case 3: return UIState.bannersUIState.URLValor3
        case 4: return UIState.bannersUIState.URLValor4
        case 5: return UIState.bannersUIState.URLValor5
        case 6: return UIState.bannersUIState.URLValor6
        default: return nil
        }
    }

    func openArchive(myUrl: String) {
        if myUrl != "" {
            if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
                self.urlWebView = myUrl
                print("URL a abrir:", urlWebView)
                self.showWebView.toggle()
            }
        }
    }

    @ViewBuilder
    func itemView(urlBanner: String, urlValor: String, numberBanner: Int) -> some View {
        Button {
            self.bannerSelected = numberBanner
            openArchive(myUrl: urlValor)
        } label: {
            CachedAsyncImage(
                url: URL(string: urlBanner),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    ProgressView()
                })
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .cornerRadius(.cornerRadius)
            .padding(.horizontal, .margin / 2)
        }
    }

    // TEMPORAL: función lottieItemView conservada como referencia, pero LottieView deshabilitado.
    // No se llama desde el TabView (el slide 1 ahora usa itemView con URL remota).
    // Para reactivar, descomenta el LottieView y vuelve a invocar lottieItemView en el body.
    @ViewBuilder
    func lottieItemView(urlValor: String) -> some View {
        Button {
            self.bannerSelected = 1
            openArchive(myUrl: urlValor)
        } label: {
            // LottieView(
            //     animationName: "Banner_Dot",
            //     loopMode: .loop,
            //     contentMode: .scaleAspectFill
            // )
            // .frame(maxWidth: .infinity)
            // .frame(height: 120)
            // .clipped()
            // .cornerRadius(.cornerRadius)
            // .padding(.horizontal, .margin / 2)
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .cornerRadius(.cornerRadius)
                .padding(.horizontal, .margin / 2)
        }
    }
}
