//
//  PickerPopupViewModifier.swift
//  CareAssistance
//
//  Created by Lara Dubs on 28/10/2022.
//

import SwiftUI

struct PickerPopupViewModifier<Element: Hashable & Identifiable & CustomStringConvertible>: ViewModifier {
    let title: String
    var items: [Element]
    
    @Binding var isPresented: Bool
    @Binding var selection: Element?
    
    func body(content: Content) -> some View {
        content
            .popup(isPresented: $isPresented) {
                if items.count > 10 {
                    ScrollView(showsIndicators: true) {
                        itemContent
                    }
                    .frame(height: 300.0)
                } else {
                    itemContent
                }
            }
    }

    @ViewBuilder
    var itemContent: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.appCalloutSemibold)
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.margin)
            Divider()
            ForEach(items) { item in
                Button {
                    selection = item
                    isPresented = false
                } label: {
                    HStack {
                        Text(item.description)
                            .font(.appCallout)
                            .foregroundColor(.primaryText)
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
}

extension View {
    @ViewBuilder
    func pickerPopup<Element: Hashable & Identifiable & CustomStringConvertible>(title: String, items: [Element], isPresented: Binding<Bool>, selection: Binding<Element?>) -> some View {
        self.modifier(PickerPopupViewModifier(title: title, items: items, isPresented: isPresented, selection: selection))
    }
}
