//
//  PickerSearchButton.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/04/2023.
//

import SwiftUI

struct PickerSearchButton<S: Hashable & Identifiable & CustomStringConvertible>: View {
    let title: String
    var items: [S]
    
    @Binding var selection: S?
    @State private var showPicker: Bool = false
    @State private var searchText: String = ""
    
    private var filteredItems: [S] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.description.lowercased().contains(searchText.lowercased()) }
        }
    }
    
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
                let uniqueItems = Array(Dictionary(grouping: filteredItems, by: { $0.id }).values
                    .compactMap({ $0.first }))
                    .sorted(by: { $0.description < $1.description })
                VStack {
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, .margin / 2)
                        .frame(height: 34)
                    ScrollView {
                        LazyVStack {
                            ForEach(uniqueItems) { item in
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
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 4).stroke())
        .foregroundColor(.primaryText)
    }
}
