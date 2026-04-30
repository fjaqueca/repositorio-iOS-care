//
//  LogoutConfirmationDialog.swift
//  CareAssistance
//

import SwiftUI

struct LogoutConfirmationDialog: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var iconScale: CGFloat = 0.0
    @State private var iconOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Backdrop semi-transparente
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            // Card
            VStack(spacing: 14) {
                // Ícono animado
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(Color(hex: "#00BBDC"))
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.9, dampingFraction: 0.5, blendDuration: 0.3)) {
                        iconScale = 1.0
                        iconOpacity = 1.0
                    }
                }
                .padding(.top, 28)

                Text("Cerrar Sesión")
                    .font(Font.custom("FiraSans-Bold", size: 17))
                    .foregroundColor(Color(hex: "#333333"))
                    .multilineTextAlignment(.center)

                Text("¿Estás seguro de que deseas\ncerrar tu sesión?")
                    .font(Font.custom("FiraSans-Regular", size: 14))
                    .foregroundColor(Color(hex: "#777777"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)

                // Botones horizontales
                HStack(spacing: 12) {
                    // Cancelar
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancelar")
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(Color(hex: "#00BBDC"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(hex: "#00BBDC"), lineWidth: 1)
                            )
                    }

                    // Cerrar Sesión
                    Button {
                        onConfirm()
                    } label: {
                        Text("Cerrar Sesión")
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(hex: "#00BBDC"))
                            )
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        }
    }
}
