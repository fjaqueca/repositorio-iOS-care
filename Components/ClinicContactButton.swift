//
//  ClinicContactButton.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/12/2022.
//

import SwiftUI
import CachedAsyncImage

struct ClinicContactButton: View {
    
    private let title: String
    private var image: String
    private let action: () -> Void
    @Binding var UIState: ClinicUIState
    
    init(title: String, image: String, UIState: Binding<ClinicUIState> , action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.action = action
        self._UIState = UIState
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Circle()
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(Color(hex: UIState.clinicDetail.btnsArt.colorTextBtn))
                    .overlay {
                        CachedAsyncImage(
                            url: URL(string: image),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25.0, height: 25.0)
                            },
                            placeholder: {
                                ProgressView()
                            })
                    }
                Text(title)
                    .font(Font.custom(UIState.clinicDetail.btnsArt.fontTextBtn, size: CGFloat(Int(UIState.clinicDetail.btnsArt.sizeTextBtn) ?? 12)))
                    .foregroundColor(Color(hex: UIState.clinicDetail.btnTextColor))
                    .frame(maxWidth: 80)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct ClinicPopupButton: View {
    
    private let title: String
    private var image: String
    private let action: () -> Void
    private let UIState: AtrButtonsPopup
    
    init(title: String, image: String, UIState: AtrButtonsPopup , action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.action = action
        self.UIState = UIState
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Circle()
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(Color(hex: UIState.colorButton))
                    .overlay {
                        CachedAsyncImage(
                            url: URL(string: image),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25.0, height: 25.0)
                            },
                            placeholder: {
                                ProgressView()
                            })
                    }
                Text(title)
                    .font(.appSubhead)
                    .foregroundColor(Color(hex: UIState.colorText))
                    .frame(height: 50,alignment: .topLeading)
                    
            }
        }
    }
}
