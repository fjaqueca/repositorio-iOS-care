//
//  Environment+CustomKeys.swift
//  CareAssistance
//
//  Created by Lara Dubs on 18/10/2022.
//

import SwiftUI

extension EnvironmentValues {
    var isLoading: Bool {
      get { self[LoadingKey.self] }
      set { self[LoadingKey.self] = newValue }
    }
}

private struct LoadingKey: EnvironmentKey {
    static let defaultValue = false
}

extension View {
    func isLoading(_ value: Bool) -> some View {
        environment(\.isLoading, value)
    }
}
