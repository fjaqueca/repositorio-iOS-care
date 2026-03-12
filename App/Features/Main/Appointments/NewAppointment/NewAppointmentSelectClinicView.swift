//
//  NewAppointmentSelectClinicView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 26/10/2022.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage

struct NewAppointmentSelectClinicView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.dismiss) var dismiss
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @ObservedResults(ClinicInit.self) var clinicObjects // <-- obtenemos las clínicas desde Realm
    @State var clinicInfo: ClinicDetail = ClinicDetail()
    @State var showNewAppointmentSelected: Bool = false
    @Binding var selectedTab: Tab
    let agreementName: String = AppStatusManager.selectedEnterprise?.campaAC ?? ""
    var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Divider()

        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                // Recorremos directamente las clínicas persistidas en Realm
                ForEach(clinicObjects) { clinic in
                    // clinicButtonView devuelve AnyView? (nil si debe ocultarse por WTW)
                    if let view = clinicButtonView(clinic) {
                        view
                    }
                }
            }
            .padding(.top, .margin)
            .padding(.horizontal, .margin)
        }
        .navigationLink(isActive: $showNewAppointmentSelected) {
            NewAppointmentSelectDetailsView(UIStateAppoint: $UIStateAppoint, id: clinicInfo.id, clinic: clinicInfo, selectedTab: $selectedTab)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(UIStateAppoint.selectClinicUIState.title.text)
                        .font(Font.custom(UIStateAppoint.selectClinicUIState.title.font, size: CGFloat(Int(UIStateAppoint.selectClinicUIState.title.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.selectClinicUIState.title.color))
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.dismiss()
                } label: {
                    Image("back")
                        .renderingMode(.template)
                        .font(Font.custom(UIStateAppoint.selectClinicUIState.title.font, size: CGFloat(Int(UIStateAppoint.selectClinicUIState.title.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.selectClinicUIState.title.color))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Construye el botón a partir del objeto ClinicInit (mismos estilos y lógica WTW)
    func clinicButtonView(_ clinic: ClinicInit) -> AnyView? {
        // atributo original (ej: "Nombre;0VS...") — usamos esto por si necesitás más datos en el futuro
        let atributoRaw = clinic.attribute.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        // infoArray para replicar la lógica antigua
        let infoArray = atributoRaw.components(separatedBy: ";")
        // si el atributo está mal formado, intentamos fallback con name/id ya persistidos
        guard infoArray.count >= 2 || (!clinic.name.isEmpty && !clinic.id.isEmpty) else {
            return nil
        }

        // Obtenemos typeId (id) y name (primera parte)
        let typeId = (infoArray.count >= 2 ? infoArray.last!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : clinic.id)
        let displayName = (infoArray.count >= 1 ? infoArray.first!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : clinic.name)

        // 🔍 Lógica de ocultamiento WTW (idéntica a la anterior)
        if isWTW() {
            let isBeneficioYappActive = UserDefaults.standard.bool(forKey: "beneficYapp")

            if (typeId == "0VSRN00000003sL4AQ" && !isBeneficioYappActive) ||
                (typeId == "0VS8c000000obNZGAY" && isBeneficioYappActive) {
                // omitimos este botón
                print("🔸 Se omitió el botón con ID: \(typeId)")
                return nil
            }
        }
        if isComprehensiveSupport() {
            let isComprehensiveSupportActive = UserDefaults.standard.bool(forKey: "comprehensiveSupport")

            if !isComprehensiveSupportActive && typeId != "0VSRN00000000sr4AA" {
                print("🔸 Se omitió el botón con ID: \(typeId)")
                return nil // 👉 salta al próximo índice
            }
        }

        // iconURL puede tener varios URLs separados por ';' -> tomamos el primero válido
        let firstIconURLString = firstURLString(from: clinic.iconURL)
        guard let iconURLStr = firstIconURLString, let iconURL = URL(string: iconURLStr) else {
            // si no hay URL válida, se omite como antes
            print("⚠️ clinic sin icon válido: \(clinic.id) - \(clinic.name)")
            return nil
        }

        return AnyView(
            Button {
                // Seteamos clinicInfo tal como antes para pasar a la pantalla de detalles
                self.clinicInfo.name = displayName
                self.clinicInfo.id = typeId
                // ponemos la primera URL para `clinicInfo.icon`
                self.clinicInfo.icon = firstIconURLString ?? clinic.iconURL
                self.showNewAppointmentSelected.toggle()
            } label: {
                VStack {
                    Circle()
                        .frame(width: 80.0, height: 80.0)
                        .foregroundColor(Color(hex: UIStateAppoint.selectClinicUIState.colorImageBack))
                        .shadow(color: .shadowLight, radius: 4, x: 1, y: 1)
                        .overlay {
                            if let iconURLStr = firstIconURLString, let url = URL(string: iconURLStr) {
                                CachedAsyncImage(
                                    url: url,
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    },
                                    placeholder: {
                                        Color.clear
                                    }
                                )
                            } else {
                                Color.clear
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .padding(.horizontal, .margin / 2)
                        .padding(.vertical, .margin / 2)

                    Text(displayName)
                        .font(Font.custom(UIStateAppoint.selectClinicUIState.itemClinic.font, size: CGFloat(Int(UIStateAppoint.selectClinicUIState.itemClinic.size) ?? 18)))
                        .foregroundColor(Color(hex: UIStateAppoint.selectClinicUIState.itemClinic.color))
                        .minimumScaleFactor(0.5)
                }
            }
        )
    }

    // MARK: - Helpers
    private func firstURLString(from raw: String) -> String? {
        // raw puede contener uno o más enlaces separados por ';'
        let parts = raw.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.first
    }

    private func isWTW() -> Bool {
        return self.agreementName.contains("Willis Tower Watson")
    }
    private func isComprehensiveSupport() -> Bool {
        return self.agreementName.contains("Acompañamiento Integral")
    }
}
