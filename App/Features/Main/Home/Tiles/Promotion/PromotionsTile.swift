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
}
