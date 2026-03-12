//
//  View+Toolbar.swift
//  CareAssistance
//
//  Created by Lara Dubs on 19/10/2022.
//

import SwiftUI

private var tabBarController: UITabBarController?
private var safeAreaInsetsBottom: CGFloat = 0.0

extension TabView {
    func enableHiding() -> some View {
        self
            .introspectViewController { controller in
                safeAreaInsetsBottom = controller.view.safeAreaInsets.bottom
            }
    }
}

extension View {
    func tabBarHidden(_ value: Bool) -> some View {
        self
            .introspectTabBarController { tabBar in
                tabBarController = tabBar
            }
            .onAppear {
                tabBarController?.tabBar.isHidden = value
            }
            .padding(.bottom, value ? safeAreaInsetsBottom : 0.0)
            .ignoresSafeArea(.container, edges: value ? .bottom : [])
    }
}
