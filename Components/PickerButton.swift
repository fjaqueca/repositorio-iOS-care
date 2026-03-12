//
//  PickerButton.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/10/2022.
//

import SwiftUI

struct PickerButton<S: Hashable & Identifiable & CustomStringConvertible>: View {
    let title: String
    var items: [S]

    @Binding var selection: S?
    @State private var showPicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                showPicker.toggle()
            } label: {
                HStack {
                    Text(showPicker ? title : selection?.description ?? title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .rotationEffect(showPicker ? .degrees(-180) : .degrees(0))
                        .animation(.default, value: showPicker)
                }
                .padding(.horizontal, .margin / 2)
                .frame(height: 34)
            }
            .disabled(items.isEmpty)

            if showPicker {
                ForEach(items) { item in
                    Button {
                        selection = item
                        showPicker = false
                    } label: {
                        HStack {
                            Text(item.description)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if selection == item {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding(.horizontal, .margin / 2)
                        .frame(height: 34)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 4).stroke())
        .foregroundColor(.primaryText)
    }
}
