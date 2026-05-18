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
    // Config completa de Mis Archivos de Salud — Elemento 12 del Custom record.
    var vistaMisArchivos: VistaMisArchivosConfig = VistaMisArchivosConfig()
    // Config del DETALLE — Elemento 8. Se reenvía a SendNewExamView para que
    // toda la pantalla de detalle (toolbar, badges, fecha, containers, botones)
    // use exclusivamente esta config.
    var vistaDetalleMisArchivos: VistaDetalleMisArchivosConfig = VistaDetalleMisArchivosConfig()
    var botonesDetalleExamen: BotonesDetalleExamenConfig = BotonesDetalleExamenConfig()
    var badgeCargadoPorPaciente: BadgeDetalleConfig = BadgeDetalleConfig(texto: "Cargado por el Paciente", colorTexto: "#FFFFFF", colorFondo: "#7B61FF", font: "FiraSans-Medium", size: "11", icono: "person.fill")
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogExamenesEnviadosConfig: DialogExamenesEnviadosConfig = DialogExamenesEnviadosConfig()
    var dialogEliminarDocOrdenConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    // Config dinámica de la vista "Subir Examen" (Elemento 10 del Custom record).
    // Se reenvía a SendNewExamView al navegar al detalle.
    var vistaSubir: VistaSubirExamenConfig = VistaSubirExamenConfig()
    var onDelete: ((String) -> Void)? = nil

    // Color de la franja izquierda — 12.15 BarraVerticalCardMisArchivosDeSalud
    private var accentColor: Color {
        Color(hex: vistaMisArchivos.barraVerticalColor.isEmpty ? "#387FC2" : vistaMisArchivos.barraVerticalColor)
    }

    var body: some View {
        Button(action: {
            isPresentingDetails = true
        }) {
            HStack(spacing: 0) {
                // Left accent border
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                // Content — Título card: 12.10 AtributosTituloCardDetalle
                VStack(alignment: .leading, spacing: 4) {
                    let titleAttr = vistaMisArchivos.tituloCardAttr
                    Text((exam.nombreDelExamenC ?? "Sin nombre").uppercased())
                        .font(Font.custom(
                            titleAttr.font.isEmpty ? "FiraSans-Bold" : titleAttr.font,
                            size: CGFloat(Int(titleAttr.size) ?? 15)
                        ))
                        .foregroundColor(Color(hex: titleAttr.color.isEmpty ? "#333333" : titleAttr.color))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Badge tipo de documento (Tipo_de_Archivo__c de Salesforce)
                    // No mostrar badge si el campo viene vacío/null (paridad web)
                    if let tipoArchivo = exam.tipoArchivoC, !tipoArchivo.isEmpty {
                        let badge = getDocumentTypeBadge()
                        Text(badge.texto)
                            .font(Font.custom(
                                badge.font.isEmpty ? "FiraSans-Medium" : badge.font,
                                size: CGFloat(Double(badge.size) ?? 11)
                            ))
                            .foregroundColor(Color(hex: badge.colorTexto))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color(hex: badge.colorFondo)))
                    }

                    // Fecha — 12.13 FechaExamenCard(Fuente;Size;Color;Formato;Icono;ColorIcono)
                    if let dateStr = exam.CreatedDate, !dateStr.isEmpty {
                        let fAttr = vistaMisArchivos.fechaAttr
                        let fechaColor = Color(hex: fAttr.color.isEmpty ? "#888888" : fAttr.color)
                        let fechaFont = fAttr.font.isEmpty ? "FiraSans-Regular" : fAttr.font
                        let fechaSize = CGFloat(Int(fAttr.size) ?? 13)
                        let icono = vistaMisArchivos.fechaIcono.isEmpty ? "calendar" : vistaMisArchivos.fechaIcono
                        let iconoColor = Color(hex: vistaMisArchivos.fechaIconoColor.isEmpty
                            ? (fAttr.color.isEmpty ? "#888888" : fAttr.color)
                            : vistaMisArchivos.fechaIconoColor)
                        HStack(spacing: 4) {
                            Image(systemName: icono)
                                .font(.system(size: fechaSize - 2))
                                .foregroundColor(iconoColor)
                            Text(formatDate(dateStr, formato: vistaMisArchivos.fechaFormato))
                                .font(Font.custom(fechaFont, size: fechaSize))
                                .foregroundColor(fechaColor)
                        }
                    }

                }
                .padding(.leading, 12)
                .padding(.vertical, 2)

                Spacer()

                // Delete icon — 12.7 IconoBasuraEliminarMiArchivoSalud(Size;Color)
                if let examId = exam.Id, !examId.isEmpty {
                    Button {
                        onDelete?(examId)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: CGFloat(Double(vistaMisArchivos.iconoBasuraSize) ?? 16)))
                            .foregroundColor(Color(hex: vistaMisArchivos.iconoBasuraColor.isEmpty ? "#FF4D4F" : vistaMisArchivos.iconoBasuraColor))
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
            // Detalle de un archivo de salud — el modo publicado usa
            // exclusivamente vistaDetalleMisArchivos (Elemento 8). botonesDetalleExamen
            // y vistaSubir se pasan por compatibilidad pero no se consumen en este flujo.
            SendNewExamView(UIState: $UIState, vistaSubir: vistaSubir, botonesDetalleExamen: botonesDetalleExamen, vistaDetalleMisArchivos: vistaDetalleMisArchivos, dialogEliminarConfig: dialogEliminarConfig, dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig, dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig, isPublished: isExamPublished(), exam: isExamPublished() ? exam : nil)
        }
    }

    func formatDate(_ isoString: String, formato: String = "dd/MM/yyyy") -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = formato.isEmpty ? "dd/MM/yyyy" : formato
        if let date = inputFormatter.date(from: isoString) {
            return outputFormatter.string(from: date)
        } else {
            return "Fecha inválida"
        }
    }

    /// Obtiene el badge de tipo de documento usando `Tipo_de_Archivo__c` directo de Salesforce.
    /// Colores, texto, font y size vienen del Elemento 12 (12.1–12.6).
    func getDocumentTypeBadge() -> BadgeConfig {
        let tipo = exam.tipoArchivoC ?? ""

        switch tipo {
        case "Receta Médica":
            return vistaMisArchivos.badgeRecetaMedica
        case "Examen de Laboratorio":
            return vistaMisArchivos.badgeExamenLaboratorio
        case "Examen de Imagen":
            return vistaMisArchivos.badgeExamenImagen
        case "Orden de Exámenes":
            return vistaMisArchivos.badgeOrdenExamen
        case "Informe Médico":
            return vistaMisArchivos.badgeInformeMedico
        default:
            return vistaMisArchivos.badgeOtros
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
