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
    @Binding var isSelected: [String:Bool]
    let exam: MedicalExams.Exam
    @State var isFavorite: Bool = false
    @Binding var isLoadingFavorite: Bool
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
                
                VStack(alignment: .leading) {
                    Text(exam.Name ?? "Sin nombre")
                        .font(Font.custom(UIState.examList.itemTitle.font, size: CGFloat(Int(UIState.examList.itemTitle.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.examList.itemTitle.color))
                    Text("\(exam.desdeC ?? "")")
                        .font(Font.custom(UIState.examList.itemSubTitle.font, size: CGFloat(Int(UIState.examList.itemSubTitle.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.examList.itemSubTitle.color))
                }
                Spacer()
                Button(action: {
                    changeFavorite()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(Color(hex: UIState.examList.iconSelectColor))
                }
                .onAppear{
                    isFavorite = exam.favoritoAppC ?? false
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
                MedicalExamsDetailsView(exam: exam, isLoadingExam: $isLoadingExam, isFavorite: $isFavorite, UIState: $UIState)
            }
        }
    }
    func changeFavorite(){
        let data = !isFavorite
        self.isLoadingFavorite = true
        Task {
            let result = await Network.shared.postFavorite(registerId: exam.Id ?? "", objet: exam.attributes?.type ?? "", data: data)
            switch result {
                case .success:
                self.isFavorite = data
                print("success")
                case let .failure(error):
                    AppStatusManager.error(error)
            }
            self.isLoadingFavorite = false
            self.isLoadingExam = true
        }
    }
    
}


