//
//  PrescriptionFilter.swift
//  CareAssistance
//
//  Created by The App Master on 30/08/2023.
//

import SwiftUI

struct PrescriptionFilter: View {
    @Binding var dateFrom: Date?
    @Binding var dateUntil: Date?
    @Binding var showFilterView: Bool
    @Binding var selectedDocumentType: String

    /// Caso 3: Fechas válidas → llama servicio con fechas
    var onApplyWithDates: ((Date, Date) -> Void)? = nil
    /// Caso 1: Sin fechas → llama servicio con default 90 días
    var onClear: (() -> Void)? = nil

    @State var UIState: ExamFilterUIState

    @State private var showPickerFrom: Bool = false
    @State private var showPickerUntil: Bool = false
    @State private var iconScale: CGFloat = 0.0
    @State private var iconOpacity: Double = 0.0
    @State private var errorMessage: String = ""

    private let maxDate: Date = Date()
    var documentTypes: [String] = ["Todos", "Orden médica", "Examen automatizado", "Receta médica"]

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture {
                    showFilterView = false
                }

            // Card
            VStack(spacing: 16) {
                // Header: botón X + ícono filtro con bounce
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "#E0E0E0"), lineWidth: 1.5)
                                )
                            Image(systemName: "line.3.horizontal.decrease")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color(hex: "#00BBDC"))
                        }
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.3)) {
                                iconScale = 1.0
                                iconOpacity = 1.0
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)

                    Button {
                        showFilterView = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#999999"))
                    }
                    .padding(.top, 14)
                    .padding(.trailing, 4)
                }

                // Título
                Text(UIState.titleText.isEmpty ? "Filtrar" : UIState.titleText)
                    .font(Font.custom("FiraSans-Bold", size: 17))
                    .foregroundColor(Color(hex: UIState.titleColor.isEmpty ? "#333333" : UIState.titleColor))

                // MARK: - Tipo de documento (picklist)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tipo de documento")
                        .font(Font.custom("FiraSans-Medium", size: 13))
                        .foregroundColor(Color(hex: "#555555"))

                    Menu {
                        ForEach(documentTypes, id: \.self) { type in
                            Button {
                                selectedDocumentType = type == "Todos" ? "" : type
                            } label: {
                                HStack {
                                    Text(type)
                                    Spacer()
                                    if (type == "Todos" && selectedDocumentType.isEmpty) ||
                                       selectedDocumentType == type {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedDocumentType.isEmpty ? "Todos" : selectedDocumentType)
                                .font(Font.custom("FiraSans-Regular", size: 14))
                                .foregroundColor(selectedDocumentType.isEmpty ? .gray.opacity(0.5) : Color(hex: "#333333"))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#00BBDC"))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }

                // MARK: - Rango de fechas
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        // Desde
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Desde")
                                .font(Font.custom("FiraSans-Medium", size: 13))
                                .foregroundColor(Color(hex: "#555555"))

                            Button {
                                showPickerFrom = true
                                showPickerUntil = false
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#00BBDC"))
                                    Text(dateFrom != nil ? formatDate(dateFrom!) : "DD/MM/AAAA")
                                        .font(Font.custom("FiraSans-Regular", size: 13))
                                        .foregroundColor(dateFrom != nil ? Color(hex: "#333333") : .gray.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }

                        // Hasta
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hasta")
                                .font(Font.custom("FiraSans-Medium", size: 13))
                                .foregroundColor(Color(hex: "#555555"))

                            Button {
                                showPickerUntil = true
                                showPickerFrom = false
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#00BBDC"))
                                    Text(dateUntil != nil ? formatDate(dateUntil!) : "DD/MM/AAAA")
                                        .font(Font.custom("FiraSans-Regular", size: 13))
                                        .foregroundColor(dateUntil != nil ? Color(hex: "#333333") : .gray.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }

                    // Mensaje de error en tiempo real
                    if !errorMessage.isEmpty && (dateFrom != nil || dateUntil != nil) {
                        Text(errorMessage)
                            .font(Font.custom("FiraSans-Regular", size: 12))
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // MARK: - Botones
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        // Aplicar
                        Button {
                            applyFilter()
                        } label: {
                            Text(UIState.btn2Text.isEmpty ? "Aplicar filtro" : UIState.btn2Text)
                                .font(Font.custom("FiraSans-Bold", size: 15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color(hex: UIState.btn2ColorBack.isEmpty ? "#00BBDC" : UIState.btn2ColorBack))
                                )
                        }

                        // Cancelar
                        Button {
                            showFilterView = false
                        } label: {
                            Text("Cancelar")
                                .font(Font.custom("FiraSans-Bold", size: 15))
                                .foregroundColor(Color(hex: "#555555"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color(hex: "#CCCCCC"), lineWidth: 1)
                                )
                        }
                    }

                    // Limpiar filtros
                    Button {
                        clearFilter()
                    } label: {
                        Text("Limpiar filtros")
                            .font(Font.custom("FiraSans-Regular", size: 13))
                            .foregroundColor(Color(hex: "#00BBDC"))
                            .underline()
                    }
                    .padding(.bottom, 4)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
            .frame(maxWidth: 330)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
            .onChange(of: dateFrom) { _ in validateDates() }
            .onChange(of: dateUntil) { _ in validateDates() }

            // DatePicker overlays
            if showPickerFrom {
                OptionalDatePickerWithButtons(
                    showDatePicker: $showPickerFrom,
                    savedDate: $dateFrom,
                    initialDate: dateFrom ?? Date(),
                    maxDate: maxDate
                )
                .background(.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 40)
            }
            if showPickerUntil {
                OptionalDatePickerWithButtons(
                    showDatePicker: $showPickerUntil,
                    savedDate: $dateUntil,
                    initialDate: dateUntil ?? Date(),
                    maxDate: maxDate
                )
                .background(.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 40)
            }
        }
    }

    // MARK: - Validación en tiempo real (paridad web)
    private func validateDates() {
        if dateFrom == nil && dateUntil == nil {
            errorMessage = ""
            return
        }
        if dateFrom == nil || dateUntil == nil {
            errorMessage = "Complete ambas fechas!"
            return
        }
        if dateUntil! < dateFrom! {
            errorMessage = "La fecha \"Hasta\" debe ser posterior a la fecha \"Desde\"!"
            return
        }
        let days = abs(Calendar.current.dateComponents([.day], from: dateFrom!, to: dateUntil!).day ?? 0)
        if days > 365 {
            errorMessage = "No es posible filtrar más de 1 año!"
            return
        }
        errorMessage = ""
    }

    // MARK: - Aplicar filtro (3 casos del web)
    private func applyFilter() {
        let hasDates = dateFrom != nil || dateUntil != nil

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 [PrescriptionFilter] APLICAR FILTRO")
        print("   dateFrom: \(dateFrom != nil ? formatDate(dateFrom!) : "nil")")
        print("   dateUntil: \(dateUntil != nil ? formatDate(dateUntil!) : "nil")")
        print("   hasDates: \(hasDates)")
        print("   errorMessage: \"\(errorMessage)\"")

        if !hasDates {
            // CASO 1: Ambas vacías → reset (servicio con default 90 días)
            print("   → CASO 1: Sin fechas → onClear (default 90 días)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            onClear?()
            showFilterView = false
            return
        }

        if hasDates && !errorMessage.isEmpty {
            // CASO 2: Hay fechas pero con error → bloquear, no cerrar
            errorMessage = "Verifique que las fechas sean correctas!"
            print("   → CASO 2: Error de validación → bloqueado")
            print("   errorMessage: \"\(errorMessage)\"")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            return
        }

        // CASO 3: Fechas válidas → llamar servicio con fechas
        print("   → CASO 3: Fechas válidas → onApplyWithDates")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        onApplyWithDates?(dateFrom!, dateUntil!)
        showFilterView = false
    }

    // MARK: - Limpiar filtros (no cierra modal, no llama servicio)
    private func clearFilter() {
        print("🧹 [PrescriptionFilter] LIMPIAR FILTROS (sin servicio, sin cerrar)")
        dateFrom = nil
        dateUntil = nil
        selectedDocumentType = ""
        errorMessage = ""
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - DatePicker para fechas opcionales
struct OptionalDatePickerWithButtons: View {
    @Binding var showDatePicker: Bool
    @Binding var savedDate: Date?
    @State var selectedDate: Date = Date()
    var initialDate: Date = Date()
    var maxDate: Date = Date()

    var body: some View {
        VStack(spacing: 0) {
            DatePicker(
                "",
                selection: $selectedDate,
                in: ...maxDate,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            .environment(\.locale, Locale(identifier: "es"))
            .onAppear { selectedDate = initialDate }

            Divider()

            HStack {
                Button {
                    showDatePicker = false
                } label: {
                    Text("Cancelar")
                        .font(Font.custom("FiraSans-Regular", size: 15))
                        .foregroundColor(.gray)
                }

                Spacer()

                Button {
                    savedDate = selectedDate
                    showDatePicker = false
                } label: {
                    Text("Aceptar")
                        .font(Font.custom("FiraSans-Bold", size: 15))
                        .foregroundColor(Color(hex: "#00BBDC"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .padding(.top, 8)
    }
}
