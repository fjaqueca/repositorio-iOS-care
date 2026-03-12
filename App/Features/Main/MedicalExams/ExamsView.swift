//
//  Exams.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI
import RealmSwift

struct ExamsView: View {
    @ObservedResults(BrandAccounts.self) var items
    @Environment(\.dismiss) var dismiss
    @State var isPatientExam: Bool = false
    @State var showFilterView: Bool = false
    @State var UIState: ExamUIState = ExamUIState()
    var body: some View {
        NavigationViewCustom {
            VStack (spacing: 0){
                Divider()
                content
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(UIState.examList.title.text)
                                .font(Font.custom(UIState.examList.title.font, size: CGFloat(Int(UIState.examList.title.size) ?? 18)))
                                .foregroundColor(Color(hex: UIState.examList.title.color))
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image("back")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.examList.title.color))
                            }
                            .disabled(showFilterView ? true : false)
                        }
                    }
                    .task{
                        loadUIState()
                    }
            }
            .configureNavigation()
        }
    }
    
    var content: some View{
        VStack{
            HStack(spacing: 10){
                Button {
                    self.isPatientExam = false
                } label: {
                    VStack{
                        Text(UIState.examWindows.titleOrderExam.text != "" ? UIState.examWindows.titleOrderExam.text : "Ordenes de Exámenes1111")
                            .font(Font.custom(isPatientExam ? UIState.examWindows.titleOrderExam.fontInActive : UIState.examWindows.titleOrderExam.fontActive, size: CGFloat(Int(UIState.examWindows.titleOrderExam.size) ?? 18)))
                            .foregroundColor(isPatientExam ? Color(hex: UIState.examWindows.titleOrderExam.colorInActive): Color(hex: UIState.examWindows.titleOrderExam.colorActive))
                        Divider()
                            .frame(height: 2)
                            .overlay(Color(hex: UIState.examWindows.colorLine))
                            .hidden(isPatientExam)
                    }
                    .padding(.vertical)
                    
                }
                Button {
                    self.isPatientExam = true
                } label: {
                    VStack{
                        Text(UIState.examWindows.titlePatientExam.text != "" ? UIState.examWindows.titlePatientExam.text : "Mis Exámenes2222")
                            .font(Font.custom(!isPatientExam ? UIState.examWindows.titlePatientExam.fontInActive : UIState.examWindows.titlePatientExam.fontActive, size: CGFloat(Int(UIState.examWindows.titlePatientExam.size) ?? 18)))
                            .foregroundColor(!isPatientExam ? Color(hex: UIState.examWindows.titlePatientExam.colorInActive): Color(hex: UIState.examWindows.titlePatientExam.colorActive))
                        Divider()
                            .frame(height: 2)
                            .overlay(Color(hex: UIState.examWindows.colorLine))
                            .hidden(!isPatientExam)
                    }
                    .padding(.vertical)
                }

            }
            if isPatientExam{
                PatientExamsView(UIState: $UIState)
            }else{
                MedicalExamsView(UIState: $UIState)
            }
        }
        
        
    }
}

