//
//  View+Extensions.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/11/2022.
//

import SwiftUI
import UIKit
import Introspect

extension View {
    func errorAlert(error: Binding<AppError?>, buttonTitle: String = "Ok") -> some View {
        popup(isPresented: .constant(error.wrappedValue != nil)) {
            VStack(spacing: .margin) {
                Text(error.wrappedValue?.name ?? "Se produjo un error.")
                    .font(.appSubtitle)
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                Text(error.wrappedValue?.message ?? "")
                    .font(.appBody)
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                
                Button {
                    error.wrappedValue = nil
                } label: {
                    Text("Aceptar")
                        .font(.appBodyBold)
                        .foregroundColor(.primaryText)
                }
                .frame(maxWidth: 300)
                .frame(height: .buttonTitleHeight)
            }
            .padding(.margin)
        }
    }
}

extension View {
    func removeBackButtonText() -> some View {
        introspectViewController { viewController in
            viewController.navigationItem.backButtonTitle = ""
        }
    }
}

extension View {
    @ViewBuilder
    func hidden(_ value: Bool) -> some View {
        if !value {
            self
        } else {
            self.hidden()
        }
    }
}
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
