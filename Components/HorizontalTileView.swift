//
//  HorizontalTileView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/08/2022.
//

import SwiftUI
import RealmSwift

/// VIew that display an array of items in a horizontal tile fashion.
struct HorizontalTileView<Item: RealmCollectionValue & Identifiable, Content: View>: View {
    let items: Results<Item>
    let content: (Item) -> Content
    let height: CGFloat

    init(items: Results<Item>, height: CGFloat = .tileHeight, @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.content = content
        self.height = height
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: proxy.size.width * 0.9, alignment: .leading)
                    }
                    Spacer()
                        .frame(width: proxy.size.width * 0.1)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(height: height)
    }
}
