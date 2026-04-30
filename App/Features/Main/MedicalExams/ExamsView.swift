//
//  Exams.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import SDWebImageSwiftUI

struct ExamsView: View {
    @ObservedResults(BrandAccounts.self) var items
    @Environment(\.dismiss) var dismiss
    @State var UIState: ExamUIState = ExamUIState()
    @State var automatedExamsState = AutomatedExamsUIState()
    @State private var currentBannerIndex = 0

    // Navigation states
    @State private var showMedicalExams = false
    @State private var showPatientExams = false
    @State private var showAutomatedExams = false

    var body: some View {
        NavigationViewCustom {
            VStack(spacing: 0) {
                Divider()
                hubContent
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    let headerTitulo = automatedExamsState.header.titulo
                    let attr = automatedExamsState.header.tituloAttr
                    Text(headerTitulo.isEmpty ? "Exámenes Médicos" : headerTitulo)
                        .font(Font.custom(
                            attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                            size: CGFloat(Int(attr.size) ?? 18)
                        ))
                        .foregroundColor(Color(hex: attr.color.isEmpty ? "#000000" : attr.color))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.template)
                            .foregroundColor(Color(hex: automatedExamsState.backArrowColorSeccion))
                    }
                }
            }
            .task {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📱 [ExamsView] VISTA CARGADA - Exámenes Médicos (Hub)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔹 BrandAccounts items.count: \(items.count)")
                if let first = items.first {
                    print("🔹 Records en primer BrandAccounts: \(first.records.count)")
                } else {
                    print("⚠️ items.first es nil - no hay BrandAccounts cargados")
                }
                print("")
                print("🔄 [ExamsView] Cargando UIState (ExamUIState desde 'SecMas')...")
                loadUIState()
                print("✅ [ExamsView] UIState cargado")
                print("")
                print("🔄 [ExamsView] Cargando AutomatedExamsConfig...")
                automatedExamsState = loadAutomatedExamsConfig()
                print("✅ [ExamsView] AutomatedExamsConfig cargado")
                print("")

                // Cargar datos del perfil del paciente y guardar en cache (UserDefaults)
                await loadProfileFields()
            }
            .configureNavigation()
        }
    }

    // MARK: - Hub Content
    private var hubContent: some View {
        let screenWidth = UIScreen.main.bounds.width

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 16)

                // Banner carousel (padding 15pt por lado, paridad Android)
                bannerCarousel
                    .frame(width: screenWidth)

                Spacer().frame(height: 8)

                // Descripcion / Instruccion (margin 20pt por lado, paridad Android)
                descriptionText
                    .frame(width: screenWidth)

                Spacer().frame(height: 20)

                // Option cards
                optionCards
                    .frame(width: screenWidth)

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showMedicalExams) {
            NavigationViewCustom {
                VStack(spacing: 0) {
                    Divider()
                    MedicalExamsView(UIState: $UIState, backArrowColor: automatedExamsState.backArrowColorSeccion, navTitle: automatedExamsState.secciones.first(where: { $0.numero == 1 })?.nombre ?? "", navTitleAttr: automatedExamsState.secciones.first(where: { $0.numero == 1 })?.tituloAttr ?? TextExamAttributes(), dialogEliminarConfig: automatedExamsState.dialogEliminarExamen, dialogExamenesEnviadosConfig: automatedExamsState.dialogExamenesEnviados, dialogEliminarDocOrdenConfig: automatedExamsState.dialogEliminarDocOrden, seleccionarTodosTexto: automatedExamsState.seleccionarTodosTexto, seleccionarTodosAttr: automatedExamsState.seleccionarTodosAttr, badgeOrdenMedica: automatedExamsState.badgeOrdenMedica, badgeExamenAutomatizado: automatedExamsState.badgeExamenAutomatizado, badgeRecetaMedica: automatedExamsState.badgeRecetaMedica, badgeDetallePrescripciones: automatedExamsState.badgeDetallePrescripciones, badgeDetalleRecetaMedica: automatedExamsState.badgeDetalleRecetaMedica, badgeDetalleExamenMedico: automatedExamsState.badgeDetalleExamenMedico, botonVerDocumentoEnviado: automatedExamsState.botonVerDocumentoEnviado, botonSubirExamen: automatedExamsState.botonSubirExamen, badgeCargadoPorPaciente: automatedExamsState.badgeCargadoPorPaciente, botonesDetalleExamen: automatedExamsState.botonesDetalleExamen)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        let sec = automatedExamsState.secciones.first(where: { $0.numero == 1 })
                        let attr = sec?.tituloAttr ?? TextExamAttributes()
                        Text(sec?.nombre ?? "Prescripciones Médicas")
                            .font(Font.custom(
                                attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                                size: CGFloat(Int(attr.size) ?? 20)
                            ))
                            .foregroundColor(Color(hex: attr.color.isEmpty ? "#00BBDC" : attr.color))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showMedicalExams = false
                        } label: {
                            Image("back")
                                .renderingMode(.template)
                                .foregroundColor(Color(hex: automatedExamsState.backArrowColorSeccion))
                        }
                    }
                }
                .configureNavigation()
            }
        }
        .fullScreenCover(isPresented: $showPatientExams) {
            NavigationViewCustom {
                VStack(spacing: 0) {
                    Divider()
                    PatientExamsView(UIState: $UIState, backArrowColor: automatedExamsState.backArrowColorSeccion, navTitle: automatedExamsState.secciones.first(where: { $0.numero == 2 })?.nombre ?? "", navTitleAttr: automatedExamsState.secciones.first(where: { $0.numero == 2 })?.tituloAttr ?? TextExamAttributes(), botonSubirExamenConfig: automatedExamsState.botonSubirExamen, badgesMisExamenes: automatedExamsState.badgesMisExamenes, botonesDetalleExamen: automatedExamsState.botonesDetalleExamen, badgeCargadoPorPaciente: automatedExamsState.badgeCargadoPorPaciente, dialogEliminarConfig: automatedExamsState.dialogEliminarExamen, dialogExamenesEnviadosConfig: automatedExamsState.dialogExamenesEnviados, dialogEliminarDocOrdenConfig: automatedExamsState.dialogEliminarDocOrden, dialogEliminarMiArchivoConfig: automatedExamsState.dialogEliminarMiArchivo)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        let sec = automatedExamsState.secciones.first(where: { $0.numero == 2 })
                        let attr = sec?.tituloAttr ?? TextExamAttributes()
                        Text(sec?.nombre ?? "Mis archivos de Salud")
                            .font(Font.custom(
                                attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                                size: CGFloat(Int(attr.size) ?? 20)
                            ))
                            .foregroundColor(Color(hex: attr.color.isEmpty ? "#00BBDC" : attr.color))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showPatientExams = false
                        } label: {
                            Image("back")
                                .renderingMode(.template)
                                .foregroundColor(Color(hex: automatedExamsState.backArrowColorSeccion))
                        }
                    }
                }
                .configureNavigation()
            }
        }
        .fullScreenCover(isPresented: $showAutomatedExams) {
            AutomatedExamsView(config: $automatedExamsState)
        }
    }

    // MARK: - Description Text
    private var descriptionText: some View {
        let descAttr = automatedExamsState.header.descripcionAttr
        let descAlign = descAttr.alignment.lowercased()
        let alignment: TextAlignment = descAlign == "center" ? .center : (descAlign == "right" ? .trailing : .leading)
        let frameAlignment: Alignment = descAlign == "center" ? .center : (descAlign == "right" ? .trailing : .leading)

        return Text(automatedExamsState.header.descripcion.isEmpty
            ? "Por favor seleccione una opcion para poder continuar:"
            : automatedExamsState.header.descripcion)
            .font(Font.custom(
                descAttr.font,
                size: CGFloat(Int(descAttr.size) ?? 14)
            ))
            .foregroundColor(Color(hex: descAttr.color))
            .multilineTextAlignment(alignment)
            .lineLimit(nil)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .padding(.horizontal, 20)
    }

    // MARK: - Banner Carousel
    private var bannerCarousel: some View {
        VStack(spacing: 8) {
            if automatedExamsState.bannersHub.isEmpty {
                // Placeholder cuando no hay banners del BrandAccount
                TabView {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: .cornerRadius)
                            .fill(Color.gray.opacity(0.15))
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray.opacity(0.4))
                                    Text("Banner \(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.4))
                                }
                            )
                            .padding(.horizontal, 15)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: UIScreen.main.bounds.width, height: 120)
            } else {
                TabView(selection: $currentBannerIndex) {
                    ForEach(Array(automatedExamsState.bannersHub.enumerated()), id: \.element.id) { index, banner in
                        WebImage(url: URL(string: banner.imageURL)) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(.cornerRadius)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: .cornerRadius)
                                .fill(Color.gray.opacity(0.15))
                                .overlay(ProgressView())
                        }
                        .padding(.horizontal, 15)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: UIScreen.main.bounds.width, height: 120)

                // Page indicators
                if automatedExamsState.bannersHub.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<automatedExamsState.bannersHub.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentBannerIndex
                                    ? Color(hex: automatedExamsState.header.colorCirculoBannerSeleccionado)
                                    : Color.gray.opacity(0.3))
                                .frame(width: 7, height: 7)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Option Cards (grilla dinámica según secciones visibles)
    private var optionCards: some View {
        Group {
            if automatedExamsState.secciones.isEmpty {
                // Fallback: 3 opciones por defecto
                HStack(alignment: .top, spacing: 12) {
                    examOptionCard(
                        title: UIState.examWindows.titleOrderExam.text.isEmpty ? "Ordenes de Examenes" : UIState.examWindows.titleOrderExam.text,
                        iconURL: nil,
                        systemIcon: "doc.text.magnifyingglass"
                    ) { showMedicalExams = true }

                    examOptionCard(
                        title: UIState.examWindows.titlePatientExam.text.isEmpty ? "Mis Examenes" : UIState.examWindows.titlePatientExam.text,
                        iconURL: nil,
                        systemIcon: "folder.fill"
                    ) { showPatientExams = true }

                    examOptionCard(
                        title: "Examenes\nAutomatizados",
                        iconURL: nil,
                        systemIcon: "gearshape.2.fill"
                    ) { showAutomatedExams = true }
                }
                .padding(.horizontal, .margin)
            } else {
                // Secciones dinámicas del BrandAccount — layout adaptativo según cantidad
                let visibleSecciones = automatedExamsState.secciones.filter { $0.visible }

                if visibleSecciones.count <= 2 {
                    // 1 o 2 opciones: HStack centrado para mantener íconos cerca del centro
                    HStack(alignment: .top, spacing: 24) {
                        ForEach(visibleSecciones) { seccion in
                            examOptionCard(
                                title: seccion.nombre,
                                iconURL: seccion.iconURL.isEmpty ? nil : seccion.iconURL,
                                systemIcon: iconForSeccion(seccion.numero),
                                expandWidth: false
                            ) {
                                handleSeccionTap(seccion.numero)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, .margin)
                } else {
                    // 3+ opciones: grilla de 3 columnas
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

                    LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                        ForEach(visibleSecciones) { seccion in
                            examOptionCard(
                                title: seccion.nombre,
                                iconURL: seccion.iconURL.isEmpty ? nil : seccion.iconURL,
                                systemIcon: iconForSeccion(seccion.numero)
                            ) {
                                handleSeccionTap(seccion.numero)
                            }
                        }
                    }
                    .padding(.horizontal, .margin)
                }
            }
        }
    }

    // MARK: - Single Option Card
    private func examOptionCard(title: String, iconURL: String?, systemIcon: String, expandWidth: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if let iconURL = iconURL, let url = URL(string: iconURL) {
                WebImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 85, height: 105)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 85, height: 105)
                        .overlay(ProgressView().scaleEffect(0.7))
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 85, height: 105)
                    .overlay(
                        Image(systemName: systemIcon)
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }
        }
        .frame(maxWidth: expandWidth ? .infinity : nil)
    }

    private func iconForSeccion(_ numero: Int) -> String {
        switch numero {
        case 1: return "doc.text.magnifyingglass"
        case 2: return "folder.fill"
        case 3: return "gearshape.2.fill"
        default: return "square.grid.2x2"
        }
    }

    private func handleSeccionTap(_ numero: Int) {
        print("👆 [ExamsView] Seccion tapped: numero=\(numero)")
        switch numero {
        case 1:
            print("   → Navegando a: Órdenes de Exámenes (MedicalExamsView)")
            showMedicalExams = true
        case 2:
            print("   → Navegando a: Mis Exámenes (PatientExamsView)")
            showPatientExams = true
        case 3:
            print("   → Navegando a: Exámenes Automatizados (AutomatedExamsView)")
            print("   → Config disponible: \(automatedExamsState.categorias.count) categorias")
            showAutomatedExams = true
        default:
            print("   ⚠️ Seccion numero \(numero) no tiene acción asignada")
            break
        }
    }

    // MARK: - Profile Fields Cache

    private func loadProfileFields() async {
        let rut = AppStatusManager.rut ?? ""
        guard !rut.isEmpty else {
            print("⚠️ [ProfileFields] No se puede cargar perfil: RUT vacio (AppStatusManager.rut es nil)")
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔄 [ProfileFields] INICIO - Cargando getProfileFields")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   RUT enviado: \"\(rut)\"")

        // Log cache actual antes de la llamada
        print("   Cache ANTES de la llamada:")
        print("     firstName: \"\(ProfileCache.firstName)\"")
        print("     lastName: \"\(ProfileCache.lastName)\"")
        print("     birthdate: \"\(ProfileCache.birthdate)\"")
        print("     email: \"\(ProfileCache.email)\"")
        print("     address: \"\(ProfileCache.address)\"")
        print("     gender: \"\(ProfileCache.gender)\"")
        print("     rut: \"\(ProfileCache.rut)\"")

        let result = await Network.shared.getProfileFields(rut: rut)

        switch result {
        case .success(let response):
            print("✅ [ProfileFields] Response OK - statusCode: \(response.statusCode ?? -1)")
            print("   data.count: \(response.data.count)")

            if let accountFilter = response.data.first {
                print("   Account array count: \(accountFilter.Account.count)")
                if let account = accountFilter.Account.first ?? nil {
                    print("   Account ID: \"\(account.Id ?? "nil")\"")
                    print("   FirstName: \"\(account.FirstName ?? "nil")\"")
                    print("   LastName: \"\(account.LastName ?? "nil")\"")
                    print("   PersonBirthdate: \"\(account.PersonBirthdate ?? "nil")\"")
                    print("   PersonEmail: \"\(account.PersonEmail ?? "nil")\"")
                    print("   BillingStreet: \"\(account.BillingStreet ?? "nil")\"")
                    print("   Gender: \"\(account.HealthCloudGA__Gender__pc ?? "nil")\"")
                    print("   IdentificationId: \"\(account.IdentificationId__pc ?? "nil")\"")
                    print("   EmpresaActual: \"\(account.empresaactualC ?? "nil")\"")
                    print("   Oncologico: \(account.Oncologico_Activo__c ?? false)")

                    ProfileCache.save(
                        firstName: account.FirstName ?? "",
                        lastName: account.LastName ?? "",
                        birthdate: account.PersonBirthdate ?? "",
                        email: account.PersonEmail ?? "",
                        address: account.BillingStreet ?? "",
                        gender: account.HealthCloudGA__Gender__pc ?? "",
                        rut: account.IdentificationId__pc ?? rut
                    )

                    // Verificar que se guardo correctamente
                    print("   Cache DESPUES de guardar:")
                    print("     firstName: \"\(ProfileCache.firstName)\"")
                    print("     lastName: \"\(ProfileCache.lastName)\"")
                    print("     birthdate: \"\(ProfileCache.birthdate)\"")
                    print("     email: \"\(ProfileCache.email)\"")
                    print("     address: \"\(ProfileCache.address)\"")
                    print("     gender: \"\(ProfileCache.gender)\"")
                    print("     rut: \"\(ProfileCache.rut)\"")
                } else {
                    print("⚠️ [ProfileFields] Account array existe pero primer elemento es nil")
                }
            } else {
                print("⚠️ [ProfileFields] data.first es nil - response sin AccountFilter")
            }

        case .failure(let error):
            print("❌ [ProfileFields] Error en getProfileFields: \(error.message)")
            print("   Se mantiene cache anterior (si existia)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
    }
}
