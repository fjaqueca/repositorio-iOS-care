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
            .sheet(isPresented: $isPresented) {
                sheetContent
                    .modifier(SheetDetentsModifier(itemCount: items.count))
            }
    }

    private var sheetContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(Font.custom("FiraSans-Bold", size: 18))
                    .foregroundColor(.primaryText)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.systemGray3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            // Lista
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(items) { item in
                        Button {
                            selection = item
                            isPresented = false
                        } label: {
                            HStack(spacing: 12) {
                                // Icono de selección
                                ZStack {
                                    Circle()
                                        .stroke(selection == item ? Color.clear : Color(.systemGray4), lineWidth: 1.5)
                                        .frame(width: 22, height: 22)

                                    if selection == item {
                                        Circle()
                                            .fill(Color.buttonPrimaryBackground)
                                            .frame(width: 22, height: 22)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }

                                Text(item.description)
                                    .font(Font.custom("FiraSans-Regular", size: 16))
                                    .foregroundColor(.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selection == item ? Color(.systemGray6) : Color.clear)
                                    .padding(.horizontal, 12)
                            )
                        }
                        .buttonStyle(.plain)

                        if item.id != items.last?.id {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
    }
}

private struct SheetDetentsModifier: ViewModifier {
    let itemCount: Int

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents(itemCount > 6 ? [.medium, .large] : [.medium])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func pickerPopup<Element: Hashable & Identifiable & CustomStringConvertible>(title: String, items: [Element], isPresented: Binding<Bool>, selection: Binding<Element?>) -> some View {
        self.modifier(PickerPopupViewModifier(title: title, items: items, isPresented: isPresented, selection: selection))
    }
}
