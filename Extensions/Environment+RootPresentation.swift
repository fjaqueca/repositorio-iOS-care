//
//  Environment+RootPresentation.swift
//  CareAssistance
//
//  Created by Lara Dubs on 05/11/2022.
//

import Foundation
import SwiftUI

struct RootPresentationKey: EnvironmentKey {
    static let defaultValue: RootPresentation = .init(dismiss: {})
}

extension EnvironmentValues {
    var rootPresentation: RootPresentation {
        get { return self[RootPresentationKey.self] }
        set { self[RootPresentationKey.self] = newValue }
    }
}

struct RootPresentation {
    var dismiss: () -> Void
}


extension View {
    func rootPresentation(_ value: RootPresentation) -> some View {
        environment(\.rootPresentation, value)
    }
    
    func rootPresentation(dismiss: @escaping () -> Void) -> some View {
        environment(\.rootPresentation, .init(dismiss: dismiss))
    }
}
