//
//  DeleteConfirmationModal.swift
//  CareAssistance
//
//  Created by Care Assistance on 14/04/2026.
//

import SwiftUI

struct DeleteConfirmationModal: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    var isLoading: Bool = false

    @State private var iconScale: CGFloat = 0.0
    @State private var iconOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Backdrop semi-transparente
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isLoading { onCancel() }
                }

            // Card
            VStack(spacing: 14) {
                // Botón X de cierre (esquina superior derecha)
                HStack {
                    Spacer()
                    Button {
                        if !isLoading { onCancel() }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#999999"))
                    }
                    .disabled(isLoading)
                }
                .padding(.top, 12)
                .padding(.trailing, 4)

                // Ícono de advertencia: círculo con borde gris + "!" amarillo (bounce in)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1.5)
                        )
                    Text("!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#F5A623"))
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.3)) {
                        iconScale = 1.0
                        iconOpacity = 1.0
                    }
                }

                Text("¿Estás seguro que quieres eliminar?")
                    .font(Font.custom("FiraSans-Bold", size: 16))
                    .foregroundColor(Color(hex: "#333333"))
                    .multilineTextAlignment(.center)

                Text("Estás a punto de eliminar un archivo, recuerda que al eliminarlo no podrás volver a acceder a él.")
                    .font(Font.custom("FiraSans-Regular", size: 13))
                    .foregroundColor(Color(hex: "#777777"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)

                // Botones horizontales
                HStack(spacing: 12) {
                    // Aceptar (celeste)
                    Button {
                        onConfirm()
                    } label: {
                        ZStack {
                            Text("Aceptar")
                                .font(Font.custom("FiraSans-Bold", size: 15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: "#00BBDC"))
                                )
                                .opacity(isLoading ? 0.5 : 1.0)

                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isLoading)

                    // Cancelar (borde gris, fondo blanco)
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancelar")
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(Color(hex: "#555555"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(hex: "#CCCCCC"), lineWidth: 1)
                            )
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1.0)
                }
                .padding(.top, 6)
                .padding(.bottom, 18)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: 310)
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
