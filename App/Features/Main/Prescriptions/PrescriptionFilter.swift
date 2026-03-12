//
//  PrescriptionFilter.swift
//  CareAssistance
//
//  Created by The App Master on 30/08/2023.
//

import SwiftUI

struct PrescriptionFilter: View {
    @Binding var dateFrom: Date
    @Binding var dateUntil: Date
    @Binding var isCurrent: Bool
    @Binding var showFilterView: Bool
    @Binding var isLoading: Bool
    @State var showPickerFrom: Bool = false
    @State var showPickerUntil: Bool = false
    @State var UIState: ExamFilterUIState
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: .zero){
                Text(UIState.titleText ?? "Filtrar por fecha")
                    .font(.appSubhead)
                    .foregroundColor(Color(hex: UIState.titleColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    VStack(alignment: .leading){
                        Text("Desde")
                            .font(.appCaption)
                        Button {
                            showPickerFrom.toggle()
                        } label: {
                            Text(dateFrom.formatted(date: .numeric, time: .omitted))
                                .foregroundColor(.gray)
                                .frame(width: 130, alignment: .leading)
                                .padding(.margin / 2)
                                .background {
                                    Color.grayLight
                                }
                                .cornerRadius(.cornerRadius)
                        }
                    }
                    VStack(alignment: .leading){
                        Text("Hasta")
                            .font(.appCaption)
                        Button {
                            showPickerUntil.toggle()
                        } label: {
                            Text(dateUntil.formatted(date: .numeric, time: .omitted))
                                .foregroundColor(.gray)
                                .frame(width: 130, alignment: .leading)
                                .padding(.margin / 2)
                                .background {
                                    Color.grayLight
                                }
                                .cornerRadius(.cornerRadius)
                        }
                    }
                    .padding()
                }
                
                Button {
                    isCurrent = !isCurrent
                } label: {
                    Text(UIState.btn1Text)
                    
                        .padding(.margin / 2)
                        .background{
                            isCurrent ? Color(hex: UIState.btn1ColorBack) : Color(hex: UIState.btn1ColorText)
                        }
                        .cornerRadius(.cornerRadius)
                        .foregroundColor(isCurrent ? Color(hex: UIState.btn1ColorText) : Color(hex: UIState.btn1ColorBack))
                        .overlay(
                            RoundedRectangle(cornerRadius: .cornerRadius)
                                .stroke(Color(hex: UIState.btn1ColorBack), lineWidth: 1)
                            )
                        .padding(.bottom)
                    
                }

                Button {
                    showFilterView = false
                    isLoading = true
                } label: {
                    
                Text(UIState.btn2Text)
                    .foregroundColor(Color(hex: UIState.btn2ColorText))
                    .frame(maxWidth: .infinity)
                    .tint(.gray)
                    .frame(height: .buttonTitleHeight)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: UIState.btn2ColorBack))
                .font(.appBodyBold)
            }
            .padding()
                
            if showPickerFrom {
                withAnimation {
                    DatePickerWithButtons(showDatePicker: $showPickerFrom, savedDate: $dateFrom, selectedDate: dateFrom)
                        .background(.white)
                        .cornerRadius(.cornerRadius)
                        .shadow(radius: 10)
                }
                
            }
            if showPickerUntil {
                withAnimation {
                    DatePickerWithButtons(showDatePicker: $showPickerUntil, savedDate: $dateUntil, selectedDate: dateUntil)
                        .background(.white)
                        .cornerRadius(.cornerRadius)
                        .shadow(radius: 10)
                }
                
            }
        }
    }
}

struct DatePickerWithButtons: View {
    @Binding var showDatePicker: Bool
    @Binding var savedDate: Date
    @State var selectedDate: Date = Date()
    
    
    var body: some View {
        ZStack {
            VStack {
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .environment(\.locale, Locale.init(identifier: "en_GB"))//this is to show 24H
                
                
                Divider()
                HStack {
                    
                    Button(action: {
                        showDatePicker = false
                    }, label: {
                        Text("Cancelar")
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        savedDate = selectedDate
                        showDatePicker = false
                    }, label: {
                        Text("Aceptar".uppercased())
                            .bold()
                    })
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
