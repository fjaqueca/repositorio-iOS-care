//
//  CenteredLoadingView.swift
//  CareAssistance
//
//  Created on 16/02/2026.
//

import SwiftUI

/// Vista de loading estandarizada que aparece centrada vertical y horizontalmente
/// con padding adecuado en toda la aplicación.
///
/// Uso:
/// ```swift
/// if isLoading {
///     CenteredLoadingView()
/// }
/// ```
struct CenteredLoadingView: View {
    var body: some View {
        ZStack {
            // Fondo semitransparente opcional (comentado por defecto)
            // Color(.systemBackground).opacity(0.5).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressView()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Vista de loading estandarizada con fondo blur
/// (equivalente al patrón `.blur(radius: isLoading ? 3 : 0.000001)`)
///
/// Uso:
/// ```swift
/// ZStack {
///     // Tu contenido aquí
///     
///     if isLoading {
///         CenteredLoadingView.withBlur()
///     }
/// }
/// ```
extension CenteredLoadingView {
    static func withBlur() -> some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.01) // Mínima opacidad para capturar toques
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressView()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CenteredLoadingView()
}

#Preview("With Blur") {
    ZStack {
        VStack {
            Text("Contenido de ejemplo")
            List(0..<10) { i in
                Text("Item \(i)")
            }
        }
        
        CenteredLoadingView.withBlur()
    }
}
