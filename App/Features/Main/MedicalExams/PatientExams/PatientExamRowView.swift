//
//  PatientExamRowView.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI

struct PatientExamRowView: View {
    @State private var isPresentingDetails = false
    let exam: FunctionFilterExamResponse.PatientExams
    @Binding var isLoadingExam: Bool
    @Binding var UIState: ExamUIState
    var backArrowColor: String = "#00BBDC"
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var onDelete: ((String) -> Void)? = nil

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    var body: some View {
        Button(action: {
            isPresentingDetails = true
        }) {
            HStack(spacing: 0) {
                // Left accent border
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor.opacity(0.3))
                    .frame(width: 4)
                    .padding(.vertical, 4)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text((exam.nombreDelExamenC ?? "Sin nombre").uppercased())
                        .font(Font.custom(
                            UIState.examList.itemTitle.font.isEmpty ? "FiraSans-Bold" : UIState.examList.itemTitle.font,
                            size: CGFloat(Int(UIState.examList.itemTitle.size) ?? 15)
                        ))
                        .foregroundColor(Color(hex: UIState.examList.itemTitle.color.isEmpty ? "#333333" : UIState.examList.itemTitle.color))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Badge tipo de documento (Tipo_de_Archivo__c de Salesforce)
                    // No mostrar badge si el campo viene vacío/null (paridad web)
                    if let tipoArchivo = exam.tipoArchivoC, !tipoArchivo.isEmpty {
                        let docType = getDocumentTypeBadge()
                        Text(docType.label)
                            .font(Font.custom("FiraSans-Medium", size: 11))
                            .foregroundColor(Color(hex: docType.textColor))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color(hex: docType.bgColor)))
                    }

                    if let dateStr = exam.CreatedDate, !dateStr.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Text(formatDate(dateStr))
                                .font(Font.custom(
                                    UIState.examList.itemSubTitle.font.isEmpty ? "FiraSans-Regular" : UIState.examList.itemSubTitle.font,
                                    size: CGFloat(Int(UIState.examList.itemSubTitle.size) ?? 13)
                                ))
                                .foregroundColor(Color(hex: UIState.examList.itemSubTitle.color.isEmpty ? "#888888" : UIState.examList.itemSubTitle.color))
                        }
                    }

                    if isExamPublished() {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("Publicado")
                                .font(Font.custom("FiraSans-Regular", size: 11))
                                .foregroundColor(.green)
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(.leading, 12)
                .padding(.vertical, 2)

                Spacer()

                // Delete icon
                if let examId = exam.Id, !examId.isEmpty {
                    Button {
                        onDelete?(examId)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#ff4d4f"))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.trailing, 4)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .navigationLink(isActive: $isPresentingDetails) {
            SendNewExamView(UIState: $UIState, backArrowColor: backArrowColor, dialogEliminarConfig: dialogEliminarConfig, isPublished: isExamPublished(), exam: isExamPublished() ? exam : nil)
        }
    }

    func formatDate(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        if let date = inputFormatter.date(from: isoString) {
            return outputFormatter.string(from: date)
        } else {
            return "Fecha inválida"
        }
    }

    struct DocTypeBadge {
        let label: String
        let textColor: String
        let bgColor: String
    }

    /// Obtiene el badge de tipo de documento usando `Tipo_de_Archivo__c` directo de Salesforce.
    /// El string del backend ES el label. El color se busca por key exacta.
    func getDocumentTypeBadge() -> DocTypeBadge {
        let tipo = exam.tipoArchivoC ?? ""

        switch tipo {
        case "Receta Médica":
            return DocTypeBadge(label: tipo, textColor: "#0183c7", bgColor: "#e6f4ff")
        case "Examen de Laboratorio":
            return DocTypeBadge(label: tipo, textColor: "#52c41a", bgColor: "#f0f9eb")
        case "Examen de Imagen":
            return DocTypeBadge(label: tipo, textColor: "#722ed1", bgColor: "#f9f0ff")
        case "Orden de Exámenes":
            return DocTypeBadge(label: tipo, textColor: "#d46b08", bgColor: "#fff7e6")
        case "Informe Médico":
            return DocTypeBadge(label: tipo, textColor: "#13c2c2", bgColor: "#e6fffb")
        default:
            // Fallback gris — tipo vacío o desconocido
            let label = tipo.isEmpty ? "Otros" : tipo
            return DocTypeBadge(label: label, textColor: "#8c8c8c", bgColor: "#f5f5f5")
        }
    }

    func isExamPublished() -> Bool {
        if ((exam.urlExamen1C?.isEmpty) == nil) || ((exam.urlExamen2C?.isEmpty) == nil) || ((exam.urlExamen3C?.isEmpty) == nil) || ((exam.urlExamen4C?.isEmpty) == nil) {
            return true
        } else {
            return false
        }
    }
}
