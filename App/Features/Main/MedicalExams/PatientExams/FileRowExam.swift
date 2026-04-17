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
    let onSelect: (UUID) -> Void
    let onDownload: () -> Void

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

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
                    .fill(hasFile ? Color(hex: "#4CAF50").opacity(0.08) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        hasFile ? Color(hex: "#4CAF50") : Color(hex: "#4CAF50").opacity(0.5),
                        style: hasFile
                            ? StrokeStyle(lineWidth: 1.5)
                            : StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State
    private var emptyContent: some View {
        Image(systemName: "paperclip")
            .font(.system(size: 28, weight: .light))
            .foregroundColor(Color(hex: "#4CAF50").opacity(0.6))
    }

    // MARK: - File Attached State
    private var fileAttachedContent: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                Image(systemName: fileIconName)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(Color(hex: "#2E7D32"))

                Text(fileLabel)
                    .font(Font.custom("FiraSans-Bold", size: 11))
                    .foregroundColor(Color(hex: "#2E7D32"))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Delete button
            if !isExamPublish {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        fileExam.imgData = ""
                        fileExam.urlImg = ""
                        fileExam.archiveExtension = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white, Color.red.opacity(0.7))
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
