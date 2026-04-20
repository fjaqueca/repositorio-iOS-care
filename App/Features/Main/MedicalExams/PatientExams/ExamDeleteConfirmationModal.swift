//
//  ExamDeleteConfirmationModal.swift
//  CareAssistance
//

import SwiftUI

struct ExamDeleteConfirmationModal: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    var isLoading: Bool = false
    var config: DialogEliminarExamenConfig = DialogEliminarExamenConfig()

    @State private var iconScale: CGFloat = 0.0
    @State private var iconOpacity: Double = 0.0

    var body: some View {
        let tAttr = config.tituloAttr
        let dAttr = config.descripcionAttr
        let btnAceptar = config.botonAceptar
        let btnCancelar = config.botonCancelar

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

                Text(config.titulo.isEmpty ? "¿Estás seguro que quieres eliminar?" : config.titulo)
                    .font(Font.custom(
                        tAttr.font.isEmpty ? "FiraSans-Bold" : tAttr.font,
                        size: CGFloat(Int(tAttr.size) ?? 16)
                    ))
                    .foregroundColor(Color(hex: tAttr.color.isEmpty ? "#333333" : tAttr.color))
                    .multilineTextAlignment(.center)

                Text(config.descripcion.isEmpty
                     ? "Estás a punto de eliminar un archivo, recuerda que al eliminarlo no podrás volver a acceder a él."
                     : config.descripcion)
                    .font(Font.custom(
                        dAttr.font.isEmpty ? "FiraSans-Regular" : dAttr.font,
                        size: CGFloat(Int(dAttr.size) ?? 13)
                    ))
                    .foregroundColor(Color(hex: dAttr.color.isEmpty ? "#777777" : dAttr.color))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)

                // Botones horizontales
                HStack(spacing: 12) {
                    // Aceptar
                    Button {
                        onConfirm()
                    } label: {
                        ZStack {
                            Text(btnAceptar.texto.isEmpty ? "Aceptar" : btnAceptar.texto)
                                .font(Font.custom("FiraSans-Bold", size: 15))
                                .foregroundColor(Color(hex: btnAceptar.colorTexto.isEmpty ? "#FFFFFF" : btnAceptar.colorTexto))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: btnAceptar.colorFondo.isEmpty ? "#00BBDC" : btnAceptar.colorFondo))
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

                    // Cancelar
                    Button {
                        onCancel()
                    } label: {
                        Text(btnCancelar.texto.isEmpty ? "Cancelar" : btnCancelar.texto)
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(Color(hex: btnCancelar.colorTexto.isEmpty ? "#555555" : btnCancelar.colorTexto))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(hex: btnCancelar.colorFondo.isEmpty ? "#FFFFFF" : btnCancelar.colorFondo))
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
