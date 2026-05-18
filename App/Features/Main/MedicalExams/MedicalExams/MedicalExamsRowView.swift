//
//  MedicalExamsRowView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/03/2023.
//

import SwiftUI
import RealmSwift

struct MedicalExamsRowView: View {
    @State private var isPresentingDetails = false
    @Binding var isSelected: [String: Bool]
    let exam: MedicalExams.Exam
    @State var isFavorite: Bool = false
    @Binding var isLoadingFavorite: Bool
    @Binding var isLoadingExam: Bool
    @Binding var UIState: ExamUIState
    // Config de la lista (Elemento 13 del record `ExamenesAutomatizados`).
    // Se usa para AtributosCard y TituloNombreCardExamen.
    var vistaPrincipal: VistaPrincipalPrescripcionesConfig = VistaPrincipalPrescripcionesConfig()
    // Config del detalle (Elemento 9 de `ExamenesAutomatizadosCustom`).
    // No se consume aquí — solo se reenvía al detail view en el navigationLink.
    var vistaDetalle: VistaDetallePrescripcionesConfig = VistaDetallePrescripcionesConfig()
    // Config de la vista Subir Examen (Elemento 10 de `ExamenesAutomatizadosCustom`).
    // Tampoco se consume aquí — solo se reenvía al detail view (que a su vez
    // lo pasa a SendNewExamView).
    var vistaSubir: VistaSubirExamenConfig = VistaSubirExamenConfig()
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogExamenesEnviadosConfig: DialogExamenesEnviadosConfig = DialogExamenesEnviadosConfig()
    var dialogEliminarDocOrdenConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var badgeOrdenMedica: BadgeConfig = BadgeConfig()
    var badgeExamenAutomatizado: BadgeConfig = BadgeConfig()
    var badgeRecetaMedica: BadgeConfig = BadgeConfig()
    /// Binding propagado desde MedicalExamsView. Lo seteamos a true desde el detalle
    /// cuando hay upload exitoso, para que la lista se refresque al volver.
    @Binding var listNeedsRefresh: Bool
    /// PatientExam asociado a esta orden (cruce por FK calculado en el padre). Si
    /// es nil → no hay archivos subidos → botón "Subir Examen". Si tiene valor →
    /// botón "Ver documento enviado". Paridad con el web.
    var linkedPatientExam: FunctionFilterExamResponse.PatientExams? = nil

    private var isItemSelected: Bool {
        isSelected[exam.Id ?? ""] == true
    }

    // AtributosCard (13.9) — 4 colores que se aplican a la fila
    private var barraVerticalColor: Color {
        let c = vistaPrincipal.cardColorBarraVertical
        return Color(hex: c.isEmpty ? "#387FC2" : c)
    }
    private var checkboxActivoColor: Color {
        let c = vistaPrincipal.cardColorCheckboxActivo
        return Color(hex: c.isEmpty ? "#387FC2" : c)
    }
    private var bordeActivoColor: Color {
        let c = vistaPrincipal.cardColorBordeActivo
        return Color(hex: c.isEmpty ? "#387FC2" : c)
    }
    private var estrellaColor: Color {
        let c = vistaPrincipal.cardColorEstrella
        return Color(hex: c.isEmpty ? "#387FC2" : c)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent border (13.9 ColorBarraVertical)
            RoundedRectangle(cornerRadius: 2)
                .fill(barraVerticalColor)
                .frame(width: 4)
                .padding(.vertical, 4)

            // Checkbox inside the card (13.9 ColorCheckboxActivo)
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isItemSelected ? checkboxActivoColor : Color.gray.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                if isItemSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(checkboxActivoColor)
                        .frame(width: 20, height: 20)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSelected[exam.Id ?? ""]?.toggle()
                }
            }

            // Content area - navigates to detail (titulo nombre card — 13.10)
            VStack(alignment: .leading, spacing: 8) {
                Text((exam.Name ?? "Sin nombre").uppercased())
                    .font(Font.custom(
                        vistaPrincipal.tituloCardAttr.font.isEmpty ? "FiraSans-Bold" : vistaPrincipal.tituloCardAttr.font,
                        size: CGFloat(Int(vistaPrincipal.tituloCardAttr.size) ?? 15)
                    ))
                    .foregroundColor(Color(hex: vistaPrincipal.tituloCardAttr.color.isEmpty ? "#333333" : vistaPrincipal.tituloCardAttr.color))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Badge tipo documento (dinámico desde Salesforce)
                if let tipo = exam.tipoDocumento {
                    let badge: BadgeConfig = {
                        switch tipo {
                        case .ordenMedica: return badgeOrdenMedica
                        case .examenAutomatizado: return badgeExamenAutomatizado
                        case .recetaMedica: return badgeRecetaMedica
                        }
                    }()
                    Text(badge.texto.isEmpty ? tipo.rawValue : badge.texto)
                        .font(Font.custom(badge.font, size: CGFloat(Int(badge.size) ?? 11)))
                        .foregroundColor(Color(hex: badge.colorTexto))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: badge.colorFondo))
                        )
                }

                // Descripción del examen (13.16 AtributosDescripcionExamenCard)
                // El texto viene del registro individual del examen en Salesforce;
                // los atributos visuales vienen del Elemento 13 del BrandAccount.
                if let descripcion = exam.descripcionC, !descripcion.isEmpty {
                    Text(descripcion)
                        .font(Font.custom(
                            vistaPrincipal.descripcionCardAttr.font.isEmpty ? "FiraSans-Regular" : vistaPrincipal.descripcionCardAttr.font,
                            size: CGFloat(Int(vistaPrincipal.descripcionCardAttr.size) ?? 13)
                        ))
                        .foregroundColor(Color(hex: vistaPrincipal.descripcionCardAttr.color.isEmpty ? "#888888" : vistaPrincipal.descripcionCardAttr.color))
                }

                // Fecha (13.14 FechaExamenCard) — con icono opcional a la izquierda
                if let dateStr = exam.desdeC, !dateStr.isEmpty {
                    let fechaColor = Color(hex: vistaPrincipal.fechaCardAttr.color.isEmpty ? "#888888" : vistaPrincipal.fechaCardAttr.color)
                    let fechaSize = CGFloat(Int(vistaPrincipal.fechaCardAttr.size) ?? 12)
                    let fechaFont = vistaPrincipal.fechaCardAttr.font.isEmpty ? "FiraSans-Regular" : vistaPrincipal.fechaCardAttr.font
                    let iconoNombre = vistaPrincipal.fechaCardIcono
                    let iconoColor = Color(hex: vistaPrincipal.fechaCardIconoColor.isEmpty ? "#888888" : vistaPrincipal.fechaCardIconoColor)
                    HStack(spacing: 4) {
                        if !iconoNombre.isEmpty {
                            Image(systemName: iconoNombre)
                                .font(.system(size: fechaSize))
                                .foregroundColor(iconoColor)
                        }
                        Text(formatDateForDisplay(dateStr, outputFormat: vistaPrincipal.fechaCardFormato))
                            .font(Font.custom(fechaFont, size: fechaSize))
                            .foregroundColor(fechaColor)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                isPresentingDetails = true
            }

            // Favorite star (13.9 ColorEstrella)
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: 18))
                .foregroundColor(isFavorite ? .yellow : estrellaColor)
                .padding(.horizontal, 10)
                .contentShape(Rectangle())
                .onTapGesture {
                    changeFavorite()
                }
                .onAppear {
                    isFavorite = exam.favoritoAppC ?? false
                }
        }
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            // 13.9 ColorBordeActivo cuando la card está seleccionada
            RoundedRectangle(cornerRadius: 10)
                .stroke(isItemSelected ? bordeActivoColor : Color(.systemGray5), lineWidth: isItemSelected ? 1.5 : 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        .contextMenu {
            Button {
                isPresentingDetails = true
            } label: {
                Label("Ver detalle", systemImage: "eye")
            }
            Button {
                changeFavorite()
            } label: {
                Label(isFavorite ? "Quitar favorito" : "Marcar favorito", systemImage: isFavorite ? "star.slash" : "star.fill")
            }
        }
        .navigationLink(isActive: $isPresentingDetails) {
            // Config visual del detail view = vistaDetalle (Elemento 9).
            // Config visual de la vista Subir Examen = vistaSubir (Elemento 10).
            MedicalExamsDetailsView(exam: exam, isLoadingExam: $isLoadingExam, isFavorite: $isFavorite, UIState: $UIState, vistaDetalle: vistaDetalle, vistaSubir: vistaSubir, dialogEliminarConfig: dialogEliminarConfig, dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig, dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig, badgeOrdenMedica: badgeOrdenMedica, badgeExamenAutomatizado: badgeExamenAutomatizado, badgeRecetaMedica: badgeRecetaMedica, listNeedsRefresh: $listNeedsRefresh, linkedPatientExam: linkedPatientExam)
        }
    }

    /// Convierte fecha de yyyy-MM-dd al formato pedido por el record (13.14).
    /// Si el formato viene vacío, cae a dd/MM/yyyy.
    private func formatDateForDisplay(_ dateStr: String, outputFormat: String = "dd/MM/yyyy") -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateStr) else { return dateStr }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat.isEmpty ? "dd/MM/yyyy" : outputFormat
        return outputFormatter.string(from: date)
    }

    func changeFavorite() {
        let data = !isFavorite
        self.isLoadingFavorite = true
        Task {
            let result = await Network.shared.postFavorite(registerId: exam.Id ?? "", objet: exam.attributes?.type ?? "", data: data)
            switch result {
            case .success:
                self.isFavorite = data
            case let .failure(error):
                AppStatusManager.error(error)
            }
            self.isLoadingFavorite = false
            self.isLoadingExam = true
        }
    }
}
