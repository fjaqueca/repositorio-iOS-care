//
//  PopUpUploadMediaView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/04/2023.
//

import SwiftUI

struct PopUpUploadMediaView<Footer: View>: View {
    private let title: String
    private let image: String
    private let titleSecondary: String
    private let imageSecondary: String
    private let footer: () -> Footer
    
    init(title: String, image: String, titleSecondary: String, imageSecondary: String, @ViewBuilder footer: @escaping () -> Footer) {
        self.image = image
        self.title = title
        self.imageSecondary = imageSecondary
        self.titleSecondary = titleSecondary
        self.footer = footer
    }
    
    var body: some View {
        HStack(spacing: .margin) {
            VStack {
                Button {
                } label: {
                    VStack {
                        Text(title)
                        Image(image)
                    }
                }
            }
            
            VStack {
                Button {
                } label: {
                    VStack {
                        Text(title)
                        Image(image)
                    }
                }
            }
            
            HStack {
                footer()
            }
        }
        .frame(idealHeight: 300)
        .padding(.horizontal, .margin)
        .padding(.top, .margin * 2)
        .padding(.bottom, .margin)
    }
}
