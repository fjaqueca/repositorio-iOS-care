//
//  CompletionRows.swift
//  CareAssistance
//
//  Created by The App Master on 11/10/2023.
//

import SwiftUI
import MultiPicker
import SDWebImageSwiftUI
import UIKit // Necesario para los generadores de feedback
import UniformTypeIdentifiers

struct NumericRow: View {

    // MARK: - Inputs
    let idCom: String
    let name: String
    let isRequired: Bool

    @Binding var response: [String : String]
    @Binding var numericNextQuestionnaireId: String

    // Parámetros necesarios para la lógica de concatenación numérica
    let conditionsOfNumericQuestionnaire: String?
    let possibilityOfId: String?
    let canEdit: Bool

    // MARK: - State
    @State private var score: Int? = nil
    @State var isSingleCompletion: Bool = false

    // MARK: - Validación requerido
    private var isRequiredInvalid: Bool {
        isRequired && score == nil
    }

    // MARK: - Borde dinámico
    private var borderColor: Color {
        isRequiredInvalid ? .red : .primaryText
    }

    var body: some View {

        if isSingleCompletion {

            VStack(spacing: 4) {

                TextField("", value: $score, formatter: formatter)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: .cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                            .animation(.easeInOut(duration: 0.25), value: borderColor)
                    )
                    .opacity(canEdit ? 1 : 0.25)

                if isRequiredInvalid {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("Este campo es obligatorio")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.bottom, 10)
            .onAppear {
                // Prefill si hay respuesta previa
                if let existing = response[idCom], let val = Int(existing) {
                    score = val
                }
            }
            .onChange(of: score) { newValue in
                response[idCom] = newValue == nil ? "" : String(newValue!)
            }
            .onChange(of: response[idCom]) { newValue in
                // Si llega la data de function_filter, reflejarla
                if let newValue, let val = Int(newValue) {
                    score = val
                }
            }

        } else {

            VStack(alignment: .leading, spacing: 8) {

                HStack(spacing: 4) {
                    Text(name)
                        .foregroundColor(.primaryText)
                        .font(.appCallout.bold())
                    
                    if isRequired && score == nil {
                        Text("*")
                            .foregroundColor(.red)
                            .font(.appCallout.bold())
                    }
                }

                VStack(spacing: 4) {

                    TextField("", value: $score, formatter: formatter)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: .cornerRadius)
                                .stroke(borderColor, lineWidth: 1)
                                .animation(.easeInOut(duration: 0.25), value: borderColor)
                        )
                        .opacity(canEdit ? 1 : 0.25)

                    if isRequiredInvalid {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text("Este campo es obligatorio")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 10)
            }
            .onAppear {
                // Prefill si hay respuesta
                if let existing = response[idCom], let val = Int(existing) {
                    score = val
                } else {
                    score = nil
                }
            }
            .onChange(of: response[idCom]) { newValue in
                if let newValue, let val = Int(newValue) {
                    score = val
                }
            }
            .onChange(of: score) { newValue in
                response[idCom] = newValue == nil ? "" : String(newValue!)

                if let value = newValue,
                   let ids = possibilityOfId {
                    numericNextQuestionnaireId = concatCondPorNum(
                        sValor: String(value),
                        sRangos: conditionsOfNumericQuestionnaire ?? "",
                        sIds: ids
                    )
                }
            }
        }
    }

    // MARK: - Lógica numérica (SIN CAMBIOS)

    func concatCondPorNum(sValor: String, sRangos: String, sIds: String) -> String {
        var valor: Float = 0.0
        let rangos = sRangos.split(separator: ";")
        let ids = sIds.split(separator: ";").map { String($0) }

        do {
            valor = try Float(sValor) ?? 0.0
        } catch {}

        for i in 0..<rangos.count {
            let terminos = rangos[i].split(separator: "|").map { String($0) }

            if terminos.count == 3 {
                var limite: Float = 0.0
                do {
                    limite = try Float(terminos[2]) ?? 0.0
                } catch {}

                if terminos[0].localizedCaseInsensitiveContains("n") {
                    if comparar(valor, limite, terminos[1]) {
                        return ids[i]
                    }
                }
            }

            if terminos.count == 5 {
                var limite1: Float = 0.0
                var limite2: Float = 0.0
                do {
                    limite1 = try Float(terminos[0]) ?? 0.0
                    limite2 = try Float(terminos[4]) ?? 0.0
                } catch {}

                if terminos[2].localizedCaseInsensitiveContains("n") {
                    if comparar(valor, limite1, terminos[1], true) &&
                        comparar(valor, limite2, terminos[3], false) {
                        return ids[i]
                    }
                }
            }
        }

        return ""
    }

    func comparar(_ val1: Float, _ val2: Float, _ signo: String, _ inv: Bool = false) -> Bool {
        var out = false
        var v1 = val1
        var v2 = val2

        if inv {
            swap(&v1, &v2)
        }

        switch signo {
        case "<":  out = v1 < v2
        case "<=": out = v1 <= v2
        case "=":  out = v1 == v2
        case ">=": out = v1 >= v2
        case ">":  out = v1 > v2
        default:   break
        }

        return out
    }

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}

struct CheckBoxRow: View {

    // MARK: - State
    @State private var isOn: Bool = false

    // MARK: - Inputs
    let idCom: String
    let name: String
    let isRequired: Bool
    @Binding var response: [String : String]
    let canEdit: Bool
    @State var isSingleCompletion: Bool = false

    private var isRequiredInvalid: Bool {
        isRequired && !isOn
    }

    private var borderColor: Color {
        isRequiredInvalid ? .red : (isOn ? .primaryText : .grayLight)
    }

    var body: some View {

        if isSingleCompletion {

            Toggle("", isOn: $isOn)
                .opacity(canEdit ? 1 : 0.3)
                .toggleStyle(CheckToggleSquareStyle(foregroundColor: .secondaryText))
                .onAppear {
                    if let existing = response[idCom] {
                        isOn = (existing == "true")
                    }
                }
                .onChange(of: isOn) { newValue in
                    response[idCom] = String(newValue)
                }
                .onChange(of: response[idCom]) { newValue in
                    if let newValue {
                        isOn = (newValue == "true")
                    }
                }

        } else {

            VStack(alignment: .leading, spacing: 4) {

                HStack {
                    HStack(spacing: 4) {
                        Text(name)
                            .foregroundColor(isOn ? .white : .primaryText)
                            .font(.appBodyCheckbox)
                        
                        if isRequired && !isOn {
                            Text("*")
                                .foregroundColor(isOn ? .white : .red)
                                .font(.appBody)
                        }
                    }

                    Spacer()

                    Toggle("", isOn: $isOn)
                        .opacity(canEdit ? 1 : 0.3)
                        .toggleStyle(
                            CheckToggleSquareStyle(
                                foregroundColor: isOn ? .white : .primaryText
                            )
                        )
                }
                .padding(.margin)
                .frame(maxWidth: .infinity)
                .background(
                    isOn
                    ? Color.buttonPrimaryBackground
                    : Color.clear
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                        .animation(.easeInOut(duration: 0.25), value: borderColor)
                )
                .cornerRadius(.cornerRadius)

                if isRequiredInvalid {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("Este campo es obligatorio")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onAppear {
                if let existing = response[idCom] {
                    isOn = (existing == "true")
                }
            }
            .onChange(of: response[idCom]) { newValue in
                if let newValue {
                    isOn = (newValue == "true")
                }
            }
            .onChange(of: isOn) { newValue in
                response[idCom] = String(newValue)
            }
        }
    }
}

/*struct PickerRow: View {
    // MARK: - Inputs
    let dataPicker: String
    let idCom: String
    let name: String
    let isRequired: Bool

    @Binding var response: [String : String]
    @Binding var positionOfPicklist: Int
    let canEdit: Bool

    // MARK: - Local State
    @State private var pickerList: [String] = []
    @State private var selectedPickerList: String = ""
    @State private var isMenuVisible: Bool = false

    // MARK: - UI Constants
    private let minFieldHeight: CGFloat = 52  // ✅ Cambio: minHeight en lugar de altura fija
    private let cornerRadius: CGFloat = 12
    private let verticalPadding: CGFloat = 10  // ✅ Nuevo: padding vertical para crecimiento dinámico

    private var isRequiredInvalid: Bool {
        isRequired && selectedPickerList.isEmpty
    }

    private var borderColor: Color {
        if isRequiredInvalid { return .red }
        return isMenuVisible ? .blue : Color(.systemGray4)
    }

    private var backgroundColor: Color {
        isRequiredInvalid ? Color.red.opacity(0.05) : Color(.systemBackground)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                if (isRequired && selectedPickerList.isEmpty) {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 4)

            // ✅ Wrapper con borde animado FUERA del contenido que se recrea
            ZStack {
                // Contenido interior que se recrea al cambiar selección
                Menu {
                    ForEach(pickerList, id: \.self) { item in
                        Button {
                            selectItem(item)
                        } label: {
                            HStack {
                                // ✅ Texto dinámico sin límite de líneas
                                Text(item)
                                    .lineLimit(nil)  // Sin límite de líneas
                                    .fixedSize(horizontal: false, vertical: true)  // Permite crecimiento vertical
                                
                                if selectedPickerList == item {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        // ✅ Campo de selección con altura dinámica
                        if selectedPickerList.isEmpty {
                            Text("Selecciona una opción...")
                                .foregroundColor(.gray.opacity(0.7))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)  // ✅ Fuerza cálculo de ancho
                                .layoutPriority(1)  // ✅ Prioridad para calcular primero
                        } else {
                            Text(selectedPickerList)
                                .foregroundColor(.primaryText)
                                .fontWeight(.medium)
                                .lineLimit(nil)  // ✅ Sin límite de líneas, permite texto largo
                                .fixedSize(horizontal: false, vertical: true)  // ✅ Permite crecimiento vertical
                                .lineSpacing(3)  // ✅ Similar al lineSpacingExtra de Android
                                .frame(maxWidth: .infinity, alignment: .leading)  // ✅ Fuerza cálculo de ancho
                                .layoutPriority(1)  // ✅ Prioridad para calcular primero
                        }

                        Spacer(minLength: 8)

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(isMenuVisible ? .blue : .primaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, verticalPadding)  // ✅ Padding vertical dinámico
                    .frame(maxWidth: .infinity, minHeight: minFieldHeight, alignment: .leading)  // ✅ minHeight con crecimiento
                }
                .id(selectedPickerList)  // ✅ CLAVE: Fuerza re-render del contenido al cambiar selección
                .onTapGesture {
                    isMenuVisible = true
                }
            }
            // ✅ Background y borde FUERA del .id(), para que se animen independientemente
            .background(
                backgroundColor
                    .animation(.easeInOut(duration: 0.25), value: isRequiredInvalid)
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: isMenuVisible ? 2 : 1)
                    .animation(.easeInOut(duration: 0.25), value: borderColor)
                    .animation(.easeInOut(duration: 0.25), value: isMenuVisible)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            .opacity(canEdit ? 1 : 0.4)

            if isRequiredInvalid {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Este campo es obligatorio")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        // ✅ REMOVIDO: Animación global que causaba el "salto"
        // .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedPickerList)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isRequiredInvalid)  // ✅ Solo animar validación
        .onAppear(perform: setupInitialData)
        .onChange(of: response[idCom]) { newValue in
            // Si llega una respuesta precargada desde function_filter, reflejarla
            if let value = newValue, !value.isEmpty, pickerList.contains(value) {
                selectedPickerList = value
                if let index = pickerList.firstIndex(of: value) {
                    positionOfPicklist = index
                }
            }
        }
    }

    private func setupInitialData() {
        pickerList = dataPicker
            .components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if let existingValue = response[idCom], !existingValue.isEmpty {
            selectedPickerList = existingValue
            if let index = pickerList.firstIndex(of: existingValue) {
                positionOfPicklist = index
            }
        } else {
            selectedPickerList = ""
        }
    }

    private func selectItem(_ item: String) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        selectedPickerList = item
        response[idCom] = item
        isMenuVisible = false

        if let index = pickerList.firstIndex(of: item) {
            positionOfPicklist = index
        }
    }
}

struct PickerCompletion<S: Hashable & CustomStringConvertible>: View {

    var items: [S]
    @Binding var selection: S
    @State private var showPicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            Button {
                showPicker.toggle()
            } label: {
                HStack {
                    Text(
                        selection.description.isEmpty
                        ? "Selecciona una opción"
                        : selection.description
                    )
                    .foregroundColor(
                        selection.description.isEmpty ? .gray : .primaryText
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .rotationEffect(showPicker ? .degrees(180) : .degrees(0))
                        .animation(.easeInOut, value: showPicker)
                }
                .padding(.horizontal, .margin / 2)
                .frame(height: 34)
            }

            if showPicker {
                ForEach(items, id: \.self) { item in
                    Button {
                        selection = item
                        showPicker = false
                    } label: {
                        HStack {
                            Text(item.description)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if selection == item {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding(.horizontal, .margin / 2)
                        .padding(.vertical, 8)
                    }
                    Divider()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.grayLight, lineWidth: 1)
        )
    }
}

// MARK: - 1. Modelo de Datos Unificado
struct ChipItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static func parse(_ rawString: String) -> [ChipItem] {
        rawString.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { ChipItem(name: $0) }
    }
    
    static func toString(_ items: [ChipItem]) -> String {
        items.map { $0.name }.joined(separator: ";")
    }
}*/

struct PickerRow: View {

    // MARK: - Inputs
    let dataPicker: String
    let idCom: String
    let name: String
    let isRequired: Bool

    @Binding var response: [String : String]
    @Binding var positionOfPicklist: Int
    let canEdit: Bool

    // MARK: - State
    @State private var selectedPickerList: String = ""
    @State private var showPickerSheet = false

    // ✅ COMPUTED PROPERTY: Parsear opciones dinámicamente (garantiza que siempre estén disponibles)
    private var pickerList: [String] {
        dataPicker
            .components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    // MARK: - UI Constants
    private let minFieldHeight: CGFloat = 52
    private let cornerRadius: CGFloat = 12

    // MARK: - Validation
    private var isRequiredInvalid: Bool {
        isRequired && selectedPickerList.isEmpty
    }

    private var borderColor: Color {
        isRequiredInvalid ? .red : Color.gray.opacity(0.4)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            // MARK: - Label
            HStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primaryText)

                if isRequired && selectedPickerList.isEmpty {
                    Text("*")
                        .foregroundColor(.red)
                }
            }

            // MARK: - Field
            Button {
                guard canEdit else { return }
                showPickerSheet = true
            } label: {

                HStack(alignment: .top, spacing: 12) {

                    Text(
                        selectedPickerList.isEmpty
                        ? "Selecciona una opción..."
                        : selectedPickerList
                    )
                    .foregroundColor(
                        selectedPickerList.isEmpty
                        ? .gray.opacity(0.7)
                        : .primaryText
                    )
                    .font(.system(size: 15))
                    .lineLimit(nil) // ✅ multiline real
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primaryText)
                }
                .padding()
                .frame(minHeight: minFieldHeight, alignment: .leading)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                        .animation(.easeInOut(duration: 0.25), value: borderColor)
                )
                .cornerRadius(cornerRadius)
                .opacity(canEdit ? 1 : 0.4)
            }
            .buttonStyle(.plain)

            // MARK: - Error
            if isRequiredInvalid {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Este campo es obligatorio")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showPickerSheet) {
            PickerOptionsSheet(
                title: name,
                options: pickerList,
                selected: selectedPickerList,
                onSelect: selectItem
            )
            .modifier(SheetCompatibilityModifier())
            .onAppear {
                print("🔍 [Sheet] Mostrando picker con \(pickerList.count) opciones")
                if !pickerList.isEmpty {
                    print("🔍 [Sheet] Primera opción: '\(pickerList[0].prefix(50))...'")
                }
            }
        }
        .onAppear {
            // Solo inicializar selección si hay respuesta previa
            print("📋 [PickerRow] dataPicker recibido: '\(dataPicker.prefix(100))...'")
            print("📋 [PickerRow] Opciones parseadas (\(pickerList.count)): \(pickerList.map { "\"\($0.prefix(30))...\"" })")
            
            if let existing = response[idCom], pickerList.contains(existing) {
                selectedPickerList = existing
                positionOfPicklist = pickerList.firstIndex(of: existing) ?? 0
                print("🔄 [PickerRow] Inicializado con selección previa: '\(existing)'")
            } else {
                selectedPickerList = ""
                print("🔄 [PickerRow] Inicializado sin selección previa")
            }
        }
        .onChange(of: response[idCom]) { newValue in
            guard let value = newValue, pickerList.contains(value) else { return }
            selectedPickerList = value
            positionOfPicklist = pickerList.firstIndex(of: value) ?? 0
        }
    }
    

    struct PickerOptionsSheet: View {

        let title: String
        let options: [String]
        let selected: String
        let onSelect: (String) -> Void

        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationView {
                Group {
                    if options.isEmpty {
                        // 🔍 Debug: Mostrar mensaje si no hay opciones
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            Text("No hay opciones disponibles")
                                .font(.headline)
                            
                            Text("El campo 'dataPicker' está vacío o mal formateado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // ✅ Lista con opciones
                        List {
                            ForEach(options, id: \.self) { item in
                                Button {
                                    onSelect(item)
                                    dismiss()
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        
                                        Text(item)
                                            .font(.system(size: 16))
                                            .foregroundColor(selected == item ? .white : .primary)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if selected == item {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selected == item ? Color.blue : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
            .onAppear {
                print("🔍 [PickerOptionsSheet] Opciones recibidas: \(options.count)")
                if !options.isEmpty {
                    print("🔍 [PickerOptionsSheet] Primera opción: '\(options[0].prefix(50))...'")
                }
            }
        }
    }

    // MARK: - Selection
    private func selectItem(_ item: String) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()

        selectedPickerList = item
        response[idCom] = item
        positionOfPicklist = pickerList.firstIndex(of: item) ?? 0
    }
}

struct PickerCompletion<S: Hashable & CustomStringConvertible>: View {

    var items: [S]
    @Binding var selection: S
    @State private var showPicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            Button {
                showPicker.toggle()
            } label: {
                HStack {
                    Text(
                        selection.description.isEmpty
                        ? "Selecciona una opción"
                        : selection.description
                    )
                    .foregroundColor(
                        selection.description.isEmpty ? .gray : .primaryText
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .rotationEffect(showPicker ? .degrees(180) : .degrees(0))
                        .animation(.easeInOut, value: showPicker)
                }
                .padding(.horizontal, .margin / 2)
                .frame(height: 34)
            }

            if showPicker {
                ForEach(items, id: \.self) { item in
                    Button {
                        selection = item
                        showPicker = false
                    } label: {
                        HStack {
                            Text(item.description)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if selection == item {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding(.horizontal, .margin / 2)
                        .padding(.vertical, 8)
                    }
                    Divider()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.grayLight, lineWidth: 1)
        )
    }
}

// MARK: - 1. Modelo de Datos Unificado
struct ChipItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static func parse(_ rawString: String) -> [ChipItem] {
        rawString.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { ChipItem(name: $0) }
    }
    
    static func toString(_ items: [ChipItem]) -> String {
        items.map { $0.name }.joined(separator: ";")
    }
}

// MARK: - 2. Componente Principal: MultiSelectField
struct MultiSelectField: View {

    // MARK: - Inputs
    let label: String
    let placeholder: String
    @Binding var selectedItems: [ChipItem]
    let allOptions: String
    let isRequired: Bool
    let isValid: Bool
    let canEdit: Bool

    // MARK: - State
    @State private var isShowingPicker = false

    private var parsedOptions: [ChipItem] {
        ChipItem.parse(allOptions)
    }

    private var isRequiredInvalid: Bool {
        isRequired && !isValid
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primaryText)
                
                if isRequired && selectedItems.isEmpty {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .bold))
                }
            }

            Button(action: { isShowingPicker.toggle() }) {
                HStack {

                    if selectedItems.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray.opacity(0.7))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedItems) { item in
                                    ChipView(item: item, isSelected: true) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedItems.removeAll { $0.id == item.id }
                                            HapticManager.impact(style: .light)
                                        }
                                    }
                                    .id(item.id)  // ✅ Fuerza recreación limpia del chip
                                    .transition(.scale.combined(with: .opacity))  // ✅ Transición suave
                                }
                            }
                            .padding(.vertical, 4)
                            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedItems)  // ✅ Anima cambios del array
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primaryText)
                }
                .padding()
                .frame(minHeight: 55)
                .opacity(canEdit ? 1 : 0.4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isRequiredInvalid ? Color.red : Color.gray.opacity(0.4),
                            lineWidth: 1
                        )
                        .animation(.easeInOut(duration: 0.25), value: isRequiredInvalid)
                )
            }

            if isRequiredInvalid {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Este campo es obligatorio")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            UniversalPickerSheet(
                title: label,
                options: parsedOptions,
                selections: $selectedItems
            )
            .modifier(SheetCompatibilityModifier())
        }
    }
}

// MARK: - 3. UniversalPickerSheet (Lógica de filtrado actualizada)
struct UniversalPickerSheet: View {
    let title: String
    let options: [ChipItem]
    @Binding var selections: [ChipItem]
    
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var filteredOptions: [ChipItem] {
        let available = options.filter { option in
            !selections.contains(where: { $0.name.lowercased() == option.name.lowercased() })
        }
        
        if searchText.isEmpty {
            return available
        } else {
            return available.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Buscar opciones disponibles...", text: $searchText)
                }
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .padding()

                ScrollView {
                    if !selections.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Seleccionados")
                                .font(.caption).bold().foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            FlowLayout(items: selections) { item in
                                ChipView(item: item, isSelected: true) {
                                    withAnimation(.spring()) {
                                        selections.removeAll { $0.id == item.id }
                                        HapticManager.impact(style: .light)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider().padding(.vertical)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Disponibles")
                            .font(.caption).bold().foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        FlowLayout(items: filteredOptions) { item in
                            ChipView(item: item, isSelected: false) {
                                withAnimation(.spring()) {
                                    selections.append(item)
                                    HapticManager.impact(style: .medium)
                                    searchText = ""
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Hecho") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - 4. Componente Visual ChipView
struct ChipView: View {
    let item: ChipItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // ✅ Altura dinámica para textos largos
                Text(item.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(nil)  // ✅ Sin límite de líneas
                    .fixedSize(horizontal: false, vertical: true)  // ✅ Permite crecimiento vertical
                    .lineSpacing(2)  // ✅ Espaciado entre líneas
                    .multilineTextAlignment(.leading)  // ✅ Alineación consistente
                
                if isSelected {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .padding(4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)  // ✅ Padding vertical permite crecimiento
            .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))  // ✅ RoundedRectangle en lugar de Capsule para mejor multiline
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 5. Helper FlowLayout
struct FlowLayout<T: Identifiable, V: View>: View {
    var items: [T]
    var content: (T) -> V
    @State private var totalHeight = CGFloat.zero
    
    init(items: [T], @ViewBuilder content: @escaping (T) -> V) {
        self.items = items
        self.content = content
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items) { item in
                self.content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item.id == self.items.last?.id {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item.id == self.items.last?.id {
                            height = 0
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// MARK: - 6. Utilidades (Haptics & Modifiers)
struct HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct SheetCompatibilityModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}

struct LabelRow: View {
    let text: String
    let isTitle: Bool

    var body: some View {
        Text(text)
            .foregroundColor(.primaryText)
            .font(isTitle ? .appCallout.bold() : .appCallout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
}

struct OpenURLRow: View {

    // MARK: - Inputs
    @Binding var response: [String : String]
    let name: String
    let idCom: String
    let url: String
    let isRequired: Bool
    // Controla si el usuario puede editar el toggle (por defecto true para compatibilidad)
    let canEditToggle: Bool

    // MARK: - State
    @State private var isOn: Bool = false
    @State private var showWebView = false

    private var isRequiredInvalid: Bool {
        isRequired && isOn == false
    }

    private var borderColor: Color {
        isRequiredInvalid ? .red : .grayLight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack(spacing: 4) {
                Text(name)
                    .font(.appCallout.bold())
                    .foregroundColor(.primaryText)
                
                if isRequired && !isOn {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.appCallout.bold())
                }
            }

            HStack(spacing: 12) {

                // Área del enlace (solo aquí se aplica el tap)
                HStack(spacing: 12) {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .semibold))

                    Text("Ver archivo adjunto")
                        .font(.appCallout)
                        .foregroundColor(.primaryText)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    openArchive()
                }

                Spacer()

                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(
                        SwitchToggleStyle(tint: .blue)
                    )
                    .disabled(!canEditToggle)
                    .opacity(canEditToggle ? 1 : 0.5)
                    .onChange(of: isOn) { newValue in
                        response[idCom] = String(newValue)
                    }
            }
            .padding()
            .frame(minHeight: 52)
            .background(
                isRequiredInvalid
                ? Color.red.opacity(0.05)
                : Color(.systemGray6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
                    .animation(.easeInOut(duration: 0.25), value: borderColor)
            )
            .cornerRadius(.cornerRadius)
        }
        .onAppear {
            if let existing = response[idCom] {
                isOn = (existing == "true")
            }
        }
        .onChange(of: response[idCom]) { newValue in
            if let newValue {
                isOn = (newValue == "true")
            }
        }
        .sheet(isPresented: $showWebView) {
            SafariWebView(url: url)
        }
        .padding(.bottom, 18)
    }

    private func openArchive() {
        guard let url = URL(string: url), !url.absoluteString.isEmpty else {
            return
        }
        showWebView = true
    }
}

struct CommentRow: View {

    @State private var comment: String = ""

    let isRequired: Bool
    @Binding var response: [String : String]

    let idCom: String
    let name: String
    let canEdit: Bool
    private let maxCharacters = 500

    private var isRequiredInvalid: Bool {
        isRequired &&
        comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var borderColor: Color {
        isRequiredInvalid ? .red : .primaryText
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            HStack(spacing: 4) {
                Text(name)
                    .font(.appCallout.bold())
                    .foregroundColor(.primaryText)
                
                if isRequired && comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.appCallout.bold())
                }
            }

            ZStack(alignment: .topLeading) {

                if comment.isEmpty {
                    Text("Escribe tu comentario…")
                        .font(.appCaptionLarge)
                        .foregroundColor(.darkGray)
                        .padding(.top, 12)
                        .padding(.horizontal, 12)
                }

                TextEditor(text: $comment)
                    .font(.appCaptionLarge)
                    .foregroundColor(.primaryText)
                    .padding(8)
                    .background(Color.clear)
                    .onChange(of: comment) { newValue in
                        if newValue.count > maxCharacters {
                            comment = String(newValue.prefix(maxCharacters))
                        }
                        response[idCom] = comment
                    }
            }
            .frame(minHeight: 100, maxHeight: 120)
            .background(Color.grayLight)
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
                    .animation(.easeInOut(duration: 0.25), value: borderColor)
            )
            .opacity(canEdit ? 1 : 0.3)

            if isRequiredInvalid {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Este campo es obligatorio")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            HStack {
                Spacer()
                Text("\(comment.count)/\(maxCharacters)")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .onAppear {
            if let existing = response[idCom], !existing.isEmpty {
                comment = existing
            }
        }
        .onChange(of: response[idCom]) { newValue in
            // Si llega la data precargada y el usuario aún no ha escrito, poblarla
            if let newValue, !newValue.isEmpty, comment.isEmpty {
                comment = newValue
            }
        }
    }
}

struct FileRow: View {
    
    // MARK: - ⚠️ LÍMITE DE TAMAÑO (igual que Android)
    private let MAX_FILE_SIZE_MB = 4
    private var maxFileSizeBytes: Int {
        MAX_FILE_SIZE_MB * 1024 * 1024 // 4 * 1024 * 1024 = 4,194,304 bytes
    }

    // MARK: - State
    @State private var showOptionPicker = false
    @State private var showCameraPicker = false
    @State private var showGalleryPicker = false
    @State private var showDocumentPicker = false
    
    // ✅ NUEVO: Alert para límite de tamaño
    @State private var showFileSizeAlert = false
    @State private var fileSizeErrorMessage = ""

    @State private var fileData: String = ""
    @State private var fileName: String = ""

    // MARK: - Inputs
    let showDescription: Bool
    let instrucciones: String
    @Binding var response: [String : String]
    let idCom: String
    let name: String
    let subname: String
    let isRequired: Bool

    private var isRequiredInvalid: Bool {
        isRequired && (response[idCom]?.isEmpty ?? true)
    }

    private var borderColor: Color {
        isRequiredInvalid ? .red : .grayLight
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            VStack(alignment: .leading, spacing: 8) {

                HStack(spacing: 4) {
                    Text(name)
                        .font(.appCallout.bold())
                        .foregroundColor(.primaryText)
                    
                    if isRequired && (response[idCom]?.isEmpty ?? true) {
                        Text("*")
                            .foregroundColor(.red)
                            .font(.appCallout.bold())
                    }
                }

                Button {
                    if fileData.isEmpty {
                        showOptionPicker.toggle()
                    }
                } label: {
                    dropzoneContent
                }
                .buttonStyle(.plain)

                if showDescription {
                    Text(instrucciones)
                        .font(.appCaption)
                        .foregroundColor(.secondaryText)
                }
            }
            .padding(.margin)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
                    .animation(.easeInOut(duration: 0.25), value: borderColor)
            )
            .cornerRadius(.cornerRadius)

            if isRequiredInvalid {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Este campo es obligatorio")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .transition(.opacity)
            }
        }

        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraPickerView(sourceType: .camera) { image in
                saveImage(image)
            }
        }
        .fullScreenCover(isPresented: $showGalleryPicker) {
            CameraPickerView(sourceType: .photoLibrary) { image in
                saveImage(image)
            }
        }
        .fullScreenCover(isPresented: $showDocumentPicker) {
            DocumentPickerView { url in
                saveDocument(url)
            }
        }
        // ✅ NUEVO: Alert de límite de tamaño (igual que Android)
        .alert("Archivo demasiado grande", isPresented: $showFileSizeAlert) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(fileSizeErrorMessage)
        }
        .actionSheet(isPresented: $showOptionPicker) {
            ActionSheet(
                title: Text("Selecciona una opción"),
                buttons: [
                    .default(Text("Abrir Cámara")) {
                        showCameraPicker = true
                    },
                    .default(Text("Abrir Fotos")) {
                        showGalleryPicker = true
                    },
                    .default(Text("Abrir Archivos")) {
                        showDocumentPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .onAppear {
            // Si viene precargado (URL S3 o base64), ponemos estado "cargado"
            if let existing = response[idCom], !existing.isEmpty {
                if let url = URL(string: existing), url.scheme != nil {
                    fileName = url.lastPathComponent.isEmpty ? "Archivo cargado" : url.lastPathComponent
                    fileData = "__loaded__" // marcador para mostrar estado cargado
                } else {
                    fileData = existing
                    fileName = "archivo"
                }
            }
        }
        .onChange(of: response[idCom]) { newValue in
            if let newValue, !newValue.isEmpty {
                if let url = URL(string: newValue), url.scheme != nil {
                    fileName = url.lastPathComponent.isEmpty ? "Archivo cargado" : url.lastPathComponent
                    fileData = "__loaded__"
                } else {
                    fileData = newValue
                    fileName = "archivo"
                }
            } else {
                fileData = ""
                fileName = ""
            }
        }
    }

    private var dropzoneContent: some View {
        VStack(spacing: 10) {

            if fileData.isEmpty {

                Image(systemName: "paperclip")
                    .font(.system(size: 28))
                    .foregroundColor(isRequiredInvalid ? .red : .secondaryText)

                Text(subname)
                    .font(.appCaptionLarge)
                    .foregroundColor(isRequiredInvalid ? .red : .secondaryText)

            } else {

                Image(systemName: "doc.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.primaryText)

                Text(fileName.isEmpty ? "Archivo cargado" : fileName)
                    .font(.appCaptionLarge)
                    .foregroundColor(.primaryText)
                    .lineLimit(1)

                Button("Eliminar") {
                    withAnimation {
                        fileData = ""
                        fileName = ""
                        response[idCom] = ""
                    }
                }
                .font(.appCaption)
                .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }

    private func saveImage(_ image: UIImage) {
        // ✅ VALIDAR TAMAÑO ANTES DE CONVERTIR A BASE64
        guard let data = image.jpegData(compressionQuality: 0.6) else {
            print("❌ [FileRow] Error al comprimir imagen")
            return
        }
        
        let fileSizeBytes = data.count
        let fileSizeMB = Double(fileSizeBytes) / (1024.0 * 1024.0)
        
        print("📊 [FileRow] Validando tamaño de imagen:")
        print("   • Tamaño: \(fileSizeBytes) bytes (\(String(format: "%.2f", fileSizeMB)) MB)")
        print("   • Límite: \(maxFileSizeBytes) bytes (\(MAX_FILE_SIZE_MB) MB)")
        
        if fileSizeBytes > maxFileSizeBytes {
            // ⚠️ ARCHIVO DEMASIADO GRANDE - Mostrar alert (igual que Android)
            print("❌ [FileRow] Archivo excede el límite de \(MAX_FILE_SIZE_MB) MB")
            fileSizeErrorMessage = "El archivo es demasiado grande. El tamaño máximo permitido es \(MAX_FILE_SIZE_MB) MB."
            showFileSizeAlert = true
            return // ← NO SUBE NADA (igual que Android)
        }
        
        // ✅ Tamaño válido - convertir a base64 y guardar con metadatos
        print("✅ [FileRow] Tamaño válido. Convirtiendo a base64...")
        let base64String = data.base64EncodedString()
        
        // ✅ FORMATO CONSISTENTE: "base64|||extension:ext|||filename:name"
        fileName = "imagen.jpg"
        fileData = "\(base64String)|||extension:jpg|||filename:\(fileName)"
        response[idCom] = fileData
        
        print("✅ [FileRow] Imagen guardada:")
        print("   • Nombre: \(fileName)")
        print("   • Extensión: jpg")
        print("   • Base64: \(base64String.count) caracteres")
    }

    private func saveDocument(_ url: URL) {
        do {
            // ✅ VALIDAR TAMAÑO ANTES DE LEER EL ARCHIVO COMPLETO
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSizeBytes = fileAttributes[.size] as? Int ?? 0
            let fileSizeMB = Double(fileSizeBytes) / (1024.0 * 1024.0)
            
            print("📊 [FileRow] Validando tamaño de documento:")
            print("   • Archivo: \(url.lastPathComponent)")
            print("   • Tamaño: \(fileSizeBytes) bytes (\(String(format: "%.2f", fileSizeMB)) MB)")
            print("   • Límite: \(maxFileSizeBytes) bytes (\(MAX_FILE_SIZE_MB) MB)")
            
            if fileSizeBytes > maxFileSizeBytes {
                // ⚠️ ARCHIVO DEMASIADO GRANDE - Mostrar alert (igual que Android)
                print("❌ [FileRow] Archivo excede el límite de \(MAX_FILE_SIZE_MB) MB")
                fileSizeErrorMessage = "El archivo es demasiado grande. El tamaño máximo permitido es \(MAX_FILE_SIZE_MB) MB."
                showFileSizeAlert = true
                return // ← NO SUBE NADA (igual que Android)
            }
            
            // ✅ Tamaño válido - leer y convertir a base64
            print("✅ [FileRow] Tamaño válido. Leyendo archivo...")
            let data = try Data(contentsOf: url)
            let lastPathComponent = url.lastPathComponent
            
            // ✅ GUARDAR: "base64|||extensión|||nombre" para posterior procesamiento
            // Esto permite que ElementDetailsView extraiga la extensión correcta al subir a S3
            let fileExtension = url.pathExtension.isEmpty ? "bin" : url.pathExtension.lowercased()
            let base64String = data.base64EncodedString()
            
            // Formato: base64|||extensión|||nombre
            fileData = "\(base64String)|||extension:\(fileExtension)|||filename:\(lastPathComponent)"
            fileName = lastPathComponent
            response[idCom] = fileData
            
            print("✅ [FileRow] Documento guardado:")
            print("   • Nombre: \(fileName)")
            print("   • Extensión: \(fileExtension)")
            print("   • Base64: \(base64String.count) caracteres")
        } catch {
            print("❌ [FileRow] Error leyendo archivo:", error)
        }
    }
}
