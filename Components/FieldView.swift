//
//  FieldView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 09/08/2022.
//

import SwiftUI

struct FieldView: View {
    @Binding var field: Field
    @State private var isPasswordVisible = false
    var textRut: String = ""
    var isError: Bool {
        field.validationErrorMessage != nil
    }

    var body: some View {
        VStack(spacing: .margin) {
            fieldView
                .keyboardType(field.keyboardType)
                .textFieldStyle(.roundedBorder)
                .font(.appCallout)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(!isError ? Color.gray : Color.negativeSentiment)
                        .transition(.opacity)
                )
                .cornerRadius(8)
            
            if let error = field.validationErrorMessage {
                Text(error)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.negativeSentiment)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 1)
        .animation(.default, value: isError)
    }

    @ViewBuilder
    var fieldView: some View {
        
        let textBinding: Binding<String>  = .init(
            get: {
                field.value ?? ""
            }, set: { value in
                field.value = value
            }
        )
        if field.isSecure {

            if isPasswordVisible {
                TextField(field.description, text: textBinding)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .overlay {
                        HStack{
                            Spacer()
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 5)
                        }
                    }
            } else {
                SecureField(field.description, text: textBinding)
                    .overlay {
                        HStack{
                            Spacer()
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 5)
                        }
                    }
            }

            
//            SecureField(field.description, text: textBinding)
        } else {
            if self.textRut != ""{
                TextField(self.textRut, text: textBinding)
                    .font(.appCallout)
                    .onAppear{
                        print(self.textRut)
                    }
            }else{
                TextField(field.description, text: textBinding)
                    .font(.appCallout)
            }
            
        }
    }
}

struct FieldView_Preview: PreviewProvider {
    struct Preview: View {
        @State var field: Field = .email

        var body: some View {
            VStack {
                FieldView(field: $field)
                    .padding(.horizontal)
                Spacer()
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
