//
//  OverlayView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 18/10/2022.
//

import SwiftUI

struct OverlayView<Content: View>: View {
    var isLoading: Bool
    let content: () -> Content
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                content()
                    .frame(width: proxy.size.width, height: proxy.size.height)

                if isLoading {
                    Color(white: 0.0, opacity: 0.25)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)

                    ProgressView()
                }
            }
        }
    }

    init(isLoading: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.isLoading = isLoading
        self.content = content
    }
}

extension View {
    func overlayView(_ value: Bool) -> some View {
        OverlayView(isLoading: value) {
            self
        }
    }
}

