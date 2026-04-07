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
                    Text(exam.nombreDelExamenC ?? "Sin nombre")
                        .font(Font.custom(
                            UIState.examList.itemTitle.font.isEmpty ? "FiraSans-Bold" : UIState.examList.itemTitle.font,
                            size: CGFloat(Int(UIState.examList.itemTitle.size) ?? 15)
                        ))
                        .foregroundColor(Color(hex: UIState.examList.itemTitle.color.isEmpty ? "#333333" : UIState.examList.itemTitle.color))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

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
            SendNewExamView(UIState: $UIState, backArrowColor: backArrowColor, isPublished: isExamPublished(), exam: isExamPublished() ? exam : nil)
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

    func isExamPublished() -> Bool {
        if ((exam.urlExamen1C?.isEmpty) == nil) || ((exam.urlExamen2C?.isEmpty) == nil) || ((exam.urlExamen3C?.isEmpty) == nil) || ((exam.urlExamen4C?.isEmpty) == nil) {
            return true
        } else {
            return false
        }
    }
}
