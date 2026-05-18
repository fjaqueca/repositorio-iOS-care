//
//  BrandViews.swift
//  CareAssistance
//
//  Created by The App Master on 29/04/2025.
//

import SwiftUI
import CachedAsyncImage

struct BrandGridView: View {
    let buttons: [BrandButton]
    let gridItemLayout = [GridItem(.flexible()),
                          GridItem(.flexible()),
                          GridItem(.flexible()),]

    let onTap: (BrandButton) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                ForEach(buttons.indices, id: \.self) { index in
                    let button = buttons[index]
                    Button(action: {
                        onTap(button)
                    }) {
                        
                            CachedAsyncImage(
                                url: URL(string: button.imageUrl),
                                content: { image in
                                    image
                                        .resizable()
                                        .cornerRadius(.cornerRadius)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 90, height: 120)
                                },
                                placeholder: {
                                    Color.clear
                                }
                            )
                            .cornerRadius(.cornerRadius)
                            .padding(.horizontal, .margin / 2)
                            .padding(.vertical, .margin / 2)
                        
                        
                    }
                }
            }
        }
    }
}

struct BrandSecondScrollView: View {
    let buttons: [BrandButton]
    let onTap: (BrandButton) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
                ForEach(buttons.indices, id: \.self) { index in
                    let button = buttons[index]
                    Button(action: {
                        onTap(button)
                    }) {
                        
                        CachedAsyncImage(
                            url: URL(string: button.imageUrl),
                            content: { image in
                                image
                                    .resizable()
                                    .cornerRadius(.cornerRadius)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 90, height: 120)
                            },
                            placeholder: {
                                Color.clear
                            }
                        )
                        .cornerRadius(.cornerRadius)
                        .padding(.horizontal, .margin / 2)
                        .padding(.vertical, .margin / 2)
                    }
                }
        }
    }
}
struct BrandScrollView: View {
    let buttons: [BrandButton]
    let onTap: (BrandButton) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(buttons.indices, id: \.self) { index in
                    let button = buttons[index]
                    Button(action: {
                        onTap(button)
                    }) {
                        // TEMPORAL: Lotties de los 4 primeros pilares (Físico Emocional,
                        // Financiero, Social, Telemedicina) deshabilitados. Se restaura
                        // el CachedAsyncImage dinámico que renderiza todos los pilares por igual.
                        // Para reactivar los Lotties, descomenta el bloque if/else if de abajo.
                        CachedAsyncImage(
                            url: URL(string: button.imageUrl),
                            content: { image in
                                image
                                    .resizable()
                                    .cornerRadius(.cornerRadius)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 90, height: 120)
                            },
                            placeholder: {
                                Color.clear
                            }
                        )
                        .cornerRadius(.cornerRadius)
                        .padding(.horizontal, .margin / 2)
                        .padding(.vertical, .margin / 2)

                        // if index == 0 {
                        //     VStack(spacing: 4) {
                        //         LottieView(
                        //             animationName: "Fisico_Emocional",
                        //             loopMode: .loop
                        //         )
                        //         .frame(width: 100, height: 100)
                        //         .cornerRadius(.cornerRadius)
                        //
                        //         Text("Físico Emocional")
                        //             .font(Font.custom("FiraSans-Bold", size: 12))
                        //             .foregroundColor(Color.black)
                        //             .multilineTextAlignment(.center)
                        //             .lineLimit(2)
                        //     }
                        //     .frame(width: 100, height: 130)
                        //     .padding(.horizontal, .margin / 2)
                        //     .padding(.vertical, .margin / 2)
                        // } else if index == 1 {
                        //     VStack(spacing: 4) {
                        //         LottieView(
                        //             animationName: "Financial",
                        //             loopMode: .loop
                        //         )
                        //         .frame(width: 100, height: 100)
                        //         .cornerRadius(.cornerRadius)
                        //
                        //         Text("Financiero")
                        //             .font(Font.custom("FiraSans-Bold", size: 12))
                        //             .foregroundColor(Color.black)
                        //             .multilineTextAlignment(.center)
                        //             .lineLimit(2)
                        //     }
                        //     .frame(width: 100, height: 130)
                        //     .padding(.horizontal, .margin / 2)
                        //     .padding(.vertical, .margin / 2)
                        // } else if index == 2 {
                        //     VStack(spacing: 4) {
                        //         LottieView(
                        //             animationName: "Social",
                        //             loopMode: .loop
                        //         )
                        //         .frame(width: 100, height: 100)
                        //         .cornerRadius(.cornerRadius)
                        //
                        //         Text("Social")
                        //             .font(Font.custom("FiraSans-Bold", size: 12))
                        //             .foregroundColor(Color.black)
                        //             .multilineTextAlignment(.center)
                        //             .lineLimit(2)
                        //     }
                        //     .frame(width: 100, height: 130)
                        //     .padding(.horizontal, .margin / 2)
                        //     .padding(.vertical, .margin / 2)
                        // } else if index == 3 {
                        //     VStack(spacing: 4) {
                        //         LottieView(
                        //             animationName: "Telemedicina",
                        //             loopMode: .loop
                        //         )
                        //         .frame(width: 100, height: 100)
                        //         .cornerRadius(.cornerRadius)
                        //
                        //         Text("Telemedicina")
                        //             .font(Font.custom("FiraSans-Bold", size: 12))
                        //             .foregroundColor(Color.black)
                        //             .multilineTextAlignment(.center)
                        //             .lineLimit(2)
                        //     }
                        //     .frame(width: 100, height: 130)
                        //     .padding(.horizontal, .margin / 2)
                        //     .padding(.vertical, .margin / 2)
                        // }
                    }
                }
            }
        }
    }
}
