//
//  NotificationPermissionView.swift
//  CareAssistance
//
//  Created on 16/03/2026.
//

import SwiftUI

/// Vista de diálogo "rationale" para permisos de notificación
/// Replica el comportamiento de showNotificationRationaleDialog() de Android
/// Se muestra ANTES del diálogo nativo del sistema
struct NotificationPermissionRationaleView: View {
    
    @Binding var isPresented: Bool
    var onAllow: () -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Fondo semi-transparente
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Diálogo
            VStack(spacing: 20) {
                // Ícono de notificación
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                // Título (como Android: "Activar notificaciones")
                Text("Activar notificaciones")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                // Mensaje explicativo (como Android: mensaje de salud)
                Text("Recibe recordatorios importantes sobre tus citas médicas, resultados de exámenes y actualizaciones de salud.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Botones
                VStack(spacing: 12) {
                    // Botón "Permitir" (como Android)
                    Button {
                        isPresented = false
                        onAllow()  // Lanza el diálogo del sistema
                    } label: {
                        Text("Permitir")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    // Botón "Ahora no" (como Android)
                    Button {
                        isPresented = false
                        onDismiss()  // Continúa sin solicitar permisos
                    } label: {
                        Text("Ahora no")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview
struct NotificationPermissionRationaleView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionRationaleView(
            isPresented: .constant(true),
            onAllow: {
                print("Usuario tocó Permitir")
            },
            onDismiss: {
                print("Usuario tocó Ahora no")
            }
        )
    }
}

// MARK: - Extension para mostrar desde UIViewController (AppDelegate)

extension UIApplication {
    
    /// Muestra el diálogo rationale de notificaciones desde cualquier parte de la app
    /// Uso en AppDelegate: UIApplication.shared.showNotificationRationaleDialog()
    func showNotificationRationaleDialog(
        onAllow: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("❌ No se pudo obtener rootViewController")
            return
        }
        
        let hostingController = UIHostingController(
            rootView: NotificationPermissionRationaleView(
                isPresented: .constant(true),
                onAllow: onAllow,
                onDismiss: onDismiss
            )
        )
        
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.view.backgroundColor = .clear
        
        rootViewController.present(hostingController, animated: true)
    }
}
