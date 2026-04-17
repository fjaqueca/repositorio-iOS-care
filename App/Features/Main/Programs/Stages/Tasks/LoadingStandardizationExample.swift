//
//  LoadingStandardizationExample.swift
//  CareAssistance
//
//  Created on 16/02/2026.
//
//  Este archivo contiene ejemplos de uso del componente CenteredLoadingView
//  para demostrar los diferentes patrones de loading estandarizados.
//

import SwiftUI

// MARK: - Ejemplo 1: Loading Básico con Blur

struct ExampleLoadingWithBlur: View {
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<10) { i in
                            Text("Item \(i)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .blur(radius: isLoading ? 3 : 0.000001)
            
            if isLoading {
                CenteredLoadingView()
            }
        }
        .navigationTitle("Loading con Blur")
        .onAppear {
            // Simular carga de datos
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Ejemplo 2: Loading de Pantalla Completa (Overlay)

struct ExampleLoadingOverlay: View {
    @State private var isLoading = true
    @State private var showOverlay = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Contenido Principal")
                    .font(.title)
                
                Button("Mostrar Overlay Loading") {
                    showOverlay = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showOverlay = false
                        }
                    }
                }
                
                List(0..<20) { i in
                    Text("Item \(i)")
                }
            }
            
            if isLoading || showOverlay {
                CenteredLoadingView()
                    .background(Color(.systemBackground).opacity(0.95))
            }
        }
        .navigationTitle("Loading Overlay")
        .onAppear {
            // Simular carga inicial
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Ejemplo 3: Múltiples Estados de Loading

struct ExampleMultipleLoadingStates: View {
    @State private var isLoadingInitial = true
    @State private var isLoadingOperation = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    if isLoadingInitial {
                        // Placeholder para mantener ScrollView activo
                        Color.clear
                            .frame(height: 100)
                    } else {
                        VStack(spacing: 15) {
                            ForEach(0..<5) { i in
                                Button("Operación \(i)") {
                                    isLoadingOperation = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        withAnimation {
                                            isLoadingOperation = false
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            }
            .blur(radius: isLoadingOperation ? 3 : 0.000001)
            
            // Loading inicial
            if isLoadingInitial {
                CenteredLoadingView()
            }
            
            // Loading de operación
            if isLoadingOperation {
                CenteredLoadingView()
            }
        }
        .navigationTitle("Múltiples Estados")
        .onAppear {
            // Simular carga inicial
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoadingInitial = false
                }
            }
        }
    }
}

// MARK: - Ejemplo 4: Comparación Antes/Después

struct ExampleBeforeAfter: View {
    @State private var useOldPattern = true
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Toggle para cambiar entre patrón antiguo y nuevo
            Toggle("Usar Patrón Antiguo (❌)", isOn: $useOldPattern)
                .padding()
                .background(Color.yellow.opacity(0.2))
            
            Divider()
            
            ZStack {
                ScrollView {
                    if useOldPattern {
                        // ❌ PATRÓN ANTIGUO: Loading dentro del ScrollView
                        if isLoading {
                            VStack {
                                Spacer()
                                    .frame(height: 50)
                                ProgressView()
                                    .padding()
                                Text("Loading desalineado 😢")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        } else {
                            contentView
                        }
                    } else {
                        // ✅ PATRÓN NUEVO: Placeholder en ScrollView
                        if isLoading {
                            Color.clear
                                .frame(height: 100)
                        } else {
                            contentView
                        }
                    }
                }
                
                // ✅ PATRÓN NUEVO: Loading fuera del ScrollView
                if !useOldPattern && isLoading {
                    CenteredLoadingView()
                        .overlay(
                            Text("Loading centrado ✅")
                                .font(.caption)
                                .foregroundColor(.green)
                                .offset(y: 50)
                        )
                }
            }
        }
        .navigationTitle("Antes vs Después")
        .onAppear {
            startLoadingCycle()
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 15) {
            ForEach(0..<10) { i in
                Text("Contenido \(i)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func startLoadingCycle() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                isLoading = false
            }
            
            // Reiniciar el ciclo
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                startLoadingCycle()
            }
        }
    }
}

// MARK: - Vista Principal de Ejemplos

struct LoadingStandardizationExamples: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Ejemplos de Uso")) {
                    NavigationLink("1. Loading con Blur") {
                        ExampleLoadingWithBlur()
                    }
                    
                    NavigationLink("2. Loading Overlay") {
                        ExampleLoadingOverlay()
                    }
                    
                    NavigationLink("3. Múltiples Estados") {
                        ExampleMultipleLoadingStates()
                    }
                    
                    NavigationLink("4. Antes vs Después") {
                        ExampleBeforeAfter()
                    }
                }
                
                Section(header: Text("Información")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📋 Componente: CenteredLoadingView")
                            .font(.headline)
                        
                        Text("Garantiza que todos los loadings aparezcan centrados vertical y horizontalmente con padding consistente.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text("✅ Ventajas:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("• Consistencia visual\n• UX mejorada\n• Código mantenible\n• Fácil de usar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Loading Examples")
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Previews

#Preview("Ejemplos Principales") {
    LoadingStandardizationExamples()
}

#Preview("Loading con Blur") {
    NavigationView {
        ExampleLoadingWithBlur()
    }
}

#Preview("Loading Overlay") {
    NavigationView {
        ExampleLoadingOverlay()
    }
}

#Preview("Múltiples Estados") {
    NavigationView {
        ExampleMultipleLoadingStates()
    }
}

#Preview("Antes vs Después") {
    NavigationView {
        ExampleBeforeAfter()
    }
}
