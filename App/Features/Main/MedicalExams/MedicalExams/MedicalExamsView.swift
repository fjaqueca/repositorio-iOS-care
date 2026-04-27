//
//  MedicalExamsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/03/2023.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import ZIPFoundation

struct MedicalExamsView: View {
    @Binding var UIState: ExamUIState
    var backArrowColor: String = "#00BBDC"
    var navTitle: String = ""
    var navTitleAttr: TextExamAttributes = TextExamAttributes()
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogExamenesEnviadosConfig: DialogExamenesEnviadosConfig = DialogExamenesEnviadosConfig()
    var dialogEliminarDocOrdenConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var seleccionarTodosTexto: String = "Seleccionar Todos"
    var seleccionarTodosAttr: TextExamAttributes = TextExamAttributes()
    var badgeOrdenMedica: BadgeConfig = BadgeConfig(texto: "Orden médica", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#00BBDC")
    var badgeExamenAutomatizado: BadgeConfig = BadgeConfig(texto: "Examen automatizado", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#7B61FF")
    var badgeRecetaMedica: BadgeConfig = BadgeConfig(texto: "Receta médica", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#00B894")
    var badgeDetallePrescripciones: BadgeDetalleConfig = BadgeDetalleConfig()
    var badgeDetalleRecetaMedica: BadgeDetalleConfig = BadgeDetalleConfig()
    var badgeDetalleExamenMedico: BadgeDetalleConfig = BadgeDetalleConfig()
    var botonVerDocumentoEnviado: ButtonExamConfig = ButtonExamConfig()
    var botonSubirExamen: ButtonExamConfig = ButtonExamConfig()
    var badgeCargadoPorPaciente: BadgeDetalleConfig = BadgeDetalleConfig(texto: "Cargado por el Paciente", colorTexto: "#FFFFFF", colorFondo: "#7B61FF", font: "FiraSans-Medium", size: "11", icono: "person.fill")
    var accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
    @State var from: String = ""
    @State var until: String = ""
    @State var dateFrom: Date? = nil
    @State var dateUntil: Date? = nil
    @State var filterExams: String = ""
    @State var total: Double = 1
    @State var count: Double = 0
    @State var progress: Double = 0.0
    @State var isCurrent: Bool = true
    @State private var isLoading: Bool = true
    @State var isLoadingAction: Bool = false
    @State var exams: MedicalExams? = nil
    /// Source of truth para decidir el botón "Subir/Ver documento enviado" (paridad
    /// con web). Se carga una vez vía getExamsForPatient(). El cruce por FK
    /// (idOrdenMedicaC / idExamenesAutomatizadosC) ocurre client-side al pasar
    /// linkedPatientExam a cada Row.
    @State var allPatientExams: [FunctionFilterExamResponse.PatientExams] = []
    /// Guard contra ejecución concurrente de getRecetas. Sin esto, al volver del
    /// detalle tras un upload, dos triggers (Color.clear.onAppear + onChange de
    /// listNeedsRefresh) disparan dos cadenas de servicios en paralelo, causando
    /// que la lista parpadee con counts intermedios. Solo permitimos UNA cadena
    /// de refresh activa a la vez.
    @State private var isFetchingRecetas: Bool = false
    @State private var showDismissButton: Bool = true
    @State var showFilterView: Bool = false
    @State var selectedFilterDocType: String = ""
    @State var showAlert: Bool = false
    @State private var isButtonDownloadEnable: Bool = false
    @State private var isButtonShareEnable: Bool = false
    @State private var isButtonSelectAllFilled: Bool = false
    @State var examSelectedList: [String: Bool] = [:]
    @State var actionButton: ActionAuthPresAndExam?
    @State var showSheetView: Bool = false
    @State var isLoadingFav: Bool = false
    @State private var urlsToZip: [URL] = []
    @State var urlShare: URL?
    @State private var showWebView = false
    @State private var downloadedFileURL: URL?
    /// Flag que el detalle setea cuando hay un upload exitoso. Al volver a la lista,
    /// disparamos un getRecetas() para refrescar las URLs ya persistidas en backend
    /// y que el botón "Subir" vs "Ver" del detalle refleje el estado real.
    @State private var listNeedsRefresh: Bool = false

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    private var selectedCount: Int {
        examSelectedList.values.filter { $0 }.count
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding(.horizontal, .margin)
                    .padding(.top, 21)

                // Select all row (always visible)
                selectAllRow
                    .padding(.horizontal, .margin)
                    .padding(.top, 23)

                // Action buttons + counter (only visible when there's a selection)
                if selectedCount > 0 {
                    actionButtonsRow
                        .padding(.horizontal, .margin)
                        .padding(.top, 19)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Hidden onAppear trigger
                Color.clear
                    .frame(height: 0)
                    .onAppear {
                        dateToString()
                        getRecetas()
                    }
                    // Refresh propagado desde MedicalExamsDetailsView tras un upload exitoso.
                    // NO reseteamos listNeedsRefresh aquí: el flag queda en true durante
                    // toda la cadena de servicios y se resetea al final en getExamsForPatient
                    // (junto con isLoading=false). Esto evita el flash de la lista cacheada.
                    .onChange(of: listNeedsRefresh) { needs in
                        guard needs else { return }
                        print("🔄 [OrdenesExamen] Refresh solicitado desde detalle (post-upload)")
                        getRecetas()
                    }

                // Exam list
                ScrollView {
                    // listNeedsRefresh también dispara el loading: cuando el detalle lo
                    // setea a true, el body se re-evalúa y muestra el spinner SIN flash
                    // de la lista cacheada. Permanece true hasta que getRecetas termina.
                    if isLoading || listNeedsRefresh {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.1)
                            Text("Cargando exámenes...")
                                .font(Font.custom("FiraSans-Regular", size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    } else {
                        if let searchExams = searchExams, !searchExams.isEmpty {
                            LazyVStack(spacing: 10) {
                                ForEach(searchExams, id: \.self) { exam in
                                    MedicalExamsRowView(
                                        isSelected: $examSelectedList,
                                        exam: exam,
                                        isLoadingFavorite: $isLoadingFav,
                                        isLoadingExam: $isLoading,
                                        UIState: $UIState,
                                        backArrowColor: backArrowColor,
                                        navTitle: navTitle,
                                        navTitleAttr: navTitleAttr,
                                        dialogEliminarConfig: dialogEliminarConfig,
                                        dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig,
                                        dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig,
                                        badgeOrdenMedica: badgeOrdenMedica,
                                        badgeExamenAutomatizado: badgeExamenAutomatizado,
                                        badgeRecetaMedica: badgeRecetaMedica,
                                        badgeDetallePrescripciones: badgeDetallePrescripciones,
                                        badgeDetalleRecetaMedica: badgeDetalleRecetaMedica,
                                        badgeDetalleExamenMedico: badgeDetalleExamenMedico,
                                        botonVerDocumentoEnviado: botonVerDocumentoEnviado,
                                        botonSubirExamenConfig: botonSubirExamen,
                                        badgeCargadoPorPaciente: badgeCargadoPorPaciente,
                                        listNeedsRefresh: $listNeedsRefresh,
                                        linkedPatientExam: linkedPatientExam(for: exam)
                                    )
                                }
                            }
                            .padding(.horizontal, .margin)
                            .padding(.top, 23)
                            .padding(.bottom, .margin)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.35))
                                Text("No se encontraron exámenes")
                                    .font(Font.custom("FiraSans-Regular", size: 16))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                        }
                    }
                }
            }

            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.examList.textToShare).\n", self.urlShare as Any])
            })
            .sheet(isPresented: $showWebView) {
                if let fileURL = downloadedFileURL {
                    WebView(url: fileURL)
                }
            }
            .onChange(of: count) { newCount in
                print("📊 [ExamList] onChange count: \(newCount)/\(total), isLoadingAction: \(isLoadingAction), actionButton: \(String(describing: actionButton))")
                if newCount >= total && total > 0 && isLoadingAction {
                    print("✅ [ExamList] Descarga completa, esperando 0.8s para cerrar dialog...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        print("📊 [ExamList] Cerrando dialog. actionButton: \(String(describing: actionButton)), downloadedFileURL: \(String(describing: downloadedFileURL))")
                        isLoadingAction = false
                        if actionButton == .isShare {
                            print("📊 [ExamList] Accion: Share -> creando ZIP...")
                            if let zipURL = createZip(from: urlsToZip, zipFileName: "DocumentosCompartidos") {
                                urlShare = zipURL
                                showSheetView = true
                            }
                        } else if actionButton == .isDownload {
                            print("📊 [ExamList] Accion: Download -> abriendo WebView. fileURL: \(String(describing: downloadedFileURL))")
                            if downloadedFileURL != nil {
                                showWebView = true
                                print("✅ [ExamList] showWebView = true")
                            } else {
                                print("❌ [ExamList] downloadedFileURL es nil, no se puede abrir WebView")
                            }
                        } else {
                            print("⚠️ [ExamList] actionButton es nil o desconocido: \(String(describing: actionButton))")
                        }
                    }
                }
            }
            .blur(radius: showFilterView || isLoadingAction || isLoadingFav ? 3 : 0.000001)

            if showFilterView {
                PrescriptionFilter(
                    dateFrom: $dateFrom,
                    dateUntil: $dateUntil,
                    showFilterView: $showFilterView,
                    selectedDocumentType: $selectedFilterDocType,
                    onApplyWithDates: { from, until in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        self.from = formatter.string(from: from)
                        self.until = formatter.string(from: until)
                        self.isLoading = true
                        getRecetas()
                    },
                    onClear: {
                        self.dateFrom = nil
                        self.dateUntil = nil
                        dateToString()
                        self.isLoading = true
                        getRecetas()
                    },
                    UIState: UIState.examFilter
                )
                .transition(.opacity)
            }
            if isLoadingAction {
                withAnimation {
                    PrescriptionDownloadView(total: $total, count: $count)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                        .padding(.horizontal, 24)
                }
            }
            if isLoadingFav {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .background(
            Group {
                if UIState.examList.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: UIState.examList.imageBackground),
                        content: { image in
                            image
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .aspectRatio(contentMode: .fill)
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                    .eraseToAnyView()
                }
            }
        )
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .frame(width: 20, height: 20)

            TextField("Buscar exámenes médicos", text: $filterExams)
                .font(Font.custom("FiraSans-Regular", size: 15))

            if !filterExams.isEmpty {
                Button {
                    filterExams = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }

            Button {
                withAnimation { showFilterView.toggle() }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.grayLight.opacity(0.5))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }

    // MARK: - Select All Row

    private var hasActiveFilters: Bool {
        dateFrom != nil || dateUntil != nil || !selectedFilterDocType.isEmpty
    }

    private var selectAllRow: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    checkSelectedList()
                }
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isButtonSelectAllFilled ? accentColor : Color.gray.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 20, height: 20)
                        if isButtonSelectAllFilled {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(accentColor)
                                .frame(width: 20, height: 20)
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    Text(seleccionarTodosTexto)
                        .font(Font.custom(
                            seleccionarTodosAttr.font.isEmpty ? "FiraSans-Regular" : seleccionarTodosAttr.font,
                            size: CGFloat(Int(seleccionarTodosAttr.size) ?? 14)
                        ))
                        .foregroundColor(seleccionarTodosAttr.color.isEmpty ? .primary : Color(hex: seleccionarTodosAttr.color))
                }
            }
            .buttonStyle(.plain)
            .onChange(of: examSelectedList) { newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    let hasUnselected = newValue.contains { !$0.value }
                    isButtonSelectAllFilled = !hasUnselected && !newValue.isEmpty
                    let hasSelected = newValue.contains { $0.value }
                    isButtonShareEnable = hasSelected
                    isButtonDownloadEnable = hasSelected
                }
            }

            Spacer()

            // Badge "Limpiar filtros" — solo visible con filtros activos
            if hasActiveFilters {
                Button {
                    clearAllFilters()
                } label: {
                    Text("Limpiar filtros")
                        .font(Font.custom("FiraSans-Medium", size: 12))
                        .foregroundColor(Color(hex: "#00BBDC"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#00BBDC"), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
    }

    // MARK: - Action Buttons (visible only when selectedCount > 0)
    private var actionButtonsRow: some View {
        VStack(spacing: 8) {
            // Counter
            HStack {
                Spacer()
                Text("\(selectedCount) seleccionada\(selectedCount == 1 ? "" : "s")")
                    .font(Font.custom("FiraSans-Regular", size: 13))
                    .foregroundColor(.gray)
            }

            HStack(spacing: 10) {
                // Descargar
                Button {
                    self.isLoadingAction = true
                    actionButton = .isDownload
                    filterIsSelected()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 13, weight: .medium))
                        Text(UIState.examList.btnDownload.textBtn.isEmpty ? "Descargar" : UIState.examList.btnDownload.textBtn)
                            .font(Font.custom("FiraSans-Medium", size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accentColor)
                    )
                }

                // Compartir
            Button {
                self.isLoadingAction = true
                actionButton = .isShare
                filterIsSelected()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .medium))
                    Text(UIState.examList.btnShare.textBtn.isEmpty ? "Compartir" : UIState.examList.btnShare.textBtn)
                        .font(Font.custom("FiraSans-Medium", size: 14))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor)
                )
            }
            }
        }
    }

    // MARK: - Computed
    var searchExams: [MedicalExams.Exam]? {
        let records: [MedicalExams.Exam]?
        if filterExams.isEmpty {
            records = exams?.records
        } else {
            records = exams?.records.filter { $0.Name?.localizedCaseInsensitiveContains(filterExams) ?? false }
        }
        // Ordenamiento 3 criterios (igual que Android):
        // 1. Favoritos primero (desc)
        // 2. Fecha desdeC descendente (mas reciente primero)
        // 3. Numero extraido del Name con regex _(\d+)\.pdf$ descendente (desempate)
        return records?.sorted { a, b in
            let favA = a.favoritoAppC ?? false
            let favB = b.favoritoAppC ?? false
            if favA != favB { return favA }
            let dateA = a.desdeC ?? ""
            let dateB = b.desdeC ?? ""
            if dateA != dateB { return dateA > dateB }
            return extractOrderNumber(from: a.Name) > extractOrderNumber(from: b.Name)
        }
    }

    /// Extrae el numero de orden del Name con regex _(\d+)\.pdf$ para desempate en ordenamiento
    private func extractOrderNumber(from name: String?) -> Int {
        guard let name = name else { return 0 }
        let pattern = "_(\\d+)\\.pdf$"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)),
              let range = Range(match.range(at: 1), in: name) else { return 0 }
        return Int(name[range]) ?? 0
    }

    // MARK: - Functions

    /// Limpia todos los filtros y recarga la lista completa sin filtros
    func clearAllFilters() {
        print("🧹 [OrdenesExamen] LIMPIAR TODOS LOS FILTROS → recarga sin filtros")
        dateFrom = nil
        dateUntil = nil
        selectedFilterDocType = ""
        dateToString()
        self.isLoading = true
        getRecetas()
    }

    func dateToString() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let defaultFrom = Calendar.current.date(byAdding: .day, value: -180, to: Date()) ?? Date()
        self.from = formatter.string(from: dateFrom ?? defaultFrom)
        self.until = formatter.string(from: dateUntil ?? Date())
    }
    func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return date
        } else {
            return Date().adding(days: +1)
        }
    }
    func getRecetas() {
        // Guard: si ya hay una cadena en curso, ignoramos llamadas duplicadas
        // (Color.clear.onAppear + onChange listNeedsRefresh suelen dispararse
        // ambos al volver del detalle).
        guard !isFetchingRecetas else {
            print("⏸️ [OrdenesExamen] getRecetas() ignorado — ya hay una cadena en curso")
            return
        }
        isFetchingRecetas = true
        self.isLoading = true
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [OrdenesExamen] INICIO - getRecetas() [PARALELO]")
        print("   accountId: \(accountId)")
        print("   from: \(from) until: \(until)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let startTime = Date()

        Task {
            // Lanzar los 4 servicios EN PARALELO (antes eran secuenciales)
            async let examsResult = Network.shared.getExams(accountId: accountId, from: from, until: until)
            async let autoResult = Network.shared.getAutomatedExamOrders(accountId: accountId)
            async let presResult = Network.shared.getRecetas(accountId: accountId, from: from, until: until)
            async let patientResult = Network.shared.getExamsForPatient(accountId: accountId)

            // Esperar todos los resultados (llegan en paralelo)
            let (examsRes, autoRes, presRes, patientRes) = await (examsResult, autoResult, presResult, patientResult)

            let elapsed = Date().timeIntervalSince(startTime)
            print("⏱️ [OrdenesExamen] 4 servicios completados en \(String(format: "%.2f", elapsed))s")

            await MainActor.run {
                // --- Servicio 1: Ordenes básicas ---
                var allRecords: [MedicalExams.Exam] = []
                var selectionList: [String: Bool] = [:]

                switch examsRes {
                case var .success(listExams):
                    for i in listExams.records.indices {
                        listExams.records[i].tipoDocumento = .ordenMedica
                    }
                    allRecords.append(contentsOf: listExams.records)
                    print("✅ [OrdenesExamen] Servicio 1 OK - ordenes basicas: \(listExams.records.count)")
                case let .failure(error):
                    print("❌ [OrdenesExamen] Servicio 1 ERROR: \(error.name) - \(error.message)")
                }

                let existingIds = Set(allRecords.compactMap { $0.Id })

                // --- Servicio 2: Ordenes automatizadas ---
                switch autoRes {
                case .success(let response):
                    let autoRecords = response.data?.first?.examenesAutomatizadosC ?? []
                    var addedCount = 0
                    for record in autoRecords {
                        if let id = record.Id, existingIds.contains(id) { continue }
                        let desdeC = self.convertISODateToYMD(record.CreatedDate)
                        let autoExam = MedicalExams.Exam(
                            attributes: nil, examenMedicoR: nil, profesionalResponsableR: nil, etapaR: nil,
                            Id: record.Id,
                            Name: record.nombreExamenC ?? record.Name,
                            desdeC: desdeC, hastaC: desdeC,
                            etapaC: nil, actividadC: nil, especialidadDelResponsableC: nil,
                            pacienteC: self.accountId, favoritoAppC: false,
                            urlDeLaOrdenMedicaC: record.urlOrdenMedicaRealC,
                            descripcionC: record.descripcionC ?? "",
                            url1C: nil, url2C: nil, url3C: nil, url4C: nil,
                            comment: nil, tipoDocumento: .examenAutomatizado
                        )
                        allRecords.append(autoExam)
                        addedCount += 1
                    }
                    print("✅ [OrdenesExamen] Servicio 2 OK - automatizados agregados: \(addedCount)")
                case .failure(let error):
                    print("⚠️ [OrdenesExamen] Servicio 2 ERROR: \(error.name) (continuamos)")
                }

                let existingIdsAfterAuto = Set(allRecords.compactMap { $0.Id })

                // --- Servicio 3: Recetas médicas ---
                switch presRes {
                case .success(let prescriptionsResponse):
                    var addedCount = 0
                    for pres in prescriptionsResponse.records {
                        if let id = pres.Id, existingIdsAfterAuto.contains(id) { continue }
                        let presExam = MedicalExams.Exam(
                            attributes: nil, examenMedicoR: nil,
                            profesionalResponsableR: MedicalExams.Exam.ExamProfessional(Name: pres.profesionalResponsableR?.Name),
                            etapaR: nil,
                            Id: pres.Id, Name: pres.Name,
                            desdeC: pres.desdeC, hastaC: pres.hastaC,
                            etapaC: nil, actividadC: nil,
                            especialidadDelResponsableC: pres.especialidadDelResponsableC,
                            pacienteC: pres.pacienteC, favoritoAppC: false,
                            urlDeLaOrdenMedicaC: pres.urlDeLaRecetaC,
                            descripcionC: "\(pres.dosisC ?? "") - \(pres.indicacionesC ?? "")",
                            url1C: nil, url2C: nil, url3C: nil, url4C: nil,
                            comment: nil, tipoDocumento: .recetaMedica
                        )
                        allRecords.append(presExam)
                        addedCount += 1
                    }
                    print("✅ [OrdenesExamen] Servicio 3 OK - recetas agregadas: \(addedCount)")
                case .failure(let error):
                    print("⚠️ [OrdenesExamen] Servicio 3 ERROR: \(error.name) (continuamos)")
                }

                // Construir selectionList
                for record in allRecords {
                    selectionList[record.Id ?? ""] = false
                }

                // --- Servicio 4: Patient Exams ---
                switch patientRes {
                case .success(let listExam):
                    let patients = listExam.data?.first?.examenesDelPacienteC ?? []
                    self.allPatientExams = patients
                    print("✅ [OrdenesExamen] Servicio 4 OK - patient exams: \(patients.count)")
                case .failure(let error):
                    print("⚠️ [OrdenesExamen] Servicio 4 ERROR: \(error.name) (continuamos)")
                }

                // Filtro local por fechas (los servicios 2 y 4 no filtran por fecha)
                var finalRecords = allRecords
                if !self.from.isEmpty && !self.until.isEmpty {
                    let beforeFilter = finalRecords.count
                    finalRecords = finalRecords.filter { exam in
                        guard let desdeC = exam.desdeC, !desdeC.isEmpty else { return true }
                        return desdeC >= self.from && desdeC <= self.until
                    }
                    let filtered = beforeFilter - finalRecords.count
                    if filtered > 0 {
                        print("📅 [OrdenesExamen] Filtro local por fechas: \(beforeFilter) → \(finalRecords.count) (\(filtered) excluidos fuera de \(self.from)...\(self.until))")
                    }
                }

                // Filtro local por tipo de documento
                if !self.selectedFilterDocType.isEmpty {
                    let beforeFilter = finalRecords.count
                    finalRecords = finalRecords.filter { exam in
                        switch self.selectedFilterDocType {
                        case "Orden médica":
                            return exam.tipoDocumento == .ordenMedica
                        case "Examen automatizado":
                            return exam.tipoDocumento == .examenAutomatizado
                        case "Receta médica":
                            return exam.tipoDocumento == .recetaMedica
                        default:
                            return true
                        }
                    }
                    print("📄 [OrdenesExamen] Filtro local por tipo \"\(self.selectedFilterDocType)\": \(beforeFilter) → \(finalRecords.count)")
                }

                // Reconstruir selectionList post-filtro
                selectionList = [:]
                for record in finalRecords {
                    selectionList[record.Id ?? ""] = false
                }

                // Asignar todo de una vez (una sola actualización de UI)
                self.exams = MedicalExams(totalSize: finalRecords.count, done: true, records: finalRecords)
                self.examSelectedList = selectionList
                self.isLoading = false
                self.listNeedsRefresh = false
                self.isFetchingRecetas = false

                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [OrdenesExamen] CARGA COMPLETA en \(String(format: "%.2f", elapsed))s")
                print("   Total combinados (post-filtro): \(finalRecords.count)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }
        }
    }

    /// Servicio 2: Obtiene órdenes de exámenes automatizados y las combina con las básicas
    func getAutomatedExamOrders() async {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [OrdenesExamen] Servicio 2 - getAutomatedExamOrders()")
        print("   accountId: \(accountId)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result = await Network.shared.getAutomatedExamOrders(accountId: accountId)
        switch result {
        case .success(let response):
            guard let autoRecords = response.data?.first?.examenesAutomatizadosC, !autoRecords.isEmpty else {
                print("⚠️ [OrdenesExamen] Servicio 2 - sin registros automatizados")
                return
            }

            let existingIds = Set(exams?.records.map { $0.Id ?? "" } ?? [])
            var addedCount = 0
            var skippedCount = 0

            for record in autoRecords {
                // Deduplicar por Id
                if let id = record.Id, existingIds.contains(id) {
                    skippedCount += 1
                    print("   ⏭️ Duplicado, omitiendo Id=\(id)")
                    continue
                }

                // Convertir CreatedDate ISO 8601 (2026-03-20T14:30:00.000Z) a yyyy-MM-dd
                let desdeC = convertISODateToYMD(record.CreatedDate)

                // Convertir a MedicalExams.Exam
                // Name: usar Nombre_Examen__c como nombre visible (Name es solo codigo "EA-000XXX")
                let autoExam = MedicalExams.Exam(
                    attributes: nil,
                    examenMedicoR: nil,
                    profesionalResponsableR: nil,
                    etapaR: nil,
                    Id: record.Id,
                    Name: record.nombreExamenC ?? record.Name,
                    desdeC: desdeC,
                    hastaC: desdeC,
                    etapaC: nil,
                    actividadC: nil,
                    especialidadDelResponsableC: nil,
                    pacienteC: accountId,
                    favoritoAppC: false,
                    urlDeLaOrdenMedicaC: record.urlOrdenMedicaRealC,
                    descripcionC: record.descripcionC ?? "",
                    url1C: nil,
                    url2C: nil,
                    url3C: nil,
                    url4C: nil,
                    comment: nil,
                    tipoDocumento: .examenAutomatizado
                )

                exams?.records.append(autoExam)
                examSelectedList[record.Id ?? ""] = false
                addedCount += 1
            }

            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [OrdenesExamen] Servicio 2 COMPLETADO")
            print("   Total automatizados recibidos: \(autoRecords.count)")
            print("   Agregados: \(addedCount)")
            print("   Duplicados omitidos: \(skippedCount)")
            print("   Total ordenes combinadas: \(exams?.records.count ?? 0)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        case .failure(let error):
            print("⚠️ [OrdenesExamen] Servicio 2 ERROR: \(error.name) - \(error.message)")
            print("   (continuamos con ordenes basicas solamente)")
        }
    }

    /// Servicio 3: Obtiene recetas médicas y las combina con las órdenes de exámenes
    func getPrescriptions() async {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [OrdenesExamen] Servicio 3 - getPrescriptions()")
        print("   accountId: \(accountId)")
        print("   from: \(from) until: \(until)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result = await Network.shared.getRecetas(accountId: accountId, from: from, until: until)
        switch result {
        case .success(let prescriptionsResponse):
            let existingIds = Set(exams?.records.map { $0.Id ?? "" } ?? [])
            var addedCount = 0

            for pres in prescriptionsResponse.records {
                if let id = pres.Id, existingIds.contains(id) {
                    continue
                }

                let presExam = MedicalExams.Exam(
                    attributes: nil,
                    examenMedicoR: nil,
                    profesionalResponsableR: MedicalExams.Exam.ExamProfessional(Name: pres.profesionalResponsableR?.Name),
                    etapaR: nil,
                    Id: pres.Id,
                    Name: pres.Name,
                    desdeC: pres.desdeC,
                    hastaC: pres.hastaC,
                    etapaC: nil,
                    actividadC: nil,
                    especialidadDelResponsableC: pres.especialidadDelResponsableC,
                    pacienteC: pres.pacienteC,
                    favoritoAppC: false,
                    urlDeLaOrdenMedicaC: pres.urlDeLaRecetaC,
                    descripcionC: "\(pres.dosisC ?? "") - \(pres.indicacionesC ?? "")",
                    url1C: nil,
                    url2C: nil,
                    url3C: nil,
                    url4C: nil,
                    comment: nil,
                    tipoDocumento: .recetaMedica
                )

                exams?.records.append(presExam)
                examSelectedList[pres.Id ?? ""] = false
                addedCount += 1
            }

            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [OrdenesExamen] Servicio 3 COMPLETADO")
            print("   Total recetas recibidas: \(prescriptionsResponse.records.count)")
            print("   Agregadas: \(addedCount)")
            print("   Total ordenes combinadas: \(exams?.records.count ?? 0)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        case .failure(let error):
            print("⚠️ [OrdenesExamen] Servicio 3 ERROR: \(error.name) - \(error.message)")
            print("   (continuamos sin recetas)")
        }
    }

    /// Convierte fecha ISO 8601 (2026-03-20T14:30:00.000Z) a formato yyyy-MM-dd
    private func convertISODateToYMD(_ isoDate: String?) -> String {
        guard let isoDate = isoDate, !isoDate.isEmpty else { return "" }
        // Intentar parsear con formato ISO 8601
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: isoDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"
            return outputFormatter.string(from: date)
        }
        // Fallback: si ya viene en yyyy-MM-dd, retornar tal cual
        if isoDate.count >= 10 {
            return String(isoDate.prefix(10))
        }
        return isoDate
    }
    func checkSelectedList() {
        if let searchExams = searchExams {
            if examSelectedList.contains(where: { !$0.value }) {
                for exam in searchExams {
                    examSelectedList[exam.Id ?? ""] = true
                }
                isButtonSelectAllFilled = true
            } else {
                for exam in searchExams {
                    examSelectedList[exam.Id ?? ""] = false
                }
                isButtonSelectAllFilled = false
            }
        }
    }
    func filterIsSelected() {
        self.urlsToZip = []
        self.total = 0.0
        self.count = 0.0
        self.progress = 0.0
        self.downloadedFileURL = nil
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 [ExamList] filterIsSelected -> actionButton: \(String(describing: actionButton))")
        if let exams = exams {
            if examSelectedList.contains(where: { $0.value }) {
                for exam in exams.records {
                    if examSelectedList[exam.Id ?? ""] ?? false {
                        self.total += 1
                    }
                }
            }
            print("📥 [ExamList] Total archivos a descargar: \(Int(total))")
            if examSelectedList.contains(where: { $0.value }) {
                for exam in exams.records {
                    if examSelectedList[exam.Id ?? ""] ?? false {
                        let url = exam.urlDeLaOrdenMedicaC ?? ""
                        print("📥 [ExamList] Descargando: \(url.suffix(40))...")
                        if actionButton == .isDownload {
                            downloadArchive(urlParameter: url, action: .isDownload)
                        }
                        if actionButton == .isShare {
                            downloadArchive(urlParameter: url, action: .isShare)
                        }
                    }
                }
                // NO resetear actionButton aqui, se necesita en onChange
                print("📥 [ExamList] Todas las descargas iniciadas. actionButton se mantiene: \(String(describing: actionButton))")
            }
        }
    }
    func downloadArchive(urlParameter: String?, action: ActionAuthPresAndExam) {
        guard let rawUrl = urlParameter, !rawUrl.isEmpty else {
            print("❌ [ExamList] downloadArchive: URL vacia, abortando")
            return
        }
        let fileName = S3FileHelper.extractFileNameFromUrl(rawUrl)
        let objectKey = S3FileHelper.extractObjectKeyFromUrl(rawUrl)
        print("📥 [ExamList] downloadArchive -> fileName: \(fileName), objectKey: \(objectKey)")

        Task {
            print("📥 [ExamList] Llamando getPresignedUrl...")
            let result = await Network.shared.getPresignedUrl(objectKey: objectKey, filename: fileName)
            await MainActor.run {
                switch result {
                case let .success(response):
                    print("📥 [ExamList] getPresignedUrl response -> error: \(response.error), url: \(response.url?.prefix(60) ?? "nil")")
                    guard let presignedUrl = response.url, !response.error,
                          let remoteURL = URL(string: presignedUrl) else {
                        print("❌ [ExamList] Respuesta invalida o con error")
                        self.count += 1
                        self.progress = Double(self.count / self.total)
                        return
                    }
                    print("📥 [ExamList] Descargando desde presigned URL...")
                    downloadFromPresignedUrl(remoteURL, fileName: fileName, action: action)
                case let .failure(error):
                    print("❌ [ExamList] Error getPresignedUrl: \(error.message)")
                    self.count += 1
                    self.progress = Double(self.count / self.total)
                }
            }
        }
    }

    func downloadFromPresignedUrl(_ remoteURL: URL, fileName: String, action: ActionAuthPresAndExam) {
        print("📥 [ExamList] downloadFromPresignedUrl -> fileName: \(fileName), action: \(action)")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("📥 [ExamList] Descargando bytes desde: \(remoteURL.absoluteString.prefix(60))...")
                let data = try Data(contentsOf: remoteURL)
                print("📥 [ExamList] Bytes recibidos: \(data.count)")
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
                let safeFileName = S3FileHelper.sanitizeFileName(fileName)
                let fileURL = documentsURL.appendingPathComponent(safeFileName)
                try data.write(to: fileURL, options: .atomic)
                print("✅ [ExamList] Archivo guardado: \(fileURL.path)")

                DispatchQueue.main.async {
                    if action == .isDownload {
                        self.downloadedFileURL = fileURL
                        print("📥 [ExamList] downloadedFileURL seteado: \(fileURL.lastPathComponent)")
                    } else if action == .isShare {
                        self.urlsToZip.append(fileURL)
                    }
                    self.count += 1
                    self.progress = Double(self.count / self.total)
                    print("📊 [ExamList] Progreso: \(Int(self.count))/\(Int(self.total))")
                }
            } catch {
                print("❌ [ExamList] Error descargando archivo: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.count += 1
                    self.progress = self.count / self.total
                }
            }
        }
    }
    func createZip(from urls: [URL], zipFileName: String) -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let zipURL = documentsURL.appendingPathComponent("\(zipFileName).zip")
        do {
            if FileManager.default.fileExists(atPath: zipURL.path) {
                try FileManager.default.removeItem(at: zipURL)
            }
            guard let archive = Archive(url: zipURL, accessMode: .create) else { return nil }
            for fileURL in urls {
                guard FileManager.default.fileExists(atPath: fileURL.path) else { continue }
                try archive.addEntry(with: fileURL.lastPathComponent, relativeTo: fileURL.deletingLastPathComponent())
            }
            return zipURL
        } catch {
            return nil
        }
    }
    func getExamsForPatient() {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
        Task {
            let result = await Network.shared.getExamsForPatient(accountId: accountId)
            switch result {
            case .success(let listExam):
                // Source of truth: guardamos TODOS los PatientExams del paciente.
                // El cruce por FK (idOrdenMedicaC / idExamenesAutomatizadosC) se hace
                // en linkedPatientExam(for:) al pintar cada Row. No mutamos url1C..4
                // de la orden — la decisión vive ahora en linkedPatientExam.
                let patients = listExam.data?.first?.examenesDelPacienteC ?? []
                await MainActor.run {
                    self.allPatientExams = patients
                    print("✅ [OrdenesExamen] Servicio 4 (PatientExams) cargados: \(patients.count)")
                }
            case let .failure(error):
                AppStatusManager.error(error)
            }
            // Apagamos AMBOS flags al final (en MainActor) para que el body cambie de
            // "loading" a "lista" en una sola transición — sin flashes intermedios.
            // También liberamos el guard de concurrencia.
            await MainActor.run {
                self.isLoading = false
                self.listNeedsRefresh = false
                self.isFetchingRecetas = false
            }
        }
    }

    /// Devuelve el PatientExam asociado a una orden, si existe (paridad con web).
    /// El cruce depende del tipo de documento padre:
    ///  - examenAutomatizado → match por idExamenesAutomatizadosC
    ///  - resto              → match por idOrdenMedicaC
    /// `nil` si no hay match → la orden aún no tiene archivos subidos.
    func linkedPatientExam(for exam: MedicalExams.Exam) -> FunctionFilterExamResponse.PatientExams? {
        guard let examId = exam.Id, !examId.isEmpty else { return nil }
        if exam.tipoDocumento == .examenAutomatizado {
            return allPatientExams.first { $0.idExamenesAutomatizadosC == examId }
        }
        return allPatientExams.first { $0.idOrdenMedicaC == examId }
    }
}
