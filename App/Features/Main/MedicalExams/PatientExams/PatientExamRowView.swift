//
//  PatientExamRowView.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI

struct PatientExamRowView: View {
    @State private var isPresentingDetails = false
    @Binding var isSelected: [String:Bool]
    let exam: FunctionFilterExamResponse.PatientExams
    @Binding var isLoadingExam: Bool
    @Binding var UIState: ExamUIState

    var body: some View {
        Button(action: {
            isPresentingDetails = true
        }) {
            HStack(alignment: .center) {
                Button(action: {
                    isSelected[exam.Id ?? ""]?.toggle()
                }, label: {
                    if isSelected[exam.Id ?? ""] == true {
                        ZStack {
                            Circle()
                                .fill(Color(hex: UIState.examList.iconSelectColor))
                                .frame(width: 25, height: 25)
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 16, height: 12)
                                .tint(Color.white)
                        }
                    }else{
                        ZStack {
                            Circle()
                                .fill(Color.grayLight)
                                .frame(width: 25, height: 25)
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 16, height: 12)
                                .foregroundColor(Color(hex: UIState.examList.iconSelectColor))
                        }
                    }
                })
                
                    VStack(alignment: .leading){
                        Text(exam.nombreDelExamenC ?? "Sin nombre")
                            .font(Font.custom(UIState.examList.itemTitle.font, size: CGFloat(Int(UIState.examList.itemTitle.size) ?? 18)))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(hex: UIState.examList.itemTitle.color))
                        Text(formatDate(exam.CreatedDate ?? ""))
                            .font(Font.custom(UIState.examList.itemSubTitle.font, size: CGFloat(Int(UIState.examList.itemSubTitle.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.examList.itemSubTitle.color))
                    }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.margin / 2)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.grayLight, lineWidth: 1)
                    .shadow(radius: 20)
            )
            .background(isSelected[exam.Id ?? ""] == true  ? Color(hex: UIState.examList.iconSelectColor).opacity(0.25) : Color.clear)
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.grayLight, lineWidth: 1)
                    .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
            )
            .padding(.margin / 2)
            .navigationLink(isActive: $isPresentingDetails) {
                SendNewExamView(UIState: $UIState, isPublished: isExamPublished(), exam: isExamPublished() ? exam : nil )
            }
        }
    }
    func formatDate(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: isoString) {
            return outputFormatter.string(from: date)
        } else {
            return "Fecha inválida"
        }
    }
    func isExamPublished() -> Bool{
        if ((exam.urlExamen1C?.isEmpty) == nil) || ((exam.urlExamen2C?.isEmpty) == nil) || ((exam.urlExamen3C?.isEmpty) == nil) || ((exam.urlExamen4C?.isEmpty) == nil){
            return true
        }else{
            return false
        }
        
    }
}
