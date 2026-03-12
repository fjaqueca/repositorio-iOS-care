//
//  PrescriptionRowView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/03/2023.
//

import SwiftUI
import RealmSwift

struct PrescriptionRowView: View {    
    @State private var isPresentingDetails = false
    @Binding var isSelected: [String:Bool]
    let prescription: Prescriptions.Prescription
    @Binding var UIState: PrescriptionUIState
    
    
    
    var body: some View {
        Button(action: {
            isPresentingDetails = true
        }) {
            HStack(alignment: .center) {
                
                Button(action: {
                    isSelected[prescription.Id ?? ""]?.toggle()
                }, label: {
                    if isSelected[prescription.Id ?? ""] == true {
                        ZStack {
                            Circle()
                                .fill(Color(hex: UIState.presList.iconSelectColor))
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
                                .foregroundColor(Color(hex: UIState.presList.iconSelectColor))
                        }
                    }
                })
                
                VStack(alignment: .leading) {
                    Text(prescription.Name ?? "Sin nombre")
                        .font(Font.custom(UIState.presList.itemTitle.font, size: CGFloat(Int(UIState.presList.itemTitle.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.presList.itemTitle.color))
                    Text("\(prescription.desdeC ?? "Sin fecha desde")")
                        .font(Font.custom(UIState.presList.itemSubTitle.font, size: CGFloat(Int(UIState.presList.itemSubTitle.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.presList.itemSubTitle.color))
                    Text(prescription.profesionalResponsableR?.Name ?? "Dr/Dra")
                        .font(Font.custom(UIState.presList.itemSubTitle.font, size: CGFloat(Int(UIState.presList.itemSubTitle.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.presList.itemSubTitle.color))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.margin / 2)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.grayLight, lineWidth: 1)
                    .shadow(radius: 20)
            )
            .background(isSelected[prescription.Id ?? ""] == true ? Color(hex: UIState.presList.iconSelectColor).opacity(0.25) : Color.clear)
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.grayLight, lineWidth: 1)
                    .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
            )
            .padding(.margin / 2)
            .navigationLink(isActive: $isPresentingDetails) {
                PrescriptionDetailsView(prescription: prescription, UIState: $UIState)
            }
        }
    }
}

