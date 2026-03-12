//
//  FilterView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 29/03/2023.
//

import SwiftUI
import RealmSwift

struct FilterView: View {
    @ObservedResults(Clinic.self, where: { $0.isActive == true }) var clinic

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Filtrar por")
                .font(.appSubhead)
                .foregroundColor(.primaryText)
            Text("Fecha")
                .font(.appCaptionLarge)
                .foregroundColor(.primaryText)
            
            datesRow
            
            Text("Seleccionar")
                .font(.appCaptionLarge)
                .foregroundColor(.primaryText)
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(clinic) { clinic in
                        Button(action: {

                        }) {
                            Text(clinic.name)
                                .font(.appCaptionLarge)
                                .frame(width: 75, height: 25)
                                .foregroundColor(.white)
                                .background(Color.buttonPrimaryBackground)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            PrimaryButton(title: "Aplicar") {

            }
        }
        .frame(maxWidth:.infinity, alignment: .leading)
        .padding(.margin)
    }
}

@ViewBuilder
var datesRow: some View {
    HStack {
        VStack(alignment: .leading) {
            Text("Desde")
                .font(.appCaption)
            Button {
                
            } label: {
                HStack {
                    Text("DD/MM/AAAA")
                        .font(.appCaption)
                        .foregroundColor(.gray)
                    Image("calendar-empty")
                        .foregroundColor(.black)
                }
                .frame(width: 124, height: 23)
                .background(Color.grayLight)
                .cornerRadius(4)
            }
        }
        
        VStack(alignment: .leading) {
            Text("Hasta")
                .font(.appCaption)
            Button {
                
            } label: {
                HStack {
                    Text("DD/MM/AAAA")
                        .font(.appCaption)
                        .foregroundColor(.gray)
                    Image("calendar-empty")
                        .foregroundColor(.black)
                }
                .frame(width: 124, height: 23)
                .background(Color.grayLight)
                .cornerRadius(4)
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
