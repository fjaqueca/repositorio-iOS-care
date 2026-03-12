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
