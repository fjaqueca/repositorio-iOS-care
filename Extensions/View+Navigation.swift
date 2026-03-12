//
//  View+Navigation.swift
//  CareAssistance
//
//  Created by Lara Dubs on 04/08/2022.
//

import SwiftUI

extension View {
    public func navigationLink<Destination: View>(
        isActive: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLinkView(
            content: self,
            isActive: isActive,
            destination: destination
        )
    }

    public func navigationLink<Item, Destination: View>(
        item: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        navigationLink(
            isActive: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            destination: {
                if let item = item.wrappedValue {
                    destination(item)
                }
            }
        )
    }
}

extension View {
    func configureNavigation() -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .tabBarHidden(false)
            .removeBackButtonText()
    }

    func navigationCustom() -> some View {
        NavigationViewCustom {
            self
        }
    }
}

/// NavigationViewCustom replaces NavigationView in order to solve SwiftUI Tabview not reloading first time,
/// or subsequent until the whole view is reloaded bug.
public struct NavigationViewCustom<Content: View>: View {
    @State var title: String = ""
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(.stack)
        .overlay(Text(title).hidden())
        .onAppear {
            DispatchQueue.main.async {
                title = "Update"
            }
        }
    }
}

public struct LazyView<Content: View>: View {
    private let build: () -> Content
    public init(@ViewBuilder build: @escaping () -> Content) {
        self.build = build
    }
    public var body: Content {
        build()
    }
}

// MARK: - ViewModifier

private struct NavigationLinkView<Content: View, Destination: View>: View {
    let content: Content
    let isActive: Binding<Bool>
    let destination: () -> Destination
    @Environment(\.rootPresentation) var rootPresentation

    var body: some View {
        content
            .background(
                NavigationLink(
                    destination:
                        LazyView {
                            destination()
                                .rootPresentation(rootPresentation)
                                .removeBackButtonText()
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    ,
                    isActive: isActive,
                    label: EmptyView.init
                )
                .hidden()
            )
    }
}
