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
    var backArrowColor: String = "#00BBDC"
    var navTitle: String = ""
    var navTitleAttr: TextExamAttributes = TextExamAttributes()
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogExamenesEnviadosConfig: DialogExamenesEnviadosConfig = DialogExamenesEnviadosConfig()
    var dialogEliminarDocOrdenConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var badgeOrdenMedica: BadgeConfig = BadgeConfig()
    var badgeExamenAutomatizado: BadgeConfig = BadgeConfig()
    var badgeRecetaMedica: BadgeConfig = BadgeConfig()
    var badgeDetallePrescripciones: BadgeDetalleConfig = BadgeDetalleConfig()
    var badgeDetalleRecetaMedica: BadgeDetalleConfig = BadgeDetalleConfig()
    var badgeDetalleExamenMedico: BadgeDetalleConfig = BadgeDetalleConfig()
    var botonVerDocumentoEnviado: ButtonExamConfig = ButtonExamConfig()
    var botonSubirExamenConfig: ButtonExamConfig = ButtonExamConfig()
    var badgeCargadoPorPaciente: BadgeDetalleConfig = BadgeDetalleConfig(texto: "Cargado por el Paciente", colorTexto: "#FFFFFF", colorFondo: "#7B61FF", font: "FiraSans-Medium", size: "11", icono: "person.fill")
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

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent border
            RoundedRectangle(cornerRadius: 2)
                .fill(isItemSelected ? accentColor : accentColor.opacity(0.3))
                .frame(width: 4)
                .padding(.vertical, 4)

            // Checkbox inside the card
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isItemSelected ? accentColor : Color.gray.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                if isItemSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accentColor)
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

            // Content area - navigates to detail
            VStack(alignment: .leading, spacing: 8) {
                Text((exam.Name ?? "Sin nombre").uppercased())
                    .font(Font.custom(
                        UIState.examList.itemTitle.font.isEmpty ? "FiraSans-Bold" : UIState.examList.itemTitle.font,
                        size: CGFloat(Int(UIState.examList.itemTitle.size) ?? 15)
                    ))
                    .foregroundColor(Color(hex: UIState.examList.itemTitle.color.isEmpty ? "#333333" : UIState.examList.itemTitle.color))
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

                if let descripcion = exam.descripcionC, !descripcion.isEmpty {
                    Text(descripcion)
                        .font(Font.custom("FiraSans-Regular", size: 13))
                        .foregroundColor(.gray)
                }

                if let dateStr = exam.desdeC, !dateStr.isEmpty {
                    Text(formatDateForDisplay(dateStr))
                        .font(Font.custom("FiraSans-Regular", size: 12))
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                isPresentingDetails = true
            }

            // Favorite star
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: 18))
                .foregroundColor(isFavorite ? .yellow : accentColor.opacity(0.4))
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
            RoundedRectangle(cornerRadius: 10)
                .stroke(isItemSelected ? accentColor.opacity(0.5) : Color(.systemGray5), lineWidth: isItemSelected ? 1.5 : 1)
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
            MedicalExamsDetailsView(exam: exam, isLoadingExam: $isLoadingExam, isFavorite: $isFavorite, UIState: $UIState, backArrowColor: backArrowColor, navTitle: navTitle, navTitleAttr: navTitleAttr, dialogEliminarConfig: dialogEliminarConfig, dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig, dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig, badgeOrdenMedica: badgeOrdenMedica, badgeExamenAutomatizado: badgeExamenAutomatizado, badgeRecetaMedica: badgeRecetaMedica, badgeDetallePrescripciones: badgeDetallePrescripciones, badgeDetalleRecetaMedica: badgeDetalleRecetaMedica, badgeDetalleExamenMedico: badgeDetalleExamenMedico, botonVerDocumentoEnviado: botonVerDocumentoEnviado, botonSubirExamenConfig: botonSubirExamenConfig, badgeCargadoPorPaciente: badgeCargadoPorPaciente, listNeedsRefresh: $listNeedsRefresh, linkedPatientExam: linkedPatientExam)
        }
    }

    /// Convierte fecha de yyyy-MM-dd a dd/MM/yyyy para display
    private func formatDateForDisplay(_ dateStr: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateStr) else { return dateStr }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
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
