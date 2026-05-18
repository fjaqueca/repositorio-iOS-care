//
//  FileRowExam.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct FileRowExam: View {
    @Binding var fileExam: FileExam
    @Binding var isExamPublish: Bool
    @Binding var UIState: ExamUIState
    // Config dinámica de los containers (10.7 y 10.8).
    var containerSinArchivo: ContainerSinArchivoConfig = ContainerSinArchivoConfig()
    var containerConArchivo: ContainerConArchivoConfig = ContainerConArchivoConfig()
    let onSelect: (UUID) -> Void
    let onDownload: () -> Void

    private var hasFile: Bool {
        !fileExam.imgData.isEmpty || !fileExam.urlImg.isEmpty
    }

    var body: some View {
        Button {
            if !hasFile && !isExamPublish {
                onSelect(fileExam.id)
            } else if !fileExam.urlImg.isEmpty {
                onDownload()
            }
        } label: {
            ZStack {
                if hasFile {
                    fileAttachedContent
                } else {
                    emptyContent
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(containerBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        containerBorderColor,
                        style: hasFile
                            ? StrokeStyle(lineWidth: 1.5)
                            : StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [FileRowExam] CONFIG RECIBIDA — hasFile=\(hasFile)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("   [10.7] SinArchivo:")
            print("      colorBorde:          \"\(containerSinArchivo.colorBorde)\"  (vacío→fallback #4CAF50 verde)")
            print("      icono:               \"\(containerSinArchivo.icono)\"")
            print("      colorIcono:          \"\(containerSinArchivo.colorIcono)\"  (vacío→fallback #4CAF50 verde)")
            print("      sizeIcono:           \"\(containerSinArchivo.sizeIcono)\"")
            print("      colorFondoContainer: \"\(containerSinArchivo.colorFondoContainer)\"  (vacío→fallback #FFFFFF)")
            print("   [10.8] ConArchivo:")
            print("      colorBorde:          \"\(containerConArchivo.colorBorde)\"")
            print("      icono:               \"\(containerConArchivo.icono)\"")
            print("      colorIcono:          \"\(containerConArchivo.colorIcono)\"")
            print("      sizeIcono:           \"\(containerConArchivo.sizeIcono)\"")
            print("      colorTextoFormato:   \"\(containerConArchivo.colorTextoFormato)\"")
            print("      iconoCancelar:       \"\(containerConArchivo.iconoCancelar)\"")
            print("      colorFondoBotonX:    \"\(containerConArchivo.colorFondoBotonCancelar)\"")
            print("      colorCruz:           \"\(containerConArchivo.colorCruz)\"")
            print("      colorFondoContainer: \"\(containerConArchivo.colorFondoContainer)\"")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }

    // 10.7 ColorFondoContainer / 10.8 ColorFondoContainer
    private var containerBackgroundColor: Color {
        let raw = hasFile ? containerConArchivo.colorFondoContainer : containerSinArchivo.colorFondoContainer
        return Color(hex: raw.isEmpty ? "#FFFFFF" : raw)
    }

    // 10.7 ColorBorde / 10.8 ColorBorde
    private var containerBorderColor: Color {
        let raw = hasFile ? containerConArchivo.colorBorde : containerSinArchivo.colorBorde
        return Color(hex: raw.isEmpty ? "#4CAF50" : raw)
    }

    // MARK: - Empty State (10.7)
    private var emptyContent: some View {
        let icono = containerSinArchivo.icono.isEmpty ? "paperclip" : containerSinArchivo.icono
        let size = CGFloat(Int(containerSinArchivo.sizeIcono) ?? 28)
        let color = Color(hex: containerSinArchivo.colorIcono.isEmpty ? "#4CAF50" : containerSinArchivo.colorIcono)
        return Image(systemName: icono)
            .font(.system(size: size, weight: .light))
            .foregroundColor(color)
    }

    // MARK: - File Attached State (10.8)
    private var fileAttachedContent: some View {
        let icono = containerConArchivo.icono.isEmpty ? fileIconName : containerConArchivo.icono
        let iconoSize = CGFloat(Int(containerConArchivo.sizeIcono) ?? 26)
        let iconoColor = Color(hex: containerConArchivo.colorIcono.isEmpty ? "#2E7D32" : containerConArchivo.colorIcono)
        let formatoColor = Color(hex: containerConArchivo.colorTextoFormato.isEmpty ? "#2E7D32" : containerConArchivo.colorTextoFormato)
        let cancelarIcono = containerConArchivo.iconoCancelar.isEmpty ? "xmark.circle.fill" : containerConArchivo.iconoCancelar
        let cruzColor = Color(hex: containerConArchivo.colorCruz.isEmpty ? "#FFFFFF" : containerConArchivo.colorCruz)
        let cancelarFondoColor = Color(hex: containerConArchivo.colorFondoBotonCancelar.isEmpty ? "#FF0000" : containerConArchivo.colorFondoBotonCancelar)
        return ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                Image(systemName: icono)
                    .font(.system(size: iconoSize, weight: .medium))
                    .foregroundColor(iconoColor)

                Text(fileLabel)
                    .font(Font.custom("FiraSans-Bold", size: 11))
                    .foregroundColor(formatoColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Delete button (X) — 10.8 IconoCancelar + ColorFondo + ColorCruz
            if !isExamPublish {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        fileExam.imgData = ""
                        fileExam.urlImg = ""
                        fileExam.archiveExtension = ""
                    }
                } label: {
                    Image(systemName: cancelarIcono)
                        .font(.system(size: 18))
                        .foregroundStyle(cruzColor, cancelarFondoColor)
                }
                .padding(5)
            }
        }
    }

    // MARK: - Helpers
    private var fileIconName: String {
        let ext = fileExam.archiveExtension.lowercased()
        switch ext {
        case "pdf":
            return "doc.richtext"
        case "jpg", "jpeg", "png", "heic":
            return "photo"
        case "doc", "docx":
            return "doc.text"
        default:
            return "doc.fill"
        }
    }

    private var fileLabel: String {
        if fileExam.archiveExtension.isEmpty {
            return "Archivo"
        }
        return ".\(fileExam.archiveExtension.uppercased())"
    }
}
